// lib/features/ads/presentation/widgets/ad_carousel.dart

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:joy_of_change_v3/new_app/feature/ads/domain/entities/ad.dart';
import 'package:joy_of_change_v3/new_app/feature/ads/presentation/bloc/ads_state.dart';
import '../bloc/ads_bloc.dart';
import '../bloc/ads_event.dart';
import 'ad_card.dart';

class AdCarousel extends StatelessWidget {
  const AdCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return BlocBuilder<AdsBloc, AdsState>(
      builder: (context, state) {
        if (state is AdsLoading) {
          return const SizedBox.shrink();
        }

        if (state is AdsLoaded && state.ads.isNotEmpty) {
          final topAds =
              state.ads.where((ad) => ad.position == AdPosition.top).toList();

          if (topAds.isEmpty) return const SizedBox.shrink();

          return CarouselSlider.builder(
            itemCount: topAds.length,
            options: CarouselOptions(
              height: screenHeight * 0.22,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 5),
              enlargeCenterPage: true,
              viewportFraction: 0.9,
              enableInfiniteScroll: topAds.length > 1,
            ),
            itemBuilder: (context, index, realIndex) {
              final ad = topAds[index];
              return AdCard(
                ad: ad,
                onTap: () {
                  context
                      .read<AdsBloc>()
                      .add(RegisterAdClickEvent(adId: ad.id));
                  _handleAdTap(context, ad);
                },
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  void _handleAdTap(BuildContext context, Ad ad) {
    if (ad.linkUrl != null && ad.linkUrl!.isNotEmpty) {
      // يمكن إضافة منطق فتح الرابط هنا
      // إذا كان internal → navigation
      // إذا كان external → url_launcher
    }
  }
}
