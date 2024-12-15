import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecipeDetailsScreen extends StatefulWidget {
  final int recipeId;

  const RecipeDetailsScreen({required this.recipeId});

  @override
  _RecipeDetailsScreenState createState() => _RecipeDetailsScreenState();
}

class _RecipeDetailsScreenState extends State<RecipeDetailsScreen> {
  late Map<String, dynamic> _recipe;
  bool _isSaved = false;

  // Fetch recipe details from Spoonacular API
  Future<Map<String, dynamic>> fetchRecipeDetails() async {
    final String apiKey = "e5cbb773c340499fa20df04fea1d0145"; // Use your valid API key
    final String baseUrl = "https://api.spoonacular.com";
    final url = Uri.parse("$baseUrl/recipes/${widget.recipeId}/information?apiKey=$apiKey");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load recipe details');
    }
  }

  // Save the recipe to SharedPreferences
  Future<void> _saveRecipe() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Check if the recipe is already saved
    if (_isSaved) {
      prefs.remove('savedRecipe_${widget.recipeId}');
    } else {
      prefs.setString('savedRecipe_${widget.recipeId}', jsonEncode(_recipe));
    }

    setState(() {
      _isSaved = !_isSaved;
    });
  }

  @override
  void initState() {
    super.initState();

    // Load saved state (whether the recipe is saved or not)
    _loadSavedState();
  }

  // Load saved state (whether the recipe is saved or not)
  Future<void> _loadSavedState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final savedRecipe = prefs.getString('savedRecipe_${widget.recipeId}');

    if (savedRecipe != null) {
      setState(() {
        _isSaved = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Recipe Details"),
        backgroundColor: Colors.deepOrange,
        actions: [
          IconButton(
            icon: Icon(_isSaved ? Icons.favorite : Icons.favorite_border),
            onPressed: _saveRecipe,
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchRecipeDetails(),
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          // Error state
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          // No data state
          if (!snapshot.hasData) {
            return Center(child: Text("No data available"));
          }

          _recipe = snapshot.data!;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(_recipe['image']),
                  SizedBox(height: 16),
                  Text(
                    _recipe['title'],
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Text("Ingredients", style: TextStyle(fontSize: 20)),
                  SizedBox(height: 8),
                  // Display ingredients in a bulleted list format
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: _recipe['extendedIngredients'].length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          "• ${_recipe['extendedIngredients'][index]['original']}",
                          style: TextStyle(fontSize: 16),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 16),
                  Text("Instructions", style: TextStyle(fontSize: 20)),
                  SizedBox(height: 8),
                  // Display instructions as HTML using flutter_widget_from_html
                  _recipe['instructions'] != null
                      ? HtmlWidget(
                    _recipe['instructions'],
                    textStyle: TextStyle(fontSize: 16),
                  )
                      : Text("No instructions available."),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
