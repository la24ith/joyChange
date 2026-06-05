// lib/features/daily_commitment/domain/usecases/get_answer_history_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:joy_of_change_v3/new_app/core/errors/failure.dart';
import 'package:joy_of_change_v3/new_app/feature/daily_commitment/domain/repositories/aily_commitment_repository.dart';
import '../entities/daily_answer.dart';

class GetAnswerHistoryUseCase {
  final DailyCommitmentRepository repository;

  GetAnswerHistoryUseCase(this.repository);

  Future<Either<Failure, List<DailyAnswer>>> call() async {
    return await repository.getAnswerHistory();
  }
}
