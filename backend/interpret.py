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

app = FastAPI()

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
    
    
@app.post("/predict/")
async def predict(model, file: UploadFile = File(...)):
    """
    Predict the image from the frontend, using a model passed in.
    
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

if __name__ == '__main__':
    # load our model to be used for prediction
    model = load_model()

    # save model to file
    torch.save(model, "model.pth")
    print("Model loaded successfully!")