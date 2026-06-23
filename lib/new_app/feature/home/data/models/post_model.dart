// lib/features/home/data/models/post_model.dart

import '../../domain/entities/post.dart';

class AuthorModel extends Author {
  const AuthorModel({
    required super.id,
    required super.name,
  });

  factory AuthorModel.fromJson(Map<dynamic, dynamic> json) {
    return AuthorModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'غير معروف',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class PostModel extends Post {
  const PostModel({
    required super.id,
    required super.title,
    required super.slug,
    required super.content,
    super.excerpt,
    super.thumbnail,
    super.thumbnailUrl,
    required super.status,
    required super.publishedAt,
    required super.viewCount,
    required super.isFeatured,
    required super.allowDownload,
    required super.author,
    super.category,
    super.patientSegment,
    required super.createdAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    // ✅ التعامل مع null بأمان لجميع الحقول
    return PostModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? 'بدون عنوان',
      slug: json['slug'] as String? ?? '',
      content: json['content'] as String? ?? '',
      excerpt: json['excerpt'] as String?,
      thumbnail: json['thumbnail'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      status: json['status'] as String? ?? 'draft',
      publishedAt: json['published_at'] != null
          ? DateTime.parse(json['published_at'] as String)
          : DateTime.now(),
      viewCount: json['view_count'] as int? ?? 0,
      isFeatured: json['is_featured'] as bool? ?? false,
      allowDownload: json['allow_download'] as bool? ?? false,
      author: json['author'] != null
          ? AuthorModel.fromJson(json['author'] as Map<String, dynamic>)
          : const AuthorModel(id: 0, name: 'غير معروف'),
      category: json['category'],
      patientSegment: json['patient_segment'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
      'content': content,
      'excerpt': excerpt,
      'thumbnail': thumbnail,
      'thumbnail_url': thumbnailUrl,
      'status': status,
      'published_at': publishedAt.toIso8601String(),
      'view_count': viewCount,
      'is_featured': isFeatured,
      'allow_download': allowDownload,
      'author': (author as AuthorModel).toJson(),
      'category': category,
      'patient_segment': patientSegment,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Convert to domain entity
  Post toEntity() {
    return Post(
      id: id,
      title: title,
      slug: slug,
      content: content,
      excerpt: excerpt,
      thumbnail: thumbnail,
      thumbnailUrl: thumbnailUrl,
      status: status,
      publishedAt: publishedAt,
      viewCount: viewCount,
      isFeatured: isFeatured,
      allowDownload: allowDownload,
      author: author,
      category: category,
      patientSegment: patientSegment,
      createdAt: createdAt,
    );
  }

  /// Create from domain entity
  factory PostModel.fromEntity(Post post) {
    return PostModel(
      id: post.id,
      title: post.title,
      slug: post.slug,
      content: post.content,
      excerpt: post.excerpt,
      thumbnail: post.thumbnail,
      thumbnailUrl: post.thumbnailUrl,
      status: post.status,
      publishedAt: post.publishedAt,
      viewCount: post.viewCount,
      isFeatured: post.isFeatured,
      allowDownload: post.allowDownload,
      author: post.author,
      category: post.category,
      patientSegment: post.patientSegment,
      createdAt: post.createdAt,
    );
  }
}

/// Pagination model for posts
class PostsPagination {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  const PostsPagination({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory PostsPagination.fromJson(Map<String, dynamic> json) {
    return PostsPagination(
      currentPage: json['current_page'] as int? ?? 1,
      lastPage: json['last_page'] as int? ?? 1,
      perPage: json['per_page'] as int? ?? 10,
      total: json['total'] as int? ?? 0,
    );
  }

  bool get hasNextPage => currentPage < lastPage;
  bool get hasPreviousPage => currentPage > 1;
}
