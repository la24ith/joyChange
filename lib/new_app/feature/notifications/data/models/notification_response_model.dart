import 'notification_hive_model.dart';

class NotificationResponseModel {
  final int id;
  final String title;
  final String message;
  final String? type;
  final String? imageUrl;
  final String? link;
  final DateTime? sendAt;
  final DateTime? sentAt;
  final DateTime? expiresAt;
  final bool isRead;
  final DateTime? readAt;
  final DateTime? receivedAt;

  NotificationResponseModel({
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
  });

  factory NotificationResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return NotificationResponseModel(
      id: json['id'],
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'],
      imageUrl: json['image_url'],
      link: json['link'],
      sendAt: json['send_at'] != null ? DateTime.parse(json['send_at']) : null,
      sentAt: json['sent_at'] != null ? DateTime.parse(json['sent_at']) : null,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'])
          : null,
      isRead: json['is_read'] ?? false,
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      receivedAt: json['received_at'] != null
          ? DateTime.parse(json['received_at'])
          : null,
    );
  }

  NotificationHiveModel toHiveModel() {
    return NotificationHiveModel(
      id: id,
      title: title,
      message: message,
      type: type,
      imageUrl: imageUrl,
      link: link,
      sendAt: sendAt,
      sentAt: sentAt,
      expiresAt: expiresAt,
      isRead: isRead,
      readAt: readAt,
      receivedAt: receivedAt,
      isScheduled: false,
      lastSyncedAt: DateTime.now(),
    );
  }
}
