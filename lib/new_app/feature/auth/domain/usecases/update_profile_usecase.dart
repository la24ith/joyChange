// lib/features/auth/domain/usecases/update_profile_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:joy_of_change_v3/new_app/core/errors/failure.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class UpdateProfileParams {
  final String? name;
  final String? phone;
  final double? currentWeight;
  final double? targetWeight;
  final double? height;
  final String? patientSegment;

  const UpdateProfileParams({
    this.name,
    this.phone,
    this.currentWeight,
    this.targetWeight,
    this.height,
    this.patientSegment,
  });

  bool get hasChanges {
    return name != null ||
        phone != null ||
        currentWeight != null ||
        targetWeight != null ||
        height != null ||
        patientSegment != null;
  }
}

class UpdateProfileUseCase {
  final AuthRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<Either<Failure, User>> call(UpdateProfileParams params) async {
    // ✅ التحقق من وجود تغييرات
    if (!params.hasChanges) {
      return Left(ValidationFailure(
        message: 'لا توجد تغييرات لحفظها',
      ));
    }

    // ✅ التحقق من الوزن الحالي
    if (params.currentWeight != null) {
      if (params.currentWeight! <= 0) {
        return Left(ValidationFailure(
          message: 'الوزن يجب أن يكون أكبر من 0',
        ));
      }
      if (params.currentWeight! > 500) {
        return Left(ValidationFailure(
          message: 'الوزن لا يمكن أن يتجاوز 500 كغ',
        ));
      }
    }

    // ✅ التحقق من الوزن المستهدف
    if (params.targetWeight != null) {
      if (params.targetWeight! <= 0) {
        return Left(ValidationFailure(
          message: 'الوزن المستهدف يجب أن يكون أكبر من 0',
        ));
      }
      if (params.targetWeight! > 500) {
        return Left(ValidationFailure(
          message: 'الوزن المستهدف لا يمكن أن يتجاوز 500 كغ',
        ));
      }
    }

    // ✅ التحقق من الطول
    if (params.height != null) {
      if (params.height! <= 0) {
        return Left(ValidationFailure(
          message: 'الطول يجب أن يكون أكبر من 0',
        ));
      }
      if (params.height! > 300) {
        return Left(ValidationFailure(
          message: 'الطول لا يمكن أن يتجاوز 300 سم',
        ));
      }
      if (params.height! < 50) {
        return Left(ValidationFailure(
          message: 'الطول لا يمكن أن يكون أقل من 50 سم',
        ));
      }
    }

    // ✅ التحقق من الفئة
    if (params.patientSegment != null) {
      final validSegments = [
        'diabetic',
        'breastfeeding',
        'weight_loss',
        'weight_gain',
        'general'
      ];
      if (!validSegments.contains(params.patientSegment)) {
        return Left(ValidationFailure(
          message: 'فئة غير صالحة',
        ));
      }
    }

    // ✅ تنفيذ التحديث
    return await repository.updateProfile(
      name: params.name,
      phone: params.phone,
      currentWeight: params.currentWeight,
      targetWeight: params.targetWeight,
      height: params.height,
      patientSegment: params.patientSegment,
    );
  }
}
