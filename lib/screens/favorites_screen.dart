import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nerdberg_app/components/sizes.dart';
import 'package:nerdberg_app/providers/post_provider.dart';
import 'package:nerdberg_app/screens/post_detail_screen.dart';
import 'package:nerdberg_app/screens/post_list_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Favorites',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Consumer<PostProvider>(
        builder: (context, provider, _) {
          final favorites = provider.favoritePosts;

          if (favorites.isEmpty) {
            return Center(
              child: FadeInWidget(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.favorite_border_rounded, size: 80, color: theme.colorScheme.outline.withValues(alpha: 0.3)),
                    SizedBox(height: 2.pH),
                    Text(
                      'No favorites yet',
                      style: theme.textTheme.titleMedium,
                    ),
                    SizedBox(height: 1.pH),
                    Text(
                      'Posts you like will show up here',
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 4.pW, vertical: 2.pH),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final post = favorites[index];
              return PostCard(
                post: post,
                isFavorite: true,
                onFavoriteToggle: () => provider.toggleFavorite(post.id),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PostDetailScreen(postId: post.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class FadeInWidget extends StatefulWidget {
  final Widget child;
  const FadeInWidget({super.key, required this.child});

  @override
  State<FadeInWidget> createState() => _FadeInWidgetState();
}

class _FadeInWidgetState extends State<FadeInWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(opacity: _animation, child: widget.child);
}
