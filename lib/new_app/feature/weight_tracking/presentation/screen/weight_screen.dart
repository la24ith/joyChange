// lib/features/weight_tracking/presentation/screens/weight_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/service_locator.dart';
import '../bloc/weight_bloc.dart';
import '../bloc/weight_event.dart';
import '../bloc/weight_state.dart';
import '../widgets/weight_skeleton.dart';
import '../widgets/weight_empty_state.dart';
import '../widgets/weight_error_state.dart';
import '../widgets/current_weight_card.dart';
import '../widgets/goal_progress_card.dart';
import '../widgets/weight_stats_widget.dart';
import '../widgets/weight_chart_widget.dart';
import '../widgets/weight_history_widget.dart';

class WeightScreen extends StatelessWidget {
  const WeightScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<WeightBloc>()..add(const LoadWeightsEvent()),
      child: const _WeightView(),
    );
  }
}

class _WeightView extends StatefulWidget {
  const _WeightView();

  @override
  State<_WeightView> createState() => _WeightViewState();
}

class _WeightViewState extends State<_WeightView> {
  @override
  void initState() {
    super.initState();
    // تحميل البيانات عند فتح الصفحة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeightBloc>().add(const LoadWeightsEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[50],
      appBar: _buildAppBar(context, isDark),
      body: BlocConsumer<WeightBloc, WeightState>(
        listener: _handleStateChanges,
        builder: (context, state) {
          return _buildBody(context, state, isTablet);
        },
      ),
    );
  }

  // ==================== APP BAR ====================
  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDark) {
    return AppBar(
      title: const Text('تتبع الوزن'),
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      actions: [
        // زر تحديث يدوي
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            context
                .read<WeightBloc>()
                .add(const LoadWeightsEvent(forceRefresh: true));
          },
          tooltip: 'تحديث البيانات',
        ),
        // زر معلومات الكاش (للمطورين)
        IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: () {
            _showCacheInfo(context);
          },
          tooltip: 'معلومات التخزين المؤقت',
        ),
      ],
    );
  }

  // ==================== STATE LISTENER ====================
  void _handleStateChanges(BuildContext context, WeightState state) {
    if (state is WeightError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'إعادة المحاولة',
            textColor: Colors.white,
            onPressed: () {
              context
                  .read<WeightBloc>()
                  .add(const LoadWeightsEvent(forceRefresh: true));
            },
          ),
        ),
      );
    }

    if (state is WeightLoaded && state.isDataStale) {
      // تنبيه المستخدم بأن البيانات قديمة
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('البيانات قديمة، جاري التحديث...'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // ==================== BODY ====================
  Widget _buildBody(BuildContext context, WeightState state, bool isTablet) {
    if (state is WeightInitial || state is WeightLoading) {
      // إذا كان هناك كاش سابق، اعرضه مع مؤشر تحميل
      final previousState = context.read<WeightBloc>().state;
      if (previousState is WeightLoaded) {
        return Stack(
          children: [
            _buildContent(context, previousState, isTablet),
            const Positioned(
              bottom: 20,
              right: 20,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
              ),
            ),
          ],
        );
      }
      return const WeightSkeleton();
    }

    if (state is WeightEmpty) {
      return const WeightEmptyState();
    }

    if (state is WeightError) {
      return WeightErrorState(
        message: state.message,
        onRetry: () {
          context
              .read<WeightBloc>()
              .add(const LoadWeightsEvent(forceRefresh: true));
        },
      );
    }

    if (state is WeightLoaded) {
      return _buildContent(context, state, isTablet);
    }

    return const SizedBox.shrink();
  }

  // ==================== CONTENT ====================
  Widget _buildContent(
      BuildContext context, WeightLoaded state, bool isTablet) {
    return RefreshIndicator(
      onRefresh: () async {
        context
            .read<WeightBloc>()
            .add(const LoadWeightsEvent(forceRefresh: true));
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(isTablet ? 24 : 16),
              child: Column(
                children: [
                  // مؤشر حالة الكاش
                  _buildCacheStatus(state),
                  const SizedBox(height: 12),
                  CurrentWeightCard(status: state.goalStatus),
                  const SizedBox(height: 20),
                  GoalProgressCard(status: state.goalStatus),
                  const SizedBox(height: 20),
                  WeightStatsWidget(stats: state.stats),
                  const SizedBox(height: 20),
                  WeightChartWidget(
                    chartData: state.chartData,
                    status: state.goalStatus,
                  ),
                  const SizedBox(height: 20),
                  WeightHistoryWidget(entries: state.entries),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== CACHE STATUS ====================
  Widget _buildCacheStatus(WeightLoaded state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: state.isFromCache ? Colors.orange[50] : Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: state.isFromCache ? Colors.orange[200]! : Colors.green[200]!,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            state.isFromCache ? Icons.hourglass_empty : Icons.check_circle,
            size: 16,
            color: state.isFromCache ? Colors.orange[600] : Colors.green[600],
          ),
          const SizedBox(width: 4),
          Text(
            state.isFromCache
                ? '📦 بيانات مخزنة (${state.lastUpdateText})'
                : '✅ محدثة (${state.lastUpdateText})',
            style: TextStyle(
              fontSize: 12,
              color: state.isFromCache ? Colors.orange[700] : Colors.green[700],
            ),
          ),
          if (state.isDataStale) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'قديمة',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.red[700],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ==================== CACHE INFO DIALOG ====================
  void _showCacheInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('معلومات التخزين المؤقت'),
        content: FutureBuilder(
          future: _getCacheInfo(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final info = snapshot.data!;
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('الحالة', info['status']!),
                  _buildInfoRow('آخر تحديث', info['lastUpdate']!),
                  _buildInfoRow('العمر', info['age']!),
                  _buildInfoRow('حجم الكاش', info['size']!),
                  _buildInfoRow('عدد العناصر', info['entries']!),
                ],
              );
            }
            return const CircularProgressIndicator();
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.read<WeightBloc>().add(ClearCacheEvent());
              Navigator.pop(context);
            },
            child: const Text('مسح الكاش'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  Future<Map<String, String>> _getCacheInfo() async {
    // يمكن جلب معلومات الكاش من الـ Repository
    return {
      'status': 'صالح',
      'lastUpdate': 'منذ 5 دقائق',
      'age': '5 دقائق',
      'size': '2.3 KB',
      'entries': '15 قياس',
    };
  }
}
