import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Register with email and password
  Future<Map<String, dynamic>> registerWithEmailPassword({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      // Create user account
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Update display name
      await userCredential.user?.updateDisplayName(username);

      // Create user document in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'username': username,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'totalQuizzes': 0,
        'totalScore': 0,
        'averageScore': 0.0,
      });

      return {'success': true, 'user': userCredential.user};
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'error': _getErrorMessage(e)};
    } catch (e) {
      return {'success': false, 'error': 'An unexpected error occurred'};
    }
  }

  // Sign in with email and password
  Future<Map<String, dynamic>> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return {'success': true, 'user': userCredential.user};
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'error': _getErrorMessage(e)};
    } catch (e) {
      return {'success': false, 'error': 'An unexpected error occurred'};
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get user data
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Save quiz result
  Future<bool> saveQuizResult({
    required String quizType,
    required int score,
    required int totalQuestions,
    required int timeSpent,
  }) async {
    try {
      final user = currentUser;
      if (user == null) return false;

      final percentage = (score / totalQuestions * 100).round();

      // Add quiz result to subcollection
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('quiz_history')
          .add({
            'quizType': quizType,
            'score': score,
            'totalQuestions': totalQuestions,
            'percentage': percentage,
            'timeSpent': timeSpent,
            'completedAt': FieldValue.serverTimestamp(),
          });

      // Update user stats
      final userDoc = _firestore.collection('users').doc(user.uid);
      final userData = await getUserData(user.uid);

      if (userData != null) {
        final totalQuizzes = (userData['totalQuizzes'] ?? 0) + 1;
        final totalScore = (userData['totalScore'] ?? 0) + percentage;
        final averageScore = totalScore / totalQuizzes;

        await userDoc.update({
          'totalQuizzes': totalQuizzes,
          'totalScore': totalScore,
          'averageScore': averageScore,
          'lastQuizDate': FieldValue.serverTimestamp(),
        });
      }

      return true;
    } catch (e) {
      print('Error saving quiz result: $e');
      return false;
    }
  }

  // Get quiz history
  Stream<QuerySnapshot> getQuizHistory(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('quiz_history')
        .orderBy('completedAt', descending: true)
        .limit(50)
        .snapshots();
  }

  // Get user statistics
  Future<Map<String, dynamic>?> getUserStats(String uid) async {
    try {
      final userData = await getUserData(uid);
      if (userData == null) return null;

      // Get quiz history count by type
      final quizHistorySnapshot =
          await _firestore
              .collection('users')
              .doc(uid)
              .collection('quiz_history')
              .get();

      Map<String, int> quizzesByType = {};
      for (var doc in quizHistorySnapshot.docs) {
        final type = doc['quizType'] as String;
        quizzesByType[type] = (quizzesByType[type] ?? 0) + 1;
      }

      return {
        'username': userData['username'] ?? 'User',
        'email': userData['email'] ?? '',
        'totalQuizzes': userData['totalQuizzes'] ?? 0,
        'averageScore': (userData['averageScore'] ?? 0.0).toDouble(),
        'quizzesByType': quizzesByType,
        'lastQuizDate': userData['lastQuizDate'],
      };
    } catch (e) {
      print('Error getting user stats: $e');
      return null;
    }
  }

  // Reset password
  Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return {'success': true};
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'error': _getErrorMessage(e)};
    }
  }

  // Helper method to get user-friendly error messages
  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password is too weak';
      case 'email-already-in-use':
        return 'An account already exists for this email';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled';
      default:
        return e.message ?? 'An error occurred';
    }
  }
}
