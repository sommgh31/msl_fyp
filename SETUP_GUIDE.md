# MSL E-Learning System Setup Guide

This guide will help you set up and run the complete MSL (Malaysian Sign Language) E-Learning system, including the Flutter app, backend API, and training components.

## 📋 What Has Been Set Up

### ✅ Flutter App (`msl_elearning/`)
- **Dependencies Added**: 
  - `http` - For API communication
  - `path_provider` - For file system access
  - `path` - For path manipulation
  - Camera and image packages already configured

- **New Files Created**:
  - `lib/services/api_service.dart` - Backend API client
  - `lib/camera_page.dart` - Real-time sign recognition page
  - `lib/config/app_config.dart` - Configuration file (backend URL)

- **Updated Files**:
  - `pubspec.yaml` - Added required dependencies
  - `main.dart` - Added camera route
  - `README.md` - Updated with setup instructions

### ✅ Backend API (`backend/`)
- FastAPI server with MediaPipe hand detection
- Endpoints for prediction and health checks
- CORS enabled for Flutter app

### ✅ Training Script (`training/`)
- ResNet18 model training script
- Automatically copies trained model to backend

## 🚀 Quick Start

### Step 1: Prepare the Backend Model

The backend needs a trained model file. You have two options:

**Option A: Use existing model (if available)**
```bash
# Copy the model from training directory to backend
cp training/models/msl_full_dataset_50_classes.pth backend/final_model.pth
```

**Option B: Train a new model**
```bash
cd training
python train_full_dataset.py
# This will automatically copy the model to backend/final_model.pth
```

### Step 2: Start the Backend Server

```bash
cd backend
pip install -r requirements.txt
python main.py
```

The server should start on `http://0.0.0.0:8000`

Verify it's working:
```bash
curl http://localhost:8000/health
```

### Step 3: Configure Flutter App Backend URL

**IMPORTANT**: Update the backend URL in `msl_elearning/lib/config/app_config.dart`:

- **Android Emulator**: `http://10.0.2.2:8000` (default)
- **iOS Simulator**: `http://localhost:8000`
- **Physical Device**: `http://YOUR_COMPUTER_IP:8000`
  - Find your IP: 
    - Windows: `ipconfig` (look for IPv4 Address)
    - Mac/Linux: `ifconfig` (look for inet)
  - Example: `http://192.168.1.100:8000`

### Step 4: Run the Flutter App

```bash
cd msl_elearning
flutter pub get  # Already done, but good to verify
flutter run
```

## 📱 App Features

1. **Home Page**: Navigate to different modules
2. **Dictionary**: Browse all MSL signs (A-Z, 0-10, basic words)
3. **Quizzes**: Test your knowledge with interactive quizzes
4. **Real-time Recognition**: Use camera to recognize signs in real-time

## 🔧 Troubleshooting

### Backend Connection Issues

1. **Check Backend is Running**
   - Verify server is running: `curl http://localhost:8000/health`
   - Check for errors in backend console

2. **Check Backend URL**
   - Verify URL in `msl_elearning/lib/config/app_config.dart`
   - For physical devices, ensure both devices are on same WiFi network
   - Check firewall isn't blocking port 8000

3. **Model Not Loading**
   - Ensure `backend/final_model.pth` exists
   - Check backend console for model loading errors
   - Verify model file is not corrupted

### Camera Issues

- **Permissions**: Ensure camera permissions are granted
- **Emulator**: Some emulators may not have camera support
- **Physical Device**: Test on a real device for best results

### Flutter Build Issues

```bash
# Clean and rebuild
cd msl_elearning
flutter clean
flutter pub get
flutter run
```

## 📁 Project Structure

```
msl_fyp/
├── backend/
│   ├── main.py              # FastAPI server
│   ├── requirements.txt    # Python dependencies
│   ├── final_model.pth     # Trained model (needs to be created/copied)
│   └── README.md           # Backend setup guide
│
├── msl_elearning/
│   ├── lib/
│   │   ├── main.dart       # App entry point
│   │   ├── homepage.dart  # Home screen
│   │   ├── dictionary.dart # Sign dictionary
│   │   ├── quiz-home.dart  # Quiz selection
│   │   ├── quizzes.dart   # Quiz questions
│   │   ├── camera_page.dart # Real-time recognition
│   │   ├── config/
│   │   │   └── app_config.dart # Configuration
│   │   └── services/
│   │       └── api_service.dart # API client
│   ├── pubspec.yaml        # Flutter dependencies
│   └── README.md           # Flutter app guide
│
└── training/
    ├── train_full_dataset.py # Model training script
    ├── dataset/             # Training images
    └── models/              # Trained models
```

## 🎯 Next Steps

1. **Train or Copy Model**: Ensure `backend/final_model.pth` exists
2. **Start Backend**: Run the FastAPI server
3. **Configure URL**: Update backend URL in Flutter app config
4. **Test Connection**: Use the camera page to test recognition
5. **Customize**: Adjust settings in `app_config.dart` as needed

## 📚 API Documentation

The backend provides these endpoints:

- `GET /health` - Check server and model status
- `GET /classes` - Get all available sign classes (50 total)
- `POST /predict` - Predict from image file
- `POST /predict_base64` - Predict from base64 image

See `backend/README.md` for detailed API documentation.

## 💡 Tips

- **Development**: Use Android emulator with `http://10.0.2.2:8000` for easiest setup
- **Testing**: Use physical device for real camera testing
- **Performance**: Backend runs faster on GPU if available (CUDA)
- **Model**: The model supports 50 classes (26 letters, 11 numbers, 13 words)

## 🆘 Need Help?

1. Check backend console for errors
2. Check Flutter console for app errors
3. Verify all dependencies are installed
4. Ensure model file exists and is valid
5. Test backend independently with curl commands

---

**Happy Learning! 🎉**

