import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nerdberg_app/components/sizes.dart';
import 'package:nerdberg_app/providers/post_provider.dart';

class PostDetailScreen extends StatelessWidget {
  final int postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<PostProvider>(
      builder: (context, provider, _) {
        final post = provider.getPostById(postId);

        if (post == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.search_off_rounded, size: 64),
                  SizedBox(height: 2.pH),
                  Text('Post not found', style: theme.textTheme.titleMedium),
                  SizedBox(height: 2.pH),
                  FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar.large(
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    'Post Details',
                    style: TextStyle(color: theme.colorScheme.onSurface),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                          theme.colorScheme.primary.withValues(alpha: 0.2),
                          theme.colorScheme.surface,
                        ],
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.article_rounded,
                        size: 80,
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        provider.isFavorite(post.id)
                            ? Icons.favorite_rounded
                            : Icons.favorite_outline_rounded,
                        key: ValueKey(provider.isFavorite(post.id)),
                        color: provider.isFavorite(post.id) ? Colors.redAccent : null,
                      ),
                    ),
                    onPressed: () => provider.toggleFavorite(post.id),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.pW, vertical: 3.pH),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: theme.colorScheme.primaryContainer,
                            child: Text(
                              '${post.userId}',
                              style: TextStyle(
                                color: theme.colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(width: 3.pW),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Author ID',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                              Text(
                                'User ${post.userId}',
                                style: theme.textTheme.titleSmall,
                              ),
                            ],
                          ),
                          const Spacer(),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 3.pW, vertical: 0.75.pH),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.tertiaryContainer,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Post #${post.id}',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.onTertiaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.pH),
                      Hero(
                        tag: 'post_title_${post.id}',
                        child: Material(
                          color: Colors.transparent,
                          child: Text(
                            post.title,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 2.pH),
                      Container(
                        height: 4,
                        width: 40,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      SizedBox(height: 3.pH),
                      Text(
                        post.body,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontSize: 18,
                          height: 1.6,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: 5.pH),
                      const Divider(),
                      SizedBox(height: 2.pH),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStat(context, Icons.remove_red_eye_outlined, '1.2k'),
                          _buildStat(context, Icons.chat_bubble_outline_rounded, '84'),
                          _buildStat(context, Icons.share_outlined, 'Share'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStat(BuildContext context, IconData icon, String label) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.outline),
        SizedBox(height: 0.5.pH),
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      ],
    );
  }
}