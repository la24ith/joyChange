// lib/features/auth/domain/usecases/update_profile_usecase.dart
/*
import 'package:dartz/dartz.dart';
import 'package:joy_of_change_v3/new_app/core/errors/failure.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Input parameters for profile update
class UpdateProfileParams {
  final String? name;
  final String? phone;
  final double? currentWeight;
  final double? targetWeight;
  final double? height;

  const UpdateProfileParams({
    this.name,
    this.phone,
    this.currentWeight,
    this.targetWeight,
    this.height,
  });

  /// Check if any field is provided for update
  bool get hasChanges {
    return name != null ||
        phone != null ||
        currentWeight != null ||
        targetWeight != null ||
        height != null;
  }
}

/// Use case for updating user profile
class UpdateProfileUseCase {
  final AuthRepository repository;

  UpdateProfileUseCase(this.repository);

  /// Execute profile update with given parameters
  /// Returns updated [User] on success, [Failure] on error
  Future<Either<Failure, User>> call(UpdateProfileParams params) async {
    // Validate that at least one field is being updated
    if (!params.hasChanges) {
      return Left(ValidationFailure(
        message: 'No changes to update',
        errors: {
          'general': ['At least one field must be provided for update']
        },
      ));
    }

    // Validate name if provided
    if (params.name != null) {
      if (params.name!.isEmpty) {
        return Left(ValidationFailure(
          message: 'Name cannot be empty',
          errors: {
            'name': ['Please enter a valid name']
          },
        ));
      }
      if (params.name!.length < 3) {
        return Left(ValidationFailure(
          message: 'Name too short',
          errors: {
            'name': ['Name must be at least 3 characters']
          },
        ));
      }
    }

    // Validate phone if provided
    if (params.phone != null && params.phone!.isNotEmpty) {
      if (params.phone!.length < 10) {
        return Left(ValidationFailure(
          message: 'Invalid phone number',
          errors: {
            'phone': ['Phone number must be at least 10 digits']
          },
        ));
      }
    }

    // Validate weight values if provided
    if (params.currentWeight != null) {
      if (params.currentWeight! <= 0) {
        return Left(ValidationFailure(
          message: 'Invalid weight',
          errors: {
            'current_weight': ['Weight must be greater than 0']
          },
        ));
      }
      if (params.currentWeight! > 500) {
        return Left(ValidationFailure(
          message: 'Invalid weight',
          errors: {
            'current_weight': ['Weight cannot exceed 500 kg']
          },
        ));
      }
    }

    // Validate target weight if provided
    if (params.targetWeight != null) {
      if (params.targetWeight! <= 0) {
        return Left(ValidationFailure(
          message: 'Invalid target weight',
          errors: {
            'target_weight': ['Target weight must be greater than 0']
          },
        ));
      }
      if (params.targetWeight! > 500) {
        return Left(ValidationFailure(
          message: 'Invalid target weight',
          errors: {
            'target_weight': ['Target weight cannot exceed 500 kg']
          },
        ));
      }
    }

    // Validate height if provided
    if (params.height != null) {
      if (params.height! <= 0) {
        return Left(ValidationFailure(
          message: 'Invalid height',
          errors: {
            'height': ['Height must be greater than 0']
          },
        ));
      }
      if (params.height! > 300) {
        return Left(ValidationFailure(
          message: 'Invalid height',
          errors: {
            'height': ['Height cannot exceed 300 cm']
          },
        ));
      }
    }

    // Execute profile update
    return await repository.updateProfile(
      name: params.name,
      phone: params.phone,
      currentWeight: params.currentWeight,
      targetWeight: params.targetWeight,
      height: params.height,
    );
  }
}*/
