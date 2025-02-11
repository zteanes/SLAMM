# SLAMM

**S**ign **L**anguage **A**nalytics and **M**obile **M**achine Learning.

This project is a part of WCU's Capstone projects for the 2024-2025 academic year.

## Authors

Zachary Eanes - [GitHub](https://github.com/zteanes) - [LinkedIn](https://www.linkedin.com/in/zteanes/)

Alexander Charlot - [GitHub](https://github.com/Al-Charlot) - [LinkedIn](https://www.linkedin.com/in/alexcharlot1/)

## Table of Contents

- [SLAMM](#slamm)
  - [Table of Contents](#table-of-contents)
  - [Introduction](#introduction)
  - [Installation](#installation)
  - [Usage](#usage)

## Introduction

This project aims to create a mobile app for both iOS and Android devices which brings together machine learning and image recognition to help communicate via American Sign Language (ASL). This app will be able to recognize and translate ASL to English in real time, creating a more inclusive environment for the deaf and hard of hearing community.

## Installation

### Server-Side

Our server is responsible for hosting the machine learning model, performing all the necessary processing, and interpreting a video of ASL. The machine/computer used to launch the server **must** have an NVIDIA graphics card, as our architecture relies on CUDA software. We recommend using a fairly powerful system to host the server for best results.

In order to run our server, follow these instructions:

1. Use `pip -r install requirements.txt`
2. Navigate to the server directory (`cd backend/server/`)
3. Using FastAPI/uvicorn, you can run the server with: `uvicorn server:app --host 0.0.0.0 --port <port>`
    It's important to note using 0.0.0.0 will allow any connections to come in to the machine. Also choose a port of your liking!
5. Next, use ngrok to open the localhost as a public URL in a different terminal: `ngrok http <port>`
    The port you use with ngrok **must** be the same one used with uvicorn.

Now your server is ready to receive requests from the client!

### Client-Side

The client is run through a Flutter application, and handles the recording and sending of the video to the server.

In order to run our client, follow these instructions:

1. Open lib/camera.dart, and edit the first line in the method uploadVideo to use the http ngrok created when setting up the server:
      `var request = http.MultipartRequest('POST', Uri.parse(<NGROK-URL-HERE>));`
2. Navigate to the frontend directory (`cd frontend`)
3. Run the following flutter commands in order:

   `flutter clean` - cleans the repository to ensure proper files

   `flutter pub get` - install necessary dependencies
   
5. Lastly, with a connected iOS/Android device run `flutter run`

Wait for the client to run and you're ready to use!
   

## Usage

TODO
