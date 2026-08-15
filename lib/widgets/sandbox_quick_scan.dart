import 'package:flutter/material.dart';
import '../models/scan_result.dart';
import '../services/security_service.dart';
import '../theme/app_colors.dart';

class SandboxQuickScan extends StatefulWidget {
  final SecurityService securityService;
  const SandboxQuickScan({super.key, required this.securityService});

  @override
  State<SandboxQuickScan> createState() => _SandboxQuickScanState();
}

class _SandboxQuickScanState extends State<SandboxQuickScan>
    with SingleTickerProviderStateMixin {
  final _ctrl = TextEditingController();
  bool _scanning = false;
  ScanResult? _result;
  late AnimationController _progressCtrl;

  @override
  void initState() {
    super.initState();
    _progressCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _progressCtrl.dispose();
    super.dispose();
  }

  Future<void> _scan() async {
    final url = _ctrl.text.trim();
    if (url.isEmpty) return;
    setState(() { _scanning = true; _result = null; });
    _progressCtrl.forward(from: 0);
    try {
      final res = await widget.securityService.scanUrl(url, depth: 0);
      setState(() { _result = res; _scanning = false; });
      _progressCtrl.stop();
    } catch (_) {
      setState(() { _scanning = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.charcoalMid,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.saffronDim,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.radar_rounded,
                      color: AppColors.saffron, size: 20),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Quick Link Scanner',
                        style: Theme.of(context).textTheme.titleLarge),
                    Text('Paste any URL to check for threats',
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── URL Input + Scan button ──────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    style: const TextStyle(
                        color: AppColors.textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Paste suspicious link here...',
                      hintStyle: const TextStyle(
                          color: AppColors.textHint, fontSize: 14),
                      prefixIcon: const Icon(Icons.link_rounded,
                          color: AppColors.textMuted, size: 18),
                      filled: true,
                      fillColor: AppColors.charcoalLight,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: AppColors.saffron, width: 1.5)),
                    ),
                    onSubmitted: (_) => _scan(),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _scanning ? null : _scan,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _scanning ? AppColors.charcoalLight : AppColors.saffron,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _scanning
                        ? const Padding(
                            padding: EdgeInsets.all(14),
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppColors.saffron),
                          )
                        : const Icon(Icons.search_rounded,
                            color: Colors.white, size: 22),
                  ),
                ),
              ],
            ),
          ),

          // ── Progress bar ─────────────────────────────────────────
          if (_scanning) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: AnimatedBuilder(
                animation: _progressCtrl,
                builder: (_, __) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Analysing...',
                            style: const TextStyle(
                                color: AppColors.saffron, fontSize: 12)),
                        const Spacer(),
                        Text(
                            '${(_progressCtrl.value * 100).toInt()}%',
                            style: const TextStyle(
                                color: AppColors.textMuted, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _progressCtrl.value,
                        backgroundColor: AppColors.charcoalLight,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.saffron),
                        minHeight: 5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // ── Result ───────────────────────────────────────────────
          if (_result != null) ...[
            const SizedBox(height: 14),
            const Divider(color: AppColors.border, height: 1),
            _ResultPanel(result: _result!),
          ],

          const SizedBox(height: 18),
        ],
      ),
    );
  }
}

// ── Result Panel ────────────────────────────────────────────────
class _ResultPanel extends StatelessWidget {
  final ScanResult result;
  const _ResultPanel({required this.result});

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor(result.category);
    final isSafe = result.category == ThreatCategory.safe;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Verdict row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isSafe
                      ? Icons.check_circle_rounded
                      : Icons.dangerous_rounded,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isSafe ? 'Link is Safe' : 'Threat Detected',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: color),
                    ),
                    Text(
                      result.category.displayName,
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 13),
                    ),
                  ],
                ),
              ),
              // Risk score badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Text(
                  '${(result.riskScore * 100).toInt()}%',
                  style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w800,
                      fontSize: 16),
                ),
              ),
            ],
          ),

          // Reasons
          if (result.reasons.isNotEmpty) ...[
            const SizedBox(height: 14),
            ...result.reasons.take(3).map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.chevron_right_rounded,
                          color: color, size: 16),
                      const SizedBox(width: 4),
                      Expanded(
                          child: Text(r,
                              style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                  height: 1.4))),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }

  Color _categoryColor(ThreatCategory cat) {
    switch (cat) {
      case ThreatCategory.safe:     return AppColors.safeGreen;
      case ThreatCategory.phishing: return AppColors.threatRed;
      case ThreatCategory.malware:  return AppColors.malware;
      case ThreatCategory.dataLeak: return AppColors.amber;
      case ThreatCategory.scam:     return AppColors.scam;
      default:                      return AppColors.textMuted;
    }
  }
}
