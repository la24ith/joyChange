// lib/features/daily_commitment/domain/usecases/get_pending_answers_usecase.dart

import 'package:joy_of_change_v3/new_app/feature/daily_commitment/domain/repositories/aily_commitment_repository.dart';

class GetPendingAnswersUseCase {
  final DailyCommitmentRepository repository;

  GetPendingAnswersUseCase(this.repository);

  Future<List<Map<String, dynamic>>> call() async {
    return await repository.getPendingAnswers();
  }
}
