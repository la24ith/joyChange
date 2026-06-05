// lib/features/ads/presentation/bloc/ads_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_active_ads_usecase.dart';
import '../../domain/usecases/register_click_usecase.dart';
import 'ads_state.dart';
import 'ads_event.dart';

class AdsBloc extends Bloc<AdsEvent, AdsState> {
  final GetActiveAdsUseCase _getActiveAdsUseCase;
  final RegisterClickUseCase _registerClickUseCase;

  AdsBloc({
    required GetActiveAdsUseCase getActiveAdsUseCase,
    required RegisterClickUseCase registerClickUseCase,
  })  : _getActiveAdsUseCase = getActiveAdsUseCase,
        _registerClickUseCase = registerClickUseCase,
        super(AdsInitial()) {
    on<LoadActiveAdsEvent>(_onLoadAds);
    on<RegisterAdClickEvent>(_onRegisterClick);
  }

  Future<void> _onLoadAds(
    LoadActiveAdsEvent event,
    Emitter<AdsState> emit,
  ) async {
    emit(AdsLoading());

    final result = await _getActiveAdsUseCase();

    result.fold(
      (failure) => emit(AdsError(message: failure.message)),
      (ads) => emit(AdsLoaded(ads: ads)),
    );
  }

  Future<void> _onRegisterClick(
    RegisterAdClickEvent event,
    Emitter<AdsState> emit,
  ) async {
    final result = await _registerClickUseCase(event.adId);

    result.fold(
      (failure) => emit(AdsError(message: failure.message)),
      (_) => emit(const ClickRegistered(linkType: 'external')),
    );
  }
}
