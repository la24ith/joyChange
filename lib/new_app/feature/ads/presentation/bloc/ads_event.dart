// lib/features/ads/presentation/bloc/ads_event.dart

import 'package:equatable/equatable.dart';
import '../../domain/entities/ad.dart';

sealed class AdsEvent extends Equatable {
  const AdsEvent();

  @override
  List<Object?> get props => [];
}

final class LoadActiveAdsEvent extends AdsEvent {}

final class RegisterAdClickEvent extends AdsEvent {
  final Ad ad;

  const RegisterAdClickEvent({required this.ad});

  @override
  List<Object?> get props => [ad];
}

/// يُستخدم لإخبار الـ Bloc بأن طلب التنقل (فتح رابط) قد تمت معالجته
/// من جهة الواجهة، فيمسح [AdsLoaded.navigationRequest] لمنع إعادة
/// تنفيذه عند أي rebuild لاحق.
final class AdNavigationHandledEvent extends AdsEvent {
  const AdNavigationHandledEvent();
}
