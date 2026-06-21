// lib/features/daily_commitment/domain/usecases/save_pending_answer_usecase.dart

import 'package:joy_of_change_v3/new_app/feature/daily_commitment/domain/repositories/aily_commitment_repository.dart';

class SavePendingAnswerUseCase {
  final DailyCommitmentRepository repository;

  SavePendingAnswerUseCase(this.repository);

  Future<void> call({
    required String answer,
    required DateTime date,
    String? notes,
  }) async {
    await repository.savePendingAnswer(
      answer: answer,
      date: date,
      notes: notes,
    );
  }
}
