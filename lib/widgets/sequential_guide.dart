import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GuideStep {
  final GlobalKey targetKey;
  final String title;
  final String body;
  final bool arrowUp; // true = arrow points up (tooltip below), false = arrow down

  const GuideStep({
    required this.targetKey,
    required this.title,
    required this.body,
    this.arrowUp = true,
  });
}

class SequentialGuide extends StatefulWidget {
  final List<GuideStep> steps;
  final VoidCallback onComplete;

  const SequentialGuide({
    super.key,
    required this.steps,
    required this.onComplete,
  });

  @override
  State<SequentialGuide> createState() => _SequentialGuideState();
}

class _SequentialGuideState extends State<SequentialGuide>
    with SingleTickerProviderStateMixin {
  int _step = 0;
  late AnimationController _fadeCtrl;
  late Animation<double> _fade;
  Rect? _targetRect;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateRect());
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _updateRect() {
    final step = widget.steps[_step];
    final box = step.targetKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null && mounted) {
      final pos = box.localToGlobal(Offset.zero);
      setState(() {
        _targetRect = Rect.fromLTWH(
            pos.dx, pos.dy, box.size.width, box.size.height);
      });
    }
  }

  void _next() async {
    await _fadeCtrl.reverse();
    if (_step < widget.steps.length - 1) {
      setState(() => _step++);
      WidgetsBinding.instance.addPostFrameCallback((_) => _updateRect());
      _fadeCtrl.forward();
    } else {
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_targetRect == null) return const SizedBox.shrink();
    final rect = _targetRect!;
    final step = widget.steps[_step];
    final screenH = MediaQuery.of(context).size.height;
    final tipTop = step.arrowUp
        ? rect.bottom + 12
        : rect.top - 180;

    return FadeTransition(
      opacity: _fade,
      child: Stack(
        children: [
          // Dark overlay with hole
          CustomPaint(
            size: MediaQuery.of(context).size,
            painter: _HolePainter(rect),
          ),

          // Arrow
          Positioned(
            left: rect.left + rect.width / 2 - 12,
            top: step.arrowUp ? rect.bottom + 1 : rect.top - 20,
            child: Icon(
              step.arrowUp
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: AppColors.saffron,
              size: 20,
            ),
          ),

          // Tooltip card
          Positioned(
            left: 24,
            right: 24,
            top: tipTop.clamp(80, screenH - 230).toDouble(),
            child: _TooltipCard(
              step: step,
              stepIndex: _step,
              totalSteps: widget.steps.length,
              onNext: _next,
              onSkip: widget.onComplete,
            ),
          ),
        ],
      ),
    );
  }
}

class _HolePainter extends CustomPainter {
  final Rect hole;
  _HolePainter(this.hole);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xCC111111);
    // Full screen dark fill
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    // Cut out highlight around target (with padding)
    final clear = Paint()..blendMode = BlendMode.clear;
    final expanded = hole.inflate(8);
    canvas.drawRRect(
        RRect.fromRectAndRadius(expanded, const Radius.circular(12)),
        clear);
    // Draw highlight border
    final border = Paint()
      ..color = AppColors.saffron.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(
        RRect.fromRectAndRadius(expanded, const Radius.circular(12)),
        border);
  }

  @override
  bool shouldRepaint(_HolePainter old) => old.hole != hole;
}

class _TooltipCard extends StatelessWidget {
  final GuideStep step;
  final int stepIndex;
  final int totalSteps;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const _TooltipCard({
    required this.step,
    required this.stepIndex,
    required this.totalSteps,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.charcoalMid,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.saffron.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: AppColors.saffronGlow,
            blurRadius: 24,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step counter
          Row(
            children: [
              ...List.generate(totalSteps, (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 4),
                width: i == stepIndex ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: i == stepIndex
                      ? AppColors.saffron
                      : AppColors.border,
                  borderRadius: BorderRadius.circular(3),
                ),
              )),
              const Spacer(),
              GestureDetector(
                onTap: onSkip,
                child: Text('Skip',
                    style: TextStyle(
                        color: AppColors.textMuted, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(step.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.saffron,
                  )),
          const SizedBox(height: 8),
          Text(step.body,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(height: 1.55)),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.saffron,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                stepIndex < totalSteps - 1 ? 'Next →' : 'Got it ✓',
                style:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
