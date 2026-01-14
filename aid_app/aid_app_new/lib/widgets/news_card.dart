import 'package:flutter/material.dart';
import 'animated_particle_background.dart';
import 'reusable_explosion_painter.dart';
import 'staggered_fade_in.dart';
import '../utils/app_colors.dart';

class NewsCard extends StatefulWidget {
  final String title;
  final String content;
  final String authorName;
  final String createdDate;
  final int likes;
  final bool isLiked;
  final VoidCallback onLike;
  final VoidCallback onTap;

  const NewsCard({
    Key? key,
    required this.title,
    required this.content,
    required this.authorName,
    required this.createdDate,
    required this.likes,
    required this.isLiked,
    required this.onLike,
    required this.onTap,
    // imageUrl is no longer used in this design to focus on the particle effect
  }) : super(key: key);

  @override
  State<NewsCard> createState() => _NewsCardState();
}

class _NewsCardState extends State<NewsCard> with TickerProviderStateMixin {
  late AnimationController _likeExplosionController;
  late AnimationController _contentEntryController;

  @override
  void initState() {
    super.initState();

    _likeExplosionController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _contentEntryController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _contentEntryController.forward();
  }

  @override
  void dispose() {
    _likeExplosionController.dispose();
    _contentEntryController.dispose();
    super.dispose();
  }

  void _handleLike() {
    widget.onLike();
    if (!_likeExplosionController.isAnimating) {
      _likeExplosionController.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardTheme = Theme.of(context).cardTheme;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        height: 250,
        child: ClipRRect(
           borderRadius: cardTheme.shape is RoundedRectangleBorder
              ? (cardTheme.shape as RoundedRectangleBorder).borderRadius
              : BorderRadius.circular(16),
          child: Container(
            decoration: const BoxDecoration(
              gradient: AppColors.violetGradient,
            ),
            child: Stack(
              children: [
                // Use the reusable animated particle background
                const Positioned.fill(
                  child: AnimatedParticleBackground(),
                ),

                // Content
                _buildContentLayer(context),

                // Like explosion effect
                Positioned(
                  right: 40,
                  bottom: 24,
                  child: AnimatedBuilder(
                    animation: _likeExplosionController,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: ExplosionPainter(progress: _likeExplosionController.value),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContentLayer(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    
    return StaggeredFadeIn(
      controller: _contentEntryController,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text(
              widget.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.headlineSmall?.copyWith(
                color: AppColors.white,
                shadows: [
                  const Shadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  )
                ],
              ),
            ),
            const SizedBox(height: 8),
             Text(
              widget.content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodyMedium?.copyWith(color: AppColors.lightGray.withOpacity(0.8)),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text(
                      widget.authorName,
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.cyan,
                      ),
                    ),
                     Text(
                      widget.createdDate,
                      style: textTheme.bodyMedium
                          ?.copyWith(fontSize: 11, color: AppColors.lightGray.withOpacity(0.7)),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: _handleLike,
                      icon: Icon(
                        widget.isLiked
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: widget.isLiked
                            ? AppColors.error
                            : AppColors.lightGray,
                      ),
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                    const SizedBox(width: 4),
                     Text(
                      '${widget.likes}',
                      style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.lightGray),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}




