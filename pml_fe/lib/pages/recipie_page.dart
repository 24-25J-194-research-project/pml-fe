import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/api_service.dart';

class RecipePage extends StatefulWidget {
  @override
  _RecipePageState createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  List<dynamic> _recipes = [];

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
      await ApiService.createRecipe("user1", name);
      _loadRecipes(); // Refresh after adding
    }
  }

  Future<String?> _getRecipeName() async {
    String? name;
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("New Recipe"),
            content: TextField(
              onChanged: (value) => name = value,
              decoration: InputDecoration(hintText: "Recipe name"),
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context, name),
                child: Text("Save"),
              ),
            ],
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
        title: Text("Recipes"),
        actions: [IconButton(icon: Icon(Icons.add), onPressed: _addRecipe)],
      ),
      body: ListView.builder(
        itemCount: _recipes.length,
        itemBuilder: (context, index) {
          final recipe = _recipes[index];
          return Dismissible(
            key: Key(recipe['_id']),
            onDismissed: (direction) => _deleteRecipe(recipe['_id']),
            background: Container(color: Colors.red),
            child: ListTile(
              title: Text(recipe['name']),
              onTap: () {
                // ✅ Pass recipe data and navigate to details page
                context.push('/recipe-details', extra: recipe);
              },
            ),
          );
        },
      ),
    );
  }
}
