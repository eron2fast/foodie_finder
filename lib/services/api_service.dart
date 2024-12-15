import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String _baseUrl = "https://api.spoonacular.com";
  final String _apiKey = "e5cbb773c340499fa20df04fea1d0145";

  Future<List<dynamic>> fetchRecipes(String ingredients) async {
    final url = Uri.parse(
        "$_baseUrl/recipes/findByIngredients?ingredients=$ingredients&number=10&apiKey=$_apiKey");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load recipes');
    }
  }
}
