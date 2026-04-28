import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/post_model.dart';

class PostService {
  final String _baseUrl = 'https://dummyjson.com';

  Future<List<PostModel>> fetchPosts() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/posts?limit=5'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonBody = jsonDecode(response.body);
      final List<dynamic> jsonList = jsonBody['posts'];
      return jsonList.map((json) => PostModel.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat dari API. Status: ${response.statusCode}');
    }
  }
}
