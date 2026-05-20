// lib/features/home/domain/usecases/get_posts_usecase.dart

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/post.dart';
import '../repositories/home_repository.dart';

class GetPostsParams {
  final int page;

  const GetPostsParams({this.page = 1});
}

class GetPostsUseCase {
  final HomeRepository repository;

  GetPostsUseCase(this.repository);

  Future<Either<Failure, List<Post>>> call(GetPostsParams params) async {
    return await repository.getPosts(page: params.page);
  }
}
