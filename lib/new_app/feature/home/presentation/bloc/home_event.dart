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
  final String? patientSegment; // ✅ إضافة segment المريض

  const FetchPostsEvent({
    this.page = 1,
    this.limit = 10,
    this.patientSegment,
  });

  @override
  List<Object?> get props => [page, limit, patientSegment];
}

// ✅ حدث Prefetch
final class PrefetchPostsEvent extends HomeEvent {
  final int page;
  final int limit;
  final String? patientSegment;
  const PrefetchPostsEvent({
    this.page = 1,
    this.limit = 10,
    this.patientSegment,
  });
}

final class FetchMorePostsEvent extends HomeEvent {
  final String? patientSegment;

  FetchMorePostsEvent({required this.patientSegment});
}

final class RefreshPostsEvent extends HomeEvent {
  final String? patientSegment; // ✅ إضافة segment عند الـ refresh

  const RefreshPostsEvent({this.patientSegment});

  @override
  List<Object?> get props => [patientSegment];
}
