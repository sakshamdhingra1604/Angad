import 'package:flutter/material.dart';
import '../models/app_firewall_rules.dart';
import '../services/security_service.dart';
import '../theme/app_colors.dart';

class AppFirewallSheet extends StatefulWidget {
  final AppFirewallRule app;
  final SecurityService securityService;

  const AppFirewallSheet({super.key, required this.app, required this.securityService});

  @override
  State<AppFirewallSheet> createState() => _AppFirewallSheetState();
}

class _AppFirewallSheetState extends State<AppFirewallSheet> {
  late AppFirewallRule _rule;

  @override
  void initState() {
    super.initState();
    _rule = widget.app;
  }

  void _toggle(String type, bool val) {
    setState(() {
      switch (type) {
        case 'wifi': _rule = _rule.copyWith(allowWifi: val); break;
        case 'mobile': _rule = _rule.copyWith(allowMobile: val); break;
        case 'bg': _rule = _rule.copyWith(allowBackground: val); break;
      }
    });
    widget.securityService.updateAppRule(
      _rule.packageName,
      allowWifi: type == 'wifi' ? val : null,
      allowMobile: type == 'mobile' ? val : null,
      allowBackground: type == 'bg' ? val : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.charcoalMid,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textMuted.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // App header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.charcoalMid,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Center(
                    child: Text(_rule.appIcon, style: const TextStyle(fontSize: 28)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_rule.appName, style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 2),
                      Text(_rule.packageName, style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontFamily: 'JetBrains Mono',
                        fontSize: 10,
                      )),
                    ],
                  ),
                ),
                _RiskBadge(score: _rule.riskScore),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Traffic stats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.charcoalMid,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatPill(Icons.arrow_upward_rounded, AppColors.infoBlue, _rule.uploadFormatted, 'Upload'),
                  Container(width: 1, height: 30, color: AppColors.border),
                  _StatPill(Icons.arrow_downward_rounded, AppColors.safeGreen, _rule.downloadFormatted, 'Download'),
                  Container(width: 1, height: 30, color: AppColors.border),
                  _StatPill(Icons.wifi_rounded, AppColors.amber, '${_rule.activeConnections}', 'Connections'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Firewall toggles
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Network Firewall Rules', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                _FirewallToggle(
                  icon: Icons.wifi_off_rounded,
                  label: 'Block Wi-Fi',
                  subtitle: 'Prevent this app from using any Wi-Fi network',
                  value: _rule.allowWifi,
                  onChanged: (v) => _toggle('wifi', v),
                  dangerColor: AppColors.threatRed,
                ),
                _FirewallToggle(
                  icon: Icons.signal_cellular_off_rounded,
                  label: 'Block Mobile Data',
                  subtitle: 'Prevent this app from using cellular network',
                  value: _rule.allowMobile,
                  onChanged: (v) => _toggle('mobile', v),
                  dangerColor: AppColors.amber,
                ),
                _FirewallToggle(
                  icon: Icons.do_not_disturb_on_rounded,
                  label: 'Block Background Activity',
                  subtitle: 'Stop this app from sending/receiving data in background',
                  value: _rule.allowBackground,
                  onChanged: (v) => _toggle('bg', v),
                  dangerColor: AppColors.infoBlue,
                ),
              ],
            ),
          ),

          // Recent connection hosts
          if (_rule.recentHosts.isNotEmpty) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Recent Connections', style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.textMuted,
                  )),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _rule.recentHosts.map((h) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.charcoalMid,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(h, style: const TextStyle(
                        color: AppColors.infoBlue,
                        fontSize: 11,
                        fontFamily: 'JetBrains Mono',
                      )),
                    )).toList(),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

class _FirewallToggle extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color dangerColor;

  const _FirewallToggle({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.dangerColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: value ? dangerColor.withValues(alpha: 0.08) : AppColors.charcoalMid,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: value ? dangerColor.withValues(alpha: 0.4) : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: value ? dangerColor : AppColors.textMuted, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: value ? dangerColor : AppColors.textPrimary,
                )),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: dangerColor,
          ),
        ],
      ),
    );
  }
}

class _RiskBadge extends StatelessWidget {
  final double score;
  const _RiskBadge({required this.score});

  Color get _color {
    if (score < 0.3) return AppColors.safeGreen;
    if (score < 0.6) return AppColors.amber;
    return AppColors.threatRed;
  }

  String get _label {
    if (score < 0.3) return 'LOW';
    if (score < 0.6) return 'MED';
    return 'HIGH';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _color.withValues(alpha: 0.35)),
      ),
      child: Column(
        children: [
          Text('${(score * 100).toInt()}%', style: TextStyle(
            color: _color,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          )),
          Text(_label, style: TextStyle(
            color: _color.withValues(alpha: 0.7),
            fontSize: 9,
            letterSpacing: 1,
            fontWeight: FontWeight.w700,
          )),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  const _StatPill(this.icon, this.color, this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 12),
            const SizedBox(width: 3),
            Text(value, style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            )),
          ],
        ),
        Text(label, style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 10,
        )),
      ],
    );
  }
}
