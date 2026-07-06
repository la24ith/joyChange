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

// ✅ إصلاح: تمت إزالة FetchWeightData — كان حدثاً معرَّفاً بلا أي هاندلر
// مسجَّل له في WeightBloc (on<FetchWeightData> غير موجود)، ولا يملك
// props صحيحة لـ Equatable. كود ميت بالكامل.

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

// ✅ إصلاح: تمت إزالة GetCacheInfoEvent — كان الهاندلر الخاص به فارغاً
// تماماً في WeightBloc. معلومات الكاش تُقرأ الآن مباشرة عبر
// GetCacheInfoUseCase من الشاشة (انظر weight_screen.dart).
