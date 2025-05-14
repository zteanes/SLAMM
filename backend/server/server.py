"""
This file outlines the necessary components for initializing the server 
and running it with the FastAPI framework.

To run the server, use the following command from the server directory:
    uvicorn app:server --host 0.0.0.0 --port <port_number>

Authors: Zach Eanes and Alex Charlot
Date: 05/07/2025
Version: 1.0
"""

# import of all necessary packages for interpret
import torch
from fastapi import FastAPI, File, Form, UploadFile
import os
from colorama import Fore
import cv2
from I3D.pytorch_i3d import InceptionI3d
import os
import torch.nn as nn
import numpy as np
import torch.nn.functional as F
from I3D.pytorch_i3d import InceptionI3d
from gpt4all import GPT4All

# load the environment variables for CUDA device necessary
os.environ["CUDA_DEVICE_ORDER"] = "PCI_BUS_ID"
os.environ["CUDA_VISIBLE_DEVICES"] = '0'

i3d = None # model itself so we can reference it throughout the entire server
llm = None # LLM model so we can reference it throughout the entire server

########### Methods for debugging and loading model ###########

def log(message):
    """
    Display a message to the console.
    """
    print(f"[server.py] {message}" + Fore.RESET)

def load_I3D_model():
    """ 
    Loads the I3D model from WLASL for communication with the frontend.
    """
    global i3d
    num_classes = 100 # number of classes we're using for the model
    weights = (os.getcwd() + 
              '/I3D/archived/asl100/FINAL_nslt_100_iters=896_top1=65.89_top5=84.11_top10=89.92.pt')


    # loading the Inception 3D Model
    i3d = InceptionI3d(400, in_channels=3)

    # load the model weights
    i3d.replace_logits(num_classes)
    i3d.load_state_dict(torch.load(weights)) 
    i3d.cuda()
    i3d = nn.DataParallel(i3d)

    # set to evaluation mode, ready for use
    i3d.eval()

def run_on_tensor(ip_tensor):
    """
    This function was adapted from: 
        https://github.com/alanjeremiah/WLASL-Recognition-and-Translation/blob/main/WLASL/I3D/run.py
    
    Run the model on the input tensor.
    """
    ip_tensor = ip_tensor[None, :]
    
    t = ip_tensor.shape[2] 
    ip_tensor.cuda()
    per_frame_logits = i3d(ip_tensor)

    # get the predictions for the video 
    predictions = F.upsample(per_frame_logits, t, mode='linear')

    predictions = predictions.transpose(2, 1)
    out_labels = np.argsort(predictions.cpu().detach().numpy()[0])
    arr = predictions.cpu().detach().numpy()[0] 

    # information from the model regarding the prediction
    log(f"Confidence in prediction: {float(max(F.softmax(torch.from_numpy(arr[0]), dim=0)))}")
    log(f"Prediction: {wlasl_dict[out_labels[0][-1]]}")
    
    # return the predictions, no matter the confidence
    return (wlasl_dict[out_labels[0][-1]], float(max(F.softmax(torch.from_numpy(arr[0]), dim=0))))

def load_frames(video_path):
    """ 
    This function was adapted from: 
        https://github.com/alanjeremiah/WLASL-Recognition-and-Translation/blob/main/WLASL/I3D/run.py

    Load RGB frames from a video file to be processed by the model.
    """


    video = cv2.VideoCapture(video_path) # video itself to be processed
    frames = [] # frames from the video 

    # loop through the video frame by frame and resize properly
    while True:
        ret, frame1 = video.read()

        # break if we reach the end of the video 
        if not ret:
            break

        # resize the frame to correct dimensions
        w, h, c = frame1.shape
        sc = 224 / w
        sx = 224 / h
        frame = cv2.resize(frame1, dsize=(0, 0), fx=sx, fy=sc)
        frame = (frame / 255.) * 2 - 1 

        # add frame to the list of frames
        frames.append(frame)

    # release video since it's no longer needed
    video.release()

    # ensure that we have frames to process
    if len(frames) == 0:
        return "No frames extracted"

    # convert to tensor and pass through model
    frames_tensor = torch.from_numpy(np.asarray(frames, dtype=np.float32).transpose([3, 0, 1, 2]))
    text_and_confidence = run_on_tensor(frames_tensor)

    # get the predicted text
    predicted_text = text_and_confidence[0].strip()
    conf = text_and_confidence[1]

    # return the predicted term
    return (predicted_text, conf) 

