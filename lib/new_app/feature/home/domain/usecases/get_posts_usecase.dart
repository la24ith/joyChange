// lib/features/home/domain/usecases/get_posts_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:joy_of_change_v3/new_app/core/errors/failure.dart';
import '../entities/post.dart';
import '../repositories/home_repository.dart';

class GetPostsParams {
  final int page;
  final int limit;
  final String? patientSegment; // ✅ segment المريض لتصفية المنشورات

  const GetPostsParams({
    this.page = 1,
    this.limit = 10,
    this.patientSegment,
  });
}

class GetPostsUseCase {
  final HomeRepository repository;

  GetPostsUseCase(this.repository);

  Future<Either<Failure, List<Post>>> call(GetPostsParams params) async {
    return await repository.getPosts(
      page: params.page,
      limit: params.limit,
      patientSegment: params.patientSegment,
    );
  }
}
