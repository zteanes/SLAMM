import matplotlib
matplotlib.use('Agg') # now figures can be saved in the background 

# import the rest of the needed libraries 
from lenet import LeNet # this our model 
from sklearn.metrics import classification_report # helps get info about testing set
from torch.utils.data import random_split # makes train/test split for us to use
from torch.utils.data import DataLoader # data loader that allows us to build data pipelines to train CNN
from torchvision.transforms import ToTensor # function converts input data -> PyTorch tensors
from torch.optim import Adam # The optimizer we will use to train our modelf
from torchvision import transforms # transforms for our dataset
from torch import nn # PyTorch's neural network implementations
import numpy as np
import matplotlib as plt
import argparse
import torch
import time
import videotransforms
import os

from nslt_dataset import NSLT as Dataset

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
print("Loading WLASL dataset...")

# possible solutions to variables for loadings and using dataset
root = os.getcwd() + "/data/start_kit/raw_videos"
mode = 'rgb'
train_split = os.getcwd() + "/data/start_kit/WLASL_v0.3.json"

# build our dataset from WLASL given information 
train_transforms = transforms.Compose([videotransforms.RandomCrop(224),
                                        videotransforms.RandomHorizontalFlip(), ])
test_transforms = transforms.Compose([videotransforms.CenterCrop(224)])

# create a dataset object for each split
dataset = Dataset(train_split, 'train', root, mode, train_transforms)
test_dataset = Dataset(train_split, 'test', root, mode, test_transforms)
val_dataset = Dataset(train_split, 'val', root, mode, test_transforms)

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
print("Creating the LeNet model...")
# 3 channels for RGB images, classes is the num of classes in data
model = LeNet(numChannels = 3, classes = len(train_loader.dataset.classes)).to(device) 

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
for epoch in range(0, epochs):
    # training mode for model
    model.train()

    total_train_loss = 0 # keep track of loss during training
    total_val_loss = 0 # keep track of loss during validation
    train_correct = 0 # keep track of correct predictions during training
    val_correct = 0 # keep track of correct predictions during validation

    # loop training data
    for (x, y) in train_loader:
        x = x.to(device)
        y = y.to(device)

        # forward pass and calculate loss
        prediction = model(x)
        loss = loss_func(prediction, y)

        # zero out gradients, backward pass, update the weights
        optimizer.zero_grad()
        loss.backward()
        optimizer.step()

        # add loss to total loss
        total_train_loss += loss 

        # calculate accuracy
        train_correct += (prediction.argmax(1) == y).type(torch.float).sum().item()

    # disable autograd for validation
    with torch.no_grad():
        model.eval()

        # loop validation data
        for (x, y) in val_loader:
            x = x.to(device)
            y = y.to(device)

            # make predictions and find loss 
            prediction = model(x)
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
    History["train_loss"].append(val_correct)

    # display our info from this epoch
    print(f"EPOCH: {e + 1}/{EPOCHS}")
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
    for (x, y) in test_loader:
        x = x.to(device)

        # make our predictions and add
        prediction = model(x)
        predictions.extend(prediction.argmax(1).cpu().numpy())

# get classification report
print(classification_report(test_dataset.targets.cpu().numpy(), 
                            np.array(predictions), 
                            target_names = test_dataset.classes))

# make a plot of everything 
plt.style.use("ggplot")
plt.figure()
plt.plot(np.arange(0, EPOCHS), History["train_loss"], label = "train_loss")
plt.plot(np.arange(0, EPOCHS), History["val_loss"], label = "val_loss")
plt.plot(np.arange(0, EPOCHS), History["train_acc"], label = "train_acc")
plt.plot(np.arange(0, EPOCHS), History["val_acc"], label = "val_acc")
plt.title("Training Loss and Accuracy using WLASL Dataset")
plt.xlabel("Epoch #")
plt.ylabel("Loss/Accuracy")
plt.legend()
plt.savefig(args["plot"])

# save the model to disk
torch.save(model.state_dict(), args["model"])
