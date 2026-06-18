import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/ad.dart';

class AdCard extends StatelessWidget {
  final Ad ad;
  final VoidCallback onTap;

  /// نص زر "اعرف أكثر"، قابل للتمرير من الخارج. تركناه بقيمة افتراضية
  /// عربية للحفاظ على نفس السلوك الحالي دون كسر أي استخدام موجود،
  /// لكنه أصبح جاهزاً لاستبداله بـ tr('ads.learn_more') أو ما يعادلها
  /// فور إضافة حزمة ترجمة (easy_localization / intl) للمشروع.
  final String learnMoreLabel;

  const AdCard({
    super.key,
    required this.ad,
    required this.onTap,
    this.learnMoreLabel = 'اعرف أكثر',
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isTablet = width >= 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: isTablet ? 24 : 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: AspectRatio(
            aspectRatio: isTablet ? 4.2 : 3.2,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (ad.imageUrl != null && ad.imageUrl!.isNotEmpty)
                  CachedNetworkImage(
                    imageUrl: ad.imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      color:
                          isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    // إذا فشل تحميل الصورة (مثل رابط غير قابل للوصول من
                    // السيرفر) نعرض خلفية متدرجة بديلة بدل ترك مساحة
                    // فاضية أو رمي خطأ يظهر للمستخدم.
                    errorWidget: (_, __, ___) => _buildGradientBackground(),
                  )
                else
                  _buildGradientBackground(),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.black.withOpacity(0.75),
                        Colors.black.withOpacity(0.25),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(isTablet ? 22 : 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ad.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: isTablet ? 20 : 16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Flexible(
                        child: Text(
                          ad.content,
                          maxLines: isTablet ? 3 : 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.95),
                            fontSize: isTablet ? 14 : 12,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          learnMoreLabel,
                          style: const TextStyle(
                            color: Colors.teal,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGradientBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.teal.shade400,
            Colors.teal.shade700,
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.ads_click_rounded,
          color: Colors.white,
          size: 48,
        ),
      ),
    );
  }
}
