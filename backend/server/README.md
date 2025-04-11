# Server

This folder contains the code necessary to run the backend server for SLAMM.

## Getting Started

First, you need to install the necessary dependencies. You can do this by running:

```pip install -r requirements.txt```

There may be some other dependencies that are not listed in the requirements.txt file, such
as:
- `NVIDIA CUDA`: https://developer.nvidia.com/cuda-downloads
- 'ngrok': https://ngrok.com/download
- ...

## Running the Server
To run the server, you can use the following command:

```uvicorn app:server --host 0.0.0.0 --port <port_number>```

After the server has finished running, you can then use ngrok to expose the server to the 
internet by running:

```ngrok http --url=<static_url> <port_number>```

For our application, there's an expected address that the Flutter application searches for
so ensure the addresses are the same in __uploadVideo() in frontend/lib/camera.dart__. For example,
the address for our use is choice-tops-kite.ngrok-free.app so our command would be:

```ngrok http --url=choice-tops-kite.ngrok-free.app 12345```

if our port is 12345.