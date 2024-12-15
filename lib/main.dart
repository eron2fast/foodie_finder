import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;  // Import http package
import 'dart:convert';  // Import dart:convert for jsonDecode
import 'package:foodie_finder/screens/recipe_details_screen.dart';
import 'package:foodie_finder/screens/saved_recipes_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const RecipeSearchScreen(),
      theme: ThemeData(primarySwatch: Colors.green),
    );
  }
}

class RecipeSearchScreen extends StatefulWidget {
  const RecipeSearchScreen({Key? key}) : super(key: key);

  @override
  _RecipeSearchScreenState createState() => _RecipeSearchScreenState();
}

class _RecipeSearchScreenState extends State<RecipeSearchScreen> {
  TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;

  // Search for recipes based on ingredient
  Future<void> _searchRecipes(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    final String apiKey = "e5cbb773c340499fa20df04fea1d0145"; // Replace with your actual API key
    final String baseUrl = "https://api.spoonacular.com";
    final url = Uri.parse("$baseUrl/recipes/complexSearch?query=$query&apiKey=$apiKey");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _searchResults = List<Map<String, dynamic>>.from(data['results']);
        });
      } else {
        throw Exception('Failed to load recipes');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching recipes')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Foodie Finder'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: Icon(Icons.bookmark),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SavedRecipesScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Search Ingredients',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (query) {
                _searchRecipes(query);
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Recipe Results', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final recipe = _searchResults[index];
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
          ),
        ],
      ),
    );
  }
}
