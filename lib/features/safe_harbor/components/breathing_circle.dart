import 'package:flutter/material.dart';
import '../../../core/constants.dart';

/// 呼吸圆圈组件
/// 显示呼吸引导动画
class BreathingCircle extends StatefulWidget {
  final bool isActive;
  final VoidCallback? onComplete;
  final Color? color;

  const BreathingCircle({
    super.key,
    this.isActive = true,
    this.onComplete,
    this.color,
  });

  @override
  State<BreathingCircle> createState() => _BreathingCircleState();
}

class _BreathingCircleState extends State<BreathingCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  BreathingPhase _currentPhase = BreathingPhase.inhale;

  @override
  void initState() {
    super.initState();
    _initAnimation();
  }

  void _initAnimation() {
    _controller = AnimationController(
      duration: const Duration(seconds: AppConstants.breathingCycleSeconds),
      vsync: this,
    );

    // 缩放动画
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // 透明度动画
    _opacityAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.addListener(() {
      if (!mounted) return;

      // 根据动画进度确定呼吸阶段
      final progress = _controller.value;

      if (progress < 0.33) {
        _currentPhase = BreathingPhase.inhale;
      } else if (progress < 0.5) {
        _currentPhase = BreathingPhase.hold;
      } else {
        _currentPhase = BreathingPhase.exhale;
      }
    });

    if (widget.isActive) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(BreathingCircle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getBreathingText() {
    switch (_currentPhase) {
      case BreathingPhase.inhale:
        return '吸气...';
      case BreathingPhase.hold:
        return '屏息...';
      case BreathingPhase.exhale:
        return '呼气...';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? const Color(0xFF4ECDC4);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 呼吸圆圈
            Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(_opacityAnimation.value),
                  border: Border.all(
                    color: color,
                    width: 2.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            // 呼吸提示文本
            Text(
              _getBreathingText(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            // 呼吸说明
            Text(
              '跟随圆圈，慢慢呼吸',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// 星光背景组件
class Starfield extends StatefulWidget {
  const Starfield({super.key});

  @override
  State<Starfield> createState() => _StarfieldState();
}

class _StarfieldState extends State<Starfield>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Star> _stars = [];

  @override
  void initState() {
    super.initState();
    _initStars();
    _initAnimation();
  }

  void _initStars() {
    final random = DateTime.now().millisecondsSinceEpoch;
    for (int i = 0; i < 50; i++) {
      _stars.add(Star(
        x: (random + i * 137) % 1000 / 1000,
        y: (random + i * 173) % 1000 / 1000,
        size: ((random + i * 97) % 30) / 10 + 1,
        speed: ((random + i * 53) % 100) / 10000 + 0.0001,
        opacity: ((random + i * 71) % 60) / 100 + 0.2,
      ));
    }
  }

  void _initAnimation() {
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
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
          size: Size.infinite,
          painter: _StarPainter(stars: _stars, progress: _controller.value),
        );
      },
    );
  }
}

class _StarPainter extends CustomPainter {
  final List<Star> stars;
  final double progress;

  _StarPainter({required this.stars, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final star in stars) {
      final y = (star.y + progress * star.speed * 1000) % 1.0;
      final opacity = star.opacity * (0.5 + 0.5 * (1 + (progress * 10 % 2 - 1)).abs());

      paint.color = const Color(0xFFF8F9FA).withOpacity(opacity);
      canvas.drawCircle(
        Offset(star.x * size.width, y * size.height),
        star.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_StarPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class Star {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double opacity;

  Star({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}
