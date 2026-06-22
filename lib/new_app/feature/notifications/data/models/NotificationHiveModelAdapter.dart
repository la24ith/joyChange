import 'package:hive/hive.dart';
import 'notification_hive_model.dart';

class NotificationHiveModelAdapter extends TypeAdapter<NotificationHiveModel> {
  @override
  final int typeId = 10;

  @override
  NotificationHiveModel read(BinaryReader reader) {
    final fields = <int, dynamic>{
      for (int i = 0; i < reader.readByte(); i++)
        reader.readByte(): reader.read(),
    };

    return NotificationHiveModel(
      id: fields[0] as int?,
      title: fields[1] as String?,
      message: fields[2] as String?,
      type: fields[3] as String?,
      imageUrl: fields[4] as String?,
      link: fields[5] as String?,
      sendAt: fields[6] as DateTime?,
      sentAt: fields[7] as DateTime?,
      expiresAt: fields[8] as DateTime?,
      isRead: fields[9] as bool?,
      readAt: fields[10] as DateTime?,
      receivedAt: fields[11] as DateTime?,
      isScheduled: fields[12] as bool?,
      lastSyncedAt: fields[13] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, NotificationHiveModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.message)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.imageUrl)
      ..writeByte(5)
      ..write(obj.link)
      ..writeByte(6)
      ..write(obj.sendAt)
      ..writeByte(7)
      ..write(obj.sentAt)
      ..writeByte(8)
      ..write(obj.expiresAt)
      ..writeByte(9)
      ..write(obj.isRead)
      ..writeByte(10)
      ..write(obj.readAt)
      ..writeByte(11)
      ..write(obj.receivedAt)
      ..writeByte(12)
      ..write(obj.isScheduled)
      ..writeByte(13)
      ..write(obj.lastSyncedAt);
  }
}
