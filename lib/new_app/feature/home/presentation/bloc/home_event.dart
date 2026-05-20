// lib/features/home/presentation/bloc/home_event.dart

import 'package:equatable/equatable.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

final class FetchPostsEvent extends HomeEvent {
  final int page;

  const FetchPostsEvent({this.page = 1});

  @override
  List<Object?> get props => [page];
}

final class RefreshPostsEvent extends HomeEvent {}
