// lib/features/ads/presentation/bloc/ads_state.dart

import 'package:equatable/equatable.dart';
import '../../domain/entities/ad.dart';

sealed class AdsState extends Equatable {
  const AdsState();

  @override
  List<Object?> get props => [];
}

final class AdsInitial extends AdsState {}

final class AdsLoading extends AdsState {}

final class AdsLoaded extends AdsState {
  final List<Ad> ads;

  const AdsLoaded({required this.ads});

  @override
  List<Object?> get props => [ads];
}

final class AdsError extends AdsState {
  final String message;

  const AdsError({required this.message});

  @override
  List<Object?> get props => [message];
}

final class ClickRegistered extends AdsState {
  final String? linkUrl;
  final String linkType;

  const ClickRegistered({this.linkUrl, required this.linkType});

  @override
  List<Object?> get props => [linkUrl, linkType];
}
