import 'package:flutter/material.dart';
import 'quizscore.dart';

class QuizQuestionPage extends StatefulWidget {
  final String quizType; // "All", "Letters", "Numbers", "Basic Words"
  final int quizNumber;

  const QuizQuestionPage({
    super.key,
    this.quizType = "All",
    this.quizNumber = 1,
  });

  @override
  State<QuizQuestionPage> createState() => _QuizQuestionPageState();
}

class _QuizQuestionPageState extends State<QuizQuestionPage> {
  int currentQuestionIndex = 0;
  int selectedIndex = -1;
  int score = 0;
  int startTime = 0;
  List<Map<String, dynamic>> questions = [];
  List<int> userAnswers = [];

  @override
  void initState() {
    super.initState();
    startTime = DateTime.now().millisecondsSinceEpoch;
    _generateQuestions();
  }

  void _generateQuestions() {
    // Get all dictionary entries
    final allEntries = _DictionaryPageState().signList;

    // Filter by quiz type
    List<Map<String, String>> filteredEntries = allEntries;
    if (widget.quizType == "Letters") {
      filteredEntries =
          allEntries.where((e) => e["category"] == "Letter").toList();
    } else if (widget.quizType == "Numbers") {
      filteredEntries =
          allEntries.where((e) => e["category"] == "Number").toList();
    } else if (widget.quizType == "Basic Words") {
      filteredEntries =
          allEntries.where((e) => e["category"] == "Basic Word").toList();
    }

    // Shuffle and take 10 questions
    filteredEntries.shuffle();
    final questionEntries = filteredEntries.take(10).toList();

    // Generate questions with multiple choice options
    for (var entry in questionEntries) {
      final correctAnswer = entry["title"]!;
      final category = entry["category"]!;

      // Get wrong answers from the same category
      final wrongAnswers =
          filteredEntries
              .where(
                (e) => e["title"] != correctAnswer && e["category"] == category,
              )
              .map((e) => e["title"]!)
              .toList()
            ..shuffle();

      final options = [
        correctAnswer,
        wrongAnswers[0],
        wrongAnswers.length > 1 ? wrongAnswers[1] : wrongAnswers[0],
        wrongAnswers.length > 2 ? wrongAnswers[2] : wrongAnswers[0],
      ]..shuffle();

      final correctIndex = options.indexOf(correctAnswer);

      questions.add({
        "imagePath": entry["imagePath"]!,
        "title": entry["title"]!,
        "options": options,
        "correctIndex": correctIndex,
        "category": category,
      });
    }

    userAnswers = List.filled(questions.length, -1);
  }

  void _checkAnswer() {
    if (selectedIndex == -1) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select an answer")));
      return;
    }

    setState(() {
      userAnswers[currentQuestionIndex] = selectedIndex;
      if (selectedIndex == questions[currentQuestionIndex]["correctIndex"]) {
        score++;
      }
    });

