""" 
File converts the PyTorch model to TorchScript model
"""


import torch

model = torch.load("asl100.pth")  
model.eval()  
scripted_model = torch.jit.script(model)  
scripted_model.save("asl100.pt")