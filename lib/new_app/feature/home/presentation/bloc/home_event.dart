// lib/features/home/presentation/bloc/home_event.dart

import 'package:equatable/equatable.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

final class FetchPostsEvent extends HomeEvent {
  final int page;
  final int limit;

  const FetchPostsEvent({this.page = 1, this.limit = 10});

  @override
  List<Object?> get props => [page, limit];
}

// ✅ حدث Prefetch جديد
final class PrefetchPostsEvent extends HomeEvent {
  const PrefetchPostsEvent();
}

final class FetchMorePostsEvent extends HomeEvent {}

final class RefreshPostsEvent extends HomeEvent {}
