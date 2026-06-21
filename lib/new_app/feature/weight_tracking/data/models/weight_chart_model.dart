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
    // دعم كل من json['data'] و json المباشر
    final data = json['data'] ?? json;

    // تحويل آمن للـ labels
    List<DateTime> parseLabels(dynamic labelsData) {
      if (labelsData == null || labelsData is! List) return [];
      try {
        return labelsData.map((e) {
          try {
            if (e is String) {
              return DateTime.parse(e);
            }
            return DateTime.now();
          } catch (_) {
            return DateTime.now();
          }
        }).toList();
      } catch (e) {
        return [];
      }
    }

    // تحويل آمن للـ series
    List<double> parseSeries(dynamic seriesData) {
      if (seriesData == null || seriesData is! List) return [];
      try {
        return seriesData.map((e) {
          try {
            return (e as num).toDouble();
          } catch (_) {
            return 0.0;
          }
        }).toList();
      } catch (e) {
        return [];
      }
    }

    final labelsList = data['labels'] as List? ?? [];
    final seriesList = data['series'] as List? ?? [];

    return WeightChartModel(
      labels: parseLabels(labelsList),
      series: parseSeries(seriesList),
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
    return const WeightChartModel(
      labels: [],
      series: [],
    );
  }

  // ==================== GETTERS ====================
  bool get hasData => series.isNotEmpty && labels.isNotEmpty;
  bool get hasValidData => hasData && series.length == labels.length;

  int get dataCount => series.length;

  double? get minValue {
    if (series.isEmpty) return null;
    return series.reduce((a, b) => a < b ? a : b);
  }

  double? get maxValue {
    if (series.isEmpty) return null;
    return series.reduce((a, b) => a > b ? a : b);
  }

  double? get latestValue {
    if (series.isEmpty) return null;
    return series.last;
  }

  double? get firstValue {
    if (series.isEmpty) return null;
    return series.first;
  }

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

  // ==================== OPERATIONS ====================

  /// الحصول على النقاط للرسم البياني
  List<Map<String, dynamic>> getChartPoints() {
    if (!hasValidData) return [];

    return List.generate(series.length, (index) {
      return {
        'index': index,
        'label': _formatDate(labels[index]),
        'value': series[index],
      };
    });
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diff =
        today.difference(DateTime(date.year, date.month, date.day)).inDays;

    if (diff == 0) return 'اليوم';
    if (diff == 1) return 'أمس';
    if (diff < 7) return 'منذ $diff أيام';
    if (diff < 14) return 'الأسبوع الماضي';
    if (diff < 30) return 'منذ ${(diff / 7).round()} أسابيع';
    if (diff < 365) return '${date.day}/${date.month}';
    return '${date.day}/${date.month}/${date.year}';
  }

  /// الحصول على البيانات المختصرة (للعرض)
  WeightChartModel getSimplified(int maxPoints) {
    if (series.length <= maxPoints) return this;

    final step = (series.length / maxPoints).ceil();
    final newLabels = <DateTime>[];
    final newSeries = <double>[];

    for (int i = 0; i < series.length; i += step) {
      newLabels.add(labels[i]);
      newSeries.add(series[i]);
    }

    // تأكد من إضافة آخر نقطة
    if (newLabels.last != labels.last) {
      newLabels.add(labels.last);
      newSeries.add(series.last);
    }

    return WeightChartModel(
      labels: newLabels,
      series: newSeries,
    );
  }

  /// الحصول على النطاق المناسب للرسم البياني
  Map<String, double> getChartRange({double padding = 2.0}) {
    if (series.isEmpty) {
      return {'min': 0.0, 'max': 100.0};
    }

    final min = series.reduce((a, b) => a < b ? a : b);
    final max = series.reduce((a, b) => a > b ? a : b);

    return {
      'min': (min - padding).clamp(0.0, double.infinity),
      'max': max + padding,
    };
  }

  // ==================== EQUATABLE ====================
  @override
  List<Object?> get props => [labels, series];

  @override
  String toString() {
    return '''
WeightChartModel(
  labels: ${labels.length} points,
  series: ${series.length} points,
  hasData: $hasData
)''';
  }
}
