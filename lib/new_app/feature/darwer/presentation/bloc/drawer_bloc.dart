// lib/features/drawer/presentation/bloc/drawer_bloc.dart

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:joy_of_change_v3/new_app/feature/darwer/data/models/drawer_models.dart';
import 'package:joy_of_change_v3/new_app/feature/darwer/domain/entities/user_subscription.dart';
import '../../domain/repositories/subscription_repository.dart';
import 'drawer_event.dart';
import 'drawer_state.dart';

class DrawerBloc extends Bloc<DrawerEvent, DrawerState> {
  final SubscriptionRepository _subscriptionRepository;
  late final StreamSubscription<UserSubscription> _subscriptionStream;

  // ✅ Cache في الذاكرة للجلسة الحالية
  UserSubscription? _cachedSubscription;

  DrawerBloc({required SubscriptionRepository subscriptionRepository})
      : _subscriptionRepository = subscriptionRepository,
        super(DrawerInitial()) {
    on<LoadUserSubscriptionEvent>(_onLoadUserSubscription);
    on<SelectMenuItemEvent>(_onSelectMenuItem);
    on<LogoutRequestedEvent>(_onLogoutRequested);
    on<SubscriptionUpdatedEvent>(_onSubscriptionUpdated);

    _initSubscriptionStream();
  }

  void _initSubscriptionStream() {
    _subscriptionStream =
        _subscriptionRepository.watchUserSubscription().listen(
      (subscription) {
        _cachedSubscription = subscription;
        add(SubscriptionUpdatedEvent(subscription: subscription));
      },
      onError: (error) {
        // عند خطأ في الـ Stream، لا تعيد المحاولة لتجنب حلقة لا نهائية
        // الـ _onLoadUserSubscription سيتعامل مع الـ Cache
      },
    );
  }

  Future<void> _onLoadUserSubscription(
    LoadUserSubscriptionEvent event,
    Emitter<DrawerState> emit,
  ) async {
    // ✅ الخطوة 1: حاول تحميل الـ Cache المحفوظ من التخزين المحلي (Hive)
    if (_cachedSubscription == null) {
      final cachedResult = await _subscriptionRepository.getCachedSubscription();
      cachedResult?.fold(
        (_) => null,
        (subscription) => _cachedSubscription = subscription,
      );
    }

    // ✅ الخطوة 2: اعرض الـ Cache فوراً إذا وُجد
    if (_cachedSubscription != null) {
      emit(DrawerLoadingWithCache(
        cachedSubscription: _cachedSubscription,
        selectedItem: MenuItem.home,
      ));
    } else {
      emit(DrawerLoading());
    }

    // ✅ الخطوة 3: اجلب البيانات من الشبكة في الخلفية
    final result = await _subscriptionRepository.getUserSubscription();

    result.fold(
      (failure) {
        // ❌ فشل الشبكة
        if (_cachedSubscription != null) {
          // ✅ عرض الـ Cache المحفوظ بدلاً من الخطأ
          emit(DrawerLoaded(
            subscription: _cachedSubscription!,
            selectedItem: MenuItem.home,
          ));
        } else {
          // لا Cache ولا إنترنت
          emit(DrawerError(
            message: 'لا يوجد اتصال بالإنترنت ولا توجد بيانات محفوظة',
          ));
        }
      },
      (subscription) {
        // ✅ نجاح: حدّث الـ Cache وعرض البيانات الجديدة
        _cachedSubscription = subscription;
        // ✅ خزّن في Hive حتى تبقى بعد إعادة تشغيل التطبيق
        _subscriptionRepository.cacheSubscription(subscription);
        emit(DrawerLoaded(
          subscription: subscription,
          selectedItem: MenuItem.home,
        ));
      },
    );
  }

  Future<void> _onSelectMenuItem(
    SelectMenuItemEvent event,
    Emitter<DrawerState> emit,
  ) async {
    final currentState = state;

    if (currentState is DrawerLoaded) {
      emit(DrawerLoaded(
        subscription: currentState.subscription,
        selectedItem: event.selectedItem,
      ));
    } else if (currentState is DrawerLoadingWithCache &&
        currentState.cachedSubscription != null) {
      emit(DrawerLoadingWithCache(
        cachedSubscription: currentState.cachedSubscription,
        selectedItem: event.selectedItem,
      ));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequestedEvent event,
    Emitter<DrawerState> emit,
  ) async {
    final result = await _subscriptionRepository.logout();

    result.fold(
      (failure) => emit(DrawerError(message: failure.message)),
      (_) {
        // ✅ مسح الـ Cache عند تسجيل الخروج
        _cachedSubscription = null;
        _subscriptionRepository.clearCachedSubscription();
        emit(DrawerLogoutSuccess());
      },
    );
  }

  Future<void> _onSubscriptionUpdated(
    SubscriptionUpdatedEvent event,
    Emitter<DrawerState> emit,
  ) async {
    _cachedSubscription = event.subscription;

    final currentState = state;

    if (currentState is DrawerLoaded) {
      emit(DrawerLoaded(
        subscription: event.subscription,
        selectedItem: currentState.selectedItem,
      ));
    } else if (currentState is DrawerLoadingWithCache) {
      emit(DrawerLoaded(
        subscription: event.subscription,
        selectedItem: currentState.selectedItem,
      ));
    }
  }

  @override
  Future<void> close() {
    _subscriptionStream.cancel();
    return super.close();
  }
}
