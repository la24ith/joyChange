// lib/features/home/presentation/bloc/home_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:joy_of_change_v3/new_app/feature/home/domain/entities/post.dart';
import '../../domain/usecases/get_posts_usecase.dart';
import 'home_state.dart';
import 'home_event.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetPostsUseCase getPostsUseCase;

  int _currentPage = 1;
  bool _hasReachedMax = false;
  List<Post> _posts = [];
  bool _isPrefetching = false;
  static const int _limit = 10;

  HomeBloc({required this.getPostsUseCase}) : super(HomeInitial()) {
    on<FetchPostsEvent>(_onFetchPosts);
    on<PrefetchPostsEvent>(_onPrefetchPosts);
    on<FetchMorePostsEvent>(_onFetchMorePosts);
    on<RefreshPostsEvent>(_onRefreshPosts);
  }

  Future<void> _onFetchPosts(
    FetchPostsEvent event,
    Emitter<HomeState> emit,
  ) async {
    if (state is HomeLoading) return;

    emit(HomeLoading());

    _currentPage = 1;
    _hasReachedMax = false;

    final result = await getPostsUseCase(GetPostsParams(
      page: _currentPage,
      limit: event.limit,
    ));

    result.fold(
      (failure) {
        // ✅ عند الخطأ يجب أن يعرض رسالة واضحة
        // الـ Repository سيرجع Cache تلقائياً إذا وُجد،
        // إذا وصلنا هنا فمعناه لا Cache ولا إنترنت
        emit(HomeError(message: failure.message));
      },
      (posts) {
        _posts = posts;

        if (_posts.isEmpty) {
          emit(HomeEmpty());
        } else {
          // ✅ إذا جاءت البيانات من الـ Cache، تعامل معها كـ hasReachedMax
          // لأن الـ Cache يحتوي فقط على الصفحة الأولى
          _hasReachedMax = posts.length < _limit;

          emit(HomeLoaded(
            posts: _posts,
            hasReachedMax: _hasReachedMax,
            currentPage: _currentPage,
          ));

          // ✅ Prefetch فقط إذا لم نصل للنهاية (= لسنا في وضع Offline)
          if (!_hasReachedMax && !_isPrefetching) {
            add(const PrefetchPostsEvent());
          }
        }
      },
    );
  }

  Future<void> _onPrefetchPosts(
    PrefetchPostsEvent event,
    Emitter<HomeState> emit,
  ) async {
    if (_hasReachedMax) return;
    if (_isPrefetching) return;

    _isPrefetching = true;

    final nextPage = _currentPage + 1;

    final result = await getPostsUseCase(GetPostsParams(
      page: nextPage,
      limit: _limit,
    ));

    result.fold(
      (failure) => null, // خطأ في الـ Prefetch = تجاهل بصمت
      (newPosts) {
        // Prefetch نجح، البيانات محفوظة في Cache الـ Repository
      },
    );

    _isPrefetching = false;
  }

  Future<void> _onFetchMorePosts(
    FetchMorePostsEvent event,
    Emitter<HomeState> emit,
  ) async {
    if (_hasReachedMax) return;
    if (state is HomePaginationLoading) return;

    final currentState = state;
    if (currentState is! HomeLoaded) return;

    final currentPosts = currentState.posts;

    emit(HomePaginationLoading(existingPosts: currentPosts));

    final nextPage = _currentPage + 1;
    final result = await getPostsUseCase(GetPostsParams(
      page: nextPage,
      limit: _limit,
    ));

    result.fold(
      (failure) {
        // ✅ فشل تحميل المزيد: ارجع للحالة السابقة مع رسالة خطأ مؤقتة
        emit(HomeError(
          message: failure.message,
          existingPosts: currentPosts,
        ));
        Future.delayed(const Duration(seconds: 2), () {
          if (!isClosed && state is HomeError) {
            emit(HomeLoaded(
              posts: currentPosts,
              hasReachedMax: _hasReachedMax,
              currentPage: _currentPage,
            ));
          }
        });
      },
      (newPosts) {
        // ✅ إذا رجعت قائمة فارغة من الـ Repository (وضع Offline للصفحات التالية)
        if (newPosts.isEmpty) {
          _hasReachedMax = true;
          emit(HomeLoaded(
            posts: currentPosts,
            hasReachedMax: true,
            currentPage: _currentPage,
          ));
          return;
        }

        _currentPage = nextPage;
        _posts = [...currentPosts, ...newPosts];
        _hasReachedMax = newPosts.length < _limit;

        emit(HomeLoaded(
          posts: _posts,
          hasReachedMax: _hasReachedMax,
          currentPage: _currentPage,
        ));

        if (!_hasReachedMax && !_isPrefetching) {
          add(const PrefetchPostsEvent());
        }
      },
    );
  }

  Future<void> _onRefreshPosts(
    RefreshPostsEvent event,
    Emitter<HomeState> emit,
  ) async {
    _isPrefetching = false;
    _hasReachedMax = false;
    _currentPage = 1;
    _posts = [];
    add(const FetchPostsEvent(page: 1, limit: _limit));
  }
}
