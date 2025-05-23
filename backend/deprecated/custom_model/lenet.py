"""
This file outlines the LeNet model for image classification using PyTorch. LeNet is a Convolutional
Neural Network (CNN) architecture that's fairly shallow and simple, but still good for machine 
learning.

File is modeled after the LeNet architecture, outlined in the following article:
https://pyimagesearch.com/2021/07/19/pytorch-training-your-first-convolutional-neural-network-cnn/

Authors: Zachary Eanes and Alex Charlot
Date: 09/23/2024
Version: 0.1
"""

# import of all necessary packages for lenet model
from torch.nn import Module     # instead of sequential, allows us to see how PyTorch works
from torch.nn import Conv2d     # convolutional layer
from torch.nn import ReLU       # activation function
from torch.nn import MaxPool2d  # 2D max pooling to reduce spatial dimensions of input
from torch.nn import Linear     # fully connected layer
from torch import flatten       # flattens input to then apply fully connected layer
from torch.nn import functional as F # used to interpolate our tensor to correct size
from torch.nn import LogSoftmax # use for softmax classifier to return predicted probabilities 


class LeNet(Module):
    """ 
    LeNet model for image classification using PyTorch.

    Args:
        Module: PyTorch's base class for all models
    """

    def __init__(self, numChannels, classes):
        """
        Constructs the LeNet model built on PyTorch's Module object.

        Args:
            numChannels (int): number of channels in the input images (1 for grayscale, 3 for RGB)
            classes (int): number of unique classes in the dataset
        """
        # call parent constructor to initialize with PyTorch specific operations
        super(LeNet, self).__init__()

        # first set of CONV => RELU => POOL        
        self.conv1 = Conv2d(in_channels = numChannels, # 20 filters with 5x5
                            out_channels = 20,
                            kernel_size = 5)
        self.relu1 = ReLU() 
        # 2x2 pooling later with 2x2 stride to reduce spatial dimensions of input
        self.pool1 = MaxPool2d(kernel_size = (2, 2), stride = (2, 2)) 

        # second set of CONV => RELU => POOL
        self.conv2 = Conv2d(in_channels = 20, # do again with larger filter amount
                            out_channels = 64,
                            kernel_size = 5)
        self.relu2 = ReLU()
        self.pool2 = MaxPool2d(kernel_size = (2, 2), stride = (2, 2))

        # single set of FC => RELU layers
        # self.fc1 = Linear(in_features = 800, out_features = 500)
        self.fc1 = Linear(in_features = 90, out_features = 500)

        self.relu3 = ReLU()

        # softmax classifier
        self.fc2 = Linear(in_features = 500, out_features = classes)

        # used to get predicted probabilities during evaluation
        self.logSoftmax = LogSoftmax(dim = 1) 

    def forward(self, x):
        """
        Overridden forward pass method for the LeNet model. 
        This function defines the network architecture itself, connecting layers together
        from the constructor of the class.
        
        Args:
            x (tensor): input data/tensor to the model
        """
        # follow the architecture of the model
        # if the input image has wrong number of channels, change it to 64 
        if x.shape[0] != 64:            
            # interpolate the tensor to the correct size
            temp_tensor = x.unsqueeze(0)  # Add a batch dimension, shape is now (1, _, 55, 50)

            # make conv layer to take any shape of x and change to 64 to fit rest of processing
            conv = Conv2d(in_channels=x.shape[0], out_channels=64, kernel_size=1) 
            output = conv(temp_tensor)

            # Remove the batch dimension if needed
            x = output.squeeze(0)
            
        x = self.conv1(x)
        x = self.relu1(x)
        x = self.pool1(x)

        x = self.conv2(x)
        x = self.relu2(x)
        x = self.pool2(x)

        x = flatten(x, 1)
        x = self.fc1(x)
        x = self.relu3(x)

        x = self.fc2(x)
        predictions = self.logSoftmax(x)

        # return the output predictions
        return predictions