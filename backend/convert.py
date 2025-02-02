""" 
this script converts the PyTorch model to an Executorch model for mobile.
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
    print("Loading model...")
    model = GCN_muti_att(input_feature=num_samples * 2, 
                         hidden_feature=hidden_size,
                         num_class=int(trained_on[3:]), 
                         p_dropout=drop_p, 
                         num_stage=num_stages).cuda()
    print("Finish loading model!")

    # return the loaded model
    return model

# load model and set to eval
model = load_model()
model.eval()

# example input 
dummy_input = torch.randn(1, 55, 100).cuda()

# convert to cpu
model = model.cpu()
dummy_input = dummy_input.cpu()

# trace the model 
traced_model = torch.jit.trace(model, dummy_input)

# save as TorchScript
traced_model.save(os.path.join(os.getcwd(), 'backend/TGCN/saved_models/asl100.pt'))

# convert to Executorch
pre_autograd_aten_dialect = export_for_training(model, (dummy_input,)).module()
print("pre_autograd_aten_dialect made")
aten_dialect: ExportedProgram = export(pre_autograd_aten_dialect, (dummy_input,))
print("aten_dialect made")
edge_program: EdgeProgramManager = to_edge(aten_dialect)
print("edge_program made")

executorch_program: ExecutorchProgramManager = edge_program.to_executorch(
    ExecutorchBackendConfig(
        passes=[]  # User-defined passes, you can leave it empty if not needed
    )
)
print("executorch_program made")

# save to .pte file
save_path = os.path.join(os.getcwd(), 'backend/TGCN/saved_models/asl100_executorch.pte')
with open(save_path, "wb") as file:
    file.write(executorch_program.buffer)

print(f"Model exported and saved to {save_path}")
print("Model converted to Executorch!")





######## old framework ########

# # load our model, set to eval
# path = os.path.join(os.getcwd(), 'backend/TGCN/saved_models/asl100.pth')
# model = torch.load(path) 
# # model = load_model()
# model.eval()  
# dummy_input = torch.randn(1, 55, model.gc1.in_features).cuda()
# export_model = export(model, torch.randn(1, 100, 42).cuda(), verbose=False)

# # convert to TorchScript
# scripted_model = torch.jit.script(model, dummy_input)  
# scripted_model.save(os.getcwd() + "backend/TGCN/saved_models/asl100.pt")

# # convert to executorch
# executorch_model = compile_tools.to_executorch(scripted_model)
# torch.jit.save(executorch_model, os.getcwd() + "backend/TGCN/saved_models/asl100.pte")
