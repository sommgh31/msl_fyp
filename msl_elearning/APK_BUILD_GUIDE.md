# APK Build Guide for MSL E-learning App

## ✅ Yes, you can build an APK!

Your Flutter app can be built into an APK file that can be installed on Android devices.

## 📦 Building the APK

### Option 1: Debug APK (for testing)
```bash
cd msl_elearning
flutter build apk --debug
```
The APK will be at: `build/app/outputs/flutter-apk/app-debug.apk`

### Option 2: Release APK (for distribution)
```bash
cd msl_elearning
flutter build apk --release
```
The APK will be at: `build/app/outputs/flutter-apk/app-release.apk`

### Option 3: Split APKs by ABI (smaller file size)
```bash
flutter build apk --split-per-abi
```
This creates separate APKs for different architectures (arm64-v8a, armeabi-v7a, x86_64)

## 🔧 Backend Connection - Important Considerations

### ⚠️ Current Setup Limitation

Your app currently uses a **hardcoded IP address** (`10.66.122.189`) in `lib/config/app_config.dart`. This means:

1. **✅ Will work if:**
   - The backend server is running on your computer
   - The Android device is on the **same WiFi network** as your computer
   - The IP address matches your computer's current IP

2. **❌ Won't work if:**
   - Device is on a different network
   - Your computer's IP changes
   - Backend server is not running
   - You want to distribute the app to others

### 📱 Solutions for Different Scenarios

#### Scenario 1: Same Network (Testing/Demo)
**Current setup works!** Just ensure:
- Backend is running: `python backend/main.py`
- Both devices on same WiFi
- IP address in `app_config.dart` matches your computer's IP

#### Scenario 2: Different Networks / Public Distribution
You have several options:

**Option A: Use a Public Server**
1. Deploy backend to a cloud service (AWS, Google Cloud, Heroku, etc.)
2. Update `app_config.dart` with the public URL:
   ```dart
   static const String _customIp = 'your-server.com'; // or IP
   return 'http://your-server.com:8000';
   ```

**Option B: Use ngrok (Temporary Public URL)**
1. Install ngrok: https://ngrok.com/
2. Run: `ngrok http 8000`
3. Use the ngrok URL in `app_config.dart`
4. ⚠️ Note: Free ngrok URLs change on restart

**Option C: Make IP Configurable in App**
Add a settings screen where users can enter the backend IP address.

**Option D: Use Dynamic DNS**
Set up a dynamic DNS service so you can use a domain name instead of IP.

## 🚀 Step-by-Step Build Process

### 1. Update Backend IP (if needed)
Edit `msl_elearning/lib/config/app_config.dart`:
```dart
static const String _customIp = 'YOUR_COMPUTER_IP'; // Update this
```

### 2. Build the APK
```bash
cd msl_elearning
flutter clean
flutter pub get
flutter build apk --release
```

### 3. Install on Device
- Transfer `app-release.apk` to your Android device
- Enable "Install from Unknown Sources" in Android settings
- Open the APK file and install

### 4. Test Backend Connection
- Ensure backend is running on your computer
- Ensure device is on same WiFi network
- Open the app and check the cloud icon (should be green)

## 🔒 Security Note

The app is configured to allow HTTP (cleartext) traffic because your backend uses HTTP. For production, consider:
- Using HTTPS with SSL certificates
- Implementing authentication
- Using environment variables for sensitive configs

## 📋 Pre-Build Checklist

- [ ] Backend IP address is correct in `app_config.dart`
- [ ] Backend server is accessible from your network
- [ ] All dependencies are up to date (`flutter pub get`)
- [ ] App version is updated in `pubspec.yaml` if needed
- [ ] Tested on a physical device first

## 🐛 Troubleshooting

### APK won't install
- Check Android version compatibility (minSdkVersion in `build.gradle`)
- Enable "Install from Unknown Sources"
- Try uninstalling previous version first

### Backend connection fails
- Verify backend is running: `curl http://YOUR_IP:8000/health`
- Check firewall allows port 8000
- Ensure both devices on same network
- Test from phone browser: `http://YOUR_IP:8000/health`

### App crashes on startup
- Check logs: `adb logcat | grep flutter`
- Verify all permissions in AndroidManifest.xml
- Ensure camera permissions are granted

## 📱 Distribution

If you want to share the APK:
1. Build release APK: `flutter build apk --release`
2. Share the file: `build/app/outputs/flutter-apk/app-release.apk`
3. **Important:** Recipients need:
   - Backend server running (or use public server)
   - Same network (or update IP in config)
   - Updated `app_config.dart` with correct backend IP

## 🎯 Recommended Production Setup

For a production-ready app:
1. Deploy backend to cloud (AWS, Google Cloud, etc.)
2. Use HTTPS with SSL certificate
3. Add authentication/API keys
4. Use environment-based configuration
5. Implement error handling and retry logic
6. Add app version checking

---

**Quick Build Command:**
```bash
cd msl_elearning && flutter build apk --release
```

The APK will be ready at: `build/app/outputs/flutter-apk/app-release.apk`

