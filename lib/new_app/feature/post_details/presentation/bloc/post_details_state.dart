// lib/features/post_details/presentation/bloc/post_details_state.dart

import 'package:equatable/equatable.dart';
import '../../../home/domain/entities/post.dart';
import '../../domain/entities/media.dart';

sealed class PostDetailsState extends Equatable {
  const PostDetailsState();

  @override
  List<Object?> get props => [];
}

final class PostDetailsInitial extends PostDetailsState {}

final class PostDetailsLoading extends PostDetailsState {}

final class PostDetailsLoaded extends PostDetailsState {
  final Post post;
  final List<Media> media;
  final bool isLiked;
  final bool isBookmarked;

  const PostDetailsLoaded({
    required this.post,
    this.media = const [],
    this.isLiked = false,
    this.isBookmarked = false,
  });

  @override
  List<Object?> get props => [post, media, isLiked, isBookmarked];
}

final class PostDetailsError extends PostDetailsState {
  final String message;

  const PostDetailsError({required this.message});

  @override
  List<Object?> get props => [message];
}
