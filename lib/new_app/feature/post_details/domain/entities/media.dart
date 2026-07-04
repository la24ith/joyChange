// lib/features/post_details/domain/entities/media.dart

import 'package:equatable/equatable.dart';

enum MediaType { image, video, audio }

// ✅ جديد: نوع مصدر الميديا
enum MediaSourceType { uploaded, external }

class Media extends Equatable {
  final int id;
  final MediaType type;

  // ✅ جديد
  final MediaSourceType sourceType;
  final String? provider; // e.g. 'youtube', 'google_drive', 'vimeo', ...
  final String? externalUrl;

  final String url;
  final String? fileUrl;
  final String fileName;
  final int fileSize;
  final String mimeType;
  final int? duration;
  final String? thumbnail;
  final String? thumbnailUrl;
  final int sortOrder;
  final bool isDownloadable;

  const Media({
    required this.id,
    required this.type,
    this.sourceType = MediaSourceType.uploaded,
    this.provider,
    this.externalUrl,
    required this.url,
    this.fileUrl,
    required this.fileName,
    required this.fileSize,
    required this.mimeType,
    this.duration,
    this.thumbnail,
    this.thumbnailUrl,
    required this.sortOrder,
    required this.isDownloadable,
  });

  bool get isExternal => sourceType == MediaSourceType.external;

  /// أفضل رابط متاح لهذا العنصر (يفضّل external_url إذا كان خارجيًا)
  String get resolvedUrl {
    if (isExternal && (externalUrl != null && externalUrl!.isNotEmpty)) {
      return externalUrl!;
    }
    return url;
  }

  @override
  List<Object?> get props => [
        id,
        type,
        sourceType,
        provider,
        externalUrl,
        url,
        fileUrl,
        fileName,
        fileSize,
        mimeType,
        duration,
        thumbnail,
        thumbnailUrl,
        sortOrder,
        isDownloadable,
      ];
}
