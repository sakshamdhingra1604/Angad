import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/threat_log.dart';
import '../services/security_service.dart';
import '../theme/app_colors.dart';
import 'merkle_tree_badge.dart';

/// Full session detail sheet — shows all connections for a specific app
/// with comprehensive, high-contrast Deep Forensics (Network, TLS, AI Scores, 42-D Features, Merkle, Feedback)
class LogSessionSheet extends StatefulWidget {
  final String appName;
  final String appIcon;
  final List<ThreatLog> logs;

  const LogSessionSheet({
    super.key,
    required this.appName,
    required this.appIcon,
    required this.logs,
  });

  @override
  State<LogSessionSheet> createState() => _LogSessionSheetState();
}

class _LogSessionSheetState extends State<LogSessionSheet> {
  ThreatLog? _expanded;
  final Set<String> _sentFeedback = {};

  @override
  Widget build(BuildContext context) {
    final blocked = widget.logs.where((l) =>
        l.severity == LogSeverity.blocked ||
        l.severity == LogSeverity.critical).length;
    final allowed = widget.logs.length - blocked;

    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: AppColors.charcoalMid,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // ── Handle ──────────────────────────────────────────────
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.borderAccent,
              borderRadius: BorderRadius.circular(3),
            ),
          ),

          // ── App Header ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.charcoalLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderAccent, width: 1.2),
                  ),
                  child: Center(
                    child: Text(widget.appIcon,
                        style: const TextStyle(fontSize: 26)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.appName,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${widget.logs.length} connections recorded  ·  $blocked threats',
                        style: TextStyle(
                          color: blocked > 0
                              ? AppColors.threatRed
                              : AppColors.textMuted,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                _MiniCountBadge(
                  label: 'BLOCKED',
                  count: '$blocked',
                  color: blocked > 0 ? AppColors.threatRed : AppColors.textMuted,
                  bgColor: blocked > 0
                      ? AppColors.threatRed.withValues(alpha: 0.15)
                      : AppColors.charcoalLight,
                ),
                const SizedBox(width: 8),
                _MiniCountBadge(
                  label: 'SAFE',
                  count: '$allowed',
                  color: AppColors.safeGreen,
                  bgColor: AppColors.safeGreen.withValues(alpha: 0.15),
                ),
              ],
            ),
          ),

          const Divider(color: AppColors.border, height: 1),

          // ── Connection Log Timeline List ─────────────────────────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
              itemCount: widget.logs.length,
              itemBuilder: (context, i) {
                final log = widget.logs[i];
                final isExpanded = _expanded?.id == log.id;
                return _ConnectionCard(
                  log: log,
                  isExpanded: isExpanded,
                  feedbackSent: _sentFeedback.contains(log.id),
                  onFeedback: (isCorrect) {
                    context.read<SecurityService>().submitFeedback(log.id, isCorrect);
                    setState(() => _sentFeedback.add(log.id));
                  },
                  onToggleExpand: () => setState(() =>
                      _expanded = isExpanded ? null : log),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Mini Header Count Badge ─────────────────────────────────────
class _MiniCountBadge extends StatelessWidget {
  final String label;
  final String count;
  final Color color;
  final Color bgColor;

  const _MiniCountBadge({
    required this.label,
    required this.count,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.2),
      ),
      child: Column(
        children: [
          Text(
            count,
            style: TextStyle(
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.w900,
              fontFamily: 'JetBrains Mono',
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Connection Card ─────────────────────────────────────────────
class _ConnectionCard extends StatelessWidget {
  final ThreatLog log;
  final bool isExpanded;
  final bool feedbackSent;
  final ValueChanged<bool> onFeedback;
  final VoidCallback onToggleExpand;

  const _ConnectionCard({
    required this.log,
    required this.isExpanded,
    required this.feedbackSent,
    required this.onFeedback,
    required this.onToggleExpand,
  });

  @override
  Widget build(BuildContext context) {
    final isBlocked = log.severity == LogSeverity.blocked ||
        log.severity == LogSeverity.critical;
    final accentColor = isBlocked ? AppColors.threatRed : AppColors.safeGreen;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isExpanded
            ? accentColor.withValues(alpha: 0.06)
            : AppColors.charcoal,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isExpanded
              ? accentColor.withValues(alpha: 0.45)
              : (isBlocked
                  ? AppColors.threatRed.withValues(alpha: 0.3)
                  : AppColors.borderAccent),
          width: isExpanded ? 1.6 : 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Tappable Summary Header ──────────────────────────
          InkWell(
            onTap: onToggleExpand,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Severity Pill Badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: log.severity.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: log.severity.color.withValues(alpha: 0.4),
                          width: 1.2),
                    ),
                    child: Text(
                      log.severity.label,
                      style: TextStyle(
                        color: log.severity.color,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Repeat counter pill (e.g. 2x)
                  if ((log.connectionCount ?? 1) > 1)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.charcoalBright,
                        borderRadius: BorderRadius.circular(5),
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

                  // Host Domain / Target
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          log.destinationHost ?? log.destIp ?? 'Unknown',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Text(
                              _formatTime(log.timestamp),
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
                                  color: AppColors.infoBlue,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                            if (log.country != null) ...[
                              const Text(' · ',
                                  style: TextStyle(
                                      color: AppColors.textHint, fontSize: 12)),
                              Text(
                                '🌍 ${log.country}',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
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

                  const SizedBox(width: 8),

                  // Traffic bars
                  _TrafficBars(risk: log.riskScore ?? 0),
                  const SizedBox(width: 8),

                  // Expand Chevron Icon
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.charcoalLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: isExpanded ? accentColor : AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Deep Forensics Expanded Dashboard ─────────────────
          if (isExpanded)
            _FullForensicsPanel(
              log: log,
              feedbackSent: feedbackSent,
              onFeedback: onFeedback,
            ),
        ],
      ),
    );
  }

  String _formatTime(DateTime ts) {
    final now = DateTime.now();
    final time =
        '${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')}:${ts.second.toString().padLeft(2, '0')}';
    if (ts.year == now.year && ts.month == now.month && ts.day == now.day) {
      return time;
    }
    return '${ts.day} ${_month(ts.month)} $time';
  }

  String _month(int m) => [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ][m - 1];
}

// ── Full Deep Forensics Panel ───────────────────────────────────
class _FullForensicsPanel extends StatelessWidget {
  final ThreatLog log;
  final bool feedbackSent;
  final ValueChanged<bool> onFeedback;

  const _FullForensicsPanel({
    required this.log,
    required this.feedbackSent,
    required this.onFeedback,
  });

  @override
  Widget build(BuildContext context) {
    final isBlocked = log.severity == LogSeverity.blocked ||
        log.severity == LogSeverity.critical;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(color: AppColors.border, height: 16),

          // ── 1. Event Summary Box ─────────────────────────────
          _ForensicBox(
            title: 'EVENT SUMMARY',
            icon: Icons.info_outline_rounded,
            color: AppColors.saffron,
            children: [
              _MonoRow('Application', '${log.appIcon} ${log.appName}'),
              _MonoRow('Target Host', log.destinationHost ?? '--'),
              _MonoRow('Timestamp', log.timestamp.toIso8601String()),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.charcoalMid,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  log.simpleMessage,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          // ── 2. Network Layer ─────────────────────────────────
          _ForensicBox(
            title: 'NETWORK LAYER',
            icon: Icons.lan_rounded,
            color: AppColors.infoBlue,
            children: [
              if (log.sourceIp != null) _MonoRow('Source IP', log.sourceIp!),
              if (log.destIp != null) _MonoRow('Destination IP', log.destIp!),
              if (log.destPort != null) _MonoRow('Destination Port', 'Port :${log.destPort}'),
              if (log.protocol != null) _MonoRow('Protocol', log.protocol!),
              if (log.country != null) _MonoRow('Server Location', '🌍 ${log.country}'),
              if (log.sniHostname != null) _MonoRow('SNI Hostname', log.sniHostname!),
              if (log.payloadSizeBytes != null)
                _MonoRow('Payload Size', _fmtBytes(log.payloadSizeBytes!)),
              if (log.packetsPerSecond != null)
                _MonoRow('Throughput (PPS)', '${log.packetsPerSecond} packets/sec'),
            ],
          ),

          // ── 3. TLS Fingerprinting & Cryptography ─────────────
          if (log.ja3Fingerprint != null || log.ja3Hash != null || log.tlsVersion != null)
            _ForensicBox(
              title: 'TLS FINGERPRINTING & CIPHERS',
              icon: Icons.fingerprint_rounded,
              color: AppColors.gold,
              children: [
                if (log.tlsVersion != null) _MonoRow('TLS Version', log.tlsVersion!),
                if (log.ja3Hash != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const SizedBox(
                        width: 110,
                        child: Text(
                          'JA3 MD5 Hash',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: log.ja3Hash!));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('JA3 hash copied to clipboard!'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: AppColors.gold.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    log.ja3Hash!,
                                    style: const TextStyle(
                                      color: AppColors.gold,
                                      fontSize: 12,
                                      fontFamily: 'JetBrains Mono',
                                      fontWeight: FontWeight.w700,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.copy_rounded,
                                    color: AppColors.gold, size: 14),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (log.ja3Fingerprint != null) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'FULL RAW JA3 STRING',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.charcoalMid,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: SelectableText(
                      log.ja3Fingerprint!,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        fontFamily: 'JetBrains Mono',
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
                if (log.cipherSuites != null && log.cipherSuites!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'CIPHER SUITES',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...log.cipherSuites!.map((c) => Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Text(
                          '• $c',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11.5,
                            fontFamily: 'JetBrains Mono',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )),
                ],
              ],
            ),

          // ── 4. AI Risk Metrics ───────────────────────────────
          _ForensicBox(
            title: 'AI THREAT & RISK SCORING',
            icon: Icons.speed_rounded,
            color: isBlocked ? AppColors.threatRed : AppColors.safeGreen,
            children: [
              if (log.riskScore != null)
                _ScoreBar(
                  'Overall Threat Risk',
                  log.riskScore!,
                  log.riskScore! > 0.6 ? AppColors.threatRed : AppColors.safeGreen,
                ),
              if (log.entropyScore != null)
                _ScoreBar(
                  'URL Shannon Entropy',
                  (log.entropyScore! / 6.0).clamp(0.0, 1.0),
                  log.entropyScore! > 3.8 ? AppColors.threatRed : AppColors.amber,
                  valueLabel: '${log.entropyScore!.toStringAsFixed(3)} / 6.0',
                ),
              if (log.tldRisk != null)
                _ScoreBar(
                  'TLD Domain Risk Factor',
                  log.tldRisk!,
                  log.tldRisk! > 0.5 ? AppColors.threatRed : AppColors.amber,
                ),
              if (log.iatDelay != null)
                _MonoRow(
                  'Inter-Arrival (IAT)',
                  '${log.iatDelay!.toStringAsFixed(1)} ms',
                ),
            ],
          ),

          // ── 5. 42-Dimension NetGuard Feature Vector ──────────
          if (log.featureVector42 != null || log.featureNames != null)
            _ForensicBox(
              title: '42-DIMENSION NEURAL FEATURE VECTOR',
              icon: Icons.view_in_ar_rounded,
              color: AppColors.saffron,
              children: [
                if (log.featureNames != null) ...[
                  ...log.featureNames!.entries.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 140,
                              child: Text(
                                e.key,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: LinearProgressIndicator(
                                  value: (e.value / 10.0).clamp(0.0, 1.0),
                                  backgroundColor: AppColors.charcoalMid,
                                  color: AppColors.saffron,
                                  minHeight: 6,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 48,
                              child: Text(
                                e.value.toStringAsFixed(2),
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  color: AppColors.saffron,
                                  fontSize: 12,
                                  fontFamily: 'JetBrains Mono',
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
                if (log.featureVector42 != null) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: log.featureVector42!
                        .asMap()
                        .entries
                        .take(16)
                        .map((e) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.charcoalMid,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.borderAccent),
                        ),
                        child: Text(
                          'f${e.key}: ${e.value.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 10.5,
                            fontFamily: 'JetBrains Mono',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),

          // ── 6. AI Decision & ShieldNet Signals ───────────────
          if (log.decisionReason != null ||
              (log.shieldNetReasons != null && log.shieldNetReasons!.isNotEmpty))
            _ForensicBox(
              title: 'AI DECISION & REASONS',
              icon: Icons.gavel_rounded,
              color: isBlocked ? AppColors.threatRed : AppColors.safeGreen,
              children: [
                if (log.decisionReason != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.charcoalMid,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      log.decisionReason!,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                      ),
                    ),
                  ),
                if (log.shieldNetReasons != null &&
                    log.shieldNetReasons!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'SHIELDNET THREAT SIGNALS:',
                    style: TextStyle(
                      color: AppColors.saffron,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...log.shieldNetReasons!.map((r) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.arrow_right_rounded,
                                color: AppColors.threatRed, size: 18),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                r,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ],
            ),

          // ── 7. OS-Level iptables Enforcement ─────────────────
          if (log.iptablesDropped == true)
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.threatRed.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.threatRed.withValues(alpha: 0.4),
                    width: 1.2),
              ),
              child: const Row(
                children: [
                  Icon(Icons.shield_rounded,
                      color: AppColors.threatRed, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'iptables DROP rule enforced at OS-level before relaying bytes',
                      style: TextStyle(
                        color: AppColors.threatRed,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // ── 8. Blockchain Merkle Proof ───────────────────────
          if (log.merkleVerified == true)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: MerkleTreeBadge(log: log, expanded: true),
            ),

          // ── 9. Verdict Feedback ──────────────────────────────
          _ForensicBox(
            title: 'VERDICT FEEDBACK',
            icon: Icons.rate_review_rounded,
            color: AppColors.gold,
            children: [
              const Text(
                'Help train Angad AI — was this verdict accurate?',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              if (feedbackSent)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.safeGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppColors.safeGreen.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle_rounded,
                          color: AppColors.safeGreen, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Feedback recorded · Thank you for training Angad AI',
                        style: TextStyle(
                          color: AppColors.safeGreen,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => onFeedback(true),
                        icon: const Icon(Icons.thumb_up_rounded, size: 16),
                        label: const Text(
                          'Correct Verdict',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.safeGreen,
                          side: BorderSide(
                              color: AppColors.safeGreen.withValues(alpha: 0.45),
                              width: 1.2),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => onFeedback(false),
                        icon: const Icon(Icons.thumb_down_rounded, size: 16),
                        label: const Text(
                          'False Positive',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.amber,
                          side: BorderSide(
                              color: AppColors.amber.withValues(alpha: 0.45),
                              width: 1.2),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _fmtBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)}MB';
  }
}

// ── Forensic Category Container Box ─────────────────────────────
class _ForensicBox extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<Widget> children;

  const _ForensicBox({
    required this.title,
    required this.icon,
    required this.color,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.charcoalLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderAccent, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

// ── Monospace Data Row ──────────────────────────────────────────
class _MonoRow extends StatelessWidget {
  final String label;
  final String value;

  const _MonoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12.5,
                fontFamily: 'JetBrains Mono',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Progress Score Bar ──────────────────────────────────────────
class _ScoreBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final String? valueLabel;

  const _ScoreBar(this.label, this.value, this.color, {this.valueLabel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                valueLabel ?? '${(value * 100).toInt()}%',
                style: TextStyle(
                  color: color,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'JetBrains Mono',
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value.clamp(0.0, 1.0),
              backgroundColor: AppColors.charcoalMid,
              color: color,
              minHeight: 6,
            ),
          ),
        ],
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
