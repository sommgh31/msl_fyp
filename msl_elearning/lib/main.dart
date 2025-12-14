import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

// Import your pages
import 'homepage.dart';
import 'dictionary.dart';
import 'quiz-home.dart';
import 'screens/realtime_camera.dart';

// To hold camera reference globally
List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Malaysian Sign Language E-learning',
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: Colors.blue,
          secondary: Colors.blue.shade300,
          surface: Colors.white,
          background: const Color(0xFFE8F5E9),
          error: Colors.red.shade400,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.black87,
          onBackground: Colors.black87,
          onError: Colors.white,
        ),
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      home: const HomePage(),
      routes: {
        '/home': (context) => const HomePage(),
        '/dictionary': (context) => const DictionaryPage(),
        '/quizHome': (context) => const QuizHomePage(),
        '/camera': (context) => const RealTimeCamera(),
      },
    );
  }
}
