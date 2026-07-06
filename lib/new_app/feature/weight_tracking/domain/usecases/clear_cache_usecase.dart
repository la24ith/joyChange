// lib/features/weight_tracking/domain/usecases/clear_cache_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:joy_of_change_v3/new_app/core/errors/failure.dart';
import '../repositories/weight_repository.dart';

/// ✅ إصلاح: use case حقيقي يمسح الكاش المخزَّن فعلياً (SharedPreferences)
/// بدل الاكتفاء بمسح الحالة داخل الـ Bloc فقط (كما كان يحدث سابقاً في
/// WeightBloc._onClearCache، الذي كان يمسح `_lastLoadedState` فقط
/// ولا يستدعي `repository.clearCache()` إطلاقاً).
class ClearCacheUseCase {
  final WeightRepository repository;

  ClearCacheUseCase(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.clearCache();
  }
}
