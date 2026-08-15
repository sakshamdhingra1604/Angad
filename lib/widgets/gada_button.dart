import 'package:flutter/material.dart';
import '../services/vpn_service.dart';
import '../theme/app_colors.dart';


/// The Angad Gada — on/off button with saffron/gold glow animation
class GadaButton extends StatefulWidget {
  final VpnState state;
  final VoidCallback onTap;
  final double size;

  const GadaButton({
    super.key,
    required this.state,
    required this.onTap,
    this.size = 200,
  });

  @override
  State<GadaButton> createState() => _GadaButtonState();
}

class _GadaButtonState extends State<GadaButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.95, end: 1.05)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  bool get _isOn => widget.state == VpnState.connected;
  bool get _isConnecting => widget.state == VpnState.connecting;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer glow rings (only when ON)
            if (_isOn)
              AnimatedBuilder(
                animation: _pulse,
                builder: (_, __) => CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: _GlowRingPainter(_pulse.value),
                ),
              ),

            // Connecting spinner ring
            if (_isConnecting)
              SizedBox(
                width: widget.size * 0.88,
                height: widget.size * 0.88,
                child: CircularProgressIndicator(
                  color: AppColors.saffron.withValues(alpha: 0.5),
                  strokeWidth: 2,
                ),
              ),

            // Gada image with animated glow container
            AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
              width: widget.size * 0.78,
              height: widget.size * 0.78,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isOn
                    ? AppColors.saffronDim
                    : AppColors.charcoalLight,
                boxShadow: _isOn
                    ? [
                        BoxShadow(
                            color: AppColors.saffronGlow,
                            blurRadius: 40,
                            spreadRadius: 4),
                        BoxShadow(
                            color: AppColors.goldGlow,
                            blurRadius: 80,
                            spreadRadius: 8),
                      ]
                    : [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 16),
                      ],
              ),
              child: ClipOval(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 600),
                  opacity: _isOn ? 1.0 : 0.45,
                  child: Image.asset(
                    'assets/images/gada.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlowRingPainter extends CustomPainter {
  final double pulse;
  _GlowRingPainter(this.pulse);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    for (int i = 0; i < 3; i++) {
      final baseR = size.width * (0.43 + i * 0.07);
      final r = baseR * (i == 0 ? pulse : 1.0);
      final opacity = (0.25 - i * 0.07).clamp(0.0, 1.0);
      canvas.drawCircle(
        center,
        r,
        Paint()
          ..color = AppColors.saffron.withValues(alpha: opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  @override
  bool shouldRepaint(_GlowRingPainter old) => old.pulse != pulse;
}
