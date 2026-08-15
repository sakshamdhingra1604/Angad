import 'dart:math';
import 'package:flutter/material.dart';
import '../services/vpn_service.dart';
import '../theme/app_colors.dart';

class DigitalEnergyCore extends StatefulWidget {
  final VpnState state;
  final VoidCallback onTap;
  final double size;

  const DigitalEnergyCore({
    super.key,
    required this.state,
    required this.onTap,
    this.size = 220,
  });

  @override
  State<DigitalEnergyCore> createState() => _DigitalEnergyCoreState();
}

class _DigitalEnergyCoreState extends State<DigitalEnergyCore>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late AnimationController _rotateCtrl;
  late AnimationController _waveCtrl;
  late AnimationController _connectCtrl;

  late Animation<double> _pulse;
  late Animation<double> _rotate;
  late Animation<double> _wave;
  late Animation<double> _connectProgress;

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _rotateCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _connectCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _pulse = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _rotate = Tween<double>(begin: 0, end: 2 * pi).animate(_rotateCtrl);
    _wave = Tween<double>(begin: 0, end: 2 * pi).animate(_waveCtrl);
    _connectProgress = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _connectCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(DigitalEnergyCore old) {
    super.didUpdateWidget(old);
    if (widget.state == VpnState.connecting && old.state != VpnState.connecting) {
      _connectCtrl.repeat();
    } else if (widget.state == VpnState.connected && old.state != VpnState.connected) {
      _connectCtrl.stop();
      _connectCtrl.value = 1.0;
    } else if (widget.state == VpnState.disconnected) {
      _connectCtrl.reset();
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _rotateCtrl.dispose();
    _waveCtrl.dispose();
    _connectCtrl.dispose();
    super.dispose();
  }

  bool get _isActive => widget.state == VpnState.connected;
  bool get _isConnecting => widget.state == VpnState.connecting;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: Listenable.merge([_pulseCtrl, _rotateCtrl, _waveCtrl, _connectCtrl]),
          builder: (context, _) {
            return CustomPaint(
              painter: _EnergyCorePainter(
                state: widget.state,
                pulse: _pulse.value,
                rotate: _rotate.value,
                wave: _wave.value,
                connectProgress: _connectProgress.value,
              ),
              child: Center(child: _buildLabel()),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLabel() {
    if (_isConnecting) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              color: AppColors.safeGreen,
              strokeWidth: 2.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'CONNECTING',
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 2,
              fontWeight: FontWeight.w700,
              color: AppColors.safeGreen,
            ),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _isActive ? 'ON' : 'OFF',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
            color: _isActive ? AppColors.safeGreen : AppColors.textMuted,
            shadows: _isActive
                ? [Shadow(color: AppColors.safeGreenGlow, blurRadius: 20)]
                : null,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _isActive ? 'PROTECTED' : 'TAP TO ACTIVATE',
          style: TextStyle(
            fontSize: 10,
            letterSpacing: 2,
            fontWeight: FontWeight.w600,
            color: _isActive ? AppColors.safeGreen : AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}

class _EnergyCorePainter extends CustomPainter {
  final VpnState state;
  final double pulse;
  final double rotate;
  final double wave;
  final double connectProgress;

  _EnergyCorePainter({
    required this.state,
    required this.pulse,
    required this.rotate,
    required this.wave,
    required this.connectProgress,
  });

  bool get _isActive => state == VpnState.connected;
  bool get _isConnecting => state == VpnState.connecting;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    if (_isActive) {
      _drawGlowRings(canvas, center, radius);
      _drawWaveOrbs(canvas, center, radius);
      _drawDataParticles(canvas, center, radius);
    } else if (_isConnecting) {
      _drawConnectingArc(canvas, center, radius);
    } else {
      _drawIdleRing(canvas, center, radius);
    }

    _drawCoreCircle(canvas, center, radius);
  }

  void _drawIdleRing(Canvas canvas, Offset center, double radius) {
    // Outer hollow ring
    final ringPaint = Paint()
      ..color = AppColors.textMuted.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius * 0.88, ringPaint);

    // Inner dashed ring suggestion
    final dashedPaint = Paint()
      ..color = AppColors.charcoalBright
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius * 0.72, dashedPaint);

    // Core fill (dark hollow)
    final corePaint = Paint()
      ..color = AppColors.charcoalMid
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.58, corePaint);
  }

  void _drawConnectingArc(Canvas canvas, Offset center, double radius) {
    final bgPaint = Paint()
      ..color = AppColors.safeGreenDim.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius * 0.88, bgPaint);

    final arcPaint = Paint()
      ..color = AppColors.safeGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: center, radius: radius * 0.88);
    canvas.drawArc(
      rect,
      rotate - pi / 2,
      connectProgress * 2 * pi,
      false,
      arcPaint,
    );

    final corePaint = Paint()
      ..color = AppColors.charcoalMid
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.58, corePaint);
  }

  void _drawGlowRings(Canvas canvas, Offset center, double radius) {
    // Outermost subtle glow
    for (int i = 3; i >= 0; i--) {
      final r = radius * (0.72 + i * 0.08 + (pulse - 1) * 0.04);
      final opacity = (0.08 - i * 0.015).clamp(0.0, 1.0);
      final p = Paint()
        ..color = AppColors.safeGreen.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, r, p);
    }

    // Bright ring outline
    final ringPaint = Paint()
      ..color = AppColors.safeGreen.withValues(alpha: 0.6 + (pulse - 1) * 2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(center, radius * 0.87 * pulse, ringPaint);

    // Inner orbit ring
    final innerRing = Paint()
      ..color = AppColors.infoBlue.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius * 0.70, innerRing);
  }

  void _drawWaveOrbs(Canvas canvas, Offset center, double radius) {
    // Draw 3 orbiting data particles
    for (int i = 0; i < 3; i++) {
      final angle = rotate + (2 * pi / 3) * i;
      final orbRadius = radius * 0.70;
      final orbCenter = Offset(
        center.dx + orbRadius * cos(angle),
        center.dy + orbRadius * sin(angle),
      );
      final orbPaint = Paint()
        ..color = AppColors.safeGreen
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(orbCenter, 4, orbPaint);
      final coreDot = Paint()..color = AppColors.safeGreen;
      canvas.drawCircle(orbCenter, 2.5, coreDot);
    }

    // Neon wave pulses emanating from center
    for (int w = 0; w < 3; w++) {
      final wavePhase = (wave + (2 * pi / 3) * w) % (2 * pi);
      final waveRadius = radius * 0.55 + (radius * 0.30) * (wavePhase / (2 * pi));
      final waveOpacity = 1.0 - wavePhase / (2 * pi);
      if (waveOpacity > 0.01) {
        final wavePaint = Paint()
          ..color = AppColors.safeGreen.withValues(alpha: waveOpacity * 0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;
        canvas.drawCircle(center, waveRadius, wavePaint);
      }
    }
  }

  void _drawDataParticles(Canvas canvas, Offset center, double radius) {
    // Small data dots at rotating positions on outer arc
    final rng = [0.1, 0.35, 0.6, 0.8, 1.1, 1.4, 1.7, 2.0, 2.3, 2.6, 2.9, 3.2];
    for (final offset in rng) {
      final angle = (rotate * 0.5 + offset) % (2 * pi);
      final r = radius * 0.88;
      final pos = Offset(center.dx + r * cos(angle), center.dy + r * sin(angle));
      final p = Paint()..color = AppColors.infoBlue.withValues(alpha: 0.6);
      canvas.drawCircle(pos, 1.5, p);
    }
  }

  void _drawCoreCircle(Canvas canvas, Offset center, double radius) {
    final gradient = RadialGradient(
      colors: _isActive
          ? [
              AppColors.safeGreenDim.withValues(alpha: 0.9),
              AppColors.charcoalMid,
            ]
          : [AppColors.charcoalMid, AppColors.charcoal],
      radius: 0.85,
    );

    final rect = Rect.fromCircle(center: center, radius: radius * 0.56);
    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawCircle(center, radius * 0.56, paint);

    // Core border glow
    if (_isActive) {
      final borderPaint = Paint()
        ..color = AppColors.safeGreen.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(center, radius * 0.56, borderPaint);
    }
  }

  @override
  bool shouldRepaint(_EnergyCorePainter old) => true;
}
