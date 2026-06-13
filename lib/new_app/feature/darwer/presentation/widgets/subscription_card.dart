// lib/features/drawer/presentation/widgets/subscription_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:joy_of_change_v3/new_app/feature/darwer/domain/entities/user_subscription.dart';
import 'package:joy_of_change_v3/new_app/feature/darwer/presentation/bloc/drawer_bloc.dart';
import 'package:joy_of_change_v3/new_app/feature/darwer/presentation/bloc/drawer_state.dart';

class SubscriptionCard extends StatelessWidget {
  const SubscriptionCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<DrawerBloc, DrawerState>(
      builder: (context, state) {
        UserSubscription? subscription;

        // ✅ استخراج الاشتراك من الحالة المناسبة
        if (state is DrawerLoaded) {
          subscription = state.subscription;
        } else if (state is DrawerLoadingWithCache) {
          subscription = state.cachedSubscription;
        }

        if (subscription != null) {
          return _buildSubscriptionCard(subscription, isDark);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSubscriptionCard(UserSubscription subscription, bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: subscription.statusColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subscription Type with Icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: subscription.statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  subscription.isActive ? Icons.verified : Icons.warning_amber,
                  size: 20,
                  color: subscription.statusColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  subscription.subscriptionDisplayName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: subscription.statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Expiry Date
          if (subscription.isActive) ...[
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  'ينتهي بتاريخ: ${subscription.formattedEndDate}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          // Remaining Days
          Row(
            children: [
              Icon(
                subscription.isActive
                    ? Icons.timer_outlined
                    : Icons.cancel_outlined,
                size: 14,
                color: subscription.statusColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  subscription.isActive
                      ? 'متبقي: ${subscription.remainingDays} يوم'
                      : 'الاشتراك غير نشط',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: subscription.statusColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
