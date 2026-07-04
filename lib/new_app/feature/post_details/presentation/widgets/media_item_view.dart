// lib/new_app/feature/post_details/presentation/widgets/media_item_view.dart
//
// ✅ يوجّه كل عنصر Media إلى الـ widget الصحيح حسب:
//   - source_type: uploaded / external
//   - provider: youtube / google_drive / (أي منصة أخرى)
//
// استخدمه داخل PremiumMediaGallery بدل ما تفترض دايمًا إنه ملف مرفوع.

import 'package:flutter/material.dart';
import 'package:joy_of_change_v3/new_app/feature/post_details/presentation/widgets/audio_player_widget.dart';
import 'package:joy_of_change_v3/new_app/feature/post_details/presentation/widgets/video_player_widget.dart';
import 'package:joy_of_change_v3/new_app/feature/post_details/presentation/widgets/youtube_player_widget.dart';

import '../../domain/entities/media.dart';
import 'drive_preview_widget.dart';
import 'external_link_card.dart';

class MediaItemView extends StatelessWidget {
  final Media media;
  final double screenWidth;
  final Map<String, String> headers;

  /// يُستدعى عند الضغط على صورة مرفوعة (لفتحها في PremiumImageViewer مثلاً)
  final VoidCallback? onImageTap;

  const MediaItemView({
    super.key,
    required this.media,
    required this.screenWidth,
    this.headers = const {},
    this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    // ── محتوى خارجي (يوتيوب / درايف / أي منصة تانية) ──────────────────
    if (media.isExternal) {
      final link = media.resolvedUrl;

      if (link.isEmpty) {
        return _EmptyExternalPlaceholder();
      }

      switch (media.provider) {
        case 'youtube':
          return YoutubeEmbedPlayer(videoUrl: link);

        case 'google_drive':
        case 'drive':
          return GoogleDrivePreview(driveUrl: link);

        default:
          // أي منصة تانية (Vimeo, Facebook, TikTok, X, SoundCloud, Spotify...)
          // ExternalLinkCard بيكتشف المنصة تلقائيًا من الرابط نفسه.
          return ExternalLinkCard(url: link, title: media.fileName);
      }
    }

    // ── محتوى مرفوع على السيرفر (uploaded) ────────────────────────────
    switch (media.type) {
      case MediaType.video:
        return PremiumVideoPlayer(videoUrl: media.resolvedUrl);

      case MediaType.audio:
        return PremiumAudioPlayer(
          audioUrl: media.resolvedUrl,
          title: media.fileName,
        );

      case MediaType.image:
        return GestureDetector(
          onTap: onImageTap,
          child: Image.network(
            media.resolvedUrl,
            headers: headers.isNotEmpty ? headers : null,
            width: screenWidth,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.grey[900],
              height: 200,
              child: const Center(
                child: Icon(Icons.broken_image, color: Colors.white54),
              ),
            ),
          ),
        );
    }
  }
}

class _EmptyExternalPlaceholder extends StatelessWidget {
  const _EmptyExternalPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[900],
      height: 200,
      child: const Center(
        child: Text(
          'رابط خارجي غير صالح',
          style: TextStyle(color: Colors.white54),
        ),
      ),
    );
  }
}
