// lib/features/post_details/presentation/bloc/post_details_event.dart

import 'package:equatable/equatable.dart';

sealed class PostDetailsEvent extends Equatable {
  const PostDetailsEvent();

  @override
  List<Object?> get props => [];
}

final class LoadPostDetailsEvent extends PostDetailsEvent {
  final int postId;
  final String? postSlug;

  const LoadPostDetailsEvent({required this.postId, this.postSlug});

  @override
  List<Object?> get props => [postId, postSlug];
}

final class ToggleLikeEvent extends PostDetailsEvent {}

final class ToggleBookmarkEvent extends PostDetailsEvent {}
