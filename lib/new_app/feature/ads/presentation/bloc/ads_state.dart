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

/// الحالة الرئيسية لعرض الإعلانات.
/// [navigationRequest] هو حدث عابر (one-time event) يُستخدم فقط لإخبار
/// الواجهة بأنه يجب فتح رابط معيّن، ولا يعني أبداً أن قائمة الإعلانات
/// قد تغيّرت أو اختفت. هذا يحل مشكلة اختفاء الإعلانات بعد الضغط عليها،
/// لأن النقر لا يستبدل AdsLoaded بحالة أخرى، بل يحدّث نفس الحالة مع
/// إضافة معلومة التنقل فقط.
final class AdsLoaded extends AdsState {
  final List<Ad> ads;
  final AdNavigationRequest? navigationRequest;

  const AdsLoaded({required this.ads, this.navigationRequest});

  AdsLoaded copyWith({
    List<Ad>? ads,
    AdNavigationRequest? navigationRequest,
    bool clearNavigationRequest = false,
  }) {
    return AdsLoaded(
      ads: ads ?? this.ads,
      navigationRequest: clearNavigationRequest
          ? null
          : (navigationRequest ?? this.navigationRequest),
    );
  }

  @override
  List<Object?> get props => [ads, navigationRequest];
}

final class AdsError extends AdsState {
  final String message;

  const AdsError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// معلومة وصفية لطلب تنقّل ناتج عن نقرة على إعلان.
/// تحمل رقماً تسلسلياً [requestId] فريد لكل نقرة حتى تستطيع الواجهة
/// التمييز بين طلب جديد وطلب قديم تمت معالجته من قبل (تجنّب فتح
/// الرابط أكثر من مرة بسبب إعادة بناء الواجهة).
class AdNavigationRequest extends Equatable {
  final int requestId;
  final String? linkUrl;
  final String linkType; // 'external' أو 'internal'

  const AdNavigationRequest({
    required this.requestId,
    required this.linkUrl,
    required this.linkType,
  });

  @override
  List<Object?> get props => [requestId, linkUrl, linkType];
}
