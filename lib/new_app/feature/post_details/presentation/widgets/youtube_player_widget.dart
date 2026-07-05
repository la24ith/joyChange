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
import 'package:url_launcher/url_launcher.dart';
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

  Future<void> _openExternally() async {
    final uri = Uri.tryParse(widget.videoUrl);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_invalidUrl || _controller == null) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'تعذر تحميل فيديو يوتيوب، الرابط غير صالح',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                // ✅ حل احتياطي: يفتح الرابط في تطبيق/متصفح يوتيوب مباشرة
                OutlinedButton.icon(
                  onPressed: _openExternally,
                  icon: const Icon(Icons.open_in_new, color: Colors.white),
                  label: const Text('فتح الرابط خارجيًا',
                      style: TextStyle(color: Colors.white)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white54),
                  ),
                ),
              ],
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
