// lib/new_app/feature/post_details/presentation/widgets/youtube_player_widget.dart
//
// ✅ مشغل يوتيوب مدمج داخل التطبيق (بدون فتح تطبيق خارجي)
// يعتمد على حزمة youtube_player_flutter (الإصدار 10.x)
// ⚠️ الإصدار 10.0.0+ يعيد تصدير API الخاص بـ youtube_player_iframe مباشرة:
//    - المُنشئ أصبح YoutubePlayerController.fromVideoId(videoId: ..., params: ...)
//      بدل YoutubePlayerController(initialVideoId: ..., flags: ...)
//    - التخصيص عبر YoutubePlayerParams بدل YoutubePlayerFlags
//    - التخلص من المتحكم عبر controller.close() بدل controller.dispose()
//    - الفل سكرين وشريط التقدم مدمجان تلقائياً (showControls) بدون أي إعداد إضافي
//
// التثبيت: flutter pub add youtube_player_flutter
// متطلبات: Flutter >= 3.38.0 / Dart SDK ^3.10.0
// Android: minSdkVersion 20 | iOS: 11+ (Swift, Xcode >= 11)

import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../../core/utils/media_source_helper.dart';

class YoutubeEmbedPlayer extends StatefulWidget {
  final String videoUrl;

  const YoutubeEmbedPlayer({super.key, required this.videoUrl});

  @override
  State<YoutubeEmbedPlayer> createState() => _YoutubeEmbedPlayerState();
}

class _YoutubeEmbedPlayerState extends State<YoutubeEmbedPlayer> {
  YoutubePlayerController? _controller;
  bool _invalidUrl = false;

  @override
  void initState() {
    super.initState();

    final videoId = MediaSourceHelper.extractYoutubeId(widget.videoUrl);

    if (videoId == null) {
      _invalidUrl = true;
      return;
    }

    _controller = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: false,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    // ✅ في الإصدار الجديد التخلص من المتحكم عبر close() وليس dispose()
    _controller?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_invalidUrl || _controller == null) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'تعذر تحميل فيديو يوتيوب، الرابط غير صالح',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ),
      );
    }

    // ✅ الفل سكرين وشريط التقدم مدمجان تلقائياً، لا حاجة لأي widget إضافي حولها
    return Center(
      child: YoutubePlayer(
        controller: _controller!,
        aspectRatio: 16 / 9,
      ),
    );
  }
}
