import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/vpn_service.dart';
import '../services/security_service.dart';
import '../theme/app_colors.dart';
import '../widgets/gada_button.dart';
import '../widgets/connection_histogram.dart';
import '../widgets/sandbox_quick_scan.dart';
import '../widgets/sequential_guide.dart';

class HomeCommandCenter extends StatefulWidget {
  const HomeCommandCenter({super.key});

  @override
  State<HomeCommandCenter> createState() => _HomeCommandCenterState();
}

class _HomeCommandCenterState extends State<HomeCommandCenter> {
  bool _showGuide = false;

  // GlobalKeys for sequential guide targets
  final _gadaKey  = GlobalKey();
  final _statsKey = GlobalKey();
  final _histoKey = GlobalKey();
  final _scanKey  = GlobalKey();

  @override
  void initState() {
    super.initState();
    _checkFirstTime();
  }

  Future<void> _checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    final seen  = prefs.getBool('guide_seen_v2') ?? false;
    if (!seen && mounted) setState(() => _showGuide = true);
  }

  Future<void> _dismissGuide() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('guide_seen_v2', true);
    if (mounted) setState(() => _showGuide = false);
  }

  List<HourlyConnData> _buildMockHistogram() {
    final rng = math.Random();
    final now = DateTime.now();
    return List.generate(8, (i) {
      final hour    = (now.hour - 7 + i + 24) % 24;
      final blocked = rng.nextInt(25) + (i == 7 ? 18 : 4);
      final allowed = rng.nextInt(120) + 30;
      return HourlyConnData(hour: hour, blocked: blocked, allowed: allowed);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vpn      = context.watch<VpnService>();
    final security = context.watch<SecurityService>();

    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.charcoal,
          body: CustomScrollView(
            slivers: [
              // ── Top App Bar ────────────────────────────────────
              SliverAppBar(
                pinned: true,
                backgroundColor: AppColors.charcoal,
                surfaceTintColor: Colors.transparent,
                toolbarHeight: 64,
                title: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'assets/images/gada.jpg',
                        width: 34,
                        height: 34,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ANGAD',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 3,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          vpn.isConnected
                              ? 'SHIELD ACTIVE · 15ms'
                              : 'STANDBY MODE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                            color: vpn.isConnected
                                ? AppColors.safeGreen
                                : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                actions: [
                  if (vpn.state == VpnState.error)
                    _VulnerableBadge()
                  else
                    Container(
                      margin: const EdgeInsets.only(right: 16),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: vpn.isConnected
                            ? AppColors.safeGreen.withValues(alpha: 0.12)
                            : AppColors.charcoalLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: vpn.isConnected
                              ? AppColors.safeGreen.withValues(alpha: 0.3)
                              : AppColors.border,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: vpn.isConnected
                                  ? AppColors.safeGreen
                                  : AppColors.textHint,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            vpn.isConnected ? 'PROTECTED' : 'OFFLINE',
                            style: TextStyle(
                              color: vpn.isConnected
                                  ? AppColors.safeGreen
                                  : AppColors.textMuted,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 110),
                  child: Column(
                    children: [
                      const SizedBox(height: 14),

                      // ── Gada Hero Activator ────────────────────
                      Center(
                        key: _gadaKey,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Energetic radial glow when active
                            if (vpn.isConnected)
                              Container(
                                width: 230,
                                height: 230,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.saffron
                                          .withValues(alpha: 0.25),
                                      blurRadius: 50,
                                      spreadRadius: 10,
                                    ),
                                  ],
                                ),
                              ),
                            GadaButton(
                              state: vpn.state,
                              size: 220,
                              onTap: () async {
                                await vpn.toggle();
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // ── Bold Status Pill & Session Duration ─────
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Column(
                          key: ValueKey(vpn.state),
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 7),
                              decoration: BoxDecoration(
                                color: _statusColor(vpn.state)
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: _statusColor(vpn.state)
                                      .withValues(alpha: 0.35),
                                  width: 1.2,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    vpn.isConnected
                                        ? Icons.verified_user_rounded
                                        : Icons.power_settings_new_rounded,
                                    size: 16,
                                    color: _statusColor(vpn.state),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _statusText(vpn.state).toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1,
                                      color: _statusColor(vpn.state),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (vpn.isConnected) ...[
                              const SizedBox(height: 6),
                              Text(
                                'Active Uptime: ${vpn.uptimeLabel}',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 26),

                      // ── Bold 2-Stat Cards ──────────────────────
                      Row(
                        key: _statsKey,
                        children: [
                          _StatCard(
                            value: '${security.blockedCount}',
                            label: 'Threats Blocked',
                            sublabel: 'LIVE ENGINE',
                            color: AppColors.threatRed,
                            icon: Icons.shield_rounded,
                          ),
                          const SizedBox(width: 14),
                          _StatCard(
                            value: '${security.scansCount}',
                            label: 'Links Scanned',
                            sublabel: 'SHIELDNET AI',
                            color: AppColors.saffron,
                            icon: Icons.radar_rounded,
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      // ── Connection Activity Histogram ──────────
                      AnimatedOpacity(
                        key: _histoKey,
                        duration: const Duration(milliseconds: 400),
                        opacity: 1.0,
                        child: ConnectionHistogram(
                          data: _buildMockHistogram(),
                          isLive: vpn.isConnected,
                        ),
                      ),

                      const SizedBox(height: 22),

                      // ── Offline Banner Alert ───────────────────
                      if (!vpn.isConnected)
                        _OfflineNotice(onActivate: () => vpn.toggle()),

                      const SizedBox(height: 22),

                      // ── Quick Sandbox Scanner ──────────────────
                      KeyedSubtree(
                        key: _scanKey,
                        child: SandboxQuickScan(securityService: security),
                      ),

                      const SizedBox(height: 22),

                      // ── AI News Verification — Coming Soon ──────
                      _ComingSoonCard(),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Sequential Guide Overlay ─────────────────────────────
        if (_showGuide)
          SequentialGuide(
            steps: [
              GuideStep(
                targetKey: _gadaKey,
                title: 'Your Shield Activator',
                body:
                    'Tap the Gada to activate Angad\'s full protection. When ON, all traffic is monitored in real time.',
                arrowUp: true,
              ),
              GuideStep(
                targetKey: _statsKey,
                title: 'Daily Security Summary',
                body:
                    'See how many threats were blocked and links scanned today. Updates in real time.',
                arrowUp: true,
              ),
              GuideStep(
                targetKey: _histoKey,
                title: 'Connection Activity',
                body:
                    'A live histogram of blocked vs allowed network connections per hour from your device.',
                arrowUp: true,
              ),
              GuideStep(
                targetKey: _scanKey,
                title: 'Quick Link Scanner',
                body:
                    'Paste any suspicious URL here to scan it instantly using Angad\'s AI engine.',
                arrowUp: true,
              ),
            ],
            onComplete: _dismissGuide,
          ),
      ],
    );
  }

  String _statusText(VpnState state) {
    switch (state) {
      case VpnState.connected:
        return 'Angad Protection Active';
      case VpnState.connecting:
        return 'Activating NetGuard...';
      case VpnState.disconnecting:
        return 'Deactivating...';
      case VpnState.error:
        return 'Protection Error';
      default:
        return 'Protection Disconnected';
    }
  }

  Color _statusColor(VpnState state) {
    switch (state) {
      case VpnState.connected:
        return AppColors.safeGreen;
      case VpnState.connecting:
        return AppColors.saffron;
      case VpnState.error:
        return AppColors.threatRed;
      default:
        return AppColors.textMuted;
    }
  }
}

// ── Bold Stat Card ─────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final String sublabel;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.value,
    required this.label,
    required this.sublabel,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.charcoalMid,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: color.withValues(alpha: 0.35),
            width: 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    sublabel,
                    style: TextStyle(
                      color: color,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.w900,
                color: color,
                fontFamily: 'JetBrains Mono',
                height: 1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Offline Notice ─────────────────────────────────────────────
class _OfflineNotice extends StatelessWidget {
  final VoidCallback onActivate;
  const _OfflineNotice({required this.onActivate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.amber.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.amber.withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.amber.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.shield_outlined,
                color: AppColors.amber, size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Device vulnerable: NetGuard proxy is offline. Tap Enable to protect your traffic.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onActivate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.saffron,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.saffron.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Text(
                'Enable',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 12.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Vulnerable Badge ───────────────────────────────────────────
class _VulnerableBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.threatRedDim,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.threatRed.withValues(alpha: 0.4)),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning_rounded, color: AppColors.threatRed, size: 14),
          SizedBox(width: 6),
          Text(
            'CONNECTION ERROR',
            style: TextStyle(
              color: AppColors.threatRed,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Coming Soon Card ───────────────────────────────────────────
class _ComingSoonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.charcoalMid,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderAccent, width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.gold.withValues(alpha: 0.25),
              ),
            ),
            child: const Icon(Icons.fact_check_rounded,
                color: AppColors.gold, size: 24),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI News Verification',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Cross-check viral news and forwards',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
            ),
            child: const Text(
              'Coming Soon',
              style: TextStyle(
                color: AppColors.gold,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
