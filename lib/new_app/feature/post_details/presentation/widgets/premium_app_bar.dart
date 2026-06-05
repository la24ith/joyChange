// lib/features/post_details/presentation/widgets/premium_app_bar.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PremiumAppBar extends StatelessWidget {
  final String title;
  final String? thumbnailUrl;
  final bool isDark;
  final bool isBookmarked;
  final bool isLiked;
  final VoidCallback onBookmark;
  final VoidCallback onLike;
  final VoidCallback onShare;

  const PremiumAppBar({
    super.key,
    required this.title,
    this.thumbnailUrl,
    required this.isDark,
    required this.isBookmarked,
    required this.isLiked,
    required this.onBookmark,
    required this.onLike,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 340,
      floating: false,
      pinned: true,
      backgroundColor: isDark ? Colors.black : Colors.white,
      foregroundColor: isDark ? Colors.white : Colors.black,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (isDark ? Colors.black : Colors.white).withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_ios, size: 18),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        _buildActionButton(
          icon: isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
          color: isBookmarked ? Colors.teal : null,
          onPressed: onBookmark,
        ),
        _buildActionButton(
          icon: isLiked ? Icons.favorite : Icons.favorite_border,
          color: isLiked ? Colors.red : null,
          onPressed: onLike,
        ),
        _buildActionButton(
          icon: Icons.share_outlined,
          onPressed: onShare,
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        centerTitle: false,
        titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (thumbnailUrl != null && thumbnailUrl!.isNotEmpty)
              CachedNetworkImage(
                imageUrl: thumbnailUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: isDark ? Colors.grey[900] : Colors.grey[200],
                ),
                errorWidget: (context, url, error) => Container(
                  color: isDark ? Colors.grey[900] : Colors.grey[200],
                  child: Icon(
                    Icons.image_not_supported,
                    color: isDark ? Colors.white54 : Colors.black54,
                  ),
                ),
                fadeInDuration: const Duration(milliseconds: 300),
              ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    isDark ? Colors.black : Colors.white,
                  ],
                  stops: const [0.6, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    Color? color,
    required VoidCallback onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: IconButton(
        icon: Icon(icon, color: color),
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor:
              (isDark ? Colors.black : Colors.white).withOpacity(0.5),
        ),
      ),
    );
  }
}
