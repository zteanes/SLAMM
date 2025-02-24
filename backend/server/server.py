"""
This file outlines the process for loading our model after receiving a request from the frontend.

We load the model, ask for a response, then provide the answer back to the frontend.

Authors: Zach Eanes and Alex Charlot
Date: 11/13/2024
Version: 0.1
"""

# import of all necessary packages for interpret
import torch
from torchvision import models
from torchvision import transforms
from fastapi import FastAPI, File, Form, UploadFile
from typing import List
from PIL import Image
import io
import os
from colorama import Fore
# from TGCN.tgcn_model import GCN_muti_att
# from TGCN.configs import Config
import cv2
from I3D.pytorch_i3d import InceptionI3d
import math
import os
import argparse
import matplotlib.pyplot as plt
import torch.nn as nn
import numpy as np
import torch.nn.functional as F
from I3D.pytorch_i3d import InceptionI3d
# from keytotext import pipeline
# import language
# from dotenv import load_dotenv
# from itertools import chain
# import pickle
from gpt4all import GPT4All

# load the environment variables for CUDA device necessary
os.environ["CUDA_DEVICE_ORDER"] = "PCI_BUS_ID"
os.environ["CUDA_VISIBLE_DEVICES"] = '0'

# setup the argument parser for the model
parser = argparse.ArgumentParser()
parser.add_argument('-mode', type=str, help='rgb or flow')
parser.add_argument('-save_model', type=str)
parser.add_argument('-root', type=str)

# global variables used for model setup later
mode = 'rgb' # mode used for the model
num_classes = 100 # number of classes for the model
save_model = './models' # save the model
root = os.getcwd() + '/data/WLASL100' # root directory for the model info 
train_split = 'preprocess/nslt_100.json' # training split for the model
# weights for the model
weights = (os.getcwd() + 
    '/I3D/archived/asl100/FINAL_nslt_100_iters=896_top1=65.89_top5=84.11_top10=89.92.pt')
i3d = None # model itself

########### Methods for debugging and loading model ###########

def log(message):
    """
    Print the model.
    """
    print(f"[interpret.py] {message}" + Fore.RESET)

def load_I3D_model():
    """ 
    Loads the I3D model from WLASL for communication with the frontend.
    """
    global num_classes, weights, i3d

    # loading the Inception 3D Model
    i3d = InceptionI3d(400, in_channels=3)

    i3d.replace_logits(num_classes)
    i3d.load_state_dict(torch.load(weights)) 
    i3d.cuda()
    i3d = nn.DataParallel(i3d)
    i3d.eval()
    
    # NOTE: the following allows you to create a model which takes words and tries to make a sentence; not needed for 
    #       the scope of our project
    """
    # loading the KeytoText model
    
    global nlp
    nlp = pipeline("k2t-new") # The pre-trained models available are 'k2t', 'k2t-base', 'mrm8488/t5-base-finetuned-common_gen', 'k2t-new'
    global params
    params = {"do_sample":True, "num_beams": 5, "no_repeat_ngram_size":2, "early_stopping":True}
    
    # loading the NGram model
    
    with open("NLP/nlp_data_processed", "rb") as fp:   # Unpickling
           train_data_processed = pickle.load(fp)
    
    global n_gram_counts_list
    with open("NLP/nlp_gram_counts", "rb") as fp:   # Unpickling
        n_gram_counts_list = pickle.load(fp)
        
    global vocabulary
    vocabulary = list(set(chain.from_iterable(train_data_processed)))
    """
    
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

    predictions = F.upsample(per_frame_logits, t, mode='linear')

    predictions = predictions.transpose(2, 1)
    out_labels = np.argsort(predictions.cpu().detach().numpy()[0])
    arr = predictions.cpu().detach().numpy()[0] 

    log(f"Confidence in prediction: {float(max(F.softmax(torch.from_numpy(arr[0]), dim=0)))}")
    log(f"Prediction: {wlasl_dict[out_labels[0][-1]]}")
    
    """
    
    The 0.5 is threshold value, it varies if the batch sizes are reduced.
    
    """
    if max(F.softmax(torch.from_numpy(arr[0]), dim=0)) > 0.0: # if it's 25% confident return it
        return (wlasl_dict[out_labels[0][-1]], float(max(F.softmax(torch.from_numpy(arr[0]), dim=0))))
    else:
        return " " 

