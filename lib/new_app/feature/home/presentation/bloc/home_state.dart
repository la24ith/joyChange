// lib/features/home/presentation/bloc/home_state.dart

import 'package:equatable/equatable.dart';
import '../../domain/entities/post.dart';

sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

final class HomeInitial extends HomeState {}

final class HomeLoading extends HomeState {}

// ✅ حالة Prefetching جديدة
final class HomePrefetching extends HomeState {
  final List<Post> existingPosts;
  const HomePrefetching({required this.existingPosts});

  @override
  List<Object?> get props => [existingPosts];
}

final class HomeLoaded extends HomeState {
  final List<Post> posts;
  final bool hasReachedMax;
  final int currentPage;

  const HomeLoaded({
    required this.posts,
    this.hasReachedMax = false,
    this.currentPage = 1,
  });

  @override
  List<Object?> get props => [posts, hasReachedMax, currentPage];
}

final class HomePaginationLoading extends HomeState {
  final List<Post> existingPosts;
  const HomePaginationLoading({required this.existingPosts});

  @override
  List<Object?> get props => [existingPosts];
}

final class HomeError extends HomeState {
  final String message;
  final List<Post>? existingPosts;

  const HomeError({required this.message, this.existingPosts});

  @override
  List<Object?> get props => [message, existingPosts];
}

final class HomeEmpty extends HomeState {}
