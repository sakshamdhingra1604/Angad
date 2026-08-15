import 'dart:math';
import 'package:flutter/material.dart';
import '../models/scan_result.dart';
import '../theme/app_colors.dart';

enum _InterceptorState { safe, deepScan, warning }

class LinkInterceptorModal extends StatefulWidget {
  final String url;
  final Future<ScanResult> Function(String url) onScan;
  final VoidCallback onDismiss;

  const LinkInterceptorModal({
    super.key,
    required this.url,
    required this.onScan,
    required this.onDismiss,
  });

  @override
  State<LinkInterceptorModal> createState() => _LinkInterceptorModalState();
}

class _LinkInterceptorModalState extends State<LinkInterceptorModal>
    with SingleTickerProviderStateMixin {
  _InterceptorState _istate = _InterceptorState.deepScan;
  ScanResult? _result;
  bool _advancedExpanded = false;
  late AnimationController _slideCtrl;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _slideCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _slide = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));
    _slideCtrl.forward();
    _performScan();
  }

  @override
  void dispose() {
    _slideCtrl.dispose();
    super.dispose();
  }

  Future<void> _performScan() async {
    setState(() => _istate = _InterceptorState.deepScan);
    final result = await widget.onScan(widget.url);
    setState(() {
      _result = result;
      _istate = result.isSafe ? _InterceptorState.safe : _InterceptorState.warning;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slide,
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (_istate) {
      case _InterceptorState.deepScan:
        return _buildDeepScanSheet(context);
      case _InterceptorState.safe:
        return _buildSafeToast(context);
      case _InterceptorState.warning:
        return _buildWarningSheet(context);
    }
  }

  // ── Scanning State ─────────────────────────────────────────────
  Widget _buildDeepScanSheet(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.charcoalLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppColors.infoBlue.withValues(alpha: 0.4))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(
            color: AppColors.textMuted,
            borderRadius: BorderRadius.circular(2),
          )),
          const SizedBox(height: 24),
          Row(
            children: [
              _ScanningAnimation(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Deep Inspection in Progress', style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.infoBlue,
                    )),
                    const SizedBox(height: 4),
                    Text('Analysing link through ShieldNet AI Tiers...', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _UrlChip(url: widget.url),
          const SizedBox(height: 16),
          // Tier progress indicators
          ..._TierItem.all.map((t) => _TierProgressRow(tier: t)),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ── Safe Toast ────────────────────────────────────────────────
  Widget _buildSafeToast(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), widget.onDismiss);
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.safeGreenDim,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.safeGreen.withValues(alpha: 0.5)),
        boxShadow: [BoxShadow(color: AppColors.safeGreenGlow, blurRadius: 12)],
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_rounded, color: AppColors.safeGreen, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Link is Safe', style: TextStyle(
                  color: AppColors.safeGreen,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                )),
                Text('ShieldNet verified — no threats detected', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          GestureDetector(
            onTap: widget.onDismiss,
            child: Icon(Icons.close_rounded, color: AppColors.textMuted, size: 18),
          ),
        ],
      ),
    );
  }

  // ── Warning Sheet ─────────────────────────────────────────────
  Widget _buildWarningSheet(BuildContext context) {
    final cat = _result?.category ?? ThreatCategory.phishing;
    final catColor = cat.color;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.charcoalMid,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: catColor.withValues(alpha: 0.6), width: 2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(
            color: AppColors.textMuted.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(2),
          ))),
          const SizedBox(height: 24),

          // Warning header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: catColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(cat.icon, color: catColor, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('⚠️  ${cat.displayName} Detected', style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: catColor,
                    )),
                    Text('Angad blocked this link for your safety', style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          _UrlChip(url: widget.url, color: catColor),
          const SizedBox(height: 16),

          // Reasons
          if (_result?.reasons.isNotEmpty == true) ...[
            Text('Why it\'s dangerous:', style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.textSecondary,
            )),
            const SizedBox(height: 8),
            ...(_result!.reasons.take(3).map((r) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.remove_circle_outline_rounded, color: catColor, size: 14),
                  const SizedBox(width: 6),
                  Expanded(child: Text(r, style: Theme.of(context).textTheme.bodyMedium)),
                ],
              ),
            ))),
          ],

          const SizedBox(height: 20),

          // Primary action — Go Back
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.onDismiss,
              style: ElevatedButton.styleFrom(
                backgroundColor: catColor,
                foregroundColor: AppColors.charcoal,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Go Back to Safety', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),

          const SizedBox(height: 12),

          // ── Mata Ji Override — VISUALLY SUBDUED ─────────────────
          // This is intentionally tiny and low-contrast so non-technical
          // users never accidentally tap "Continue anyway"
          Center(
            child: GestureDetector(
              onTap: () => setState(() => _advancedExpanded = !_advancedExpanded),
              child: Text(
                'Advanced options',
                style: TextStyle(
                  color: AppColors.textMuted.withValues(alpha: 0.55),
                  fontSize: 11,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.textMuted.withValues(alpha: 0.3),
                ),
              ),
            ),
          ),

          if (_advancedExpanded) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.threatRedDim,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.threatRed.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('⚠ Expert / Developer Mode',
                    style: TextStyle(color: AppColors.threatRed.withValues(alpha: 0.7), fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'This link has been confirmed malicious. Continuing may expose your device to serious risk. This action is logged.',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 10, height: 1.5),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: widget.onDismiss,
                    child: Text(
                      'I understand the risks — continue anyway',
                      style: TextStyle(
                        color: AppColors.threatRed.withValues(alpha: 0.55),
                        fontSize: 11,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.threatRed.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _UrlChip extends StatelessWidget {
  final String url;
  final Color? color;

  const _UrlChip({required this.url, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.charcoal,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: (color ?? AppColors.border).withValues(alpha: 0.3)),
      ),
      child: Text(
        url,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color?.withValues(alpha: 0.8) ?? AppColors.textSecondary,
          fontSize: 12,
          fontFamily: 'JetBrains Mono',
        ),
      ),
    );
  }
}

class _ScanningAnimation extends StatefulWidget {
  @override
  State<_ScanningAnimation> createState() => _ScanningAnimationState();
}

class _ScanningAnimationState extends State<_ScanningAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
    _anim = Tween<double>(begin: 0, end: 1).animate(_ctrl);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => CustomPaint(
        size: const Size(48, 48),
        painter: _ScannerPainter(_anim.value),
      ),
    );
  }
}

