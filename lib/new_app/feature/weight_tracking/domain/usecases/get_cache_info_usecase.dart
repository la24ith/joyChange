// lib/features/weight_tracking/domain/usecases/get_cache_info_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:joy_of_change_v3/new_app/core/errors/failure.dart';
import '../repositories/weight_repository.dart';

/// ✅ إصلاح: use case حقيقي يقرأ معلومات الكاش الفعلية من التخزين المحلي.
/// سابقاً كانت نافذة معلومات الكاش في weight_screen.dart تعرض قيماً
/// ثابتة/وهمية (hardcoded) لا علاقة لها بالكاش الحقيقي، وكان
/// GetCacheInfoEvent في الـ Bloc بلا أي تنفيذ (جسم فارغ تماماً).
class GetCacheInfoUseCase {
  final WeightRepository repository;

  GetCacheInfoUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call() async {
    return await repository.getCacheInfo();
  }
}
