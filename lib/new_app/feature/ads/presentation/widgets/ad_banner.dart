// lib/features/ads/presentation/widgets/ad_banner.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:joy_of_change_v3/new_app/feature/ads/domain/entities/ad.dart';
import 'package:joy_of_change_v3/new_app/feature/ads/presentation/bloc/ads_state.dart';
import '../bloc/ads_bloc.dart';
import '../bloc/ads_event.dart';
import 'ad_card.dart';

class AdBanner extends StatelessWidget {
  const AdBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdsBloc, AdsState>(
      builder: (context, state) {
        if (state is AdsLoaded && state.ads.isNotEmpty) {
          final topAd = state.ads.firstWhere(
            (ad) => ad.position == AdPosition.top,
            orElse: () => state.ads.first,
          );
          return AdCard(
            ad: topAd,
            onTap: () {
              context.read<AdsBloc>().add(RegisterAdClickEvent(adId: topAd.id));
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
