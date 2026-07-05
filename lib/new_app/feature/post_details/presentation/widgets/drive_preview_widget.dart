// lib/new_app/feature/post_details/presentation/widgets/drive_preview_widget.dart
//
// ✅ معاينة ملفات غوغل درايف (فيديو أو ملفات عامة) داخل التطبيق عبر WebView
// نستخدم رابط /preview الرسمي من غوغل لأنه الوحيد الذي يدعم الستريمنغ
// بشكل موثوق (روابط uc?export=download مخصصة للتحميل وليست للعرض المباشر)
//
// ⚠️ الشكل الداخلي لمشغل الفيديو نفسه (أزرار التشغيل، الشريط...) يظل
// واجهة جوجل نفسها لأنه محتوى ويب مضمّن، ولا يمكن "تصميمه" من تطبيقنا.
// اللي أضفناه هنا هو طبقة تحكم فوقه: تكبير لملء الشاشة + فتح خارجي احتياطي.
//
// الحزم المطلوبة: webview_flutter, url_launcher

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:joy_of_change_v3/new_app/core/utils/media_source_helper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class GoogleDrivePreview extends StatefulWidget {
  final String driveUrl;

  const GoogleDrivePreview({super.key, required this.driveUrl});

  @override
  State<GoogleDrivePreview> createState() => _GoogleDrivePreviewState();
}

class _GoogleDrivePreviewState extends State<GoogleDrivePreview> {
  WebViewController? _webController;
  bool _isLoading = true;
  bool _hasError = false;
  bool _controlsVisible = true;
  String? _previewUrl;

  @override
  void initState() {
    super.initState();
    _setupController();
  }

  void _setupController() {
    final fileId = MediaSourceHelper.extractDriveFileId(widget.driveUrl);

    if (fileId == null) {
      setState(() => _hasError = true);
      return;
    }

    _previewUrl = 'https://drive.google.com/file/d/$fileId/preview';

    _webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
          onWebResourceError: (error) {
            // ✅ صفحة /preview بتحمّل موارد فرعية (iframes زي auth_warmup،
            // سكريبتات تتبّع...). فشل مورد فرعي لا يعني فشل عرض الفيديو،
            // فنعتبره خطأ فادح فقط لو كان من الإطار الرئيسي نفسه.
            if (error.isForMainFrame == false) return;
            debugPrint(
                '❌ GoogleDrivePreview main-frame error: ${error.description} (${error.errorCode})');
            if (mounted) {
              setState(() {
                _isLoading = false;
                _hasError = true;
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(_previewUrl!));
  }

  void _retry() {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    _setupController();
  }

  Future<void> _openExternally() async {
    final uri = Uri.tryParse(widget.driveUrl);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _openFullscreen() {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: true,
        transitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (_, __, ___) =>
            _DriveFullscreenPage(driveUrl: widget.driveUrl),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError || _webController == null) {
      return _DriveErrorState(onRetry: _retry, onOpenExternally: _openExternally);
    }

    return GestureDetector(
      onTap: () => setState(() => _controlsVisible = !_controlsVisible),
      child: Stack(
        alignment: Alignment.center,
        children: [
          WebViewWidget(controller: _webController!),
          if (_isLoading) const CircularProgressIndicator(color: Colors.teal),
          if (_controlsVisible && !_isLoading)
            Positioned(
              top: 8,
              right: 8,
              child: Row(
                children: [
                  _DriveControlButton(
                    icon: Icons.open_in_new,
                    onTap: _openExternally,
                  ),
                  const SizedBox(width: 8),
                  _DriveControlButton(
                    icon: Icons.fullscreen,
                    onTap: _openFullscreen,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _DriveControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _DriveControlButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.55),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}

class _DriveErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  final VoidCallback onOpenExternally;

  const _DriveErrorState({
    required this.onRetry,
    required this.onOpenExternally,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[900],
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.white54, size: 40),
              const SizedBox(height: 8),
              const Text(
                'تعذر عرض ملف غوغل درايف',
                style: TextStyle(color: Colors.white54),
              ),
              const SizedBox(height: 16),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                children: [
                  TextButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh, color: Colors.teal),
                    label: const Text('إعادة المحاولة',
                        style: TextStyle(color: Colors.teal)),
                  ),
                  TextButton.icon(
                    onPressed: onOpenExternally,
                    icon: const Icon(Icons.open_in_new, color: Colors.teal),
                    label: const Text('فتح في درايف',
                        style: TextStyle(color: Colors.teal)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ✅ صفحة ملء الشاشة: بتدوّر الشاشة landscape وتخفي أشرطة النظام،
// مع زرار إغلاق واضح، وبترجع كل حاجة لوضعها الطبيعي عند الخروج.
class _DriveFullscreenPage extends StatefulWidget {
  final String driveUrl;

  const _DriveFullscreenPage({required this.driveUrl});

  @override
  State<_DriveFullscreenPage> createState() => _DriveFullscreenPageState();
}

class _DriveFullscreenPageState extends State<_DriveFullscreenPage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: GoogleDrivePreview(driveUrl: widget.driveUrl),
            ),
            Positioned(
              top: 8,
              left: 8,
              child: _DriveControlButton(
                icon: Icons.close,
                onTap: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}