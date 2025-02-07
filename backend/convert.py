""" 
This script converts the PyTorch model to either a TorchScript or Executorch model.

Author: Zach Eanes
Date: 02/04/2025
"""
import torch
from torch.export import export, export_for_training, ExportedProgram
import os
import executorch
from executorch.exir import ExecutorchBackendConfig, EdgeProgramManager, ExecutorchProgramManager, to_edge
from TGCN.tgcn_model import GCN_muti_att
from TGCN.configs import Config

# use it later when we already have the model
num_samples = 0

def load_model():
    """
    Load the model for communication with frontend.
    """
    # global variables we need to use
    global num_samples

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
    model = GCN_muti_att(input_feature=num_samples * 2, 
                         hidden_feature=hidden_size,
                         num_class=int(trained_on[3:]), 
                         p_dropout=drop_p, 
                         num_stage=num_stages).cuda()

    # return the loaded model
    return model

# load model and set to eval
model = load_model()
model.eval()

# example input that our model expects
dummy_input = torch.randn(1, 55, 100).cuda()

# convert to cpu !!if you don't do this it seg faults!!
model = model.cpu()
dummy_input = dummy_input.cpu()

# trace the model using torchscript and then save it
traced_model = torch.jit.trace(model, dummy_input)
traced_model.save(os.path.join(os.getcwd(), 'backend/TGCN/saved_models/asl100.pt'))

# convert to Executorch (followed steps directly from Executorch documentation)
pre_autograd_aten_dialect = export_for_training(model, (dummy_input,)).module()
aten_dialect: ExportedProgram = export(pre_autograd_aten_dialect, (dummy_input,))
edge_program: EdgeProgramManager = to_edge(aten_dialect)

executorch_program: ExecutorchProgramManager = edge_program.to_executorch(
    ExecutorchBackendConfig(
        passes=[]  # User-defined passes, you can leave it empty if not needed
    )
)

# save to .pte file
save_path = os.path.join(os.getcwd(), 'backend/TGCN/saved_models/asl100_executorch.pte')
with open(save_path, "wb") as file:
    file.write(executorch_program.buffer)

# print it worked
print(f"Model exported and saved to {save_path}.\nConverted to Executorch model!!")


######## old framework ########
# load our model, set to eval, then save to new file
# path = os.path.join(os.getcwd(), 'backend/TGCN/saved_models/asl100.pth')
# model = torch.load(path) 
# model.eval()  
# scripted_model = torch.jit.script(model)  
# scripted_model.save(os.getcwd() + "backend/TGCN/saved_models/asl100.pt")
