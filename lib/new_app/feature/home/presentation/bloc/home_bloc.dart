// lib/features/home/presentation/bloc/home_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_posts_usecase.dart';
import 'home_state.dart';
import 'home_event.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetPostsUseCase getPostsUseCase;

  HomeBloc({required this.getPostsUseCase}) : super(HomeInitial()) {
    on<FetchPostsEvent>(_onFetchPosts);
    on<RefreshPostsEvent>(_onRefreshPosts);
  }

  Future<void> _onFetchPosts(
    FetchPostsEvent event,
    Emitter<HomeState> emit,
  ) async {
    if (event.page == 1) {
      emit(HomeLoading());
    }

    final result = await getPostsUseCase(GetPostsParams(page: event.page));

    result.fold(
      (failure) {
        if (event.page == 1) {
          emit(HomeError(message: failure.message));
        }
      },
      (posts) {
        if (event.page == 1) {
          emit(HomeLoaded(posts: posts));
        } else {
          final currentState = state;
          if (currentState is HomeLoaded) {
            emit(HomeLoaded(
              posts: [...currentState.posts, ...posts],
              hasReachedMax: posts.isEmpty,
            ));
          }
        }
      },
    );
  }

  Future<void> _onRefreshPosts(
    RefreshPostsEvent event,
    Emitter<HomeState> emit,
  ) async {
    add(const FetchPostsEvent(page: 1));
  }
}