def load_rgb_frames_from_video(video_path):
    """ 
    This function was adapted from: 
        https://github.com/alanjeremiah/WLASL-Recognition-and-Translation/blob/main/WLASL/I3D/run.py

    Load RGB frames from a video file to be processed by the model.
    """
    vidcap = cv2.VideoCapture(video_path)  # Open the video file

    frames = []

    # loop through the video frame by frame and resize properly
    while True:
        ret, frame1 = vidcap.read()
        if not ret:  # If no more frames, break
            break

        w, h, c = frame1.shape
        sc = 224 / w
        sx = 224 / h
        frame = cv2.resize(frame1, dsize=(0, 0), fx=sx, fy=sc)

        frame = (frame / 255.) * 2 - 1  # Normalize frame
        frames.append(frame)


    # release video since it's no longer needed
    vidcap.release()

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
    
    global wlasl_dict 
    wlasl_dict = {}
    
    with open('I3D/preprocess/wlasl_class_list.txt') as file:
        for line in file:
            split_list = line.split()
            if len(split_list) != 2:
                key = int(split_list[0])
                value = split_list[1] + " " + split_list[2]
            else:
                key = int(split_list[0])
                value = split_list[1]
            wlasl_dict[key] = value


########### end methods for debugging and loading model ###########

# initialize the FastAPI
app = FastAPI(redirect_slashes=False)

# initialize and load the model if available
if torch.cuda.is_available():
    # load the machine learning model first, as well as dictionary 
    load_I3D_model()
    create_WLASL_dictionary()
    log(Fore.GREEN + "-"*20 + "Model loaded successfully!" + "-"*20)

    # load the LLM model 
    model = GPT4All("Meta-Llama-3-8B-Instruct.Q4_0.gguf") # downloads / loads a 4.66GB LLM
    with model.chat_session():
        msg = "say a sweet message about how you've been properly loaded on a server."
        log(Fore.GREEN + model.generate(msg, max_tokens=1024))

else:
    log(Fore.RED + "-"*20 
        + "CUDA is not available. Please ensure cuda is available before running the server." 
        + "-"*20)


########### Below are the valid routes through the FastAPI ###########

@app.get("/")
async def root():
    """
    Basic landing screen for the FastAPI backend of SLAMM.
    """
    return {"message": "This is the working backend for SLAMM."}
    

words = []
confidences = []
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
    text_and_conf = load_rgb_frames_from_video(path)
    predicted_text = text_and_conf[0]
    conf = text_and_conf[1]

    # store the words and confidences
    words.append(predicted_text)
    confidences.append(conf)

    # delete the video
    os.remove(path)

    # return the predicted text
    if buffer == 1: # if it's one, we're storing words for the time being, so just return current one
        return {"message": predicted_text, "confidence" : conf}
    else: # if it's zero, we're done storing words and return all of them 
        # create a string of all the words, clear the list
        translations = " ".join(words)
        words = []

        avg_conf = str(sum(confidences) / len(confidences))
        log(f"Average value of our confidences: {avg_conf}")
        confidences = []

        # ask llm to reinterpret the words into a more coherent sentence
        to_ask = ("You're assisting me in translating sign language, specifically ASL. Using a "
                 + "machine learning model to predict signs, the following words have been " 
                 + "translated: " + translations + "\n\nPlease provide a SINGLE, COHERENT sentence"
                 + "that summarizes the message being conveyed. Keep it simple and understandable "
                 + "language, as well as concise. Do not include any other words or phrases other"
                 + "than the translated sentence. I only want the sentence that summarizes the "
                 + "translated terms.")

        # ask the llm to generate a response
        with model.chat_session():
            llm_message = model.generate(to_ask, max_tokens=1024)
        log(llm_message)

        return {"message": translations, "llm_message" : llm_message, "confidence" : avg_conf}
        
