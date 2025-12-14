import 'package:flutter/material.dart';
import 'quiz-home.dart';
import 'quizzes.dart';

class QuizScorePage extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final int timeSpent; // in seconds
  final String quizType;
  final int quizNumber;

  const QuizScorePage({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.timeSpent,
    required this.quizType,
    required this.quizNumber,
  });

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    if (minutes > 0) {
      return "$minutes:${secs.toString().padLeft(2, '0')} minutes";
    }
    return "$secs seconds";
  }

  String _getScoreMessage() {
    final percentage = (score / totalQuestions * 100).round();
    if (percentage >= 90) {
      return "Excellent!";
    } else if (percentage >= 70) {
      return "Good Job!";
    } else if (percentage >= 50) {
      return "Not Bad!";
    } else {
      return "Keep Practicing!";
    }
  }

  Color _getScoreColor() {
    final percentage = (score / totalQuestions * 100).round();
    if (percentage >= 90) {
      return Colors.green;
    } else if (percentage >= 70) {
      return Colors.blue;
    } else if (percentage >= 50) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  IconData _getScoreIcon() {
    final percentage = (score / totalQuestions * 100).round();
    if (percentage >= 90) {
      return Icons.emoji_events;
    } else if (percentage >= 70) {
      return Icons.check_circle;
    } else if (percentage >= 50) {
      return Icons.thumb_up;
    } else {
      return Icons.school;
    }
  }

  @override
  Widget build(BuildContext context) {
    final percentage = (score / totalQuestions * 100).round();
    final scoreColor = _getScoreColor();
    final scoreIcon = _getScoreIcon();
    final scoreMessage = _getScoreMessage();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              // Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    "Quiz $quizNumber - $quizType",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.menu, size: 24),
                    onPressed: () {},
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Score Icon
              Icon(scoreIcon, color: scoreColor, size: 90),

              const SizedBox(height: 20),

              // Score Message
              Text(
                scoreMessage,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: scoreColor,
                ),
              ),

              const SizedBox(height: 10),

              // Score Percentage
              Text(
                "$score / $totalQuestions",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: scoreColor,
                ),
              ),

              Text(
                "${percentage}% Correct",
                style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
              ),

              const SizedBox(height: 30),

              // Score cards
              _buildScoreTile(
                Icons.timer_outlined,
                "Time",
                _formatTime(timeSpent),
              ),
              _buildScoreTile(
                Icons.emoji_events_outlined,
                "Accuracy",
                "$percentage%",
              ),
              _buildScoreTile(
                Icons.verified_outlined,
                "Correct Answers",
                "$score out of $totalQuestions",
              ),

              const Spacer(),

              // Buttons
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => QuizQuestionPage(
                            quizType: quizType,
                            quizNumber: quizNumber,
                          ),
                    ),
                  );
                },
                child: const Text("Try Again"),
              ),

              const SizedBox(height: 12),

              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.blue.shade600),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const QuizHomePage(),
                    ),
                    (route) => false,
                  );
                },
                child: Text(
                  "Back to Quizzes",
                  style: TextStyle(color: Colors.blue.shade600),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreTile(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
