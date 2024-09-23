import matplotlib
matplotlib.use('Agg') # now figures can be saved in the background 

# import the rest of the needed libraries 
from lenet import LeNet # this our model 
from sklearn.metrics import classification_report # helps get info about testing set
from torch.utils.data import random_split # makes train/test split for us to use
from torch.utils.data import DataLoader # data loader that allows us to build data pipelines to train CNN
from torchvision.transforms import ToTensor # function converts input data -> PyTorch tensors
from torch.optim import Adam # The optimizer we will use to train our model
from torch import nn # PyTorch's neural network implementations
import numpy as np
import matplotlib as plt
import argparse
import torch
import time
import videotransforms
import os

# construct the argument parser and parse the arguments as needed 
ap = argparse.ArgumentParser()
ap.add_argument("-m", "--model", type = str, required = True,
	            help = os.getcwd() + "/output/model.pth")
ap.add_argument("-p", "--plot", type = str, required = True,
	            help = os.getcwd() + "/output/model_plot.png")
args = vars(ap.parse_args())

# define training parameters used throughout program
INIT_LR = 1e-3 # initial learning rate
BATCH_SIZE = 64 # batch size for training 
# NOTE: epochs can be increased for higher accuracy, but must avoid overfitting
EPOCHS = 10 # number of epochs to train 

# define the train and val splits
TRAIN_SPLIT = 0.75
VAL_SPLIT = 1 - TRAIN_SPLIT

# use either a GPU or CPU for training model
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

# prepare our dataset for training 
print("[INFO] loading WLASL dataset...")

# possible solutions to variables for loadings and using dataset
root = os.getcwd() + "/data/start_kit/raw_videos"
mode = 'rgb'
train_split = os.getcwd() + "/data/start_kit/WLASL_v0.3.json"

# build our dataset from WLASL given information 
train_transforms = transforms.Compose([videotransforms.RandomCrop(224),
                                        videotransforms.RandomHorizontalFlip(), ])
test_transforms = transforms.Compose([videotransforms.CenterCrop(224)])

dataset = Dataset(train_split, 'train', root, mode, train_transforms)
dataloader = DataLoader(dataset, batch_size=configs.batch_size, shuffle=True, num_workers=0,
                                            pin_memory=True)

val_dataset = Dataset(train_split, 'test', root, mode, test_transforms)
val_dataloader = DataLoader(val_dataset, batch_size=configs.batch_size, shuffle=True, num_workers=2,
                                                pin_memory=False)

dataloaders = {'train': dataloader, 'test': val_dataloader}
datasets = {'train': dataset, 'test': val_dataset}

