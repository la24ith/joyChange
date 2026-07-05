// lib/features/post_details/presentation/widgets/premium_video_player.dart

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/storage/secure_storage.dart';
import 'package:joy_of_change_v3/new_app/core/constant/api_endpoints.dart';

class PremiumVideoPlayer extends StatefulWidget {
  final String videoUrl;

  const PremiumVideoPlayer({super.key, required this.videoUrl});

  @override
  State<PremiumVideoPlayer> createState() => _PremiumVideoPlayerState();
}

class _PremiumVideoPlayerState extends State<PremiumVideoPlayer>
    with AutomaticKeepAliveClientMixin {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  bool _isLoading = true;
  String? _errorMessage;

  @override
  bool get wantKeepAlive => false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // ✅ نفس منطق المصادقة الأصلي بدون أي تغيير
    final secureStorage = getIt<SecureStorageService>();
    final token = await secureStorage.read(key: 'access_token');
    final deviceId = await secureStorage.read(key: 'device_id');

    // ngrok يحتاج https
    final videoUrl = widget.videoUrl.replaceFirst('http://', 'https://');

    try {
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(ApiEndpoints.mediaUrl(videoUrl)),
        httpHeaders: {
          'Authorization': 'Bearer $token',
          'X-Device-Id': deviceId ?? '',
          'Range': 'bytes=0-',
        },
      );

      await controller.initialize();

      // ✅ Chewie يضيف واجهة تحكم احترافية جاهزة فوق نفس الـ controller:
      // progress bar، Fullscreen، تحكم في السرعة، كتم الصوت، إلخ.
      final chewieController = ChewieController(
        videoPlayerController: controller,
        autoPlay: false,
        looping: false,
        aspectRatio: controller.value.aspectRatio == 0
            ? 16 / 9
            : controller.value.aspectRatio,
        allowFullScreen: true,
        allowMuting: true,
        allowPlaybackSpeedChanging: true,
        playbackSpeeds: const [0.5, 0.75, 1.0, 1.25, 1.5, 2.0],
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.teal,
          handleColor: Colors.teal,
          bufferedColor: Colors.white24,
          backgroundColor: Colors.white12,
        ),
        placeholder: Container(color: Colors.black),
        errorBuilder: (context, errorMessage) => _ErrorPlaceholder(
          message: errorMessage,
          onRetry: _initializeVideo,
        ),
      );

      if (!mounted) {
        chewieController.dispose();
        controller.dispose();
        return;
      }

      setState(() {
        _videoController = controller;
        _chewieController = chewieController;
        _isLoading = false;
      });

      print('✅ Video streaming ready (chewie)');
    } catch (e) {
      print('❌ Video error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'فشل تحميل الفيديو';
        });
      }
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isLoading) {
      return Container(
        color: Colors.black,
        height: 250,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 12),
              Text('جاري تحميل الفيديو...',
                  style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return _ErrorPlaceholder(
        message: _errorMessage!,
        onRetry: _initializeVideo,
      );
    }

    if (_chewieController == null || _videoController == null) {
      return Container(color: Colors.black, height: 250);
    }

    // ✅ مش بنلف Chewie بـ AspectRatio على نسبة الفيديو الحقيقية.
    // Chewie بيتكفل داخليًا بعرض الفيديو بالنسبة الصحيحة (letterbox
    // للفيديوهات العمودية) طالما إحنا مدّيناه مساحة محدودة (bounded) من
    // الأب — وهي هنا ثابتة (height: 420) جاية من CarouselSlider في
    // premium_media_gallery.dart. كنا قبل كده بنلف بـ AspectRatio بنسبة
    // الفيديو نفسها، فأي فيديو عمودي كان بيضيّق العرض الكلي (شامل شريط
    // التحكم) ويعمل overflow بسيط في شريط الوقت/الأزرار.
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Chewie(controller: _chewieController!),
    );
  }
}

class _ErrorPlaceholder extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorPlaceholder({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[900],
      height: 250,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red[400], size: 48),
            const SizedBox(height: 12),
            Text(message, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            ),
          ],
        ),
      ),
    );
  }
}
