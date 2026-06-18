// lib/features/ads/presentation/widgets/ad_carousel.dart

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:joy_of_change_v3/new_app/feature/ads/domain/entities/ad.dart';
import 'package:joy_of_change_v3/new_app/feature/ads/presentation/bloc/ads_state.dart';
import '../bloc/ads_bloc.dart';
import '../bloc/ads_event.dart';
import 'ad_card.dart';
import 'ad_navigation_handler.dart';

class AdCarousel extends StatefulWidget {
  const AdCarousel({super.key});

  @override
  State<AdCarousel> createState() => _AdCarouselState();
}

class _AdCarouselState extends State<AdCarousel> {
  @override
  void initState() {
    super.initState();
    final bloc = context.read<AdsBloc>();
    if (bloc.state is AdsInitial) {
      bloc.add(LoadActiveAdsEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return BlocConsumer<AdsBloc, AdsState>(
      listener: (context, state) {
        if (state is AdsLoaded) {
          handleAdNavigation(context, state.navigationRequest);
        }
      },
      builder: (context, state) {
        if (state is AdsLoading || state is AdsInitial) {
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
              enlargeCenterPage: false,
              viewportFraction: 1,
              enableInfiniteScroll: topAds.length > 1,
            ),
            itemBuilder: (context, index, realIndex) {
              final ad = topAds[index];
              return AdCard(
                ad: ad,
                onTap: () {
                  context.read<AdsBloc>().add(RegisterAdClickEvent(ad: ad));
                },
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
