// lib/features/home/presentation/widgets/offline_indicator.dart

import 'package:flutter/material.dart';

class OfflineIndicator extends StatefulWidget {
  final bool isOffline;
  final VoidCallback? onRetry;
  final double? screenWidth;

  const OfflineIndicator({
    super.key,
    required this.isOffline,
    this.onRetry,
    this.screenWidth,
  });

  @override
  State<OfflineIndicator> createState() => _OfflineIndicatorState();
}

class _OfflineIndicatorState extends State<OfflineIndicator> {
  int _pendingCount = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isOffline) return const SizedBox.shrink();

    final width = widget.screenWidth ?? MediaQuery.of(context).size.width;
    final isTablet = width >= 600;
    final paddingHorizontal = isTablet ? 24.0 : 16.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: paddingHorizontal, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.wifi_off_rounded, color: Colors.amber.shade700, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'غير متصل بالإنترنت',
                  style: TextStyle(
                    fontSize: isTablet ? 15 : 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade800,
                  ),
                ),
                Text(
                  _pendingCount > 0
                      ? '$_pendingCount عملية في انتظار المزامنة'
                      : 'عرض المحتوى المحفوظ مسبقاً',
                  style: TextStyle(
                    fontSize: isTablet ? 13 : 12,
                    color: Colors.amber.shade600,
                  ),
                ),
              ],
            ),
          ),
          if (widget.onRetry != null)
            TextButton(
              onPressed: widget.onRetry,
              style: TextButton.styleFrom(
                foregroundColor: Colors.amber.shade700,
              ),
              child: const Text('إعادة المحاولة'),
            ),
        ],
      ),
    );
  }
}
