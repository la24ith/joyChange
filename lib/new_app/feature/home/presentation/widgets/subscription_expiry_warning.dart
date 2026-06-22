// lib/features/home/presentation/widgets/subscription_expiry_warning.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:joy_of_change_v3/new_app/core/constant/app_colors.dart';
import 'package:joy_of_change_v3/new_app/feature/darwer/domain/entities/user_subscription.dart';
import 'package:joy_of_change_v3/new_app/feature/darwer/presentation/bloc/drawer_bloc.dart';
import 'package:joy_of_change_v3/new_app/feature/darwer/presentation/bloc/drawer_state.dart';

class SubscriptionExpiryWarning extends StatelessWidget {
  final double? screenWidth;

  const SubscriptionExpiryWarning({super.key, this.screenWidth});

  @override
  Widget build(BuildContext context) {
    final width = screenWidth ?? MediaQuery.of(context).size.width;
    final isTablet = width >= 600;

    return BlocBuilder<DrawerBloc, DrawerState>(
      builder: (context, state) {
        // استخراج الاشتراك من الحالة
        UserSubscription? subscription;
        if (state is DrawerLoaded) {
          subscription = state.subscription;
        } else if (state is DrawerLoadingWithCache) {
          subscription = state.cachedSubscription;
        }

        // لا نعرض شيئاً إذا:
        // - لا يوجد اشتراك
        // - الاشتراك غير نشط (منتهي)
        // - المتبقي أكثر من 3 أيام
        if (subscription == null ||
            !subscription.isActive ||
            subscription.remainingDays > 3) {
          return const SizedBox.shrink();
        }

        // تحديد اللون حسب عدد الأيام المتبقية
        final isUrgent = subscription.remainingDays <= 1;
        final warningColor =
            isUrgent ? Colors.red.shade600 : Colors.orange.shade600;
        final bgColor = isUrgent ? Colors.red.shade50 : Colors.orange.shade50;
        final borderColor =
            isUrgent ? Colors.red.shade200 : Colors.orange.shade200;

        return Container(
          margin: EdgeInsets.symmetric(
            horizontal: isTablet ? 24.0 : 16.0,
            vertical: 8.0,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: warningColor,
                size: isTablet ? 28 : 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isUrgent
                          ? '⚠️ اشتراكك ينتهي اليوم!'
                          : '⚠️ اشتراكك على وشك الانتهاء',
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        fontWeight: FontWeight.bold,
                        color: warningColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'يتبقى ${subscription.remainingDays} يوم${subscription.remainingDays == 1 ? '' : 'ات'} على انتهاء اشتراكك',
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 13,
                        color: warningColor.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  _showRenewDialog(context);
                },
                style: TextButton.styleFrom(
                  foregroundColor: warningColor,
                  backgroundColor: warningColor.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('تجديد'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRenewDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('تجديد الاشتراك'),
        content: const Text(
            'تواصل مع المشرف لتجديد الاشتراكك والاستمرار في الاستفادة من جميع الميزات.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناََ'),
          ),
        ],
      ),
    );
  }
}
