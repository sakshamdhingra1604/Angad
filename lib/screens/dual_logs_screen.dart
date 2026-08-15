import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/security_service.dart';
import '../models/threat_log.dart';
import '../theme/app_colors.dart';
import '../widgets/log_session_sheet.dart';

class DualLogsScreen extends StatefulWidget {
  const DualLogsScreen({super.key});

  @override
  State<DualLogsScreen> createState() => _DualLogsScreenState();
}

class _DualLogsScreenState extends State<DualLogsScreen> {
  bool _showIntro    = true;
  bool _forensicMode = false;
  final _searchCtrl  = TextEditingController();
  String _query      = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Group logs: date → app → logs ───────────────────────────
  Map<String, Map<String, List<ThreatLog>>> _groupLogs(List<ThreatLog> raw) {
    final filtered = _query.isEmpty
        ? raw
        : raw.where((l) =>
            (l.appName.toLowerCase().contains(_query)) ||
            (l.destinationHost?.toLowerCase().contains(_query) ?? false) ||
            (l.destIp?.toLowerCase().contains(_query) ?? false)).toList();

    final map = <String, Map<String, List<ThreatLog>>>{};
    for (final log in filtered) {
      final dateKey = _dateKey(log.timestamp);
      map.putIfAbsent(dateKey, () => {});
      map[dateKey]!.putIfAbsent(log.appName, () => []);
      map[dateKey]![log.appName]!.add(log);
    }
    return map;
  }

  String _dateKey(DateTime dt) {
    final now = DateTime.now();
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return 'TODAY';
    }
    final y = dt.subtract(const Duration(days: 1));
    if (dt.year == y.year && dt.month == y.month && dt.day == y.day) {
      return 'YESTERDAY';
    }
    return '${_dayName(dt.weekday).toUpperCase()}, ${dt.day} ${_monthAbbr(dt.month).toUpperCase()} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final security = context.watch<SecurityService>();
    final grouped  = _groupLogs(security.logs);

    return Scaffold(
      backgroundColor: AppColors.charcoal,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ──────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.charcoal,
            surfaceTintColor: Colors.transparent,
            automaticallyImplyLeading: false,
            toolbarHeight: 64,
            title: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.saffronDim,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppColors.saffron.withValues(alpha: 0.3)),
                  ),
                  child: const Icon(Icons.analytics_rounded,
                      color: AppColors.saffron, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'Activity Logs',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                ),
              ],
            ),
            actions: [
              // Standard / Forensics toggle switch
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: _ModeSwitch(
                  forensicMode: _forensicMode,
                  onChanged: (val) => setState(() => _forensicMode = val),
                ),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Column(
                children: [
                  // ── Daily Summary Card ───────────────────────────
                  _DailySummaryCard(logs: security.logs),
                  const SizedBox(height: 16),

                  // ── Intro / Teaching Guide Card ───────────────────
                  if (_showIntro) ...[
                    _IntroCard(
                        onDismiss: () => setState(() => _showIntro = false)),
                    const SizedBox(height: 16),
                  ],

                  // ── High-Contrast Search Bar ─────────────────────
                  _SearchBar(
                    controller: _searchCtrl,
                    onChanged: (q) => setState(() => _query = q.toLowerCase()),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // ── Timeline List ─────────────────────────────────────
          if (security.logs.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Text(
                  'No activity logged yet',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 15),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final dateKeys = grouped.keys.toList();
                  if (index >= dateKeys.length) return null;
                  final dateKey = dateKeys[index];
                  final appGroups = grouped[dateKey]!;

                  return _DateSection(
                    dateLabel: dateKey,
                    isLast: index == dateKeys.length - 1,
                    appGroups: appGroups,
                    forensicMode: _forensicMode,
                    onAppTap: (appName, appIcon, logs) =>
                        _openSessionSheet(context, appName, appIcon, logs),
                  );
                },
                childCount: grouped.length,
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  void _openSessionSheet(BuildContext context, String appName,
      String appIcon, List<ThreatLog> logs) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LogSessionSheet(
        appName: appName,
        appIcon: appIcon,
        logs: logs,
      ),
    );
  }

  String _dayName(int d) =>
      ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][d - 1];
  String _monthAbbr(int m) => [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ][m - 1];
}

