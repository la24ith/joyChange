// lib/features/home/domain/entities/post.dart

import 'package:equatable/equatable.dart';

class Author extends Equatable {
  final int id;
  final String name;

  const Author({
    required this.id,
    required this.name,
  });

  @override
  List<Object?> get props => [id, name];
}

class Post extends Equatable {
  final int id;
  final String title;
  final String slug;
  final String content;
  final String? excerpt;
  final String? thumbnail;
  final String? thumbnailUrl;
  final String status;
  final DateTime publishedAt;
  final int viewCount;
  final bool isFeatured;
  final bool allowDownload;
  final Author author;
  final dynamic category;
  final dynamic patientSegment;
  final DateTime createdAt;

  const Post({
    required this.id,
    required this.title,
    required this.slug,
    required this.content,
    this.excerpt,
    this.thumbnail,
    this.thumbnailUrl,
    required this.status,
    required this.publishedAt,
    required this.viewCount,
    required this.isFeatured,
    required this.allowDownload,
    required this.author,
    this.category,
    this.patientSegment,
    required this.createdAt,
  });

  /// Get formatted date string
  String get formattedDate {
    // TODO: Format according to locale
    return '${publishedAt.day}/${publishedAt.month}/${publishedAt.year}';
  }

  @override
  List<Object?> get props => [
        id,
        title,
        slug,
        content,
        excerpt,
        thumbnail,
        thumbnailUrl,
        status,
        publishedAt,
        viewCount,
        isFeatured,
        allowDownload,
        author,
        category,
        patientSegment,
        createdAt,
      ];
}
