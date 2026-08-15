import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'scan_result.dart';

enum LogSeverity { info, warning, blocked, critical }

extension LogSeverityExt on LogSeverity {
  Color get color {
    switch (this) {
      case LogSeverity.info: return AppColors.infoBlue;
      case LogSeverity.warning: return AppColors.amber;
      case LogSeverity.blocked: return AppColors.threatRed;
      case LogSeverity.critical: return AppColors.threatRed;
    }
  }

  String get label {
    switch (this) {
      case LogSeverity.info: return 'INFO';
      case LogSeverity.warning: return 'WARN';
      case LogSeverity.blocked: return 'BLOCKED';
      case LogSeverity.critical: return 'CRITICAL';
    }
  }

  IconData get icon {
    switch (this) {
      case LogSeverity.info: return Icons.info_outline_rounded;
      case LogSeverity.warning: return Icons.warning_amber_rounded;
      case LogSeverity.blocked: return Icons.block_rounded;
      case LogSeverity.critical: return Icons.dangerous_rounded;
    }
  }
}

class ThreatLog {
  final String id;
  final DateTime timestamp;
  final LogSeverity severity;
  final ThreatCategory category;

  // ── Layer 1: Simple View ──────────────────────────────────────
  final String appName;
  final String appIcon;
  final String simpleMessage;   // e.g. "Blocked malicious connection from Chrome"
  final String? destinationHost;

  // ── Layer 2: Deep Forensics ───────────────────────────────────
  final String? sourceIp;
  final String? destIp;
  final int? destPort;
  final String? sniHostname;
  final String? ja3Fingerprint;
  final String? ja3Hash;
  final double? riskScore;
  final double? entropyScore;
  final double? iatDelay;         // Inter-Arrival Time (ms)
  final double? tldRisk;
  final int? payloadSizeBytes;
  final int? packetsPerSecond;
  final List<double>? featureVector42;   // 42-dim NetGuard feature vector
  final Map<String, double>? featureNames; // name -> value mapping
  final String? tlsVersion;
  final List<String>? cipherSuites;
  final String? decisionReason;
  final List<String>? shieldNetReasons;
  final bool? iptablesDropped;
  final String? protocol;          // TCP / UDP / TLS / QUIC
  final String? country;           // Server country (e.g. "US", "IN")
  final int? connectionCount;      // How many times this connection repeated

  // ── Blockchain Verification ───────────────────────────────────
  final bool? merkleVerified;
  final String? merkleHash;
  final String? merkleBlockHeight;
  final String? merkleTimestamp;

  // ── False Positive Reporting ──────────────────────────────────
  bool? userFeedback;   // true = correct, false = false positive

  ThreatLog({
    required this.id,
    required this.timestamp,
    required this.severity,
    required this.category,
    required this.appName,
    required this.appIcon,
    required this.simpleMessage,
    this.destinationHost,
    this.sourceIp,
    this.destIp,
    this.destPort,
    this.sniHostname,
    this.ja3Fingerprint,
    this.ja3Hash,
    this.riskScore,
    this.entropyScore,
    this.iatDelay,
    this.tldRisk,
    this.payloadSizeBytes,
    this.packetsPerSecond,
    this.featureVector42,
    this.featureNames,
    this.tlsVersion,
    this.cipherSuites,
    this.decisionReason,
    this.shieldNetReasons,
    this.iptablesDropped,
    this.protocol,
    this.country,
    this.connectionCount,
    this.merkleVerified,
    this.merkleHash,
    this.merkleBlockHeight,
    this.merkleTimestamp,
    this.userFeedback,
  });

  ThreatLog copyWith({bool? userFeedback}) {
    return ThreatLog(
      id: id,
      timestamp: timestamp,
      severity: severity,
      category: category,
      appName: appName,
      appIcon: appIcon,
      simpleMessage: simpleMessage,
      destinationHost: destinationHost,
      sourceIp: sourceIp,
      destIp: destIp,
      destPort: destPort,
      sniHostname: sniHostname,
      ja3Fingerprint: ja3Fingerprint,
      ja3Hash: ja3Hash,
      riskScore: riskScore,
      entropyScore: entropyScore,
      iatDelay: iatDelay,
      tldRisk: tldRisk,
      payloadSizeBytes: payloadSizeBytes,
      packetsPerSecond: packetsPerSecond,
      featureVector42: featureVector42,
      featureNames: featureNames,
      tlsVersion: tlsVersion,
      cipherSuites: cipherSuites,
      decisionReason: decisionReason,
      shieldNetReasons: shieldNetReasons,
      iptablesDropped: iptablesDropped,
      protocol: protocol,
      country: country,
      connectionCount: connectionCount,
      merkleVerified: merkleVerified,
      merkleHash: merkleHash,
      merkleBlockHeight: merkleBlockHeight,
      merkleTimestamp: merkleTimestamp,
      userFeedback: userFeedback ?? this.userFeedback,
    );
  }

  bool get hasDeepData =>
      ja3Fingerprint != null ||
      featureVector42 != null ||
      entropyScore != null ||
      merkleVerified == true;

  String get timeAgo {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
