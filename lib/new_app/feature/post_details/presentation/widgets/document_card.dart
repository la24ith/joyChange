// lib/new_app/feature/post_details/presentation/widgets/document_card.dart
//
// ✅ بطاقة لعناصر media من نوع document (ملف PDF/Word...).
// روابط المستندات المرفوعة روابط موقّعة مؤقتة لكنها تحتاج هيدرز
// Authorization و X-Device-Id، لذا لا يمكن فتحها مباشرة في المتصفح.
// نحمّل الملف مع الهيدرز إلى ملف مؤقت ثم نفتح قائمة المشاركة ليختار
// المستخدم التطبيق المناسب لفتحه.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:joy_of_change_v3/new_app/core/constant/api_endpoints.dart';
import 'package:joy_of_change_v3/new_app/core/utils/url_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../domain/entities/media.dart';

class DocumentCard extends StatefulWidget {
  final Media media;

  const DocumentCard({super.key, required this.media});

  @override
  State<DocumentCard> createState() => _DocumentCardState();
}

class _DocumentCardState extends State<DocumentCard> {
  bool _isDownloading = false;

  String get _fileName {
    final name = widget.media.fileName;
    if (name.isNotEmpty) return name;
    final segments = Uri.tryParse(widget.media.url)?.pathSegments ?? const [];
    return segments.isNotEmpty ? segments.last : 'document';
  }

  Future<File> _download() async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/post_media_${widget.media.id}_$_fileName');
    if (await file.exists() && await file.length() > 0) return file;

    final headers = await UrlHelper.getAuthHeaders();
    final response = await http
        .get(Uri.parse(ApiEndpoints.mediaUrl(widget.media.url)),
            headers: headers)
        .timeout(const Duration(seconds: 120));

    if (response.statusCode != 200 || response.bodyBytes.isEmpty) {
      throw Exception('Download failed: HTTP ${response.statusCode}');
    }
    await file.writeAsBytes(response.bodyBytes);
    return file;
  }

  Future<void> _open() async {
    if (_isDownloading) return;
    setState(() => _isDownloading = true);
    try {
      final file = await _download();
      await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
    } catch (e) {
      debugPrint('❌ Document open error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر تحميل الملف، حاول مرة أخرى')),
        );
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: isDark ? Colors.grey[850] : Colors.grey[100],
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.description_rounded,
                size: 64, color: Colors.teal.shade400),
            const SizedBox(height: 16),
            Text(
              _fileName,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isDownloading ? null : _open,
              icon: _isDownloading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.download_rounded),
              label: Text(_isDownloading ? 'جاري التحميل...' : 'فتح الملف'),
            ),
          ],
        ),
      ),
    );
  }
}
