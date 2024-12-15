import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:foodie_finder/screens/recipe_details_screen.dart';

class SavedRecipesScreen extends StatefulWidget {
  @override
  _SavedRecipesScreenState createState() => _SavedRecipesScreenState();
}

class _SavedRecipesScreenState extends State<SavedRecipesScreen> {
  List<Map<String, dynamic>> _savedRecipes = [];

  // Load saved recipes from SharedPreferences
  Future<void> _loadSavedRecipes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedRecipeKeys = prefs.getKeys().where((key) => key.startsWith('savedRecipe_')).toList();

    List<Map<String, dynamic>> savedRecipes = [];

    for (String key in savedRecipeKeys) {
      final savedRecipe = prefs.getString(key);
      if (savedRecipe != null) {
        savedRecipes.add(jsonDecode(savedRecipe));
      }
    }

    setState(() {
      _savedRecipes = savedRecipes;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadSavedRecipes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Saved Recipes"),
        backgroundColor: Colors.deepOrange,
      ),
      body: _savedRecipes.isEmpty
          ? Center(child: Text("No saved recipes"))
          : ListView.builder(
        itemCount: _savedRecipes.length,
        itemBuilder: (context, index) {
          final recipe = _savedRecipes[index];
          return ListTile(
            title: Text(recipe['title']),
            subtitle: Text(recipe['sourceName'] ?? 'Source not available'),
            leading: Image.network(
              recipe['image'],
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RecipeDetailsScreen(
                    recipeId: recipe['id'],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
