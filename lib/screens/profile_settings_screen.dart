import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/vpn_service.dart';
import '../services/security_service.dart';
import '../services/theme_service.dart';
import '../theme/app_colors.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  bool   _isHindi       = false;
  double _strictness    = 0.5;
  bool   _batterySaver  = false;
  bool   _notifications = true;
  bool   _simpleMode    = true; // true = Standard Mode, false = Expert Mode

  String get _strictnessLabel {
    if (_strictness < 0.35) return 'Permissive';
    if (_strictness < 0.7)  return 'Balanced';
    return 'Maximum Protection';
  }

  Color get _strictnessColor {
    if (_strictness < 0.35) return AppColors.safeGreen;
    if (_strictness < 0.7)  return AppColors.amber;
    return AppColors.threatRed;
  }

  @override
  Widget build(BuildContext context) {
    final vpn      = context.watch<VpnService>();
    final security = context.watch<SecurityService>();

    return Scaffold(
      backgroundColor: AppColors.charcoal,
      body: CustomScrollView(
        slivers: [
          // ── AppBar ───────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.charcoal,
            surfaceTintColor: Colors.transparent,
            toolbarHeight: 58,
            automaticallyImplyLeading: false,
            title: Text('Settings',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w800)),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Profile card ─────────────────────────────────
                  _ProfileCard(security: security),
                  const SizedBox(height: 24),

                  // ── Protection Mode ──────────────────────────────
                  _SectionHeader('PROTECTION MODE'),
                  const SizedBox(height: 12),
                  _ModeToggle(
                    simpleMode: _simpleMode,
                    onChanged: (v) => setState(() => _simpleMode = v),
                  ),
                  const SizedBox(height: 20),

                  // ── AI Strictness ────────────────────────────────
                  _SectionHeader('AI DETECTION SENSITIVITY'),
                  const SizedBox(height: 12),
                  _SettingsCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('Sensitivity Level',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _strictnessColor
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(_strictnessLabel,
                                  style: TextStyle(
                                      color: _strictnessColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Higher sensitivity blocks more threats but may flag legitimate sites.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: _strictnessColor,
                            thumbColor: _strictnessColor,
                            overlayColor:
                                _strictnessColor.withValues(alpha: 0.15),
                            inactiveTrackColor: AppColors.charcoalLight,
                            trackHeight: 4,
                          ),
                          child: Slider(
                            value: _strictness,
                            onChanged: (v) =>
                                setState(() => _strictness = v),
                            min: 0,
                            max: 1,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Low',
                                style: const TextStyle(
                                    color: AppColors.textHint,
                                    fontSize: 11)),
                            Text('High',
                                style: const TextStyle(
                                    color: AppColors.textHint,
                                    fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── General ──────────────────────────────────────
                  _SectionHeader('GENERAL & APPEARANCE'),
                  const SizedBox(height: 12),
                  _SettingsCard(
                    child: Column(
                      children: [
                        Consumer<ThemeService>(
                          builder: (context, theme, _) => _ToggleRow(
                            icon: theme.isDarkMode
                                ? Icons.dark_mode_rounded
                                : Icons.light_mode_rounded,
                            label: 'Dark Theme',
                            subtitle: theme.isDarkMode
                                ? 'Pitch black & deep dark mode (Active)'
                                : 'Clean light theme (Active)',
                            value: theme.isDarkMode,
                            onChanged: (_) => theme.toggleTheme(),
                            iconColor: AppColors.saffron,
                          ),
                        ),
                        const Divider(
                            color: AppColors.border, height: 1),
                        _ToggleRow(
                          icon: Icons.language_rounded,
                          label: 'Language',
                          subtitle: _isHindi ? 'हिंदी' : 'English',
                          value: _isHindi,
                          onChanged: (v) => setState(() => _isHindi = v),
                          iconColor: AppColors.infoBlue,
                        ),
                        const Divider(
                            color: AppColors.border, height: 1),
                        _ToggleRow(
                          icon: Icons.notifications_outlined,
                          label: 'Threat Notifications',
                          subtitle:
                              'Alert when a threat is blocked in real time',
                          value: _notifications,
                          onChanged: (v) =>
                              setState(() => _notifications = v),
                          iconColor: AppColors.saffron,
                        ),
                        const Divider(
                            color: AppColors.border, height: 1),
                        _ToggleRow(
                          icon: Icons.battery_saver_rounded,
                          label: 'Battery Saver',
                          subtitle:
                              'Reduces scan frequency to save power',
                          value: _batterySaver,
                          onChanged: (v) =>
                              setState(() => _batterySaver = v),
                          iconColor: AppColors.safeGreen,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Session stats ────────────────────────────────
                  _SectionHeader('SESSION'),
                  const SizedBox(height: 12),
                  _SettingsCard(
                    child: Column(
                      children: [
                        _InfoRow(
                            'Protection Status',
                            vpn.isConnected ? 'Active' : 'Inactive',
                            vpn.isConnected
                                ? AppColors.safeGreen
                                : AppColors.textMuted),
                        const Divider(color: AppColors.border, height: 1),
                        _InfoRow('Session Duration',
                            vpn.isConnected ? vpn.uptimeLabel : '—',
                            AppColors.textSecondary),
                        const Divider(color: AppColors.border, height: 1),
                        _InfoRow('Threats Blocked Today',
                            '${security.blockedCount}',
                            AppColors.threatRed),
                        const Divider(color: AppColors.border, height: 1),
                        _InfoRow('Links Scanned Today',
                            '${security.scansCount}',
                            AppColors.saffron),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── About ────────────────────────────────────────
                  _SectionHeader('ABOUT'),
                  const SizedBox(height: 12),
                  _SettingsCard(
                    child: Column(
                      children: [
                        _TapRow(
                          icon: Icons.info_outline_rounded,
                          label: 'About Angad',
                          onTap: () => showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              backgroundColor: AppColors.charcoalMid,
                              title: const Text('About Angad',
                                  style: TextStyle(color: AppColors.textPrimary)),
                              content: const Text(
                                'Angad v1.0.0\n\n'
                                'Your Digital Kavach — India\'s first AI-powered cybersecurity '
                                'ecosystem combining ShieldNet (URL threat classifier) and '
                                'NetGuard (OS-level TCP firewall proxy).\n\n'
                                'Built by Shaktix · Made in India 🇮🇳',
                                style: TextStyle(color: AppColors.textSecondary, height: 1.5)),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Close',
                                      style: TextStyle(color: AppColors.saffron)),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Divider(color: AppColors.border, height: 1),
                        _TapRow(
                          icon: Icons.privacy_tip_outlined,
                          label: 'Privacy Policy',
                          onTap: () => showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              backgroundColor: AppColors.charcoalMid,
                              title: const Text('Privacy Policy',
                                  style: TextStyle(color: AppColors.textPrimary)),
                              content: const SingleChildScrollView(
                                child: Text(
                                  '• All threat analysis runs on-device.\n'
                                  '• No personal data is sent to third-party servers.\n'
                                  '• Logs are stored locally and auto-deleted after 30 days.\n'
                                  '• NetGuard intercepts only metadata (IP, port, SNI) — never payload content.\n'
                                  '• You can export or delete all logs at any time.',
                                  style: TextStyle(color: AppColors.textSecondary, height: 1.6)),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Got it',
                                      style: TextStyle(color: AppColors.saffron)),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Divider(color: AppColors.border, height: 1),
                        _TapRow(
                          icon: Icons.article_outlined,
                          label: 'Terms of Service',
                          onTap: () => showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              backgroundColor: AppColors.charcoalMid,
                              title: const Text('Terms of Service',
                                  style: TextStyle(color: AppColors.textPrimary)),
                              content: const Text(
                                'By using Angad you agree to:\n\n'
                                '• Use the app only for lawful purposes.\n'
                                '• Not attempt to reverse-engineer the AI models.\n'
                                '• Understand that Angad is a security aid — not a guarantee.\n\n'
                                'Shaktix reserves the right to update these terms at any time.',
                                style: TextStyle(color: AppColors.textSecondary, height: 1.5)),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Accept',
                                      style: TextStyle(color: AppColors.saffron)),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Divider(color: AppColors.border, height: 1),
                        _TapRow(
                          icon: Icons.logout_rounded,
                          label: 'Sign Out',
                          labelColor: AppColors.threatRed,
                          onTap: () => Navigator.of(context)
                              .pushReplacementNamed('/login'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      'Angad v1.0.0 · Your Digital Kavach',
                      style: const TextStyle(
                          color: AppColors.textHint, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Profile Card ────────────────────────────────────────────────
class _ProfileCard extends StatelessWidget {
  final SecurityService security;
  const _ProfileCard({required this.security});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.charcoalMid,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.saffron.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.saffronDim,
              borderRadius: BorderRadius.circular(14),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset('assets/images/gada.jpg',
                  fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Angad User',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 2),
                Text('user@angad.app',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded,
              color: AppColors.textMuted, size: 20),
        ],
      ),
    );
  }
}

// ── Protection Mode Toggle ──────────────────────────────────────
class _ModeToggle extends StatelessWidget {
  final bool simpleMode;
  final ValueChanged<bool> onChanged;
  const _ModeToggle({required this.simpleMode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(true),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: simpleMode
                    ? AppColors.saffron.withValues(alpha: 0.12)
                    : AppColors.charcoalMid,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: simpleMode
                        ? AppColors.saffron
                        : AppColors.border,
                    width: simpleMode ? 1.5 : 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.person_rounded,
                      color: simpleMode
                          ? AppColors.saffron
                          : AppColors.textMuted,
                      size: 22),
                  const SizedBox(height: 8),
                  Text('Standard',
                      style: TextStyle(
                          color: simpleMode
                              ? AppColors.saffron
                              : AppColors.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text('Plain alerts for everyday use',
                      style: TextStyle(
                          color: AppColors.textMuted, fontSize: 11)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: !simpleMode
                    ? AppColors.gold.withValues(alpha: 0.12)
                    : AppColors.charcoalMid,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: !simpleMode ? AppColors.gold : AppColors.border,
                    width: !simpleMode ? 1.5 : 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.developer_mode_rounded,
                      color: !simpleMode
                          ? AppColors.gold
                          : AppColors.textMuted,
                      size: 22),
                  const SizedBox(height: 8),
                  Text('Expert',
                      style: TextStyle(
                          color: !simpleMode
                              ? AppColors.gold
                              : AppColors.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text('Deep forensics & OS-level logs',
                      style: TextStyle(
                          color: AppColors.textMuted, fontSize: 11)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Helpers ────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          color: AppColors.saffron,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5));
}

class _SettingsCard extends StatelessWidget {
  final Widget child;
  const _SettingsCard({required this.child});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: AppColors.charcoalMid,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: child,
      );
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color iconColor;

  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500)),
                Text(subtitle,
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.saffron,
            activeTrackColor: AppColors.saffronDim,
            inactiveThumbColor: AppColors.textMuted,
            inactiveTrackColor: AppColors.charcoalLight,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  const _InfoRow(this.label, this.value, this.valueColor);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 14)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  color: valueColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _TapRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? labelColor;
  final VoidCallback onTap;
  const _TapRow(
      {required this.icon,
      required this.label,
      this.labelColor,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon,
                color: labelColor ?? AppColors.textMuted, size: 18),
            const SizedBox(width: 12),
            Text(label,
                style: TextStyle(
                    color: labelColor ?? AppColors.textSecondary,
                    fontSize: 14)),
            const Spacer(),
            Icon(Icons.chevron_right_rounded,
                color: AppColors.textHint, size: 18),
          ],
        ),
      ),
    );
  }
}
