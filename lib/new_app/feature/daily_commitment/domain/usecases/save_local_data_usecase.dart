// lib/features/daily_commitment/domain/usecases/save_local_data_usecase.dart

import '../../data/models/local_commitment_data.dart';
import 'package:joy_of_change_v3/new_app/feature/daily_commitment/domain/repositories/aily_commitment_repository.dart';

class SaveLocalDataUseCase {
  final DailyCommitmentRepository repository;

  SaveLocalDataUseCase(this.repository);

  Future<void> call(LocalCommitmentData data) async {
    await repository.saveLocalData(data);
  }
}
