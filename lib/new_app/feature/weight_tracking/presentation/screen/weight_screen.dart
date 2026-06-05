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
import '../widgets/add_weight_bottom_sheet.dart';

class WeightScreen extends StatelessWidget {
  const WeightScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<WeightBloc>()..add(LoadWeightsEvent()),
      child: const _WeightView(),
    );
  }
}

class _WeightView extends StatelessWidget {
  const _WeightView();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[50],
      appBar: AppBar(
        title: const Text('تتبع الوزن'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: BlocBuilder<WeightBloc, WeightState>(
        builder: (context, state) {
          if (state is WeightLoading) {
            return const WeightSkeleton();
          }

          if (state is WeightEmpty) {
            return WeightEmptyState(
              onAddPressed: () => _showAddBottomSheet(context),
            );
          }

          if (state is WeightError) {
            return WeightErrorState(
              message: state.message,
              onRetry: () {
                context.read<WeightBloc>().add(RefreshWeightsEvent());
              },
            );
          }

          if (state is WeightLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<WeightBloc>().add(RefreshWeightsEvent());
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(isTablet ? 24 : 16),
                      child: Column(
                        children: [
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

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddBottomSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('إضافة وزن'),
        backgroundColor: Colors.teal,
      ),
    );
  }

  void _showAddBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddWeightBottomSheet(),
    ).then((_) {
      context.read<WeightBloc>().add(RefreshWeightsEvent());
    });
  }
}
