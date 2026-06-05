// lib/features/daily_commitment/domain/usecases/get_today_question_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:joy_of_change_v3/new_app/core/errors/failure.dart';
import 'package:joy_of_change_v3/new_app/feature/daily_commitment/domain/repositories/aily_commitment_repository.dart';
import '../entities/daily_question.dart';

class GetTodayQuestionUseCase {
  final DailyCommitmentRepository repository;

  GetTodayQuestionUseCase(this.repository);

  Future<Either<Failure, DailyQuestion>> call() async {
    return await repository.getTodayQuestion();
  }
}
