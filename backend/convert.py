""" 
File converts the PyTorch model to TorchScript model
"""
import torch
import os
from TGCN.tgcn_model import GCN_muti_att
from TGCN.configs import Config

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
    print("Loading model...")
    model = GCN_muti_att(input_feature=num_samples * 2, hidden_feature=hidden_size,
                         num_class=int(trained_on[3:]), p_dropout=drop_p, num_stage=num_stages).cuda()
    print("Finish loading model!")

    # return the loaded model
    return model


# load our model, set to eval, then save to new file
path = os.path.join(os.getcwd(), 'backend/TGCN/saved_models/asl100.pth')
model = torch.load(path) 
model.eval()  
scripted_model = torch.jit.script(model)  
scripted_model.save(os.getcwd() + "backend/TGCN/saved_models/asl100.pt")