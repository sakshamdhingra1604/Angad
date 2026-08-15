import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class OnboardingOverlay extends StatefulWidget {
  final VoidCallback onDismiss;

  const OnboardingOverlay({super.key, required this.onDismiss});

  @override
  State<OnboardingOverlay> createState() => _OnboardingOverlayState();
}

class _OnboardingOverlayState extends State<OnboardingOverlay>
    with SingleTickerProviderStateMixin {
  int _step = 0;
  late AnimationController _fadeCtrl;
  late Animation<double> _fade;

  static const _steps = [
    _OverlayStep(
      icon: Icons.graphic_eq_rounded,
      title: 'Digital Energy Core',
      body: 'Tap the glowing core to activate your full AI protection shield. When green, all your traffic is secure.',
      highlightPosition: Alignment.center,
    ),
    _OverlayStep(
      icon: Icons.radar_rounded,
      title: 'Quick Scan',
      body: 'Got a suspicious link from WhatsApp or SMS? Paste it here for an instant AI safety check.',
      highlightPosition: Alignment.bottomCenter,
    ),
    _OverlayStep(
      icon: Icons.apps_rounded,
      title: 'Apps Control',
      body: 'Tap any app to individually block its Wi-Fi, mobile data, or background permissions.',
      highlightPosition: Alignment.bottomCenter,
    ),
    _OverlayStep(
      icon: Icons.receipt_long_rounded,
      title: 'Threat Logs',
      body: 'See all blocked threats in plain language. Tap any log for deep technical forensics.',
      highlightPosition: Alignment.bottomCenter,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _fade = Tween<double>(begin: 0, end: 1).animate(_fadeCtrl);
    _fadeCtrl.forward();
  }

  @override
  void dispose() { _fadeCtrl.dispose(); super.dispose(); }

  void _next() {
    if (_step < _steps.length - 1) {
      _fadeCtrl.reverse().then((_) {
        setState(() => _step++);
        _fadeCtrl.forward();
      });
    } else {
      _dismiss();
    }
  }

  void _dismiss() {
    _fadeCtrl.reverse().then((_) => widget.onDismiss());
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_step];
    return FadeTransition(
      opacity: _fade,
      child: GestureDetector(
        onTap: _next,
        child: Container(
          color: AppColors.overlayDark,
          child: SafeArea(
            child: Column(
              children: [
                const Spacer(),
                // Highlight card
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.charcoalMid,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.safeGreen.withValues(alpha: 0.5)),
                      boxShadow: [BoxShadow(
                        color: AppColors.safeGreenGlow,
                        blurRadius: 30,
                        spreadRadius: 2,
                      )],
                    ),
                    child: Column(
                      children: [
                        // Step dots
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(_steps.length, (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: i == _step ? 20 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: i == _step ? AppColors.safeGreen : AppColors.textMuted.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          )),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.safeGreenDim,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(step.icon, color: AppColors.safeGreen, size: 32),
                        ),
                        const SizedBox(height: 16),
                        Text(step.title, style: Theme.of(context).textTheme.headlineMedium),
                        const SizedBox(height: 10),
                        Text(step.body, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6)),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            TextButton(
                              onPressed: _dismiss,
                              child: Text('Skip', style: TextStyle(color: AppColors.textMuted)),
                            ),
                            const Spacer(),
                            ElevatedButton(
                              onPressed: _next,
                              child: Text(_step < _steps.length - 1 ? 'Next  →' : 'Get Started  ✓'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OverlayStep {
  final IconData icon;
  final String title;
  final String body;
  final Alignment highlightPosition;

  const _OverlayStep({
    required this.icon,
    required this.title,
    required this.body,
    required this.highlightPosition,
  });
}
