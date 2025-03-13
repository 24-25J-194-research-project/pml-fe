import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RecipeDetailPage extends StatelessWidget {
  final Map<String, dynamic> recipe;

  const RecipeDetailPage({Key? key, required this.recipe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(recipe['name'])),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Display Ingredients
              Text(
                "Ingredients:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 8),
              ...recipe['ingredients']
                  .map<Widget>((ingredient) => Text(ingredient))
                  .toList(),
              SizedBox(height: 16),

              // ✅ Display Steps
              Text(
                "Steps:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 8),
              ...recipe['steps']
                  .map<Widget>((step) => Text(step['step']))
                  .toList(),
              SizedBox(height: 32),

              // ✅ Get Started Button
              ElevatedButton(
                onPressed: () {
                  context.push('/interactive-cooking', extra: recipe);
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(12),
                  backgroundColor: Colors.blue,
                ),
                child: Text(
                  "Get Started",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
