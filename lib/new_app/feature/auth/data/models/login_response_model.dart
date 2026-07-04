// lib/features/auth/data/models/login_response_model.dart

import 'package:equatable/equatable.dart';
import '../../presentation/bloc/auth_state.dart';
import 'user_model.dart';

class LoginResponseModel extends Equatable {
  final bool success;
  final String? code;
  final String? message;
  final String? token;
  final UserModel? user;
  final int? userId;
  final String? email;

  const LoginResponseModel({
    required this.success,
    this.code,
    this.message,
    this.token,
    this.user,
    this.userId,
    this.email,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    final isSuccess = json['success'] == true;
    final code = json['code'] as String?;
    final message = json['message'] as String?;

    // Extract user data from different possible paths
    UserModel? userModel;
    int? userId;
    String? email;

    if (json['data'] != null) {
      if (json['data']['user'] != null) {
        userModel =
            UserModel.fromJson(json['data']['user'] as Map<String, dynamic>);
        userId = userModel?.id;
        email = userModel?.email;
      } else if (json['data']['user_id'] != null) {
        userId = json['data']['user_id'] as int?;
      }
      if (json['data']['email'] != null) {
        email = json['data']['email'] as String?;
      }
    }

    return LoginResponseModel(
      success: isSuccess,
      code: code,
      message: message,
      token: json['data']?['token'] as String?,
      user: userModel,
      userId: userId,
      email: email,
    );
  }

  /// Convert API response to AuthState
  AuthState toAuthState() {
    // Success case (no error code)
    if (success && code == null && token != null && user != null) {
      return Authenticated(
        user: user!.toEntity(),
        token: token!,
      );
    }

    // Handle error cases based on code
    // ✅ نستخدم دائماً رسائل عربية ثابتة لكل حالة معروفة، ولا نعتمد على
    // نص الرسالة القادم من السيرفر لأنه قد يصل بالإنجليزية أو بصياغة تقنية.
    switch (code) {
      case 'NEEDS_SUBSCRIPTION':
        return PendingSubscription(
          message: 'تم إنشاء حسابك بنجاح، بانتظار تفعيل الاشتراك',
          email: email ?? '',
          userId: userId ?? 0,
        );

      case 'SUBSCRIPTION_INACTIVE':
        return const SubscriptionInactive(
          message: 'اشتراكك منتهٍ أو غير مفعل، يرجى التواصل مع الإدارة',
        );

      case 'UNAPPROVED_DEVICE':
        return PendingDeviceApproval(
          message: 'الجهاز بحاجة لتفعيل من الإدارة',
          email: email ?? '',
        );

      default:
        return const InvalidCredentials(
          message: 'خطأ في كلمة السر أو البريد الإلكتروني',
        );
    }
  }

  @override
  List<Object?> get props => [
        success,
        code,
        message,
        token,
        user,
        userId,
        email,
      ];
}