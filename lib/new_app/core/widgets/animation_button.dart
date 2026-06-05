import 'package:flutter/material.dart';

class AnimatedMenuButton extends StatefulWidget {
  final VoidCallback onTap;

  const AnimatedMenuButton({
    super.key,
    required this.onTap,
  });

  @override
  State<AnimatedMenuButton> createState() => _AnimatedMenuButtonState();
}

class _AnimatedMenuButtonState extends State<AnimatedMenuButton> {
  double scale = 1;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => scale = 0.9),
      onTapUp: (_) {
        setState(() => scale = 1);
        widget.onTap();
      },
      onTapCancel: () => setState(() => scale = 1),
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 120),
        child: const Icon(Icons.menu),
      ),
    );
  }
}
