// lib/features/daily_commitment/domain/usecases/submit_answer_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:joy_of_change_v3/new_app/core/errors/failure.dart';
import 'package:joy_of_change_v3/new_app/feature/daily_commitment/domain/repositories/aily_commitment_repository.dart';
import '../entities/daily_answer.dart';

class SubmitAnswerParams {
  final String answer;
  final DateTime date;
  final String? notes;

  const SubmitAnswerParams({
    required this.answer,
    required this.date,
    this.notes,
  });
}

class SubmitAnswerUseCase {
  final DailyCommitmentRepository repository;

  SubmitAnswerUseCase(this.repository);

  Future<Either<Failure, DailyAnswer>> call(SubmitAnswerParams params) async {
    if (params.answer != 'yes' && params.answer != 'no') {
      return Left(ValidationFailure(
        message: 'الإجابة يجب أن تكون yes أو no',
      ));
    }

    if (params.date.isAfter(DateTime.now())) {
      return Left(ValidationFailure(
        message: 'لا يمكن الإجابة على سؤال في المستقبل',
      ));
    }

    return await repository.submitAnswer(
      answer: params.answer,
      date: params.date,
      notes: params.notes,
    );
  }
}
