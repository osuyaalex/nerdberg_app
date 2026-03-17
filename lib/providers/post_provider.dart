import 'package:flutter/foundation.dart';
import 'package:nerdberg_app/data/post_repository.dart';
import 'package:nerdberg_app/models/post.dart';

enum PostStatus { initial, loading, loaded, error }

class PostProvider extends ChangeNotifier {
  final PostRepository _repository;

  PostProvider({PostRepository? repository})
      : _repository = repository ?? PostRepository();

  List<Post> _posts = [];
  final Set<int> _favoriteIds = {};
  PostStatus _status = PostStatus.initial;
  String _errorMessage = '';

  List<Post> get posts => _posts;
  PostStatus get status => _status;
  String get errorMessage => _errorMessage;

  List<Post> get favoritePosts =>
      _posts.where((post) => _favoriteIds.contains(post.id)).toList();

  bool isFavorite(int postId) => _favoriteIds.contains(postId);

  Future<void> loadPosts() async {
    _status = PostStatus.loading;
    notifyListeners();

    try {
      _posts = await _repository.fetchPosts();
      _status = PostStatus.loaded;
    } catch (e) {
      _status = PostStatus.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  void toggleFavorite(int postId) {
    if (_favoriteIds.contains(postId)) {
      _favoriteIds.remove(postId);
    } else {
      _favoriteIds.add(postId);
    }
    notifyListeners();
  }

  Post? getPostById(int id) {
    try {
      return _posts.firstWhere((post) => post.id == id);
    } catch (_) {
      return null;
    }
  }
}