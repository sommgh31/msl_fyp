import 'package:flutter/material.dart';

class DictionaryPage extends StatefulWidget {
  const DictionaryPage({super.key});

  @override
  State<DictionaryPage> createState() => _DictionaryPageState();
}

class _DictionaryPageState extends State<DictionaryPage> {
  String selectedFilter = "Recent";
  String searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Complete dictionary list: A-Z (26), 0-9 (10), and 14 basic words
  final List<Map<String, String>> signList = [
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

  List<Map<String, String>> get filteredSignList {
    List<Map<String, String>> filtered = signList;

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      filtered =
          filtered.where((sign) {
            return sign["title"]!.toLowerCase().contains(
              searchQuery.toLowerCase(),
            );
          }).toList();
    }

    // Apply sorting filter
    if (selectedFilter == "A-Z") {
      filtered.sort((a, b) => a["title"]!.compareTo(b["title"]!));
    } else if (selectedFilter == "Category") {
      filtered.sort((a, b) {
        int categoryCompare = a["category"]!.compareTo(b["category"]!);
        if (categoryCompare != 0) return categoryCompare;
        return a["title"]!.compareTo(b["title"]!);
      });
    }

    return filtered;
  }

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
              // Top bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const Text(
                    "Sign Dictionary",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  IconButton(
                    icon: const Icon(Icons.menu, size: 24),
                    onPressed: () {},
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Search bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.blueGrey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: "Search sign...",
                          border: InputBorder.none,
                        ),
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                        },
                      ),
                    ),
                    if (searchQuery.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          setState(() {
                            searchQuery = "";
                            _searchController.clear();
                          });
                        },
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Filter row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DropdownButton<String>(
                    value: selectedFilter,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: "Recent", child: Text("Recent")),
                      DropdownMenuItem(value: "A-Z", child: Text("A-Z")),
                      DropdownMenuItem(
                        value: "Category",
                        child: Text("Category"),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedFilter = value!;
                      });
                    },
                  ),
                  Text(
                    "${filteredSignList.length} items",
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // List of dictionary items
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: filteredSignList.length,
                  itemBuilder: (context, index) {
                    final sign = filteredSignList[index];
                    return _buildSignListItem(
                      sign["title"]!,
                      sign["category"]!,
                      sign["imagePath"]!,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- UI widgets below ---

  Widget _buildSignListItem(String title, String category, String imagePath) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () {
          // Handle sign detail view or video playback
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Image container for sign language picture
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    width: 80,
                    height: 80,
                    errorBuilder: (context, error, stackTrace) {
                      // Placeholder if image not found
                      return Container(
                        color: Colors.amber.shade50,
                        child: const Icon(
                          Icons.image_outlined,
                          size: 40,
                          color: Colors.orange,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      category,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              // Arrow icon
              Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
