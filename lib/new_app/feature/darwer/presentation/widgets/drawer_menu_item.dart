// lib/features/drawer/presentation/widgets/drawer_menu_item.dart

import 'package:flutter/material.dart';
import 'package:joy_of_change_v3/new_app/feature/darwer/data/models/drawer_models.dart';

class DrawerMenuItem extends StatefulWidget {
  final MenuItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const DrawerMenuItem({
    super.key,
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<DrawerMenuItem> createState() => _DrawerMenuItemState();
}

class _DrawerMenuItemState extends State<DrawerMenuItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? (isDark
                    ? Colors.teal.withOpacity(0.2)
                    : Colors.teal.withOpacity(0.1))
                : (_isHovered
                    ? (isDark ? Colors.grey[800] : Colors.grey[100])
                    : Colors.transparent),
            borderRadius: BorderRadius.circular(16),
            border: widget.isSelected
                ? Border.all(
                    color: Colors.teal.withOpacity(0.5),
                    width: 1,
                  )
                : null,
          ),
          child: Row(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  widget.isSelected ? widget.item.activeIcon : widget.item.icon,
                  key: ValueKey(widget.isSelected),
                  size: 22,
                  color: widget.isSelected
                      ? Colors.teal
                      : (isDark ? Colors.white70 : Colors.black54),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  widget.item.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        widget.isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: widget.isSelected
                        ? Colors.teal
                        : (isDark ? Colors.white70 : Colors.black54),
                  ),
                ),
              ),
              if (widget.isSelected)
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.teal,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
