// lib/features/ads/presentation/bloc/ads_event.dart

import 'package:equatable/equatable.dart';

sealed class AdsEvent extends Equatable {
  const AdsEvent();

  @override
  List<Object?> get props => [];
}

final class LoadActiveAdsEvent extends AdsEvent {}

final class RegisterAdClickEvent extends AdsEvent {
  final int adId;

  const RegisterAdClickEvent({required this.adId});

  @override
  List<Object?> get props => [adId];
}
