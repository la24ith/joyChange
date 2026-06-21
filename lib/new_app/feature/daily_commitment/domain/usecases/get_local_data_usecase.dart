// lib/features/daily_commitment/domain/usecases/get_local_data_usecase.dart

import 'package:joy_of_change_v3/new_app/feature/daily_commitment/domain/repositories/aily_commitment_repository.dart';
import '../../data/models/local_commitment_data.dart';

class GetLocalDataUseCase {
  final DailyCommitmentRepository repository;

  GetLocalDataUseCase(this.repository);

  Future<LocalCommitmentData> call() async {
    return await repository.getLocalData();
  }
}
