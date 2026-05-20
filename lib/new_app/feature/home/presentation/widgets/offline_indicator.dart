// lib/features/home/presentation/widgets/offline_indicator.dart

import 'package:flutter/material.dart';

class OfflineIndicator extends StatelessWidget {
  const OfflineIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.wifi_off_rounded,
            color: Colors.amber.shade700,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'لا يوجد اتصال بالإنترنت. يتم عرض المحتوى المحفوظ.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.amber.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
