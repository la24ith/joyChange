// lib/features/weight_tracking/presentation/bloc/weight_event.dart
import 'package:equatable/equatable.dart';

abstract class WeightEvent extends Equatable {
  const WeightEvent();

  @override
  List<Object?> get props => [];
}

class LoadWeightsEvent extends WeightEvent {
  final bool forceRefresh;

  const LoadWeightsEvent({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

class RefreshWeightsEvent extends WeightEvent {}

class FetchWeightData extends WeightEvent {
  final bool forceRefresh;

  const FetchWeightData({this.forceRefresh = false});
}

class AddWeightEvent extends WeightEvent {
  final double weight;
  final DateTime date;
  final String? notes;

  const AddWeightEvent({
    required this.weight,
    required this.date,
    this.notes,
  });

  @override
  List<Object?> get props => [weight, date, notes];
}

class ClearCacheEvent extends WeightEvent {}

class GetCacheInfoEvent extends WeightEvent {}
