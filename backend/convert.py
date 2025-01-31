""" 
this script converts the PyTorch model to an Executorch model for mobile.
"""
import torch
import os
import executorch
import executorch.tools.convert as convert
from TGCN.tgcn_model import GCN_muti_att
from TGCN.configs import Config
from torch.export import export


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

# load our model, set to eval
path = os.path.join(os.getcwd(), 'backend/TGCN/saved_models/asl100.pth')
model = load_model()
model.load_state_dict(torch.load(path))
model.eval()

# export with torch.export 
dummy_input = torch.randn(1, 55, model.gc1.in_features).cuda()
export_model = export(model, dummy_input)

# convert to executorch
executorch_model = convert.to_executorch(export_model)

# save to a .pte file 
executorch_path = os.path.join(os.getcwd(), "backend/TGCN/saved_models/asl100.pte")
with open(executorch_path, "wb") as f:
    f.write(executorch_program.buffer)
print(f"Executorch model saved to {executorch_path}")



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
