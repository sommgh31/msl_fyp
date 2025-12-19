import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Import your pages
import 'homepage.dart';
import 'dictionary.dart';
import 'quiz-home.dart';
import 'camera_page.dart';
import 'auth/login_page.dart';

// To hold camera reference globally
List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize cameras
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
      home: const AuthWrapper(),
      routes: {
        '/home': (context) => const HomePage(),
        '/dictionary': (context) => const DictionaryPage(),
        '/quizHome': (context) => const QuizHomePage(),
        '/camera': (context) => const CameraPage(),
        '/login': (context) => const LoginPage(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFFE8F5E9),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF00695C)),
            ),
          );
        }

        // Show login page if not authenticated
        if (!snapshot.hasData) {
          return const LoginPage();
        }

        // Show home page if authenticated
        return const HomePage();
      },
    );
  }
}
