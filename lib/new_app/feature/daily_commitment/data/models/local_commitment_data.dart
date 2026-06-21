// lib/features/daily_commitment/data/models/local_commitment_data.dart

class LocalCommitmentData {
  static const String defaultQuestion = 'هل التزمت اليوم بعادتك الإيجابية؟';

  final String question;
  final DateTime lastSyncDate;
  final bool answeredToday;
  final String? todayAnswer;
  final DateTime? answerTime;
  final int totalDays;
  final int yesCount;
  final int noCount;
  final int adherenceRate;
  final bool isSynced;
  final int skippedCount;

  const LocalCommitmentData({
    required this.question,
    required this.lastSyncDate,
    required this.answeredToday,
    this.todayAnswer,
    this.answerTime,
    required this.totalDays,
    required this.yesCount,
    required this.noCount,
    required this.adherenceRate,
    required this.isSynced,
    this.skippedCount = 0,
  });

  factory LocalCommitmentData.empty() {
    return LocalCommitmentData(
      question: defaultQuestion,
      lastSyncDate: DateTime.now(),
      answeredToday: false,
      totalDays: 0,
      yesCount: 0,
      noCount: 0,
      adherenceRate: 0,
      isSynced: true,
      skippedCount: 0,
    );
  }

  factory LocalCommitmentData.fromJson(Map<String, dynamic> json) {
    return LocalCommitmentData(
      question: json['question'] ?? defaultQuestion,
      lastSyncDate: json['lastSyncDate'] != null
          ? DateTime.parse(json['lastSyncDate'])
          : DateTime.now(),
      answeredToday: json['answeredToday'] ?? false,
      todayAnswer: json['todayAnswer'],
      answerTime: json['answerTime'] != null
          ? DateTime.parse(json['answerTime'])
          : null,
      totalDays: json['totalDays'] ?? 0,
      yesCount: json['yesCount'] ?? 0,
      noCount: json['noCount'] ?? 0,
      adherenceRate: json['adherenceRate'] ?? 0,
      isSynced: json['isSynced'] ?? true,
      skippedCount: json['skippedCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'lastSyncDate': lastSyncDate.toIso8601String(),
      'answeredToday': answeredToday,
      'todayAnswer': todayAnswer,
      'answerTime': answerTime?.toIso8601String(),
      'totalDays': totalDays,
      'yesCount': yesCount,
      'noCount': noCount,
      'adherenceRate': adherenceRate,
      'isSynced': isSynced,
      'skippedCount': skippedCount,
    };
  }

  LocalCommitmentData updateWithAnswer(String answer) {
    final newYes = answer == 'yes' ? yesCount + 1 : yesCount;
    final newNo = answer == 'no' ? noCount + 1 : noCount;
    final newTotal = totalDays + 1;
    final newRate = newTotal > 0 ? (newYes / newTotal * 100).round() : 0;

    return LocalCommitmentData(
      question: question,
      lastSyncDate: DateTime.now(),
      answeredToday: true,
      todayAnswer: answer,
      answerTime: DateTime.now(),
      totalDays: newTotal,
      yesCount: newYes,
      noCount: newNo,
      adherenceRate: newRate,
      isSynced: false,
      skippedCount: skippedCount,
    );
  }

  LocalCommitmentData markAsSynced() {
    return LocalCommitmentData(
      question: question,
      lastSyncDate: DateTime.now(),
      answeredToday: answeredToday,
      todayAnswer: todayAnswer,
      answerTime: answerTime,
      totalDays: totalDays,
      yesCount: yesCount,
      noCount: noCount,
      adherenceRate: adherenceRate,
      isSynced: true,
      skippedCount: skippedCount,
    );
  }

  LocalCommitmentData updateFromServer({
    required int total,
    required int yes,
    required int no,
    required int skipped,
    required int adherenceRate,
    required bool answeredToday,
    required String? todayAnswer,
  }) {
    return LocalCommitmentData(
      question: question,
      lastSyncDate: DateTime.now(),
      answeredToday: answeredToday,
      todayAnswer: todayAnswer,
      answerTime: answeredToday ? DateTime.now() : null,
      totalDays: total,
      yesCount: yes,
      noCount: no,
      adherenceRate: adherenceRate,
      isSynced: true,
      skippedCount: skipped,
    );
  }
}
