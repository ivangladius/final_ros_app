#!/bin/bash

# Change to the app directory
cd /app

# Run Flutter doctor
flutter doctor

flutter clean

# Get Flutter dependencies
flutter pub get

# Run the Flutter app in web mode with the headless-device
flutter run -d web-server --web-port 8080 --web-hostname 0.0.0.0 --web-renderer html