import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9), // Soft green background
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar with greeting
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Welcome back!",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Let's continue learning",
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.menu, size: 28),
                    onPressed: () {},
                    color: Colors.black87,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Profile Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade50, Colors.blue.shade100],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.shade100.withOpacity(0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person_outline,
                        size: 40,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Username",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Keep exploring new signs!",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Learning Modules Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Learning Modules",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      letterSpacing: 0.5,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      "View All",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Module Cards Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 0.95,
                children: [
                  _buildModuleCard(
                    context,
                    title: "Quizzes",
                    subtitle: "Test your knowledge",
                    icon: Icons.quiz_outlined,
                    gradientColors: [
                      const Color(0xFFFFF8F0), // Warm cream
                      const Color(0xFFFFE8D6), // Soft beige
                    ],
                    iconColor: const Color(0xFF8B6F47), // Warm brown
                    iconBgColor: const Color(0xFFFFF8F0),
                    onTap: () {
                      Navigator.pushNamed(context, '/quizHome');
                    },
                  ),
                  _buildModuleCard(
                    context,
                    title: "Dictionary",
                    subtitle: "Browse all signs",
                    icon: Icons.menu_book_outlined,
                    gradientColors: [
                      const Color(0xFFE3F2FD), // Soft blue
                      const Color(0xFFBBDEFB), // Light blue
                    ],
                    iconColor: const Color(0xFF1976D2), // Blue
                    iconBgColor: const Color(0xFFE3F2FD),
                    onTap: () {
                      Navigator.pushNamed(context, '/dictionary');
                    },
                  ),
                  _buildModuleCard(
                    context,
                    title: "Real-time",
                    subtitle: "Live recognition",
                    icon: Icons.camera_alt_outlined,
                    gradientColors: [
                      const Color(0xFFE0F2F1), // Soft mint
                      const Color(0xFFB2DFDB), // Light teal
                    ],
                    iconColor: const Color(0xFF00695C), // Teal
                    iconBgColor: const Color(0xFFE0F2F1),
                    onTap: () {
                      Navigator.pushNamed(context, '/camera');
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // Enhanced module card widget with better design
  Widget _buildModuleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradientColors,
    required Color iconColor,
    required Color iconBgColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: gradientColors[1].withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 6),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.8),
                blurRadius: 10,
                offset: const Offset(-2, -2),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: iconColor.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(icon, size: 36, color: iconColor),
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
