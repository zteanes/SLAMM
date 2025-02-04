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
from fastapi import FastAPI, File, UploadFile
from typing import List
from PIL import Image
import io
import os
from colorama import Fore
from TGCN.tgcn_model import GCN_muti_att
from TGCN.configs import Config
import cv2

# initialize the FastAPI
app = FastAPI()

########### Methods for debugging and loading model ###########

def log(message):
    """
    Print the model.
    """
    print(f"[interpret.py] {message}" + Fore.RESET)

# method to load the model
def load_model():
    """
    Load the model for communication with frontend.
    """
    # change root and subset accordingly.
    root = os.getcwd();
    trained_on = 'asl100'

    # config file for all information used to load model
    config_file = os.path.join(root, 'backend/TGCN/configs/{}.ini'.format(trained_on, trained_on))
    configs = Config(config_file)

    # necessary variables we get from the config
    num_samples = configs.num_samples
    hidden_size = configs.hidden_size
    drop_p = configs.drop_p
    num_stages = configs.num_stages

    # load the model
    log(Fore.CYAN + "Loading model...")
    model = GCN_muti_att(input_feature=num_samples * 2, hidden_feature=hidden_size,
                         num_class=int(trained_on[3:]), p_dropout=drop_p, 
                         num_stage=num_stages).cuda()
    log(Fore.CYAN + "Finish loading model!")

    # return the loaded model
    return model
    
# load model and set to eval; ensure cuda is available
if torch.cuda.is_available():
    log(Fore.GREEN + "CUDA is available!")
    model = load_model()
    model.eval()
    log(Fore.GREEN + "Model loaded successfully!")
else:
    log(Fore.RED + "CUDA is not available. Please ensure cuda is available before running the server.")

########### end methods for debugging and loading model ###########


########### Below are the valid routes through the FastAPI ###########

@app.get("/")
async def root():
    """
    Basic landing screen for the FastAPI backend of SLAMM.
    """
    return {"message": "This is the working backend for SLAMM."}
    

@app.post("/predict_video/")
async def predict_video(file: UploadFile = File(...)):
    """ 
    Receives a video from the frontend and TODO: predicts the sign language video.

    For now, just receives the video and plays it to ensure proper communication.

    Args:
        file: UploadFile - the video received and to be predicted
    """
    log(Fore.CYAN + "Received video from frontend!!!!!")
    # load the video into memory
    video_bytes = await file.read()
    path = f"temp_{file.filename}"

    # write the video to a temporary file
    with open(path, "wb") as f:
        f.write(video_bytes)
    
    # open and play video w/ OpenCV
    cap = cv2.VideoCapture(path)

    while cap.isOpened():
        ret, frame = cap.read()
        if not ret:
            break
        cv2.imshow('Received video', frame)
        if cv2.waitKey(25) & 0xFF == ord('q'):
            break
    
    cap.release()
    cv2.destroyAllWindows()

    # remove the temporary file
    os.remove(path)

    return {"message": "Video received and played successfully!"}

@app.post("/predict/")
async def predict(file: UploadFile = File(...)):
    global model
    """
    Predict the video from the frontend, using a model passed in.
    
    Args:
        model: torch.nn.Module - the model to be used for prediction
        file: UploadFile - the image to be predicted
    """
    # read the image and make necessary conversions 
    image = Image.open(io.BytesIO(await file.read()))
    image = image.convert('RGB')
    
    # transform the image TODO: see how it's transformed/processing in test_tgcn.py
    transform = transforms.Compose([
        transforms.Resize(256),
        transforms.CenterCrop(224),
        transforms.ToTensor(),
        transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]),
    ])
    
    image = transform(image).unsqueeze(0)
    
    # get the prediction
    model.eval()
    with torch.no_grad():
       # TODO: how do i feel an video/image to the model?
       prediction = model(image)
        
    return prediction

# if __name__ == '__main__':
#     # load our model to be used for prediction
#     model = load_model()

#     # save model to file
#     torch.save(model, "model.pth")
#     print("Model loaded successfully!")