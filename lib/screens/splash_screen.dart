import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _gadaCtrl;
  late AnimationController _ringCtrl;
  late AnimationController _textCtrl;
  late AnimationController _exitCtrl;

  late Animation<double> _gadaOpacity;
  late Animation<double> _gadaScale;
  late Animation<double> _ringRadius;
  late Animation<double> _ringOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _textOpacity;
  late Animation<double> _exitOpacity;

  @override
  void initState() {
    super.initState();
    _gadaCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _ringCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _textCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _exitCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));

    _gadaOpacity = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _gadaCtrl, curve: Curves.easeOut));
    _gadaScale   = Tween<double>(begin: 0.7, end: 1.0).animate(
        CurvedAnimation(parent: _gadaCtrl, curve: Curves.easeOutBack));

    _ringRadius  = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _ringCtrl, curve: Curves.easeOut));
    _ringOpacity = Tween<double>(begin: 0.6, end: 0).animate(
        CurvedAnimation(parent: _ringCtrl, curve: Curves.easeIn));

    _textSlide   = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
        CurvedAnimation(parent: _textCtrl, curve: Curves.easeOutCubic));
    _textOpacity = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _textCtrl, curve: Curves.easeIn));

    _exitOpacity = Tween<double>(begin: 1, end: 0).animate(
        CurvedAnimation(parent: _exitCtrl, curve: Curves.easeIn));

    _runSequence();
  }

  Future<void> _runSequence() async {
    await Future.delayed(const Duration(milliseconds: 300));
    await _gadaCtrl.forward();
    _ringCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    await _textCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 1200));
    await _exitCtrl.forward();
    if (mounted) Navigator.of(context).pushReplacementNamed('/onboarding');
  }

  @override
  void dispose() {
    _gadaCtrl.dispose();
    _ringCtrl.dispose();
    _textCtrl.dispose();
    _exitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _exitCtrl,
      builder: (_, child) => Opacity(opacity: _exitOpacity.value, child: child),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Gada with pulsing rings ─────────────────────
              SizedBox(
                width: 320,
                height: 320,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Rings (emanate from center, synced with gada)
                    AnimatedBuilder(
                      animation: _ringCtrl,
                      builder: (_, __) => CustomPaint(
                        size: const Size(320, 320),
                        painter: _SplashRingPainter(_ringRadius.value, _ringOpacity.value),
                      ),
                    ),
                    // Gada image (enlarged & centered)
                    AnimatedBuilder(
                      animation: _gadaCtrl,
                      builder: (_, __) => Opacity(
                        opacity: _gadaOpacity.value,
                        child: Transform.scale(
                          scale: _gadaScale.value,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: Image.asset(
                              'assets/images/gada.jpg',
                              width: 250,
                              height: 250,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ── ANGAD wordmark + tagline ────────────────────
              SlideTransition(
                position: _textSlide,
                child: FadeTransition(
                  opacity: _textOpacity,
                  child: Column(
                    children: [
                      Text(
                        'ANGAD',
                        style: TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 10,
                          color: AppColors.textPrimary,
                          shadows: [
                            Shadow(color: AppColors.saffronGlow, blurRadius: 24),
                            Shadow(color: AppColors.goldGlow, blurRadius: 48),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(width: 28, height: 1, color: AppColors.gold.withValues(alpha: 0.5)),
                          const SizedBox(width: 10),
                          Text(
                            'Your Digital Kavach',
                            style: TextStyle(
                              fontSize: 14,
                              letterSpacing: 2,
                              color: AppColors.gold,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(width: 28, height: 1, color: AppColors.gold.withValues(alpha: 0.5)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SplashRingPainter extends CustomPainter {
  final double progress;
  final double opacity;
  _SplashRingPainter(this.progress, this.opacity);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    for (int i = 1; i <= 3; i++) {
      final radius = (size.width * 0.42 * progress * i / 3).clamp(0.0, size.width * 0.5);
      final alpha  = (opacity * (1.0 - (i - 1) * 0.25)).clamp(0.0, 1.0);
      final paint  = Paint()
        ..color = AppColors.saffron.withValues(alpha: alpha * 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(center, radius, paint);
    }
    // Glow fill under gada
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.saffron.withValues(alpha: 0.15 * progress),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: size.width * 0.4));
    canvas.drawCircle(center, size.width * 0.4, glowPaint);
  }

  @override
  bool shouldRepaint(_SplashRingPainter old) =>
      old.progress != progress || old.opacity != opacity;
}
