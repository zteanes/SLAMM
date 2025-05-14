# SLAMM
<<<<<<< HEAD
=======

**S**ign **L**anguage **A**nalytics and **M**obile **M**achine Learning.

This project is a part of WCU's Capstone projects for the 2024-2025 academic year.

SLAMM is a mobile app designed to allow simple and quick translation of American Sign Language, 
or ASL for short. This is inspired by the lack of widely available tools to translate ASL in the iOS or Android 
app stores. There are many translation tools which are available for spoken language, but when it comes to ASL 
it's been neglected. It's important as many people rely on ASL as a primary form of communication, 
and SLAMM is designed to be a solution in allowing people to feel included and understood. 

## Authors

Zachary Eanes - [GitHub](https://github.com/zteanes) - [LinkedIn](https://www.linkedin.com/in/zteanes/)

Alexander Charlot - [GitHub](https://github.com/Al-Charlot) - [LinkedIn](https://www.linkedin.com/in/alexcharlot1/)

## Table of Contents

- [SLAMM](#slamm)
  - [Table of Contents](#table-of-contents)
  - [Introduction](#introduction)
  - [Installation](#installation)
  - [How to Use](#how-to-use)
  - [Thanks and Recognition](#thanks-and-recognition)

## Introduction

This project aims to create a mobile app for both iOS and Android devices which brings together machine learning and image recognition to help communicate via American Sign Language (ASL). This app will be able to recognize and translate ASL to English in real time, creating a more inclusive environment for the deaf and hard of hearing community.

## Installation

### Server-Side

Our server is responsible for hosting the machine learning model, performing all the necessary processing, and interpreting a video of ASL. The machine/computer used to launch the server **must** have an NVIDIA graphics card, as our architecture relies on CUDA software. We recommend using a fairly powerful system to host the server for the best results.

To run our server, follow these instructions:

1. Use `pip -r install requirements.txt`
2. Navigate to the server directory (`cd backend/server/`)
3. Using FastAPI/uvicorn, you can run the server with: `uvicorn server:app --host 0.0.0.0 --port <port>`
    It's important to note that using 0.0.0.0 will allow any connections to come into the machine. Also, choose a port of your liking!
5. Next, use ngrok to open localhost as a public URL in a different terminal: `ngrok http <port>`
    The port you use with ngrok **must** be the same one used with uvicorn.

Now your server is ready to receive requests from the client!

### Client-Side

The client runs through a Flutter application and handles the recording and sending of the video to the server.

To run our client, follow these instructions:

1. Open lib/camera.dart, and edit the first line in the method `uploadVideo` to use the HTTP ngrok created when setting up the server:
      `var request = http.MultipartRequest('POST', Uri.parse(<NGROK-URL-HERE>));`
2. Navigate to the frontend directory (`cd frontend`)
3. Run the following Flutter commands in order:

   `flutter clean` - cleans the repository to ensure proper files

   `flutter pub get` - install necessary dependencies
   
5. Lastly, with a connected iOS/Android device, run `flutter run`

Wait for the client to run, and you're ready to use it!
   

## How to Use

To use the app effectively, let's first consider how SLAMM actually works! It's done by recording short 
videos of a person signing a single term, and then receiving a prediction from a machine learning model trained 
to recognize ASL. We recommend recording a video that contains only one sign at a time, and ensuring that as 
much of the sign is in the video. Try to eliminate as much video and after the sign to ensure the highest level 
of accuracy. This is because the model is trained to recognize a single sign, and if there is \"dead space\" in 
the video, it will confuse the model and lead to lower accuracy or a wrong translation. Whenever you receive a 
translation and reinterpretation back, you'll notice the coloring of the text. The text is colored so that a user 
will know how confident the model is in its prediction. The colors are as follows:

- Green: The model is very confident in its prediction. (70%+)
- Yellow: The model is somewhat confident in its prediction. (35%-69%)
- Red: The model is not confident in its prediction. (0%-34%)

Otherwise, simply navigate to the camera screen, use the camera switch button in the upper-right to select the 
camera you wish to use. Then, click the button in the bottom-middle of the screen to begin recording! Once you 
begin recording, you'll notice a new button appears in the bottom-left of the screen. This is our "next word" 
button, and it allows you to begin signing a new word without having to stop the recording. In essence, it 
allows you to translation a sentence in a single video! Whenever you're done recording, simply click the 
"stop recording" button in the bottom-middle of the screen. This will stop the recording, and you can then hit 
translate to receive a translation!

## Thanks and Recognition

This project would not have been possible with the amazing work of WLASL, which can be found 
[here](https://github.com/dxli94/WLASL). This served as the backbone for our project, as their I3D Model for 
recognition of ASL terms.

>>>>>>> capstone/main
