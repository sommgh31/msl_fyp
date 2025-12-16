import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import '../config/app_config.dart';

class ApiService {
  static String get baseUrl => AppConfig.backendBaseUrl;

  /// Check if backend is healthy
  static Future<Map<String, dynamic>?> checkHealth() async {
    final url = '$baseUrl${AppConfig.healthEndpoint}';
    try {
      final response = await http
          .get(Uri.parse(url), headers: {'Content-Type': 'application/json'})
          .timeout(AppConfig.connectionTimeout);

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
      print('Health check failed: Status ${response.statusCode}');
      return null;
    } catch (e) {
      print('Health check error for $url: $e');
      return null;
    }
  }

  /// Get all available classes
  static Future<List<String>?> getClasses() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl${AppConfig.classesEndpoint}'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(AppConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final classes = data['classes'] as List;
        return classes.map((e) => e.toString()).toList();
      }
      return null;
    } catch (e) {
      print('Get classes error: $e');
      return null;
    }
  }

  /// Predict from image file
  static Future<Map<String, dynamic>?> predictFromFile(File imageFile) async {
    try {
      // Read and compress image
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);

      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Resize if too large
      img.Image processedImage = image;
      if (image.width > AppConfig.maxImageSize ||
          image.height > AppConfig.maxImageSize) {
        final ratio =
            image.width > image.height
                ? AppConfig.maxImageSize / image.width
                : AppConfig.maxImageSize / image.height;
        processedImage = img.copyResize(
          image,
          width: (image.width * ratio).toInt(),
          height: (image.height * ratio).toInt(),
        );
      }

      // Convert to JPEG
      final jpegBytes = img.encodeJpg(
        processedImage,
        quality: AppConfig.jpegQuality,
      );

      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl${AppConfig.predictEndpoint}'),
      );

      request.files.add(
        http.MultipartFile.fromBytes('file', jpegBytes, filename: 'image.jpg'),
      );

      final streamedResponse = await request.send().timeout(
        AppConfig.requestTimeout,
      );
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        print('Prediction error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Predict from file error: $e');
      return null;
    }
  }

  /// Predict from base64 encoded image
  static Future<Map<String, dynamic>?> predictFromBase64(
    String base64Image,
  ) async {
    try {
      // Remove data URL prefix if present
      String imageData = base64Image;
      if (base64Image.contains(',')) {
        imageData = base64Image.split(',')[1];
      }

      final response = await http
          .post(
            Uri.parse('$baseUrl${AppConfig.predictBase64Endpoint}'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'image': imageData}),
          )
          .timeout(AppConfig.requestTimeout);

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        print('Prediction error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Predict from base64 error: $e');
      return null;
    }
  }

  /// Convert image bytes to base64
  static String imageToBase64(List<int> imageBytes) {
    return base64Encode(imageBytes);
  }
}
