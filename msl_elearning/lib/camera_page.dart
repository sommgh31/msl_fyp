import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'services/api_service.dart';
import 'main.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _controller;
  bool _isInitialized = false;
  bool _isProcessing = false;
  bool _isBackendConnected = false;
  String? _lastPrediction;
  double? _lastConfidence;
  List<Map<String, dynamic>>? _topPredictions;
  String? _errorMessage;
  int _selectedCameraIndex = 0;
  bool _isFrontCamera = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _checkBackendConnection();
  }

  Future<void> _checkBackendConnection() async {
    final health = await ApiService.checkHealth();
    setState(() {
      _isBackendConnected = health != null && health['model_loaded'] == true;
      if (!_isBackendConnected) {
        final baseUrl = ApiService.baseUrl;
        if (health == null) {
          _errorMessage =
              'Cannot reach backend at $baseUrl\n\n'
              'Please check:\n'
              '1. Backend server is running (python main.py)\n'
              '2. Correct IP address in lib/config/app_config.dart\n'
              '3. Both devices on same WiFi network\n'
              '4. Firewall allows port 8000';
        } else {
          _errorMessage =
              'Backend connected but model not loaded.\n'
              'Check backend console for errors.';
        }
      } else {
        _errorMessage = null;
      }
    });
  }

  Future<void> _initializeCamera() async {
    if (cameras.isEmpty) {
      setState(() {
        _errorMessage = 'No cameras available';
      });
      return;
    }

    // Find back camera (default)
    int cameraIndex = 0;
    for (int i = 0; i < cameras.length; i++) {
      if (cameras[i].lensDirection == CameraLensDirection.back) {
        cameraIndex = i;
        break;
      }
    }

    await _switchCamera(cameraIndex);
  }

  Future<void> _switchCamera(int cameraIndex) async {
    if (cameraIndex >= cameras.length) return;

    // Dispose old controller
    await _controller?.dispose();

    setState(() {
      _isInitialized = false;
      _errorMessage = null;
    });

    try {
      _controller = CameraController(
        cameras[cameraIndex],
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();
      setState(() {
        _isInitialized = true;
        _selectedCameraIndex = cameraIndex;
        _isFrontCamera =
            cameras[cameraIndex].lensDirection == CameraLensDirection.front;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize camera: $e';
      });
    }
  }

  Future<void> _toggleCamera() async {
    if (cameras.length < 2) {
      setState(() {
        _errorMessage = 'Only one camera available';
      });
      return;
    }

    // Find the other camera
    CameraLensDirection currentDirection =
        cameras[_selectedCameraIndex].lensDirection;
    CameraLensDirection targetDirection =
        currentDirection == CameraLensDirection.front
            ? CameraLensDirection.back
            : CameraLensDirection.front;

    int targetIndex = _selectedCameraIndex;
    for (int i = 0; i < cameras.length; i++) {
      if (cameras[i].lensDirection == targetDirection) {
        targetIndex = i;
        break;
      }
    }

    await _switchCamera(targetIndex);
  }

  Future<void> _captureAndPredict() async {
    if (!_isInitialized || _controller == null || _isProcessing) return;

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      // Capture image
      final XFile image = await _controller!.takePicture();

      // Read image bytes
      final Uint8List imageBytes = await image.readAsBytes();

      // Decode and process image
      final img.Image? decodedImage = img.decodeImage(imageBytes);
      if (decodedImage == null) {
        throw Exception('Failed to decode image');
      }

      // Resize if too large
      img.Image processedImage = decodedImage;
      if (decodedImage.width > 1024 || decodedImage.height > 1024) {
        final ratio =
            decodedImage.width > decodedImage.height
                ? 1024 / decodedImage.width
                : 1024 / decodedImage.height;
        processedImage = img.copyResize(
          decodedImage,
          width: (decodedImage.width * ratio).toInt(),
          height: (decodedImage.height * ratio).toInt(),
        );
      }

      // Convert to JPEG
      final jpegBytes = img.encodeJpg(processedImage, quality: 85);

      // Save to temp file for API call
      final tempDir = await getTemporaryDirectory();
      final tempFile = File(path.join(tempDir.path, 'temp_capture.jpg'));
      await tempFile.writeAsBytes(jpegBytes);

      // Call API
      final result = await ApiService.predictFromFile(tempFile);

      // Clean up temp file
      try {
        await tempFile.delete();
      } catch (e) {
        // Ignore cleanup errors
      }

      if (result != null) {
        setState(() {
          _lastPrediction = result['prediction'] as String?;
          _lastConfidence = (result['confidence'] as num?)?.toDouble();
          _topPredictions =
              result['top5'] != null
                  ? List<Map<String, dynamic>>.from(result['top5'] as List)
                  : null;
          _errorMessage = null;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to get prediction from server';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 16.0,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: const Text(
                      'Real-time Recognition',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isFrontCamera ? Icons.camera_front : Icons.camera_rear,
                      color: Colors.black87,
                    ),
                    onPressed: _isInitialized ? _toggleCamera : null,
                    tooltip:
                        _isFrontCamera
                            ? 'Switch to back camera'
                            : 'Switch to front camera',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  IconButton(
                    icon: Icon(
                      _isBackendConnected ? Icons.cloud_done : Icons.cloud_off,
                      color: _isBackendConnected ? Colors.green : Colors.red,
                    ),
                    onPressed: _checkBackendConnection,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Backend status
            if (!_isBackendConnected)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage ?? 'Backend not connected',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Camera preview
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child:
                      _isInitialized && _controller != null
                          ? CameraPreview(_controller!)
                          : const Center(child: CircularProgressIndicator()),
                ),
              ),
            ),

            // Prediction results
            if (_lastPrediction != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFFE0F2F1), const Color(0xFFB2DFDB)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFB2DFDB).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Prediction:',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        if (_lastConfidence != null)
                          Text(
                            '${(_lastConfidence! * 100).toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _lastPrediction!,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00695C),
                      ),
                    ),
                    if (_topPredictions != null &&
                        _topPredictions!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Text(
                        'Top Predictions:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ..._topPredictions!
                          .take(3)
                          .map(
                            (pred) => Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    pred['class'] as String,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  Text(
                                    '${((pred['confidence'] as num) * 100).toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                    ],
                  ],
                ),
              ),

            // Error message
            if (_errorMessage != null && _lastPrediction == null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade300),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.orange.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // Capture button
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isProcessing ? Colors.grey : const Color(0xFF00695C),
                  boxShadow: [
                    BoxShadow(
                      color: (_isProcessing
                              ? Colors.grey
                              : const Color(0xFF00695C))
                          .withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child:
                    _isProcessing
                        ? const Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                        : IconButton(
                          icon: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 40,
                          ),
                          onPressed:
                              _isBackendConnected ? _captureAndPredict : null,
                        ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
