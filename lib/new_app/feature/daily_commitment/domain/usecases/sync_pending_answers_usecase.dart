// lib/features/daily_commitment/domain/usecases/sync_pending_answers_usecase.dart

import 'package:joy_of_change_v3/new_app/feature/daily_commitment/domain/repositories/aily_commitment_repository.dart';

class SyncPendingAnswersUseCase {
  final DailyCommitmentRepository repository;

  SyncPendingAnswersUseCase(this.repository);

  Future<void> call() async {
    await repository.syncPendingAnswers();
  }
}