    // Move to next question or show results
    Future.delayed(const Duration(milliseconds: 500), () {
      if (currentQuestionIndex < questions.length - 1) {
        setState(() {
          currentQuestionIndex++;
          selectedIndex =
              userAnswers[currentQuestionIndex] != -1
                  ? userAnswers[currentQuestionIndex]
                  : -1;
        });
      } else {
        // Quiz completed
        final endTime = DateTime.now().millisecondsSinceEpoch;
        final timeSpent = ((endTime - startTime) / 1000).round();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => QuizScorePage(
                  score: score,
                  totalQuestions: questions.length,
                  timeSpent: timeSpent,
                  quizType: widget.quizType,
                  quizNumber: widget.quizNumber,
                ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final currentQuestion = questions[currentQuestionIndex];
    final progress = (currentQuestionIndex + 1) / questions.length;

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
                  Text(
                    "Quiz ${widget.quizNumber} - ${widget.quizType}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "${currentQuestionIndex + 1}/${questions.length}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Progress Bar
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade300,
                color: const Color(0xFF8B6F47), // Warm brown
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),

              const SizedBox(height: 20),

              // Image
              Container(
                width: double.infinity,
                height: 250,
                padding: const EdgeInsets.all(10),
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
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    currentQuestion["imagePath"],
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.amber.shade50,
                        child: const Icon(
                          Icons.image_outlined,
                          size: 80,
                          color: Colors.orange,
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Center(
                child: Text(
                  "Choose your answer",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),

              const SizedBox(height: 16),

              // Answers
              Expanded(
                child: ListView(
                  children: [
                    for (int i = 0; i < currentQuestion["options"].length; i++)
                      _buildAnswerButton(
                        currentQuestion["options"][i],
                        i,
                        currentQuestion["correctIndex"],
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Check Button
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B6F47), // Warm brown
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    shadowColor: const Color(0xFF8B6F47).withOpacity(0.4),
                  ),
                  onPressed: _checkAnswer,
                  child: Text(
                    currentQuestionIndex == questions.length - 1
                        ? "Finish Quiz"
                        : "Next Question",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerButton(String text, int index, int correctIndex) {
    final bool isSelected = selectedIndex == index;
    final bool isAnswered = userAnswers[currentQuestionIndex] != -1;
    final bool isCorrect = index == correctIndex;
    final bool showResult = isAnswered && isSelected;

    Color? backgroundColor;
    Color? borderColor;
    Color? textColor;

    if (isAnswered) {
      if (isCorrect) {
        backgroundColor = const Color(0xFFC8E6C9);
        borderColor = const Color(0xFF81C784);
        textColor = const Color(0xFF2E7D32);
      } else if (isSelected && !isCorrect) {
        backgroundColor = const Color(0xFFFFCDD2);
        borderColor = const Color(0xFFE57373);
        textColor = const Color(0xFFC62828);
      } else {
        backgroundColor = Colors.white;
        borderColor = Colors.grey.shade300;
        textColor = Colors.black87;
      }
    } else {
      backgroundColor = isSelected ? Colors.red.shade50 : Colors.white;
      borderColor = isSelected ? Colors.red.shade300 : Colors.grey.shade300;
      textColor = isSelected ? Colors.red.shade600 : Colors.black87;
    }

    return GestureDetector(
      onTap:
          isAnswered
              ? null
              : () {
                setState(() {
                  selectedIndex = index;
                });
              },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            if (showResult)
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color:
                    isCorrect
                        ? const Color(0xFF66BB6A)
                        : const Color(0xFFE57373),
                size: 20,
              )
            else if (isSelected)
              Icon(
                Icons.radio_button_checked,
                color: Colors.red.shade400,
                size: 20,
              )
            else
              Icon(
                Icons.radio_button_unchecked,
                color: Colors.grey.shade400,
                size: 20,
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15,
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper class to access dictionary data
class _DictionaryPageState {
  List<Map<String, String>> get signList {
    return [
      // A-Z Letters
      {"title": "A", "category": "Letter", "imagePath": "assets/images/A.png"},
      {"title": "B", "category": "Letter", "imagePath": "assets/images/B.png"},
      {"title": "C", "category": "Letter", "imagePath": "assets/images/C.png"},
      {"title": "D", "category": "Letter", "imagePath": "assets/images/D.png"},
      {"title": "E", "category": "Letter", "imagePath": "assets/images/E.png"},
      {"title": "F", "category": "Letter", "imagePath": "assets/images/F.png"},
      {"title": "G", "category": "Letter", "imagePath": "assets/images/G.png"},
      {"title": "H", "category": "Letter", "imagePath": "assets/images/H.png"},
      {"title": "I", "category": "Letter", "imagePath": "assets/images/I.png"},
      {"title": "J", "category": "Letter", "imagePath": "assets/images/J.png"},
      {"title": "K", "category": "Letter", "imagePath": "assets/images/K.png"},
      {"title": "L", "category": "Letter", "imagePath": "assets/images/L.png"},
      {"title": "M", "category": "Letter", "imagePath": "assets/images/M.png"},
      {"title": "N", "category": "Letter", "imagePath": "assets/images/N.png"},
      {"title": "O", "category": "Letter", "imagePath": "assets/images/O.png"},
      {"title": "P", "category": "Letter", "imagePath": "assets/images/P.png"},
      {"title": "Q", "category": "Letter", "imagePath": "assets/images/Q.png"},
      {"title": "R", "category": "Letter", "imagePath": "assets/images/R.png"},
      {"title": "S", "category": "Letter", "imagePath": "assets/images/S.png"},
      {"title": "T", "category": "Letter", "imagePath": "assets/images/T.png"},
      {"title": "U", "category": "Letter", "imagePath": "assets/images/U.png"},
      {"title": "V", "category": "Letter", "imagePath": "assets/images/V.png"},
      {"title": "W", "category": "Letter", "imagePath": "assets/images/W.png"},
      {"title": "X", "category": "Letter", "imagePath": "assets/images/X.png"},
      {"title": "Y", "category": "Letter", "imagePath": "assets/images/Y.png"},
      {"title": "Z", "category": "Letter", "imagePath": "assets/images/Z.png"},
      // 0-9 Numbers
      {"title": "0", "category": "Number", "imagePath": "assets/images/0.png"},
      {"title": "1", "category": "Number", "imagePath": "assets/images/1.png"},
      {"title": "2", "category": "Number", "imagePath": "assets/images/2.png"},
      {"title": "3", "category": "Number", "imagePath": "assets/images/3.png"},
      {"title": "4", "category": "Number", "imagePath": "assets/images/4.png"},
      {"title": "5", "category": "Number", "imagePath": "assets/images/5.png"},
      {"title": "6", "category": "Number", "imagePath": "assets/images/6.png"},
      {"title": "7", "category": "Number", "imagePath": "assets/images/7.png"},
      {"title": "8", "category": "Number", "imagePath": "assets/images/8.png"},
      {"title": "9", "category": "Number", "imagePath": "assets/images/9.png"},
      // 14 Basic Words
      {
        "title": "Air",
        "category": "Basic Word",
        "imagePath": "assets/images/air.png",
      },
      {
        "title": "Demam",
        "category": "Basic Word",
        "imagePath": "assets/images/demam.png",
      },
      {
        "title": "Dengar",
        "category": "Basic Word",
        "imagePath": "assets/images/dengar.png",
      },
      {
        "title": "Senyap",
        "category": "Basic Word",
        "imagePath": "assets/images/senyap.png",
      },
      {
        "title": "Tidur",
        "category": "Basic Word",
        "imagePath": "assets/images/tidur.png",
      },
      {
        "title": "Masa",
        "category": "Basic Word",
        "imagePath": "assets/images/masa.png",
      },
      {
        "title": "Awak",
        "category": "Basic Word",
        "imagePath": "assets/images/awak.png",
      },
      {
        "title": "Maaf",
        "category": "Basic Word",
        "imagePath": "assets/images/maaf.png",
      },
      {
        "title": "Tolong",
        "category": "Basic Word",
        "imagePath": "assets/images/tolong.png",
      },
      {
        "title": "Makan",
        "category": "Basic Word",
        "imagePath": "assets/images/makan.png",
      },
      {
        "title": "Minum",
        "category": "Basic Word",
        "imagePath": "assets/images/minum.png",
      },
      {
        "title": "Salah",
        "category": "Basic Word",
        "imagePath": "assets/images/salah.png",
      },
      {
        "title": "Saya",
        "category": "Basic Word",
        "imagePath": "assets/images/saya.png",
      },
      {
        "title": "Sayang Awak",
        "category": "Basic Word",
        "imagePath": "assets/images/sayang_awak.png",
      },
    ];
  }
}
