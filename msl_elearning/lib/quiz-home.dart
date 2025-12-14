import 'package:flutter/material.dart';
import 'quizzes.dart';

class QuizHomePage extends StatelessWidget {
  const QuizHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9), // Soft green background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    "Quizzes",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  IconButton(
                    icon: const Icon(Icons.menu, size: 24),
                    onPressed: () {},
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Pop Quiz Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFFFF8F0), // Warm cream
                      const Color(0xFFFFE8D6), // Soft beige
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFE8D6).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Pop Quiz!",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "Click below to start a random quiz!",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B6F47), // Warm brown
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 2,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => const QuizQuestionPage(
                                      quizType: "All",
                                      quizNumber: 1,
                                    ),
                              ),
                            );
                          },
                          child: const Text("Start Random Quiz"),
                        ),
                      ],
                    ),
                    const Icon(
                      Icons.quiz,
                      size: 50,
                      color: Color(0xFF8B6F47), // Warm brown
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // Quiz Categories Section
              const Text(
                "Quiz Categories",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 10),

              // Quiz list
              Expanded(
                child: ListView(
                  children: [
                    _buildQuizCard(
                      context,
                      const Color(0xFF1976D2), // Blue
                      "All Categories",
                      "Test your knowledge on letters, numbers, and basic words",
                      Icons.abc,
                      "All",
                    ),
                    _buildQuizCard(
                      context,
                      const Color(0xFF8B6F47), // Warm brown
                      "Letters (A-Z)",
                      "Practice with alphabet signs",
                      Icons.text_fields,
                      "Letters",
                    ),
                    _buildQuizCard(
                      context,
                      const Color(0xFF00695C), // Teal
                      "Numbers (0-9)",
                      "Test your number sign language skills",
                      Icons.numbers,
                      "Numbers",
                    ),
                    _buildQuizCard(
                      context,
                      const Color(0xFF7B1FA2), // Soft purple
                      "Basic Words",
                      "Learn common everyday words",
                      Icons.chat_bubble_outline,
                      "Basic Words",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuizCard(
    BuildContext context,
    Color color,
    String title,
    String subtitle,
    IconData icon,
    String quizType,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            blurRadius: 6,
            offset: const Offset(-1, -1),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => QuizQuestionPage(
                        quizType: quizType,
                        quizNumber:
                            quizType == "All"
                                ? 1
                                : (quizType == "Letters"
                                    ? 2
                                    : (quizType == "Numbers" ? 3 : 4)),
                      ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color.withOpacity(0.3), width: 1),
              ),
              child: Text(
                "Start",
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
