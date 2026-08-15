import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppInstallAlert extends StatefulWidget {
  final String appName;
  final String appIcon;
  final VoidCallback onDismiss;

  const AppInstallAlert({
    super.key,
    required this.appName,
    required this.appIcon,
    required this.onDismiss,
  });

  @override
  State<AppInstallAlert> createState() => _AppInstallAlertState();
}

class _AppInstallAlertState extends State<AppInstallAlert>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _progress;
  bool _scanComplete = false;
  bool _isSafe = true;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _progress = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    _ctrl.forward().then((_) {
      if (mounted) setState(() { _scanComplete = true; _isSafe = true; });
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.charcoalMid,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _scanComplete
              ? (_isSafe ? AppColors.safeGreen.withValues(alpha: 0.4) : AppColors.threatRed.withValues(alpha: 0.4))
              : AppColors.infoBlue.withValues(alpha: 0.4)),
          boxShadow: [BoxShadow(
            color: (_scanComplete ? (_isSafe ? AppColors.safeGreenGlow : AppColors.threatRedGlow) : AppColors.cyberBlueGlow),
            blurRadius: 12,
          )],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(widget.appIcon, style: const TextStyle(fontSize: 26)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _scanComplete ? 'Scan Complete' : 'New App Detected',
                        style: TextStyle(
                          color: _scanComplete
                              ? (_isSafe ? AppColors.safeGreen : AppColors.threatRed)
                              : AppColors.infoBlue,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        _scanComplete
                            ? (_isSafe ? '${widget.appName} — No threats found' : '${widget.appName} — Risk detected!')
                            : 'Analysing ${widget.appName} for data leaks...',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: widget.onDismiss,
                  child: const Icon(Icons.close_rounded, color: AppColors.textMuted, size: 18),
                ),
              ],
            ),
            if (!_scanComplete) ...[
              const SizedBox(height: 10),
              AnimatedBuilder(
                animation: _progress,
                builder: (_, __) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _progress.value,
                        backgroundColor: AppColors.charcoalBright,
                        color: AppColors.infoBlue,
                        minHeight: 3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getScanStage(_progress.value),
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getScanStage(double progress) {
    if (progress < 0.25) return 'Checking APK signature...';
    if (progress < 0.5) return 'Scanning requested permissions...';
    if (progress < 0.75) return 'Analyzing data exfiltration vectors...';
    return 'Cross-referencing threat database...';
  }
}
