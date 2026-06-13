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

  // ✅ Cache محلي لتخزين آخر البيانات المستلمة
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
        // ✅ تحديث الـ Cache عند استلام بيانات جديدة
        _cachedSubscription = subscription;
        add(SubscriptionUpdatedEvent(subscription: subscription));
      },
      onError: (error) {
        // في حالة الخطأ، حاول التحميل مرة أخرى
        add(LoadUserSubscriptionEvent());
      },
    );
  }

  Future<void> _onLoadUserSubscription(
    LoadUserSubscriptionEvent event,
    Emitter<DrawerState> emit,
  ) async {
    // ✅ استراتيجية العرض الفوري:
    // 1. إذا كان لدينا Cache، أظهره فورًا مع حالة تحميل
    // 2. إذا لم يكن لدينا Cache، أظهر شاشة تحميل فقط

    if (_cachedSubscription != null && state is! DrawerLoaded) {
      // عرض البيانات المخزنة مع مؤشر تحميل
      emit(DrawerLoadingWithCache(
        cachedSubscription: _cachedSubscription,
        selectedItem: MenuItem.home,
      ));
    } else if (_cachedSubscription == null) {
      // أول مرة لا يوجد بيانات
      emit(DrawerLoading());
    }

    // ✅ جلب البيانات الجديدة في الخلفية (لا يعطل الـ UI)
    final result = await _subscriptionRepository.getUserSubscription();

    result.fold(
      (failure) {
        // ❌ في حالة الخطأ
        if (_cachedSubscription != null) {
          // إذا كان لدينا Cache، استمر في عرضه
          emit(DrawerLoaded(
            subscription: _cachedSubscription!,
            selectedItem: MenuItem.home,
          ));
        } else {
          // لا يوجد Cache، أظهر الخطأ
          emit(DrawerError(message: failure.message));
        }
      },
      (subscription) {
        // ✅ نجاح التحميل
        _cachedSubscription = subscription;
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

    // حالة البيانات محملة بالكامل
    if (currentState is DrawerLoaded) {
      emit(DrawerLoaded(
        subscription: currentState.subscription,
        selectedItem: event.selectedItem,
      ));
    }
    // حالة التحميل مع Cache - نسمح بتغيير الاختيار أيضاً
    else if (currentState is DrawerLoadingWithCache &&
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
        emit(DrawerLogoutSuccess());
      },
    );
  }

  Future<void> _onSubscriptionUpdated(
    SubscriptionUpdatedEvent event,
    Emitter<DrawerState> emit,
  ) async {
    // ✅ تحديث Cache
    _cachedSubscription = event.subscription;

    final currentState = state;

    // تحديث الواجهة بناءً على الحالة الحالية
    if (currentState is DrawerLoaded) {
      emit(DrawerLoaded(
        subscription: event.subscription,
        selectedItem: currentState.selectedItem,
      ));
    } else if (currentState is DrawerLoadingWithCache) {
      // انتقل من حالة التحميل إلى محملة بالكامل
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
