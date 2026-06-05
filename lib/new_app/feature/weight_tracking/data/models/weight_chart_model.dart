// lib/features/weight_tracking/data/models/weight_chart_model.dart

class WeightChartModel {
  final List<DateTime> labels;
  final List<double> series;

  const WeightChartModel({
    required this.labels,
    required this.series,
  });

  factory WeightChartModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final labels = (data['labels'] as List)
        .map((e) => DateTime.parse(e as String))
        .toList();
    final series = (data['series'] as List)
        .map((e) => double.parse(e.toString()))
        .toList();

    return WeightChartModel(labels: labels, series: series);
  }

  bool get hasData => series.isNotEmpty;
}
