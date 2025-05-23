""" 
This file outlines the process we aimed to use to train our own model. We attempted using
the LeNet architecture and the ResNet34 architecture, but neither were successful. It's still
useful to see our attempts in creating our own model, as it shows our thoughts and shows 
a general idea of what we learned and how we would train a model.

Authors: Zachary Eanes and Alex Charlot
Date: 12/06/2024
"""

import matplotlib
matplotlib.use('Agg') # now figures can be saved in the background 

# import the rest of the needed libraries 
from lenet import LeNet # this our model 
from resnet34 import ResNet34 # this is the model we are comparing to
from sklearn.metrics import classification_report # helps get info about testing set
from torch.utils.data import random_split # makes train/test split for us to use
from torch.utils.data import DataLoader # data loader that allows us to build data pipelines to train CNN
from torchvision.transforms import ToTensor # function converts input data -> PyTorch tensors
from torch.optim import Adam # The optimizer we will use to train our model
from torchvision import transforms # transforms for our dataset
from torch import nn # PyTorch's neural network implementations
import numpy as np
import matplotlib.pyplot as plt
import argparse
import torch
import time
import videotransforms
import os
from torch.nn import Conv2d 
from sign_dataset import Sign_Dataset as Dataset

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
IN_CHANNELS = 64 # number of input channels for our model

# define the train and val splits
TRAIN_SPLIT = 0.75
VAL_SPLIT = 1 - TRAIN_SPLIT



# use either a GPU or CPU for training model
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

# prepare our dataset for training 
print("Loading WLASL dataset...")

# possible solutions to variables for loadings and using dataset
mode = 'rnd_start'
#train_split = os.getcwd() + "/data/start_kit/new_WLASL_v0.3.json"
train_split = os.getcwd() + "/data/start_kit/splits/asl100.json"
poses = os.getcwd() + "/data/start_kit/pose_per_individual_videos"

# build our dataset from WLASL given information 
train_transforms = transforms.Compose([videotransforms.RandomCrop(224),
                                        videotransforms.RandomHorizontalFlip(), ])
test_transforms = transforms.Compose([videotransforms.CenterCrop(224)])

# create a dataset object for each split
print("Creating the datasets...")

dataset = Dataset(index_file_path = train_split, 
                  split = 'train', 
                  pose_root = poses)
print("Training dataset created!")

test_dataset = Dataset(index_file_path = train_split, 
                  split = 'test', 
                  pose_root = poses)
print("Test dataset created!")

val_dataset = Dataset(index_file_path = train_split, 
                  split = 'val', 
                  pose_root = poses)
print("Validation dataset created!")
# display the datasets
print(f"Training dataset size: {dataset.__len__()}")
print(f"Test dataset size: {len(test_dataset)}")
print(f"Validation dataset size: {len(val_dataset)}")
# create a dictionary of our datasets for easy access
datasets = {'train': dataset, 'test': test_dataset, 'val': val_dataset}

# initialize train, validation, and test data loaders
train_loader = DataLoader(datasets['train'], batch_size = BATCH_SIZE, shuffle = True)
val_loader = DataLoader(datasets['val'], batch_size = BATCH_SIZE)
test_loader = DataLoader(datasets['test'], batch_size = BATCH_SIZE)

# calculate number of steps for epoch
train_steps = len(train_loader.dataset)
val_steps = len(val_loader.dataset)

# Begin our LeNet model (hooray!)
print("Creating the model...")
# 3 channels for RGB images, classes is the num of classes in data
num_classes = len(dataset.label_encoder.classes_) # get number of classes in dataset
print("NUMBER OF CLASSES", num_classes) 
model = ResNet34(in_channels = IN_CHANNELS, num_classes = num_classes).to(device) 

# make optimizer and loss functions 
optimizer = Adam(model.parameters(), lr=INIT_LR)
loss_func = nn.NLLLoss()

# make a dict so we can store history of training
History = { "train_loss" : [],
            "val_loss" : [],
            "train_acc" : [],
            "val_acc" : [] 
          }

# time the training for fun
print("Training the model...")
start = time.time()

