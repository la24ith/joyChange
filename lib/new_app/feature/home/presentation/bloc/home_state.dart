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

final class HomeLoaded extends HomeState {
  final List<Post> posts;
  final bool hasReachedMax;

  const HomeLoaded({
    required this.posts,
    this.hasReachedMax = false,
  });

  @override
  List<Object?> get props => [posts, hasReachedMax];
}

final class HomeError extends HomeState {
  final String message;

  const HomeError({required this.message});

  @override
  List<Object?> get props => [message];
}
