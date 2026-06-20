import 'package:equatable/equatable.dart';

enum AdType { inline, banner, interstitial }

enum AdPosition { top, bottom, middle }

enum LinkType { external, internal }

class Ad extends Equatable {
  final int id;
  final String title;
  final String content;
  final String? imageUrl;
  final String? image;

  final AdType type;
  final String? linkUrl;
  final LinkType linkType;
  final AdPosition position;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final int impressionCount;
  final int clickCount;

  const Ad({
    required this.id,
    required this.title,
    required this.content,
    this.imageUrl,
    this.image,
    required this.type,
    this.linkUrl,
    required this.linkType,
    required this.position,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.impressionCount,
    required this.clickCount,
  });

  bool get isExpired => DateTime.now().isAfter(endDate);
  bool get isNotStarted => DateTime.now().isBefore(startDate);
  bool get isValid => isActive && !isExpired && !isNotStarted;

  @override
  List<Object?> get props => [
        id,
        title,
        content,
        imageUrl,
        type,
        linkUrl,
        linkType,
        position,
        startDate,
        endDate,
        isActive,
        impressionCount,
        clickCount,
      ];
}
