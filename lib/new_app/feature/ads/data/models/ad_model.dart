import '../../domain/entities/ad.dart';

class AdModel extends Ad {
  const AdModel({
    required super.id,
    required super.title,
    required super.content,
    super.imageUrl,
    required super.type,
    super.linkUrl,
    required super.linkType,
    required super.position,
    required super.startDate,
    required super.endDate,
    required super.isActive,
    required super.impressionCount,
    required super.clickCount,
  });

  factory AdModel.fromJson(Map<String, dynamic> json) {
    return AdModel(
      id: json['id'] as int,
      title: json['title'] as String,
      content: json['content'] as String,
      imageUrl: json['image_url'] as String?,
      type: _parseType(json['type'] as String),
      linkUrl: json['link_url'] as String?,
      linkType: _parseLinkType(json['link_type'] as String),
      position: _parsePosition(json['position'] as String),
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      isActive: json['is_active'] as bool,
      impressionCount: json['impression_count'] as int,
      clickCount: json['click_count'] as int,
    );
  }

  static AdType _parseType(String type) {
    switch (type.toLowerCase()) {
      case 'inline':
        return AdType.inline;
      case 'banner':
        return AdType.banner;
      case 'interstitial':
        return AdType.interstitial;
      default:
        return AdType.inline;
    }
  }

  static LinkType _parseLinkType(String type) {
    switch (type.toLowerCase()) {
      case 'external':
        return LinkType.external;
      case 'internal':
        return LinkType.internal;
      default:
        return LinkType.external;
    }
  }

  static AdPosition _parsePosition(String position) {
    switch (position.toLowerCase()) {
      case 'top':
        return AdPosition.top;
      case 'bottom':
        return AdPosition.bottom;
      case 'middle':
        return AdPosition.middle;
      default:
        return AdPosition.top;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'image_url': imageUrl,
      'type': type.name,
      'link_url': linkUrl,
      'link_type': linkType.name,
      'position': position.name,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'is_active': isActive,
      'impression_count': impressionCount,
      'click_count': clickCount,
    };
  }

  Ad toEntity() {
    return Ad(
      id: id,
      title: title,
      content: content,
      imageUrl: imageUrl,
      type: type,
      linkUrl: linkUrl,
      linkType: linkType,
      position: position,
      startDate: startDate,
      endDate: endDate,
      isActive: isActive,
      impressionCount: impressionCount,
      clickCount: clickCount,
    );
  }
}