// ── Standard / Forensics Mode Switch Button ──────────────────────
class _ModeSwitch extends StatelessWidget {
  final bool forensicMode;
  final ValueChanged<bool> onChanged;

  const _ModeSwitch({
    required this.forensicMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.charcoalMid,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TabBtn(
            label: 'Standard',
            icon: Icons.list_alt_rounded,
            isSelected: !forensicMode,
            onTap: () => onChanged(false),
          ),
          _TabBtn(
            label: 'Forensics',
            icon: Icons.biotech_rounded,
            isSelected: forensicMode,
            onTap: () => onChanged(true),
          ),
        ],
      ),
    );
  }
}

class _TabBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabBtn({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.saffron : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.saffron.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? Colors.white : AppColors.textMuted,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textMuted,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Daily Summary Card ──────────────────────────────────────────
class _DailySummaryCard extends StatelessWidget {
  final List<ThreatLog> logs;
  const _DailySummaryCard({required this.logs});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayLogs = logs.where((l) =>
        l.timestamp.year  == today.year &&
        l.timestamp.month == today.month &&
        l.timestamp.day   == today.day).toList();

    final blocked  = todayLogs.where((l) =>
        l.severity == LogSeverity.blocked ||
        l.severity == LogSeverity.critical).length;
    final allowed  = todayLogs.length - blocked;
    final apps     = todayLogs.map((l) => l.appName).toSet().length;
    final topThreat = todayLogs.where((l) =>
        l.severity == LogSeverity.critical ||
        l.severity == LogSeverity.blocked).firstOrNull;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.charcoalMid,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderAccent, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 12,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.charcoalLight,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(19)),
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.saffron,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  "TODAY'S SECURITY OVERVIEW",
                  style: TextStyle(
                    color: AppColors.saffron,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                const Spacer(),
                Text(
                  _fmtDate(today),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // 3 Metric Columns
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                _SummaryCol(
                  count: '$blocked',
                  label: 'Threats Blocked',
                  color: blocked > 0 ? AppColors.threatRed : AppColors.textMuted,
                  icon: Icons.shield_rounded,
                  bgColor: blocked > 0
                      ? AppColors.threatRed.withValues(alpha: 0.12)
                      : AppColors.charcoalLight,
                ),
                Container(
                  width: 1,
                  height: 48,
                  color: AppColors.border,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                ),
                _SummaryCol(
                  count: '$allowed',
                  label: 'Clean Traffic',
                  color: AppColors.safeGreen,
                  icon: Icons.check_circle_rounded,
                  bgColor: AppColors.safeGreen.withValues(alpha: 0.12),
                ),
                Container(
                  width: 1,
                  height: 48,
                  color: AppColors.border,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                ),
                _SummaryCol(
                  count: '$apps',
                  label: 'Apps Monitored',
                  color: AppColors.saffron,
                  icon: Icons.apps_rounded,
                  bgColor: AppColors.saffron.withValues(alpha: 0.12),
                ),
              ],
            ),
          ),

          // Critical alert highlight banner
          if (topThreat != null)
            Container(
              margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.threatRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppColors.threatRed.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: AppColors.threatRed, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            height: 1.4),
                        children: [
                          TextSpan(
                            text: '${topThreat.appName}: ',
                            style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w800),
                          ),
                          TextSpan(
                            text: topThreat.decisionReason ??
                                'Blocked suspicious connection',
                            style: const TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.day} ${['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][d.month - 1]} ${d.year}';
}

class _SummaryCol extends StatelessWidget {
  final String count;
  final String label;
  final Color color;
  final Color bgColor;
  final IconData icon;

  const _SummaryCol({
    required this.count,
    required this.label,
    required this.color,
    required this.bgColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            count,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              fontFamily: 'JetBrains Mono',
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Teaching / Legend Card ──────────────────────────────────────
class _IntroCard extends StatelessWidget {
  final VoidCallback onDismiss;
  const _IntroCard({required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.charcoalMid,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AppColors.saffron.withValues(alpha: 0.35), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.school_rounded,
                  color: AppColors.saffron, size: 18),
              const SizedBox(width: 8),
              const Text(
                'HOW TO READ YOUR LOGS',
                style: TextStyle(
                  color: AppColors.saffron,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onDismiss,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.charcoalLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.close_rounded,
                      color: AppColors.textMuted, size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Activity logs are grouped chronologically like a phone call log. Tap any app card to inspect complete forensics details including IP, TLS ciphers, and 42-D neural features.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          _LegendItem(
            icon: Icons.check_circle_outline_rounded,
            color: AppColors.safeGreen,
            title: 'Allowed Traffic',
            desc: 'Legitimate connection verified by NetGuard',
          ),
          const SizedBox(height: 8),
          _LegendItem(
            icon: Icons.block_rounded,
            color: AppColors.threatRed,
            title: 'Blocked Threat',
            desc: 'Malicious domain/phishing dropped at OS level',
          ),
          const SizedBox(height: 8),
          _LegendItem(
            icon: Icons.signal_cellular_alt_rounded,
            color: AppColors.gold,
            title: 'Risk Signal Bars',
            desc: 'Higher bars indicate elevated AI threat score',
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String desc;

  const _LegendItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 17),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 12.5, height: 1.4),
              children: [
                TextSpan(
                  text: '$title: ',
                  style: TextStyle(color: color, fontWeight: FontWeight.w800),
                ),
                TextSpan(
                  text: desc,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Search Bar ───────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14.5,
          fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: 'Search applications, domains, IP addresses...',
        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
        prefixIcon: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: Icon(Icons.search_rounded, color: AppColors.saffron, size: 20),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 44),
        filled: true,
        fillColor: AppColors.charcoalMid,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.saffron, width: 1.8),
        ),
      ),
    );
  }
}

// ── Date Section with Timeline ───────────────────────────────────
class _DateSection extends StatelessWidget {
  final String dateLabel;
  final bool isLast;
  final Map<String, List<ThreatLog>> appGroups;
  final bool forensicMode;
  final void Function(String, String, List<ThreatLog>) onAppTap;

  const _DateSection({
    required this.dateLabel,
    required this.isLast,
    required this.appGroups,
    required this.forensicMode,
    required this.onAppTap,
  });

  @override
  Widget build(BuildContext context) {
    final appNames = appGroups.keys.toList();

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Timeline Node & Line ──────────────────────────────
          SizedBox(
            width: 44,
            child: Column(
              children: [
                const SizedBox(height: 18),
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppColors.saffron,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.saffron.withValues(alpha: 0.45),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2.5,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: AppColors.saffron.withValues(alpha: 0.3),
                    ),
                  ),
              ],
            ),
          ),

          // ── Cards Column ──────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 16, bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Title
                  Padding(
                    padding: const EdgeInsets.only(top: 14, bottom: 12),
                    child: Text(
                      dateLabel,
                      style: const TextStyle(
                        color: AppColors.saffron,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),

                  // App Cards
                  for (final appName in appNames) ...[
                    _AppGroupCard(
                      appName: appName,
                      logs: appGroups[appName]!,
                      forensicMode: forensicMode,
                      onTap: () => onAppTap(
                        appName,
                        appGroups[appName]!.first.appIcon,
                        appGroups[appName]!,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── App Group Card ────────────────────────────────────────────────
class _AppGroupCard extends StatelessWidget {
  final String appName;
  final List<ThreatLog> logs;
  final bool forensicMode;
  final VoidCallback onTap;

  const _AppGroupCard({
    required this.appName,
    required this.logs,
    required this.forensicMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final blocked = logs.where((l) =>
        l.severity == LogSeverity.blocked ||
        l.severity == LogSeverity.critical).length;
    final hasBlock = blocked > 0;
    final preview = logs.take(4).toList();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.charcoalMid,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasBlock
                ? AppColors.threatRed.withValues(alpha: 0.35)
                : AppColors.borderAccent,
            width: hasBlock ? 1.4 : 1.2,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 3),
            )
          ],
        ),
        child: Column(
          children: [
            // ── App Header ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.charcoalLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Center(
                      child: Text(
                        logs.first.appIcon,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appName,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          hasBlock
                              ? '$blocked threats blocked · ${logs.length} connections'
                              : '${logs.length} connections recorded',
                          style: TextStyle(
                            color: hasBlock
                                ? AppColors.threatRed
                                : AppColors.textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.charcoalLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.arrow_forward_ios_rounded,
                        color: AppColors.textMuted, size: 14),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: AppColors.border),

            // ── Preview Connection Rows ────────────────────────
            for (final log in preview) ...[
              _PreviewRow(log: log, forensicMode: forensicMode),
              if (log != preview.last)
                const Divider(
                  height: 1,
                  indent: 14,
                  endIndent: 14,
                  color: AppColors.border,
                ),
            ],

            // Expand Footer
            if (logs.length > 4)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: AppColors.charcoalLight.withValues(alpha: 0.5),
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(15)),
                ),
                child: Center(
                  child: Text(
                    'Tap to view all ${logs.length} connections & deep forensics →',
                    style: const TextStyle(
                      color: AppColors.saffron,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
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

// ── Preview Row (Inside App Card) ────────────────────────────────
class _PreviewRow extends StatelessWidget {
  final ThreatLog log;
  final bool forensicMode;
  const _PreviewRow({required this.log, required this.forensicMode});

  @override
  Widget build(BuildContext context) {
    final isBlocked = log.severity == LogSeverity.blocked ||
        log.severity == LogSeverity.critical;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          // Repeat Counter Pill (e.g. 2x, 4x)
          if ((log.connectionCount ?? 1) > 1)
            Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.charcoalBright,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.borderAccent),
              ),
              child: Text(
                '${log.connectionCount}x',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'JetBrains Mono',
                ),
              ),
            ),

          // Host Domain + Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.destinationHost ?? log.destIp ?? 'Unknown',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                if (forensicMode && log.entropyScore != null)
                  Wrap(
                    spacing: 6,
                    children: [
                      _ForensicPill(
                        'H: ${log.entropyScore!.toStringAsFixed(2)}',
                        log.entropyScore! > 3.8
                            ? AppColors.threatRed
                            : AppColors.amber,
                      ),
                      if (log.protocol != null)
                        _ForensicPill(log.protocol!, AppColors.infoBlue),
                      if (log.country != null)
                        _ForensicPill('🌍 ${log.country}', AppColors.textSecondary),
                      if (log.destPort != null)
                        _ForensicPill(':${log.destPort}', AppColors.textMuted),
                    ],
                  )
                else
                  Row(
                    children: [
                      Text(
                        _fmtTime(log.timestamp),
                        style: const TextStyle(
                          color: AppColors.saffron,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (log.protocol != null) ...[
                        const Text(' · ',
                            style: TextStyle(
                                color: AppColors.textHint, fontSize: 12)),
                        Text(
                          log.protocol!,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Traffic risk bars
          _TrafficBars(risk: log.riskScore ?? 0),
          const SizedBox(width: 10),

          // Block icon
          Icon(
            isBlocked
                ? Icons.block_rounded
                : Icons.check_circle_outline_rounded,
            color: isBlocked ? AppColors.threatRed : AppColors.safeGreen,
            size: 19,
          ),
        ],
      ),
    );
  }

  String _fmtTime(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    final s = t.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}

class _ForensicPill extends StatelessWidget {
  final String text;
  final Color color;
  const _ForensicPill(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          fontFamily: 'JetBrains Mono',
        ),
      ),
    );
  }
}

// ── Traffic Bars Indicator ──────────────────────────────────────
class _TrafficBars extends StatelessWidget {
  final double risk;
  const _TrafficBars({required this.risk});

  @override
  Widget build(BuildContext context) {
    final color = risk > 0.6
        ? AppColors.threatRed
        : risk > 0.3
            ? AppColors.amber
            : AppColors.safeGreen;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (int i = 0; i < 4; i++)
          Container(
            margin: const EdgeInsets.only(right: 2),
            width: 3.5,
            height: 5.0 + i * 3.5,
            decoration: BoxDecoration(
              color: i < (risk * 4).ceil() ? color : AppColors.charcoalBright,
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
      ],
    );
  }
}
