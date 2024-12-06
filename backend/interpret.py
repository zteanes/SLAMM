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
    print(f"[interpret.py] {message}")

# method to load the model
def load_model():
    """
    Load the model for communication with frontend.
    """
    # change root and subset accordingly.
    root = os.getcwd();
    trained_on = 'asl2000'

    checkpoint = 'ckpt.pth'

    split_file = os.path.join(root, 'data/start_kit/splits/{}.json'.format(trained_on))

    pose_data_root = os.path.join(root, 'data/start_kit/pose_per_individual_videos')
    config_file = os.path.join(root, 'backend/TGCN/archived/{}/{}.ini'.format(trained_on, 
                                                                              trained_on))
    configs = Config(config_file)

    num_samples = configs.num_samples
    hidden_size = configs.hidden_size
    drop_p = configs.drop_p
    num_stages = configs.num_stages
    batch_size = configs.batch_size

    # load the model
    log(Fore.CYAN + "Loading model...")
    model = GCN_muti_att(input_feature=num_samples * 2, hidden_feature=hidden_size,
                         num_class=int(trained_on[3:]), p_dropout=drop_p, 
                         num_stage=num_stages).cuda()
    log(Fore.CYAN + "Finish loading model!")
    return model
    
    
@app.post("/predict/")
async def predict(file: UploadFile = File(...), model:model):
    """
    Predict the image.

    Args:
        file (UploadFile): The image to predict
        model (model): The model to use for prediction
    """
    # read the image and make necessary conversions 
    image = Image.open(io.BytesIO(await file.read()))
    image = image.convert('RGB')
    image = transforms.ToTensor()(image).unsqueeze(0)
    
    # get the prediction
    prediction = model(image)
    return prediction

if __name__ == '__main__':
    model = load_model()
    print("Model loaded successfully!")