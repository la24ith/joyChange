// lib/features/weight_tracking/data/models/weight_chart_model.dart
import 'package:equatable/equatable.dart';

class WeightChartModel extends Equatable {
  final List<DateTime> labels;
  final List<double> series;

  const WeightChartModel({
    required this.labels,
    required this.series,
  });

  // ==================== FROM JSON ====================
  factory WeightChartModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;

    List<DateTime> parseLabels(dynamic labelsData) {
      if (labelsData == null || labelsData is! List) return [];
      return labelsData.map((e) {
        try {
          return DateTime.parse(e.toString());
        } catch (_) {
          return DateTime.now();
        }
      }).toList();
    }

    // ✅ إصلاح: الـ API يرجع series كـ strings ["66.00", "77.00", "88.00"]
    List<double> parseSeries(dynamic seriesData) {
      if (seriesData == null || seriesData is! List) return [];
      return seriesData.map((e) {
        if (e is num) return e.toDouble();
        if (e is String) return double.tryParse(e) ?? 0.0;
        return 0.0;
      }).toList();
    }

    return WeightChartModel(
      labels: parseLabels(data['labels']),
      series: parseSeries(data['series']),
    );
  }

  // ==================== TO JSON ====================
  Map<String, dynamic> toJson() {
    return {
      'labels': labels.map((e) => e.toIso8601String().split('T')[0]).toList(),
      'series': series,
    };
  }

  // ==================== FACTORY ====================
  factory WeightChartModel.empty() {
    return const WeightChartModel(labels: [], series: []);
  }

  // ==================== GETTERS ====================
  bool get hasData => series.isNotEmpty && labels.isNotEmpty;
  bool get hasValidData => hasData && series.length == labels.length;
  int get dataCount => series.length;

  double? get minValue => series.isEmpty ? null : series.reduce((a, b) => a < b ? a : b);
  double? get maxValue => series.isEmpty ? null : series.reduce((a, b) => a > b ? a : b);
  double? get latestValue => series.isEmpty ? null : series.last;
  double? get firstValue => series.isEmpty ? null : series.first;

  double? get totalChange {
    if (series.length < 2) return null;
    return series.last - series.first;
  }

  String get formattedTotalChange {
    final change = totalChange;
    if (change == null) return '--';
    final prefix = change > 0 ? '+' : '';
    return '$prefix${change.toStringAsFixed(1)} كجم';
  }

  List<Map<String, dynamic>> getChartPoints() {
    if (!hasValidData) return [];
    return List.generate(series.length, (index) => {
      'index': index,
      'label': _formatDate(labels[index]),
      'value': series[index],
    });
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diff = today.difference(DateTime(date.year, date.month, date.day)).inDays;
    if (diff == 0) return 'اليوم';
    if (diff == 1) return 'أمس';
    if (diff < 7) return 'منذ $diff أيام';
    if (diff < 14) return 'الأسبوع الماضي';
    if (diff < 30) return 'منذ ${(diff / 7).round()} أسابيع';
    if (diff < 365) return '${date.day}/${date.month}';
    return '${date.day}/${date.month}/${date.year}';
  }

  WeightChartModel getSimplified(int maxPoints) {
    if (series.length <= maxPoints) return this;
    final step = (series.length / maxPoints).ceil();
    final newLabels = <DateTime>[];
    final newSeries = <double>[];
    for (int i = 0; i < series.length; i += step) {
      newLabels.add(labels[i]);
      newSeries.add(series[i]);
    }
    if (newLabels.last != labels.last) {
      newLabels.add(labels.last);
      newSeries.add(series.last);
    }
    return WeightChartModel(labels: newLabels, series: newSeries);
  }

  Map<String, double> getChartRange({double padding = 2.0}) {
    if (series.isEmpty) return {'min': 0.0, 'max': 100.0};
    final min = series.reduce((a, b) => a < b ? a : b);
    final max = series.reduce((a, b) => a > b ? a : b);
    return {
      'min': (min - padding).clamp(0.0, double.infinity),
      'max': max + padding,
    };
  }

  @override
  List<Object?> get props => [labels, series];

  @override
  String toString() => 'WeightChartModel(labels: ${labels.length}, series: ${series.length}, hasData: $hasData)';
}
