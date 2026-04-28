import 'dart:convert';
import '../../models/post_model.dart';
import '../services/post_service.dart';
import '../../core/storage/local_storage.dart';

class PostResult {
  final List<PostModel> posts;
  final bool isOnline;

  PostResult({required this.posts, required this.isOnline});
}

class PostRepository {
  final PostService postService = PostService();

  Future<PostResult> getPosts() async {
    try {
      final posts = await postService.fetchPosts();
      
      // Save to cache
      final jsonString = jsonEncode(
        posts.map((post) => post.toJson()).toList(),
      );
      await LocalStorage.saveCachedPosts(jsonString);
      
      return PostResult(posts: posts, isOnline: true);
    } catch (e) {
      // Fallback to cache if offline or error
      final cachedData = await LocalStorage.getCachedPosts();
      if (cachedData != null) {
        final List<dynamic> jsonData = jsonDecode(cachedData);
        final cachedPosts = jsonData.map((item) => PostModel.fromJson(item)).toList();
        return PostResult(posts: cachedPosts, isOnline: false);
      } else {
        rethrow;
      }
    }
  }
}
