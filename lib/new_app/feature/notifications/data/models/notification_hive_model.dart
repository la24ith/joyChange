import 'package:hive/hive.dart';

@HiveType(typeId: 10)
class NotificationHiveModel extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String message;

  @HiveField(3)
  String? type;

  @HiveField(4)
  String? imageUrl;

  @HiveField(5)
  String? link;

  @HiveField(6)
  DateTime? sendAt;

  @HiveField(7)
  DateTime? sentAt;

  @HiveField(8)
  DateTime? expiresAt;

  @HiveField(9)
  bool isRead;

  @HiveField(10)
  DateTime? readAt;

  @HiveField(11)
  DateTime? receivedAt;

  @HiveField(12)
  bool isScheduled;

  @HiveField(13)
  DateTime? lastSyncedAt;

  NotificationHiveModel({
    required this.id,
    required this.title,
    required this.message,
    this.type,
    this.imageUrl,
    this.link,
    this.sendAt,
    this.sentAt,
    this.expiresAt,
    required this.isRead,
    this.readAt,
    this.receivedAt,
    required this.isScheduled,
    this.lastSyncedAt,
  });

  NotificationHiveModel copyWith({
    int? id,
    String? title,
    String? message,
    String? type,
    String? imageUrl,
    String? link,
    DateTime? sendAt,
    DateTime? sentAt,
    DateTime? expiresAt,
    bool? isRead,
    DateTime? readAt,
    DateTime? receivedAt,
    bool? isScheduled,
    DateTime? lastSyncedAt,
  }) {
    return NotificationHiveModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      link: link ?? this.link,
      sendAt: sendAt ?? this.sendAt,
      sentAt: sentAt ?? this.sentAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      receivedAt: receivedAt ?? this.receivedAt,
      isScheduled: isScheduled ?? this.isScheduled,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }
}
