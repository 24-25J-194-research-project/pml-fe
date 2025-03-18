import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';

class RecipePage extends StatefulWidget {
  @override
  _RecipePageState createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  List<dynamic> _recipes = [];
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  void _loadRecipes() async {
    try {
      final recipes = await ApiService.getRecipes("user1");
      setState(() {
        _recipes = recipes;
      });
    } catch (e) {
      print("Error loading recipes: $e");
    }
  }

  void _addRecipe() async {
    String? name = await _getRecipeName();
    if (name != null && name.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Generating recipe... Please wait."),
          duration: Duration(seconds: 3),
        ),
      );
      await ApiService.createRecipe("user1", name);
      _loadRecipes(); // Refresh after adding
      _notificationService.showRecipeGeneratedNotification();
      // _notificationService.playRecipeGeneratedSound();
    }
  }

  // Future<String?> _getRecipeName() async {
  //   String? name;
  //   await showDialog(
  //     context: context,
  //     builder:
  //         (context) => AlertDialog(
  //           title: Text("New Recipe"),
  //           content: TextField(
  //             onChanged: (value) => name = value,
  //             decoration: InputDecoration(hintText: "Recipe name"),
  //           ),
  //           actions: [
  //             ElevatedButton(
  //               onPressed: () => Navigator.pop(context, name),
  //               child: Text("Save"),
  //             ),
  //           ],
  //         ),
  //   );
  //   return name;
  // }

  Future<String?> _getRecipeName() async {
    String? name;
    await showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ✅ Title
                  Text(
                    "Add a New Recipe",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 12),

                  // ✅ Lottie Animation
                  SizedBox(
                    height: 300,
                    width: 300,
                    child: Lottie.asset(
                      'assets/animations/addNewRec.json',
                      fit: BoxFit.cover,
                    ),
                  ),
                  // SizedBox(height: 10),

                  // ✅ Input Field
                  TextField(
                    onChanged: (value) => name = value,
                    decoration: InputDecoration(
                      hintText: "What you want to eat today?",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                    ),
                  ),
                  SizedBox(height: 30),

                  // ✅ Generate Button
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, name),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 24,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Generate Recipe",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
    return name;
  }

  void _deleteRecipe(String id) async {
    await ApiService.deleteRecipe(id);
    _loadRecipes(); // Refresh after delete
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Recipes", style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),

      body:
          _recipes.isEmpty
              ? Center(child: Text("No recipes found."))
              : ListView.builder(
                itemCount: _recipes.length,
                itemBuilder: (context, index) {
                  final recipe = _recipes[index];
                  return Dismissible(
                    key: Key(recipe['_id']),
                    onDismissed: (direction) => _deleteRecipe(recipe['_id']),
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 20),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    child: Container(
                      margin: EdgeInsets.symmetric(
                        vertical: 4, // ✅ Reduced vertical padding
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4, // ✅ Softer shadow
                            spreadRadius:
                                1, // ✅ Slight spread for a mellow feel
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 16,
                        ), // ✅ Reduced padding
                        title: Text(
                          recipe['name'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight
                                    .w500, // ✅ Slightly more weight for better readability
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteRecipe(recipe['_id']),
                        ),
                        onTap: () {
                          context.push('/recipe-details', extra: recipe);
                        },
                      ),
                    ),
                  );
                },
              ),

      // ✅ Floating button to add new recipes
      floatingActionButton: FloatingActionButton(
        onPressed: _addRecipe,
        backgroundColor: Colors.blue,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
