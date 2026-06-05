// lib/features/post_details/domain/entities/media.dart

import 'package:equatable/equatable.dart';

enum MediaType { image, video, audio }

class Media extends Equatable {
  final int id;
  final MediaType type;
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

  @override
  List<Object?> get props => [
        id,
        type,
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
