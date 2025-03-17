import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

class RecipeDetailPage extends StatelessWidget {
  final Map<String, dynamic> recipe;

  const RecipeDetailPage({Key? key, required this.recipe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          recipe['name'],
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.2),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 🔹 First Lottie Animation (Ingredients Count)
                  Container(
                    width: 130,
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Lottie.asset(
                          'assets/animations/ing.json',
                          fit: BoxFit.cover,
                          width: 80,
                          height: 80,
                        ),

                        SizedBox(height: 8),
                        Text(
                          '${recipe['ingredients'].length} Ingredients',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16),
                  // 🔹 Second Lottie Animation (Steps Count)
                  Container(
                    width: 130,
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Lottie.asset(
                          'assets/animations/cooking.json',
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),

                        SizedBox(height: 8),
                        Text(
                          '${recipe['steps'].length} Steps',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),

              // ✅ Ingredients Section
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Ingredients",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(
                    recipe['ingredients'].length,
                    (index) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        "• ${recipe['ingredients'][index]}", // ✅ Changed to bullet point
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // ✅ Steps Section
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Steps",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(
                    recipe['steps'].length,
                    (index) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        "• ${recipe['steps'][index]['step']}", // ✅ Changed to bullet point
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24),

              // ✅ Start Cooking Button (Floating Effect)
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    context.push('/interactive-cooking', extra: recipe);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.all(12),
                    backgroundColor: Colors.blue,
                    minimumSize: Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Start Cooking",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
