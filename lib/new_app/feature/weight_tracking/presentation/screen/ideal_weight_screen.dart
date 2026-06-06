// lib/features/weight_tracking/presentation/pages/ideal_weight_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:joy_of_change_v3/new_app/feature/weight_tracking/domain/entities/weight_goal_status.dart';
//import 'package:share_plus/share_plus.dart';
import 'dart:math' as math;

import '../bloc/weight_bloc.dart';
import '../bloc/weight_state.dart';

class IdealWeightPage extends StatefulWidget {
  final bool isSplashMode;

  const IdealWeightPage({
    super.key,
    this.isSplashMode = false,
  });

  @override
  State<IdealWeightPage> createState() => _IdealWeightPageState();
}

class _IdealWeightPageState extends State<IdealWeightPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _confettiController;
  bool _showConfetti = true;

  @override
  void initState() {
    super.initState();
    _confettiController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _showConfetti = false;
        });
        _confettiController.stop();
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<WeightBloc>().state;

    if (state is WeightLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state is! WeightLoaded) {
      return const Scaffold(
        body: Center(
          child: Text('لا توجد بيانات'),
        ),
      );
    }

    final goal = state.goalStatus;

    return _buildCelebrationScreen(goal);
  }

  Widget _buildCelebrationScreen(WeightGoalStatus goal) {
    return Stack(
      children: [
        // Gradient Background
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.teal.shade400,
                Colors.teal.shade800,
                Colors.cyan.shade900,
              ],
            ),
          ),
        ),

        // Confetti Animation
        if (_showConfetti)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: ConfettiPainter(animation: _confettiController),
              ),
            ),
          ),

        // Main Content
        SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 280,
                floating: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text(
                    widget.isSplashMode
                        ? '🎉 مبروك الإنجاز! 🎉'
                        : 'الوزن المثالي',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 10,
                          color: Colors.black26,
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.teal.shade400.withOpacity(0.3),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedTrophy(
                              controller: _confettiController,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              '🎉 مبروك!',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    blurRadius: 10,
                                    color: Colors.black26,
                                    offset: Offset(2, 2),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              goal.message.isNotEmpty
                                  ? goal.message
                                  : 'لقد وصلت إلى وزنك المثالي بنجاح',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.95),
                                shadows: [
                                  Shadow(
                                    blurRadius: 8,
                                    color: Colors.black26,
                                    offset: Offset(1, 1),
                                  ),
                                ],
                              ),
                            ),
                            if (widget.isSplashMode) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'سيتم توجيهك تلقائياً خلال 5 ثواني...',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Progress Ring Card
                    GlassmorphismCard(
                      child: Column(
                        children: [
                          const Text(
                            'إنجازك',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ProgressRing(
                            progress: 100,
                            size: 180,
                            strokeWidth: 12,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            '100% مكتمل',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'الهدف: ${goal.formattedTargetWeight}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Current and Target Weight Cards
                    Row(
                      children: [
                        Expanded(
                          child: GlassmorphismCard(
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.monitor_weight,
                                  size: 40,
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'الوزن الحالي',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  goal.formattedCurrentWeight,
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GlassmorphismCard(
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.flag,
                                  size: 40,
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'الهدف المحقق',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  goal.formattedTargetWeight,
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Ideal Weight Card
                    if (goal.idealWeight != null)
                      GlassmorphismCard(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.favorite,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'الوزن المثالي',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${goal.idealWeight!.toStringAsFixed(1)} كجم',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 20),

                    // Motivational Quote
                    GlassmorphismCard(
                      child: Column(
                        children: [
                          const Icon(
                            Icons.format_quote,
                            size: 40,
                            color: Colors.white70,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'النجاح ليس نهائياً، والفشل ليس قاتلاً، بل الشجاعة للاستمرار هي ما يهم.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                              color: Colors.white,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '- ونستون تشرشل',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Share Button
                    if (!widget.isSplashMode)
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.share, size: 24),
                          label: const Text(
                            'مشاركة الإنجاز',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            /*       Share.share('''
🎉 وصلت إلى هدفي في الوزن!

الوزن الحالي: ${goal.formattedCurrentWeight}
الهدف: ${goal.formattedTargetWeight}
${goal.idealWeight != null ? 'الوزن المثالي: ${goal.idealWeight!.toStringAsFixed(1)} كجم' : ''}

أنا فخور بإنجازي في رحلة اللياقة!
#رحلة_التغيير #الوزن_المثالي
''');
                     */
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber.shade600,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 5,
                          ),
                        ),
                      ),

                    const SizedBox(height: 32),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// GlassmorphismCard Widget
class GlassmorphismCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const GlassmorphismCard({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}

// AnimatedTrophy Widget
class AnimatedTrophy extends StatelessWidget {
  final AnimationController controller;

  const AnimatedTrophy({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: math.sin(controller.value * math.pi * 2) * 0.1,
          child: TweenAnimationBuilder(
            tween: Tween<double>(begin: 0.8, end: 1.2),
            duration: const Duration(milliseconds: 500),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.amber.shade300,
                        Colors.amber.shade600,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.emoji_events,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// ProgressRing Widget
class ProgressRing extends StatelessWidget {
  final double progress;
  final double size;
  final double strokeWidth;

  const ProgressRing({
    super.key,
    required this.progress,
    required this.size,
    required this.strokeWidth,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0, end: progress),
        duration: const Duration(seconds: 2),
        builder: (context, value, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  value: value / 100,
                  strokeWidth: strokeWidth,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              Text(
                '${value.toInt()}%',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ConfettiPainter Widget
class ConfettiPainter extends CustomPainter {
  final Animation<double> animation;
  final List<ConfettiParticle> particles;

  ConfettiPainter({required this.animation}) : particles = _generateParticles();

  static List<ConfettiParticle> _generateParticles() {
    final random = math.Random();
    return List.generate(100, (index) {
      return ConfettiParticle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: 4 + random.nextDouble() * 8,
        color: Color.fromRGBO(
          random.nextInt(256),
          random.nextInt(256),
          random.nextInt(256),
          0.8,
        ),
        speed: 0.5 + random.nextDouble() * 2,
      );
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    final progress = animation.value;

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
  bool shouldRepaint(ConfettiPainter oldDelegate) {
    return true;
  }
}

// ConfettiParticle Class
class ConfettiParticle {
  final double x;
  final double y;
  final double size;
  final Color color;
  final double speed;

  ConfettiParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.color,
    required this.speed,
  });
}
