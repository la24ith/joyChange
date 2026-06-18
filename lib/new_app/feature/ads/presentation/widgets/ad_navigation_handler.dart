// lib/features/ads/presentation/widgets/ad_navigation_handler.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../bloc/ads_bloc.dart';
import '../bloc/ads_event.dart';
import '../bloc/ads_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// يعالج طلب التنقل الناتج عن نقرة على إعلان: يفتح رابطاً خارجياً
/// بالمتصفح، أو ينقل المستخدم داخلياً عبر [Navigator] حسب [linkType].
///
/// ملاحظة حول الروابط الداخلية: بما أن المشروع لا يملك حالياً نظام
/// Routing موحّد بأسماء معروفة، فإننا نتعامل مع [linkUrl] في الحالة
/// الداخلية كاسم "route" يُمرَّر مباشرة إلى Navigator.pushNamed. هذا
/// يتطلب أن تكون الروابط الداخلية مُعرَّفة ضمن `routes` أو
/// `onGenerateRoute` في MaterialApp (مثل: '/offers', '/article/3').
/// عند إضافة GoRouter لاحقاً، يكفي تعديل هذه الدالة فقط دون أي تغيير
/// في باقي طبقات الميزة.
Future<void> handleAdNavigation(
  BuildContext context,
  AdNavigationRequest? request,
) async {
  if (request == null) return;

  // نخبر الـ Bloc فوراً أن هذا الطلب قد عُولج، لمنع إعادة تنفيذه
  // عند أي rebuild لاحق للواجهة (مثل تغيير الثيم أو إعادة فتح الشاشة).
  context.read<AdsBloc>().add(const AdNavigationHandledEvent());

  final linkUrl = request.linkUrl;
  if (linkUrl == null || linkUrl.isEmpty) return;

  if (request.linkType == 'internal') {
    if (!context.mounted) return;
    try {
      await Navigator.of(context).pushNamed(linkUrl);
    } catch (e) {
      // الـ route غير معرّف؛ نتجنب انهيار التطبيق ونعرض تنبيهاً بسيطاً
      // بدل تجاهل الخطأ بصمت أو إسقاط التطبيق.
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('الصفحة المطلوبة غير متاحة حالياً')),
        );
      }
    }
    return;
  }

  // external
  final uri = Uri.tryParse(linkUrl);
  if (uri == null) return;

  try {
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذّر فتح الرابط')),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذّر فتح الرابط')),
      );
    }
  }
}