# loop epochs
for epoch in range(0, EPOCHS):
    # training mode for model
    model.train()

    total_train_loss = 0 # keep track of loss during training
    total_val_loss = 0 # keep track of loss during validation
    train_correct = 0 # keep track of correct predictions during training
    val_correct = 0 # keep track of correct predictions during validation

    # loop training data
    for (x, y, z) in train_loader:
        x = x.to(device)
        y = y.to(device)

        # forward pass and calculate loss
        x = x.unsqueeze(1).expand(-1, 64, -1, -1)
        prediction = model(x).squeeze(0)

        # if we had to change the channels in x, do so for y as well
        if y.shape[0] != prediction.shape[0]:
            # change prediction back to 34 channels 
            conv_reverse = nn.Conv2d(in_channels=100, out_channels=y.shape[0], kernel_size=1)
            prediction = 
                conv_reverse(prediction.unsqueeze(1).unsqueeze(1)).squeeze(0).squeeze(1).squeeze(1)

        loss = loss_func(prediction, y)

        # zero out gradients, backward pass, update the weights
        optimizer.zero_grad()
        loss.backward()
        optimizer.step()

        # add loss to total loss
        total_train_loss += loss 

        # calculate accuracy
        train_correct += (prediction.argmax(1) == y).type(torch.float).sum().item()

    print("train correct:", train_correct)
    print("total train loss:", total_train_loss)
    
    # disable autograd for validation
    with torch.no_grad():
        model.eval()

        # loop validation data
        print(val_loader)
        for (x, y, z) in val_loader:
            x = x.to(device)
            y = y.to(device)

            # make predictions and find loss 
            x = x.unsqueeze(1).expand(-1, 64, -1, -1)
            prediction = model(x)

            if y.shape[0] != prediction.shape[0]:
                # reshape predictions to correct match y
                conv_reverse = nn.Conv2d(in_channels=100, out_channels=y.shape[0], kernel_size=1)
                prediction = 
                    conv_reverse(prediction.unsqueeze(1).unsqueeze(1)).squeeze(0).squeeze(1).squeeze(1)

            total_val_loss += loss_func(prediction, y)

            # sum number of correct predictions
            val_correct += (prediction.argmax(1) == y).type(torch.float).sum().item()

    # calculate averages
    avg_train_loss = total_train_loss / train_steps
    avg_val_loss = total_val_loss / val_steps

    # calculate accuracy
    train_correct = train_correct / len(train_loader.dataset)
    val_correct = val_correct / len(val_loader.dataset)

    # update the training history
    History["train_loss"].append(avg_train_loss.cpu().detach().numpy())
    History["val_loss"].append(avg_val_loss.cpu().detach().numpy())
    History["train_acc"].append(train_correct)
    History["val_acc"].append(val_correct)

    # display our info from this epoch
    print(f"\n\n\nEPOCH: {epoch + 1}/{EPOCHS}")
    print(f"Training Loss: {avg_train_loss}, Train Accuracy {train_correct}")
    print(f"Validation Loss: {avg_val_loss}, Train Accuracy {val_correct}")

# end timer
end = time.time()
print(f"Total time spent training the model: {end - start}")

# evaluate the model on test set
print("Evaluating the model...")

with torch.no_grad():
    # set model to evaluation and make list of predictions
    model.eval()
    predictions = []
    for (x, y, z) in test_loader:
        x = x.to(device)

        # make our predictions and add
        x = x.unsqueeze(1).expand(-1, 64, -1, -1)
        prediction = model(x)
        predictions.extend(prediction.argmax(1).cpu().numpy())

# Loss plot
plt.subplot(1, 2, 1)
print(f"train_loss at the end:{History['train_loss']}")
print(f"val_loss at the end:{History['val_loss']}")
plt.plot(History['train_loss'], label='Training Loss')
plt.plot(History['val_loss'], label='Validation Loss')
plt.title('Training and Validation Loss')
plt.xlabel('Epoch')
plt.ylabel('Loss')
plt.legend()

# Accuracy plot
plt.subplot(1, 2, 2)
print(f"train_acc at the end: {History['train_acc']}")
print(f"val_acc at the end: {History['val_acc']}")
plt.plot(History['train_acc'], label='Training Accuracy')
plt.plot(History['val_acc'], label='Validation Accuracy')
plt.title('Training and Validation Accuracy')
plt.xlabel('Epoch')
plt.ylabel('Accuracy')
plt.legend()

# Save plot to specified path
plt.tight_layout()
plt.savefig(os.getcwd() + "/backend/output/model_plot.png")
print(f"Plot saved to {os.getcwd()}/backend/output/model_plot.png")

# save the model to disk
torch.save(model.state_dict(), os.getcwd() + "/backend/output/model.pth")
