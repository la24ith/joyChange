// lib/features/post_details/presentation/bloc/post_details_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../../../home/domain/repositories/home_repository.dart';
import '../../data/datasources/post_remote_ds.dart';
import 'post_details_state.dart';
import 'post_details_event.dart';

class PostDetailsBloc extends Bloc<PostDetailsEvent, PostDetailsState> {
  final HomeRepository _homeRepository;
  final PostRemoteDataSource _postRemoteDataSource;

  // ✅ أضف هذه المتغيرات
  int? _currentPostId;
  String? _currentPostSlug;

  int? get currentPostId => _currentPostId;
  String? get currentPostSlug => _currentPostSlug;

  PostDetailsBloc({
    required HomeRepository homeRepository,
    required PostRemoteDataSource postRemoteDataSource,
  })  : _homeRepository = homeRepository,
        _postRemoteDataSource = postRemoteDataSource,
        super(PostDetailsInitial()) {
    on<LoadPostDetailsEvent>(_onLoadPostDetails);
    on<ToggleLikeEvent>(_onToggleLike);
    on<ToggleBookmarkEvent>(_onToggleBookmark);
  }

  Future<void> _onLoadPostDetails(
    LoadPostDetailsEvent event,
    Emitter<PostDetailsState> emit,
  ) async {
    // ✅ حفظ الـ postId و postSlug
    _currentPostId = event.postId;
    _currentPostSlug = event.postSlug;

    emit(PostDetailsLoading());

    try {
      final postResult = await _homeRepository.getPostById(event.postId);
      final media = await _postRemoteDataSource.getPostMedia(event.postId);

      postResult.fold(
        (failure) {
          emit(PostDetailsError(message: failure.message));
        },
        (post) {
          emit(PostDetailsLoaded(
            post: post,
            media: media.map((m) => m.toEntity()).toList(),
          ));
        },
      );
    } catch (e) {
      emit(PostDetailsError(message: 'Failed to load post details'));
    }
  }

  Future<void> _onToggleLike(
    ToggleLikeEvent event,
    Emitter<PostDetailsState> emit,
  ) async {
    final currentState = state;
    if (currentState is PostDetailsLoaded) {
      emit(PostDetailsLoaded(
        post: currentState.post,
        media: currentState.media,
        isLiked: !currentState.isLiked,
        isBookmarked: currentState.isBookmarked,
      ));
      // TODO: Call API to toggle like
    }
  }

  Future<void> _onToggleBookmark(
    ToggleBookmarkEvent event,
    Emitter<PostDetailsState> emit,
  ) async {
    final currentState = state;
    if (currentState is PostDetailsLoaded) {
      emit(PostDetailsLoaded(
        post: currentState.post,
        media: currentState.media,
        isLiked: currentState.isLiked,
        isBookmarked: !currentState.isBookmarked,
      ));
      // TODO: Call API to toggle bookmark
    }
  }
}
