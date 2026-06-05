// lib/features/post_details/presentation/widgets/premium_content_section.dart

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class PremiumContentSection extends StatelessWidget {
  final String content;
  final bool isDark;

  const PremiumContentSection({
    super.key,
    required this.content,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MarkdownBody(
            data: content,
            styleSheet: MarkdownStyleSheet(
              p: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
              h1: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
              h2: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
              h3: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
              a: TextStyle(
                color: Colors.teal,
                decoration: TextDecoration.underline,
              ),
              blockquote: TextStyle(
                color: isDark ? Colors.white60 : Colors.black54,
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
              code: TextStyle(
                backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                fontSize: 14,
                fontFamily: 'monospace',
              ),
              listBullet: TextStyle(
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            selectable: true,
            shrinkWrap: true,
          ),
        ],
      ),
    );
  }
}
