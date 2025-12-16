import 'dart:io';
import 'package:flutter/foundation.dart';

class AppConfig {
  // Backend API Configuration
  //
  // IMPORTANT: Update this URL based on your setup:
  //
  // For Android Emulator: http://10.0.2.2:8000
  // For iOS Simulator: http://localhost:8000
  // For Physical Device: http://YOUR_COMPUTER_IP:8000
  //   (Find your IP with: ipconfig on Windows, ifconfig on Mac/Linux)
  //
  // Example for physical device: http://192.168.1.100:8000
  //
  // YOUR COMPUTER IP ADDRESSES FOUND:
  // - 172.23.208.1 (likely virtual adapter)
  // - 10.66.122.189 (likely WiFi/LAN - USE THIS ONE)
  //
  // ⚠️ IMPORTANT: Change the IP below to match your network!
  // For Android Emulator: use '10.0.2.2'
  // For Physical Device/Web: use your computer's WiFi IP (10.66.122.189)
  static const String _customIp = '10.66.122.189'; // ← Change this if needed

  // Auto-detect backend URL based on platform
  static String get backendBaseUrl {
    if (kIsWeb) {
      // For web, use localhost or your computer's IP
      // If running on same machine, use localhost
      // If accessing from another device, use your IP
      return 'http://$_customIp:8000';
    } else if (Platform.isAndroid) {
      // Check if running on emulator or physical device
      // For emulator: 10.0.2.2
      // For physical device: use your computer's IP
      // You can manually set this below
      return 'http://10.66.122.189:8000'; // Change to 10.0.2.2 for emulator
    } else if (Platform.isIOS) {
      // For iOS simulator: localhost
      // For physical device: use your computer's IP
      return 'http://$_customIp:8000'; // Change to localhost for simulator
    }
    // Default fallback
    return 'http://$_customIp:8000';
  }

  // API Endpoints
  static const String healthEndpoint = '/health';
  static const String classesEndpoint = '/classes';
  static const String predictEndpoint = '/predict';
  static const String predictBase64Endpoint = '/predict_base64';

  // Timeout durations
  static const Duration connectionTimeout = Duration(seconds: 5);
  static const Duration requestTimeout = Duration(seconds: 10);

  // Image processing settings
  static const int maxImageSize = 1024; // pixels on longest side
  static const int jpegQuality = 85; // 0-100
}
