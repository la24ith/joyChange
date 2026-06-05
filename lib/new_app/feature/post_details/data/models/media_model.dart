// lib/features/post_details/data/models/media_model.dart

import 'package:joy_of_change_v3/new_app/core/constant/api_endpoints.dart';
import 'package:joy_of_change_v3/new_app/core/utils/url_helper.dart';

import '../../domain/entities/media.dart';

class MediaModel extends Media {
  const MediaModel({
    required super.id,
    required super.type,
    required super.url,
    super.fileUrl,
    required super.fileName,
    required super.fileSize,
    required super.mimeType,
    super.duration,
    super.thumbnail,
    super.thumbnailUrl,
    required super.sortOrder,
    required super.isDownloadable,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'url': url,
      'file_url': fileUrl,
      'file_name': fileName,
      'file_size': fileSize,
      'mime_type': mimeType,
      'duration': duration,
      'thumbnail': thumbnail,
      'thumbnail_url': thumbnailUrl,
      'sort_order': sortOrder,
      'is_downloadable': isDownloadable,
    };
  }

  Media toEntity() {
    return Media(
      id: id,
      type: type,
      url: url,
      fileUrl: fileUrl,
      fileName: fileName,
      fileSize: fileSize,
      mimeType: mimeType,
      duration: duration,
      thumbnail: thumbnail,
      thumbnailUrl: thumbnailUrl,
      sortOrder: sortOrder,
      isDownloadable: isDownloadable,
    );
  }

  factory MediaModel.fromJson(Map<String, dynamic> json) {
    final typeString = json['type'] as String;
    MediaType type;
    switch (typeString) {
      case 'image':
        type = MediaType.image;
        break;
      case 'video':
        type = MediaType.video;
        break;
      case 'audio':
        type = MediaType.audio;
        break;
      default:
        type = MediaType.image;
    }

    // الحصول على الرابط الأصلي
    final rawUrl = json['url'] as String? ?? json['file_url'] as String?;

    // ✅ تحويل الرابط إلى HTTPS وإضافة ngrok

    return MediaModel(
      id: json['id'] as int,
      type: type,
      url: rawUrl!,
      fileUrl: (json['file_url'] as String?),
      fileName: json['file_name'] as String? ?? '',
      fileSize: json['file_size'] as int? ?? 0,
      mimeType: json['mime_type'] as String? ?? '',
      duration: json['duration'] as int?,
      thumbnail: (json['thumbnail'] as String?),
      thumbnailUrl: (json['thumbnail_url'] as String?),
      sortOrder: json['sort_order'] as int? ?? 0,
      isDownloadable: json['is_downloadable'] as bool? ?? false,
    );
  }
}