def create_WLASL_dictionary():
    """ 
    Adapted from the following repository:
        https://github.com/alanjeremiah/WLASL-Recognition-and-Translation/blob/main/WLASL/I3D/run.py
    
    Create a dictionary for the WLASL dataset.
    """
    
    # load the WLASL dictionary from the class so we can access it throughout the server
    global wlasl_dict 
    wlasl_dict = {}
    
    # open the class list and read in our values for the dictionary
    with open('I3D/preprocess/wlasl_class_list.txt') as file:

        # iterate each line in the file and split it into a key and value
        for line in file:
            split_list = line.split()
            if len(split_list) != 2:
                key = int(split_list[0])
                value = split_list[1] + " " + split_list[2]
            else:
                key = int(split_list[0])
                value = split_list[1]
            
            # add the key and value to the dictionary
            wlasl_dict[key] = value


def init():
    """
    Constructs and initializes necessary aspects for the server to run.
    """
    # message to be sent at the launch of the LLM model to explain its purpose
    setup_msg = """
    You are a model loaded in the backend of a server, with the sole responsibility of the 
    following:

    Translate provided American Sign Language (ASL) into English text and summarize the message 
    into a single, coherent sentence. The sentence should be simple, understandable, and concise. 
    Do not include any other words, reinforcements, or explanations beyond the translated sentence.
    """
    global llm

    # initialize and load the model if available
    if torch.cuda.is_available():
        # load the machine learning model first, as well as dictionary 
        load_I3D_model()
        create_WLASL_dictionary()
        log(Fore.GREEN + "-"*20 + "Model loaded successfully!" + "-"*20)

        # load the LLM model 
        llm = GPT4All("Meta-Llama-3-8B-Instruct.Q4_0.gguf") # downloads / loads a 4.66GB LLM
        with llm.chat_session():
            msg = setup_msg
            log(Fore.GREEN + llm.generate(msg, max_tokens=1024))
    else: # we can't load the model so this is bad
        log(Fore.RED + "-"*20 
            + "CUDA is not available. Please ensure cuda is available before running the server." 
            + "-"*20)
        exit(1)

########### end methods for debugging and loading model ###########



########### FastAPI setup and model loading ###########

# initialize the FastAPI and the rest of the necessary components for the server
app = FastAPI(redirect_slashes=False)
init()

########### Below are the valid routes through the FastAPI ###########

@app.get("/")
async def root():
    """
    Basic landing screen for the FastAPI backend of SLAMM.
    """
    return {"message": "This is the working backend for SLAMM."}


words = [] # list of the word to be buffered until user needs them 
confidences = [] # list of the confidence values for the words to be buffered
@app.post("/predict_video")
async def predict_video(file: UploadFile = File(...), buffer: int = Form(...)):
    """ 
    Receives a video from the frontend and predicts the sign language video.

    Args:
        file: UploadFile - the video received and to be predicted
    """
    global words, confidences

    # read the video in from uploaded 
    video_bytes = await file.read()

    # write video to temp file
    path = f"temp_{file.filename}"
    print(path)
    with open(path, "wb") as f:
        f.write(video_bytes)

    # pass to function to process and predict
    text_and_conf = load_frames(path)
    predicted_text = text_and_conf[0]
    conf = text_and_conf[1]

    # store the words and confidences
    words.append(predicted_text)
    confidences.append(conf)

    # delete the video
    os.remove(path)

    # return the predicted text
    if buffer == 1: # if it's one, we're storing words, so just return current prediction
        return {"message": predicted_text, "confidence" : conf}
    else: # if it's zero, we're done storing words and return all of them 
        # create a string of all the words, clear the list
        translations = " ".join(words)
        words = []

        # calculate the average confidence
        avg_conf = str(sum(confidences) / len(confidences))
        log(f"Average value of our confidences: {avg_conf}")
        confidences = []

        # ask llm to reinterpret the words into a more coherent sentence
        to_ask = """
            You are provided with a list of words generated by interpreting American Sign Language 
            (ASL) into English text. Your task is to summarize these words into a single, coherent 
            sentence. Please only use the words provided in the list and do not add any additional 
            information or context. The sentence should be simple, understandable, and concise.

            Respond only with the sentence. Do not include any other words, explanations, or code.

            Here is the list of words: """ + translations

        # ask the llm to generate a response
        with llm.chat_session():
            llm_message = llm.generate(to_ask, max_tokens=1024)
        log(llm_message)

        return {"message": translations, "llm_message" : llm_message, "confidence" : avg_conf}
