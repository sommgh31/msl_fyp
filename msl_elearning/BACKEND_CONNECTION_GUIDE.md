# Backend Connection Guide

## Quick Fix for Your Current Issue

Your backend is running, but the app can't connect because it's using the wrong IP address.

### ✅ Solution

I've updated `lib/config/app_config.dart` to use your computer's IP: **10.66.122.189**

### 🔍 Verify Backend is Accessible

Test from your computer:
```bash
curl http://10.66.122.189:8000/health
```

Or open in browser:
```
http://10.66.122.189:8000/health
```

### 📱 For Android Phone

1. **Ensure both devices are on the same WiFi network**
2. The config is now set to: `http://10.66.122.189:8000`
3. If this doesn't work, try the other IP: `172.23.208.1`

### 🌐 For Web Browser (Edge)

The web version should also use `http://10.66.122.189:8000`

### 🔧 If Still Not Working

1. **Check Windows Firewall**:
   - Open Windows Defender Firewall
   - Allow port 8000 for Python/uvicorn
   - Or temporarily disable firewall to test

2. **Verify Backend is Running**:
   ```bash
   netstat -an | findstr :8000
   ```
   Should show: `TCP    0.0.0.0:8000           0.0.0.0:0              LISTENING`

3. **Test from Phone Browser**:
   - On your phone, open browser
   - Go to: `http://10.66.122.189:8000/health`
   - If this works, the Flutter app should work too

4. **Check IP Address**:
   - Your IPs found: `10.66.122.189` and `172.23.208.1`
   - Try both in the config if one doesn't work
   - Make sure you're using the WiFi/LAN adapter IP, not the virtual adapter

### 📝 Quick Config Change

Edit `msl_elearning/lib/config/app_config.dart`:

```dart
static const String _customIp = '10.66.122.189'; // Your IP here
```

### 🎯 Different Scenarios

**Android Emulator:**
```dart
static const String _customIp = '10.0.2.2';
```

**Physical Android Device:**
```dart
static const String _customIp = '10.66.122.189'; // Your computer's IP
```

**Web Browser (same computer):**
```dart
static const String _customIp = 'localhost';
```

**Web Browser (different device):**
```dart
static const String _customIp = '10.66.122.189'; // Your computer's IP
```

### 🚨 Common Issues

1. **"Connection refused"**: Backend not running or wrong IP
2. **"Timeout"**: Firewall blocking or wrong network
3. **"Model not loaded"**: Backend running but model file missing

### ✅ Success Indicators

When working correctly:
- Backend console shows: `✅ Model ready on cpu`
- App shows green cloud icon (✓) in camera page
- Health check returns: `{"status": "healthy", "model_loaded": true}`