class _ScannerPainter extends CustomPainter {
  final double progress;
  _ScannerPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final bgPaint = Paint()
      ..color = AppColors.infoBlueDim
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    final sweepPaint = Paint()
      ..shader = SweepGradient(
        colors: [AppColors.infoBlue.withValues(alpha: 0), AppColors.infoBlue],
        startAngle: 0,
        endAngle: pi / 2,
        transform: GradientRotation(progress * 2 * pi - pi / 2),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, sweepPaint);

    final border = Paint()
      ..color = AppColors.infoBlue.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius - 1, border);

    final centerDot = Paint()..color = AppColors.infoBlue;
    canvas.drawCircle(center, 4, centerDot);
  }

  @override
  bool shouldRepaint(_ScannerPainter old) => old.progress != progress;
}

class _TierItem {
  final String label;
  final String description;
  _TierItem(this.label, this.description);

  static final all = [
    _TierItem('Tier 0', 'AI URL text analysis'),
    _TierItem('Tier 1', 'Blocklists & DNS checks'),
    _TierItem('Tier 2', 'Redirect chain tracing'),
  ];
}

class _TierProgressRow extends StatelessWidget {
  final _TierItem tier;
  const _TierProgressRow({required this.tier});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 48,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.infoBlueDim,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(tier.label, style: const TextStyle(
              color: AppColors.infoBlue,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            )),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(tier.description, style: Theme.of(context).textTheme.bodySmall)),
          const SizedBox(width: 8),
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              color: AppColors.infoBlue,
              strokeWidth: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
