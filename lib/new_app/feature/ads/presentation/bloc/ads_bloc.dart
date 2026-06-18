// lib/features/ads/presentation/bloc/ads_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_active_ads_usecase.dart';
import '../../domain/usecases/register_click_usecase.dart';
import 'ads_state.dart';
import 'ads_event.dart';

class AdsBloc extends Bloc<AdsEvent, AdsState> {
  final GetActiveAdsUseCase _getActiveAdsUseCase;
  final RegisterClickUseCase _registerClickUseCase;

  int _navigationRequestCounter = 0;

  // يمنع إرسال أكثر من طلب شبكة متزامن لتحميل الإعلانات. الفحص على
  // مستوى الـ state وحده غير كافٍ، لأنه لو AdBanner و AdCarousel كلاهما
  // ينفّذان initState بنفس الفريم، فكلاهما سيريان state == AdsInitial
  // قبل أن تتم معالجة أي event، فيرسلان الحدث مرتين. هذا الـ flag
  // الداخلي يضمن تنفيذ طلب واحد فقط بأي وقت.
  bool _isLoadingAds = false;

  // يمنع تسجيل نقرة مكررة على نفس الإعلان لو ضغط المستخدم بسرعة أكثر
  // من مرة قبل أن تكتمل معالجة النقرة الأولى (مثل ضغط مزدوج بطيء أو
  // اتصال شبكة بطيء). بدون هذا، قد يُسجَّل click_count مضاعفاً وقد
  // يُفتح الرابط الخارجي مرتين.
  final Set<int> _pendingClickAdIds = {};

  AdsBloc({
    required GetActiveAdsUseCase getActiveAdsUseCase,
    required RegisterClickUseCase registerClickUseCase,
  })  : _getActiveAdsUseCase = getActiveAdsUseCase,
        _registerClickUseCase = registerClickUseCase,
        super(AdsInitial()) {
    on<LoadActiveAdsEvent>(_onLoadAds);
    on<RegisterAdClickEvent>(_onRegisterClick);
    on<AdNavigationHandledEvent>(_onNavigationHandled);
  }

  Future<void> _onLoadAds(
    LoadActiveAdsEvent event,
    Emitter<AdsState> emit,
  ) async {
    if (_isLoadingAds) return;
    _isLoadingAds = true;

    emit(AdsLoading());

    try {
      final result = await _getActiveAdsUseCase();

      result.fold(
        (failure) => emit(AdsError(message: failure.message)),
        (ads) {
          final validAds = ads.where((ad) => ad.isValid).toList();
          emit(AdsLoaded(ads: validAds));
        },
      );
    } finally {
      _isLoadingAds = false;
    }
  }

  Future<void> _onRegisterClick(
    RegisterAdClickEvent event,
    Emitter<AdsState> emit,
  ) async {
    if (_pendingClickAdIds.contains(event.ad.id)) return;
    _pendingClickAdIds.add(event.ad.id);

    try {
      final currentState = state;

      final result = await _registerClickUseCase(event.ad.id);

      _navigationRequestCounter++;
      final navigationRequest = AdNavigationRequest(
        requestId: _navigationRequestCounter,
        linkUrl: event.ad.linkUrl,
        linkType: event.ad.linkType.name,
      );

      result.fold(
        (failure) {
          // فشل تسجيل النقرة لا يجب أن يمنع المستخدم من فتح الرابط أو
          // أن يُسقط الإعلانات من الشاشة؛ فقط نسجّل الخطأ ونستمر بفتح الرابط.
          if (currentState is AdsLoaded) {
            emit(currentState.copyWith(navigationRequest: navigationRequest));
          }
        },
        (_) {
          if (currentState is AdsLoaded) {
            emit(currentState.copyWith(navigationRequest: navigationRequest));
          }
        },
      );
    } finally {
      _pendingClickAdIds.remove(event.ad.id);
    }
  }

  void _onNavigationHandled(
    AdNavigationHandledEvent event,
    Emitter<AdsState> emit,
  ) {
    final currentState = state;
    if (currentState is AdsLoaded) {
      emit(currentState.copyWith(clearNavigationRequest: true));
    }
  }
}
