import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:nerdberg_app/models/post.dart';

class PostRepository {
  static const String _apiUrl = 'https://jsonplaceholder.typicode.com/posts';
  static const String _localAsset = 'assets/data/posts.json';

  /// Fetches posts from the remote API.
  /// Falls back to local JSON asset on failure.
  Future<List<Post>> fetchPosts() async {
    try {
      final response = await http
          .get(Uri.parse(_apiUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return _parsePosts(response.body);
      }
      throw Exception('Failed to load posts: ${response.statusCode}');
    } catch (_) {
      return _loadLocalPosts();
    }
  }

  Future<List<Post>> _loadLocalPosts() async {
    final jsonString = await rootBundle.loadString(_localAsset);
    return _parsePosts(jsonString);
  }

  List<Post> _parsePosts(String jsonString) {
    final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
    return jsonList
        .map((json) => Post.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}