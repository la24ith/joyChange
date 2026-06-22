// lib/features/post_details/presentation/widgets/premium_media_gallery.dart

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:joy_of_change_v3/new_app/core/utils/url_helper.dart';
import 'package:joy_of_change_v3/new_app/feature/post_details/presentation/widgets/audio_player_widget.dart';
import 'package:joy_of_change_v3/new_app/feature/post_details/presentation/widgets/image_viewer.dart';
import 'package:joy_of_change_v3/new_app/feature/post_details/presentation/widgets/video_player_widget.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../domain/entities/media.dart';

class PremiumMediaGallery extends StatefulWidget {
  final List<Media> media;
  final double? screenWidth;

  const PremiumMediaGallery({
    super.key,
    required this.media,
    this.screenWidth,
  });

  @override
  State<PremiumMediaGallery> createState() => _PremiumMediaGalleryState();
}

class _PremiumMediaGalleryState extends State<PremiumMediaGallery>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late CarouselSliderController _carouselController;
  int _currentIndex = 0;
  late AnimationController _indicatorController;
  late Animation<double> _indicatorAnimation;
  bool _isDisposed = false;
  late final bool _hasOnlyImages;
  late final List<Media> _sortedMedia;

  // ✅ تخزين headers مرة واحدة
  Map<String, String> _headers = {};

  @override
  bool get wantKeepAlive => false;

  @override
  void initState() {
    super.initState();
    _carouselController = CarouselSliderController();

    // ✅ ترتيب الوسائط وتجاهل العنصر الأول إذا كان صورة
    _sortedMedia = List<Media>.from(widget.media)
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    // ✅ إذا كان العنصر الأول صورة، قم بإزالته
    if (_sortedMedia.isNotEmpty && _sortedMedia.first.type == MediaType.image) {
      _sortedMedia.removeAt(0);
    }

    _hasOnlyImages = _sortedMedia.every((m) => m.type == MediaType.image);

    _indicatorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _indicatorAnimation = CurvedAnimation(
      parent: _indicatorController,
      curve: Curves.easeOutCubic,
    );

    // ✅ تحميل headers مسبقاً
    _loadHeaders();
  }

  Future<void> _loadHeaders() async {
    _headers = await UrlHelper.getAuthHeaders();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _isDisposed = true;
    _indicatorController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index, CarouselPageChangedReason reason) {
    if (_isDisposed) return;
    setState(() => _currentIndex = index);
    _indicatorController.forward(from: 0.0);
  }

  void _showImageViewer(List<Media> media, int initialIndex) {
    final imageMedia = media.where((m) => m.type == MediaType.image).toList();
    if (imageMedia.isEmpty) return;

    final imageUrls = imageMedia.map((m) => m.url).toList();
    final clickedMedia = media[initialIndex];
    final imageIndex = imageMedia.indexWhere((m) => m.id == clickedMedia.id);

    if (imageIndex == -1) return;

    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) => PremiumImageViewer(
          imageUrls: imageUrls,
          initialIndex: imageIndex,
        ),
      ),
    );
  }

  // ✅ تحويل إلى Widget عادي (غير Future)
  Widget _buildMediaWidget(Media media) {
    var secureUrl = media.url;
    secureUrl = secureUrl.replaceFirst(
      'http://',
      'https://',
    );

    switch (media.type) {
      case MediaType.image:
        return CachedNetworkImage(
          imageUrl: secureUrl,
          httpHeaders: _headers,
          fit: BoxFit.cover,
          width: double.infinity,
          placeholder: (_, __) => Container(
            color: Colors.grey[200],
            child:
                const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          errorWidget: (_, __, ___) => Container(
            color: Colors.grey[200],
            child: const Icon(Icons.broken_image, size: 48),
          ),
        );
      case MediaType.video:
        return PremiumVideoPlayer(videoUrl: secureUrl);
      case MediaType.audio:
        return PremiumAudioPlayer(audioUrl: secureUrl, title: media.fileName);
    }
  }

  Widget _buildModernIndicator(int length, bool isDark) {
    return Row(
      children: List.generate(
        length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: _currentIndex == index ? 24 : 6,
          height: 6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: _currentIndex == index
                ? Theme.of(context).primaryColor
                : isDark
                    ? Colors.white.withOpacity(0.4)
                    : Colors.black.withOpacity(0.2),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_sortedMedia.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ✅ عرض مؤقت أثناء تحميل headers
    if (_headers.isEmpty) {
      return Container(
        height: 420,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[850] : Colors.grey[200],
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              CarouselSlider.builder(
                carouselController: _carouselController,
                itemCount: _sortedMedia.length,
                options: CarouselOptions(
                  height: 420,
                  viewportFraction: 0.92,
                  enlargeCenterPage: true,
                  enlargeFactor: 0.15,
                  enableInfiniteScroll: false,
                  autoPlay: _hasOnlyImages,
                  autoPlayInterval: const Duration(seconds: 5),
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                  scrollPhysics: const BouncingScrollPhysics(),
                  onPageChanged: _onPageChanged,
                ),
                itemBuilder: (context, index, realIndex) {
                  final mediaItem = _sortedMedia[index];
                  return GestureDetector(
                    onTap: () {
                      if (mediaItem.type == MediaType.image) {
                        _showImageViewer(_sortedMedia, index);
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: VisibilityDetector(
                          key: Key(
                              'media_${mediaItem.id}_${mediaItem.type.name}'),
                          onVisibilityChanged: (info) {
                            if (info.visibleFraction > 0.5 &&
                                mediaItem.type == MediaType.video) {
                              // Video became visible - can auto-play if desired
                            }
                          },
                          child: _buildMediaWidget(mediaItem),
                        ),
                      ),
                    ),
                  );
                },
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.05),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Center(
                  child: AnimatedBuilder(
                    animation: _indicatorAnimation,
                    builder: (context, child) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.black.withOpacity(0.6)
                              : Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildModernIndicator(_sortedMedia.length, isDark),
                            const SizedBox(width: 12),
                            Container(
                              width: 1,
                              height: 16,
                              color: isDark
                                  ? Colors.white.withOpacity(0.3)
                                  : Colors.black.withOpacity(0.2),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${_currentIndex + 1}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            Text(
                              ' / ${_sortedMedia.length}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? Colors.white.withOpacity(0.6)
                                    : Colors.black.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
