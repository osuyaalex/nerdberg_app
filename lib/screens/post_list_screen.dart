import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nerdberg_app/components/sizes.dart';
import 'package:nerdberg_app/providers/post_provider.dart';
import 'package:nerdberg_app/screens/favorites_screen.dart';
import 'package:nerdberg_app/screens/post_detail_screen.dart';

class PostListScreen extends StatelessWidget {
  const PostListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.3],
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.05),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar.large(
              expandedHeight: 180,
              backgroundColor: Colors.transparent,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: EdgeInsets.only(left: 6.pW, bottom: 2.pH),
                title: Text(
                  'Nerdberg Posts',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                  ),
                ),
                background: Stack(
                  children: [
                    Positioned(
                      right: -20,
                      top: -20,
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        size: 150,
                        color: theme.colorScheme.primary.withValues(alpha: 0.05),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                Consumer<PostProvider>(
                  builder: (context, provider, _) {
                    final hasFavorites = provider.favoritePosts.isNotEmpty;
                    return Container(
                      margin: EdgeInsets.only(right: 4.pW),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, animation) =>
                              ScaleTransition(scale: animation, child: child),
                          child: Icon(
                            hasFavorites
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            key: ValueKey(hasFavorites),
                            color: hasFavorites ? Colors.redAccent : Colors.grey,
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (_, __, ___) => const FavoritesScreen(),
                              transitionsBuilder: (_, anim, __, child) {
                                return FadeTransition(opacity: anim, child: child);
                              },
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
            Consumer<PostProvider>(
              builder: (context, provider, _) {
                switch (provider.status) {
                  case PostStatus.initial:
                  case PostStatus.loading:
                    return const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator.adaptive()),
                    );
                  case PostStatus.error:
                    return SliverFillRemaining(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.pW),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.error_outline_rounded, 
                                   size: 64, color: theme.colorScheme.error),
                              SizedBox(height: 2.pH),
                              Text(
                                'Oops! Something went wrong',
                                style: theme.textTheme.titleLarge,
                              ),
                              SizedBox(height: 1.pH),
                              Text(
                                provider.errorMessage,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium,
                              ),
                              SizedBox(height: 3.pH),
                              FilledButton.icon(
                                onPressed: () => provider.loadPosts(),
                                icon: const Icon(Icons.refresh_rounded),
                                label: const Text('Try Again'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  case PostStatus.loaded:
                    return SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: 4.pW, vertical: 2.pH),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final post = provider.posts[index];
                            return _AnimatedPostCard(
                              index: index,
                              post: post,
                              isFavorite: provider.isFavorite(post.id),
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
                          childCount: provider.posts.length,
                        ),
                      ),
                    );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedPostCard extends StatefulWidget {
  final int index;
  final dynamic post;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onTap;

  const _AnimatedPostCard({
    required this.index,
    required this.post,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.onTap,
  });

  @override
  State<_AnimatedPostCard> createState() => _AnimatedPostCardState();
}

class _AnimatedPostCardState extends State<_AnimatedPostCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400 + (widget.index % 6 * 100)),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: PostCard(
          post: widget.post,
          isFavorite: widget.isFavorite,
          onFavoriteToggle: widget.onFavoriteToggle,
          onTap: widget.onTap,
        ),
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  final dynamic post;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onTap;

  const PostCard({
    super.key,
    required this.post,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: EdgeInsets.only(bottom: 2.pH),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          splashColor: theme.colorScheme.primary.withValues(alpha: 0.05),
          highlightColor: Colors.transparent,
          child: Padding(
            padding: EdgeInsets.all(5.pW),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Hero(
                        tag: 'post_title_${post.id}',
                        child: Material(
                          color: Colors.transparent,
                          child: Text(
                            post.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                              color: theme.colorScheme.onSurface,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 2.pW),
                    _FavoriteButton(
                      isFavorite: isFavorite,
                      onToggle: onFavoriteToggle,
                    ),
                  ],
                ),
                SizedBox(height: 1.5.pH),
                Text(
                  post.body,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                    height: 1.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.pH),
                Row(
                  children: [
                    _Tag(
                      label: 'User ${post.userId}',
                      icon: Icons.person_outline_rounded,
                      color: theme.colorScheme.primary,
                    ),
                    SizedBox(width: 2.pW),
                    _Tag(
                      label: 'ID: ${post.id}',
                      icon: Icons.tag_rounded,
                      color: theme.colorScheme.secondary,
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onToggle;

  const _FavoriteButton({required this.isFavorite, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isFavorite 
              ? Colors.redAccent.withValues(alpha: 0.1) 
              : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
          child: Icon(
            isFavorite ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
            key: ValueKey(isFavorite),
            size: 24,
            color: isFavorite ? Colors.redAccent : Colors.grey.shade400,
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _Tag({required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.5.pW, vertical: 0.6.pH),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          SizedBox(width: 1.pW),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

