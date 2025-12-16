# MSL E-Learning App

A Flutter application for learning Malaysian Sign Language (MSL) with real-time recognition capabilities.

## Features

- **Dictionary**: Browse all MSL signs (A-Z letters, 0-10 numbers, and basic words)
- **Quizzes**: Test your knowledge with interactive quizzes
- **Real-time Recognition**: Use your camera to recognize sign language in real-time

## Setup Instructions

### 1. Install Dependencies

```bash
cd msl_elearning
flutter pub get
```

### 2. Backend Configuration

The app connects to a FastAPI backend for sign language recognition. 

**Important**: Update the backend URL in `lib/config/app_config.dart`:

- **Android Emulator**: `http://10.0.2.2:8000` (default)
- **iOS Simulator**: `http://localhost:8000`
- **Physical Device**: `http://YOUR_COMPUTER_IP:8000`
  - Find your IP: `ipconfig` (Windows) or `ifconfig` (Mac/Linux)
  - Example: `http://192.168.1.100:8000`

### 3. Start the Backend Server

Navigate to the backend directory and start the server:

```bash
cd ../backend
pip install -r requirements.txt
python main.py
```

The server should start on `http://0.0.0.0:8000`

### 4. Run the Flutter App

```bash
cd msl_elearning
flutter run
```

## Project Structure

```
lib/
├── main.dart              # App entry point
├── homepage.dart          # Home screen
├── dictionary.dart        # Sign dictionary
├── quiz-home.dart         # Quiz selection
├── quizzes.dart           # Quiz questions
├── camera_page.dart       # Real-time recognition
├── config/
│   └── app_config.dart    # App configuration (backend URL)
└── services/
    └── api_service.dart   # Backend API client
```

## Backend API Endpoints

- `GET /health` - Health check
- `GET /classes` - Get all available sign classes
- `POST /predict` - Predict from image file
- `POST /predict_base64` - Predict from base64 image

## Troubleshooting

### Backend Connection Issues

1. Ensure the backend server is running
2. Check the backend URL in `lib/config/app_config.dart`
3. For physical devices, ensure both device and computer are on the same network
4. Check firewall settings

### Camera Issues

- Ensure camera permissions are granted
- Check if camera is available on your device/emulator

## Dependencies

- `camera`: Camera functionality
- `http`: HTTP client for API calls
- `image`: Image processing
- `path_provider`: File system access
