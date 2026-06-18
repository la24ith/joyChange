// lib/features/ads/presentation/widgets/ad_banner.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:joy_of_change_v3/new_app/feature/ads/domain/entities/ad.dart';
import 'package:joy_of_change_v3/new_app/feature/ads/presentation/bloc/ads_state.dart';
import '../bloc/ads_bloc.dart';
import '../bloc/ads_event.dart';
import 'ad_card.dart';
import 'ad_navigation_handler.dart';

class AdBanner extends StatefulWidget {
  const AdBanner({super.key});

  @override
  State<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> {
  @override
  void initState() {
    super.initState();
    // تحميل الإعلانات تلقائياً عند ظهور البانر لأول مرة. الفحص هنا
    // غير كافٍ بمفرده لمنع التكرار (لو AdBanner و AdCarousel يُبنيان
    // بنفس الفريم فكلاهما سيجد الحالة AdsInitial قبل معالجة أي حدث،
    // فيُرسلان نفس الحدث مرتين). الحل الكامل لمنع طلب الشبكة المكرر
    // يكون داخل الـ Bloc نفسه (تجاهل LoadActiveAdsEvent لو هناك طلب
    // قيد التنفيذ بالفعل)، وهذا الفحص هنا يبقى كخط دفاع أول بسيط.
    final bloc = context.read<AdsBloc>();
    if (bloc.state is AdsInitial) {
      bloc.add(LoadActiveAdsEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdsBloc, AdsState>(
      listener: (context, state) {
        if (state is AdsLoaded) {
          handleAdNavigation(context, state.navigationRequest);
        }
      },
      builder: (context, state) {
        if (state is AdsLoaded && state.ads.isNotEmpty) {
          // نفلتر إعلانات الموضع "top" فقط من بين الصالحة، وإن لم
          // توجد أي إعلانات بهذا الموضع لا نعرض شيئاً بدل عرض إعلان
          // من موضع مختلف بشكل غير متوقع.
          final topAds =
              state.ads.where((ad) => ad.position == AdPosition.top).toList();

          if (topAds.isEmpty) return const SizedBox.shrink();

          final topAd = topAds.first;

          return AdCard(
            ad: topAd,
            onTap: () {
              context.read<AdsBloc>().add(RegisterAdClickEvent(ad: topAd));
            },
          );
        }
        // يغطي حالات AdsInitial و AdsLoading و AdsError و قائمة فاضية
        return const SizedBox.shrink();
      },
    );
  }
}
