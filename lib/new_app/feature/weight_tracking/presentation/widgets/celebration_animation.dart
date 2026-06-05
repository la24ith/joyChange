// lib/features/weight/presentation/widgets/celebration_animation.dart
import 'package:flutter/material.dart';
import 'dart:math';

class CelebrationAnimation extends StatefulWidget {
  const CelebrationAnimation({super.key});

  @override
  State<CelebrationAnimation> createState() => _CelebrationAnimationState();
}

class _CelebrationAnimationState extends State<CelebrationAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_ConfettiParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    for (int i = 0; i < 50; i++) {
      _particles.add(_ConfettiParticle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: 8 + _random.nextDouble() * 12,
        color: Color.fromRGBO(
          _random.nextInt(256),
          _random.nextInt(256),
          _random.nextInt(256),
          0.8,
        ),
        speed: 0.5 + _random.nextDouble() * 1.5,
        angle: _random.nextDouble() * 2 * pi,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _CelebrationPainter(
            particles: _particles,
            progress: _controller.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _CelebrationPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  _CelebrationPainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()..color = particle.color;
      final yOffset = (progress * particle.speed * size.height) % size.height;
      final x = particle.x * size.width;
      final y = (particle.y * size.height + yOffset) % size.height;

      canvas.drawRect(
        Rect.fromLTWH(x, y, particle.size, particle.size),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_CelebrationPainter oldDelegate) {
    return true;
  }
}

class _ConfettiParticle {
  final double x;
  final double y;
  final double size;
  final Color color;
  final double speed;
  final double angle;

  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.color,
    required this.speed,
    required this.angle,
  });
}
