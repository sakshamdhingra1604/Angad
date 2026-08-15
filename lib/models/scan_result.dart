import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum ThreatCategory { safe, phishing, malware, dataLeak, scam, unknown }

enum DecisionType { allow, review, block }

enum TierLevel { tier0, tier1, tier2, tier3, tier4 }

extension ThreatCategoryExt on ThreatCategory {
  String get displayName {
    switch (this) {
      case ThreatCategory.safe: return 'Safe';
      case ThreatCategory.phishing: return 'Phishing';
      case ThreatCategory.malware: return 'Malware';
      case ThreatCategory.dataLeak: return 'Data Leak';
      case ThreatCategory.scam: return 'Scam';
      case ThreatCategory.unknown: return 'Unknown';
    }
  }

  Color get color {
    switch (this) {
      case ThreatCategory.safe: return AppColors.safe;
      case ThreatCategory.phishing: return AppColors.phishing;
      case ThreatCategory.malware: return AppColors.malware;
      case ThreatCategory.dataLeak: return AppColors.dataLeak;
      case ThreatCategory.scam: return AppColors.scam;
      case ThreatCategory.unknown: return AppColors.textMuted;
    }
  }

  IconData get icon {
    switch (this) {
      case ThreatCategory.safe: return Icons.verified_rounded;
      case ThreatCategory.phishing: return Icons.phishing_rounded;
      case ThreatCategory.malware: return Icons.bug_report_rounded;
      case ThreatCategory.dataLeak: return Icons.leak_remove_rounded;
      case ThreatCategory.scam: return Icons.warning_amber_rounded;
      case ThreatCategory.unknown: return Icons.help_outline_rounded;
    }
  }
}

class ScanResult {
  final String url;
  final ThreatCategory category;
  final double riskScore;
  final DecisionType decision;
  final List<String> reasons;
  final DateTime scannedAt;
  final TierLevel depthReached;
  final Map<String, dynamic> tierResults;
  final List<String> warnings;
  final String? screenshotUrl;

  // Deep Forensics Fields (Layer 2)
  final List<double>? featureVector;  // 41-dimensional
  final String? ja3Fingerprint;
  final String? ja3Hash;
  final String? sniHostname;
  final double? entropyScore;
  final double? iatDelay;
  final double? tldRisk;
  final int? payloadSize;
  final double? brandImpersonationScore;
  final String? merkleHash;
  final bool? merkleVerified;

  const ScanResult({
    required this.url,
    required this.category,
    required this.riskScore,
    required this.decision,
    required this.reasons,
    required this.scannedAt,
    required this.depthReached,
    required this.tierResults,
    required this.warnings,
    this.screenshotUrl,
    this.featureVector,
    this.ja3Fingerprint,
    this.ja3Hash,
    this.sniHostname,
    this.entropyScore,
    this.iatDelay,
    this.tldRisk,
    this.payloadSize,
    this.brandImpersonationScore,
    this.merkleHash,
    this.merkleVerified,
  });

  factory ScanResult.fromJson(Map<String, dynamic> json) {
    return ScanResult(
      url: json['url'] ?? '',
      category: _parseCategory(json['category']),
      riskScore: (json['risk_score'] ?? 0.0).toDouble(),
      decision: _parseDecision(json['decision']),
      reasons: List<String>.from(json['reasons'] ?? []),
      scannedAt: DateTime.tryParse(json['scanned_at'] ?? '') ?? DateTime.now(),
      depthReached: _parseTier(json['depth_reached']),
      tierResults: Map<String, dynamic>.from(json['tier_results'] ?? {}),
      warnings: List<String>.from(json['warnings'] ?? []),
      screenshotUrl: json['screenshot_url'],
      featureVector: json['feature_vector'] != null
          ? List<double>.from(json['feature_vector'].map((e) => e.toDouble()))
          : null,
      ja3Fingerprint: json['ja3_fingerprint'],
      ja3Hash: json['ja3_hash'],
      sniHostname: json['sni_hostname'],
      entropyScore: json['entropy_score']?.toDouble(),
      iatDelay: json['iat_delay']?.toDouble(),
      tldRisk: json['tld_risk']?.toDouble(),
      payloadSize: json['payload_size'],
      brandImpersonationScore: json['brand_impersonation_score']?.toDouble(),
      merkleHash: json['merkle_hash'],
      merkleVerified: json['merkle_verified'],
    );
  }

  Map<String, dynamic> toJson() => {
    'url': url,
    'category': category.name,
    'risk_score': riskScore,
    'decision': decision.name,
    'reasons': reasons,
    'scanned_at': scannedAt.toIso8601String(),
    'depth_reached': depthReached.name,
    'tier_results': tierResults,
    'warnings': warnings,
    'screenshot_url': screenshotUrl,
    'feature_vector': featureVector,
    'ja3_fingerprint': ja3Fingerprint,
    'ja3_hash': ja3Hash,
    'sni_hostname': sniHostname,
    'entropy_score': entropyScore,
    'iat_delay': iatDelay,
    'tld_risk': tldRisk,
    'payload_size': payloadSize,
    'brand_impersonation_score': brandImpersonationScore,
    'merkle_hash': merkleHash,
    'merkle_verified': merkleVerified,
  };

  static ThreatCategory _parseCategory(String? val) {
    switch (val) {
      case 'safe': return ThreatCategory.safe;
      case 'phishing': return ThreatCategory.phishing;
      case 'malware': return ThreatCategory.malware;
      case 'data_leak': return ThreatCategory.dataLeak;
      case 'scam': return ThreatCategory.scam;
      default: return ThreatCategory.unknown;
    }
  }

  static DecisionType _parseDecision(String? val) {
    switch (val) {
      case 'allow': return DecisionType.allow;
      case 'review': return DecisionType.review;
      case 'block': return DecisionType.block;
      default: return DecisionType.review;
    }
  }

  static TierLevel _parseTier(String? val) {
    switch (val) {
      case 'tier0': return TierLevel.tier0;
      case 'tier1': return TierLevel.tier1;
      case 'tier2': return TierLevel.tier2;
      case 'tier3': return TierLevel.tier3;
      case 'tier4': return TierLevel.tier4;
      default: return TierLevel.tier0;
    }
  }

  bool get isBlocked => decision == DecisionType.block;
  bool get isSafe => category == ThreatCategory.safe;
  String get riskPercent => '${(riskScore * 100).toInt()}%';
}
