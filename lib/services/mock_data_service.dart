import 'dart:math';
import '../models/scan_result.dart';
import '../models/threat_log.dart';
import '../models/app_firewall_rules.dart';
import '../models/telemetry_data.dart';

// Internal helper for mock log generation
class _AppSession {
  final String appName;
  final String appIcon;
  final String packageName;
  final bool isSystemApp;
  // (domain, port, protocol, country, count, isBlocked, riskScore)
  final List<(String, int, String, String, int, bool, double)> hosts;

  const _AppSession(this.appName, this.appIcon, this.packageName,
      this.isSystemApp, this.hosts);
}

class MockDataService {
  static final _rng = Random();

  // ── Mock Scan Results ─────────────────────────────────────────
  static ScanResult mockScan(String url) {
    final isBad = url.contains('bit.ly') ||
        url.contains('free') ||
        url.contains('login') ||
        url.contains('prize') ||
        url.contains('win') ||
        url.contains('verify') ||
        url.contains('otp');

    final category = isBad
        ? [ThreatCategory.phishing, ThreatCategory.scam, ThreatCategory.malware][_rng.nextInt(3)]
        : ThreatCategory.safe;
    final riskScore = isBad ? 0.65 + _rng.nextDouble() * 0.35 : _rng.nextDouble() * 0.15;

    return ScanResult(
      url: url,
      category: category,
      riskScore: riskScore,
      decision: riskScore > 0.7
          ? DecisionType.block
          : riskScore > 0.4
              ? DecisionType.review
              : DecisionType.allow,
      reasons: isBad
          ? [
              'Brand impersonation detected: Fake SBI/HDFC login page',
              'Domain registered ${_rng.nextInt(30) + 1} days ago',
              'Suspicious redirect chain detected',
              'Homoglyph characters found in domain',
              'High entropy URL path segment',
            ]
          : ['URL passes all tier-0 checks', 'Reputable domain with valid TLS cert'],
      scannedAt: DateTime.now(),
      depthReached: TierLevel.values[_rng.nextInt(3)],
      tierResults: {
        'tier0': {'score': riskScore, 'model_confidence': 0.92},
        'tier1': {'domain_age_days': _rng.nextInt(3650), 'has_valid_cert': !isBad},
      },
      warnings: isBad ? ['tier2_timeout: redirect chain too deep'] : [],
      featureVector: List.generate(41, (_) => _rng.nextDouble()),
      ja3Fingerprint: isBad ? _randomHex(32) : null,
      ja3Hash: isBad ? _randomHex(16) : null,
      sniHostname: Uri.tryParse(url)?.host ?? url,
      entropyScore: isBad ? 3.8 + _rng.nextDouble() * 1.5 : 2.1 + _rng.nextDouble(),
      iatDelay: 12.0 + _rng.nextDouble() * 8,
      tldRisk: isBad ? 0.6 + _rng.nextDouble() * 0.4 : _rng.nextDouble() * 0.2,
      payloadSize: _rng.nextInt(512000) + 1024,
      brandImpersonationScore: isBad ? 0.7 + _rng.nextDouble() * 0.3 : 0,
      merkleHash: isBad ? _randomHex(64) : null,
      merkleVerified: isBad,
    );
  }

  // ── Mock Threat Logs ──────────────────────────────────────────
  static List<ThreatLog> mockLogs() {
    final appSessions = [
      _AppSession('Gmail', '📧', 'com.google.android.gm', false, [
        ('taskassist-pa.googleapis.com', 443, 'TLS', 'US', 2, false, 0.05),
        ('ci3.googleusercontent.com',    443, 'TLS', 'US', 2, false, 0.04),
        ('addons-pa.googleapis.com',     443, 'TLS', 'US', 1, false, 0.03),
        ('cloudsearch.googleapis.com',   443, 'TLS', 'US', 1, false, 0.04),
        ('mail.google.com',              443, 'TLS', 'US', 1, false, 0.03),
        ('inbox.google.com',             443, 'TLS', 'US', 1, false, 0.03),
      ]),
      _AppSession('WhatsApp', '💬', 'com.whatsapp', false, [
        ('139.84.137.53',    443,  'TLS',    'SG', 1, false, 0.08),
        ('graph.whatsapp.com', 443, 'TLS',   'US', 1, false, 0.07),
        ('g.whatsapp.net',   5222, 'TCP',    'US', 4, false, 0.09),
        ('media.whatsapp.net', 443, 'TLS',   'US', 2, false, 0.08),
      ]),
      _AppSession('Instagram', '📸', 'com.instagram.android', false, [
        ('graph.facebook.com',                    443, 'TLS', 'US', 1, false, 0.22),
        ('instagram.fdel1-7.fna.fbcdn.net',       443, 'TLS', 'IN', 1, false, 0.20),
        ('116.119.124.162',                       443, 'TCP', 'IN', 2, false, 0.18),
        ('scontent-del2-1.cdninstagram.com',      443, 'TLS', 'IN', 2, false, 0.21),
        ('i.instagram.com',                       443, 'TLS', 'US', 2, false, 0.19),
        ('57.144.152.196',                        443, 'TCP', 'US', 1, false, 0.25),
      ]),
      _AppSession('Truecaller', '📱', 'com.truecaller', false, [
        ('api4.truecaller.com',           443, 'TLS', 'SE', 3, true, 0.65),
        ('contact-search.truecaller.com', 443, 'TLS', 'SE', 1, true, 0.70),
        ('analytics.truecaller.com',      443, 'TLS', 'SE', 2, true, 0.68),
      ]),
      _AppSession('ShareIt', '🔗', 'com.shareit.free', false, [
        ('172.104.163.44',          8080, 'TCP', 'SG', 1, true, 0.78),
        ('ads.ushareit.com',          80, 'TCP', 'CN', 4, true, 0.82),
        ('data-collect.ushareit.com', 443, 'TLS', 'CN', 2, true, 0.85),
        ('log.ushareit.com',          443, 'TLS', 'CN', 1, true, 0.79),
      ]),
      _AppSession('Telegram', '✈️', 'org.telegram.messenger', false, [
        ('149.154.167.51', 443,  'MTProto', 'NL', 1, false, 0.06),
        ('api.telegram.org', 443, 'TLS',    'NL', 2, false, 0.05),
        ('cdn.telegram.org', 443, 'TLS',    'NL', 1, false, 0.06),
      ]),
      _AppSession('PhonePe', '💰', 'com.phonepe.app', false, [
        ('api.phonepe.com',      443, 'TLS', 'IN', 2, false, 0.12),
        ('checkout.phonepe.com', 443, 'TLS', 'IN', 1, false, 0.10),
        ('155.20.11.42',         443, 'TLS', 'IN', 1, false, 0.13),
      ]),
      _AppSession('YouTube', '▶️', 'com.google.android.youtube', false, [
        ('googlevideo.com',                       443, 'QUIC', 'US', 5, false, 0.04),
        ('yt3.ggpht.com',                         443, 'TLS',  'US', 1, false, 0.03),
        ('youtubei.googleapis.com',               443, 'TLS',  'US', 2, false, 0.04),
        ('r3---sn-vgqsen76.googlevideo.com',      443, 'QUIC', 'IN', 3, false, 0.03),
      ]),
    ];

    final logs = <ThreatLog>[];
    final baseTime = DateTime.now();

    for (int dayOffset = 0; dayOffset < 3; dayOffset++) {
      final dayBase = baseTime.subtract(Duration(days: dayOffset));
      for (final session in appSessions) {
        if (dayOffset > 0 && _rng.nextBool()) continue;

        for (final h in session.hosts) {
          final domain   = h.$1;
          final port     = h.$2;
          final proto    = h.$3;
          final country  = h.$4;
          final count    = h.$5;
          final blocked  = h.$6;
          final risk     = h.$7;
          final entropy  = blocked ? 4.1 + _rng.nextDouble() * 1.2 : 2.2 + _rng.nextDouble() * 0.9;
          final iat      = blocked ? 180.0 + _rng.nextDouble() * 320 : 12.0 + _rng.nextDouble() * 30;
          final payload  = _rng.nextInt(512 * 1024) + 512;

          final ts = dayBase.subtract(Duration(
            hours: _rng.nextInt(16),
            minutes: _rng.nextInt(60),
            seconds: _rng.nextInt(60),
          ));

          logs.add(ThreatLog(
            id: 'log_${_randomHex(8)}',
            timestamp: ts,
            severity: blocked
                ? (risk > 0.8 ? LogSeverity.critical : LogSeverity.blocked)
                : LogSeverity.info,
            category: blocked
                ? (risk > 0.8 ? ThreatCategory.malware : ThreatCategory.dataLeak)
                : ThreatCategory.safe,
            appName:  session.appName,
            appIcon:  session.appIcon,
            simpleMessage: blocked
                ? 'Blocked suspicious connection from ${session.appName}'
                : 'Connection allowed: $domain',
            destinationHost: domain,
            sourceIp: '10.0.0.2',
            destIp: '${_rng.nextInt(222)+1}.${_rng.nextInt(255)}.${_rng.nextInt(255)}.${_rng.nextInt(255)}',
            destPort: port,
            sniHostname: domain.startsWith(RegExp(r'\d')) ? null : domain,
            ja3Fingerprint: blocked ? _randomHex(32) : null,
            ja3Hash: blocked ? _randomHex(16) : null,
            riskScore: risk,
            entropyScore: entropy,
            iatDelay: iat,
            tldRisk: blocked ? 0.55 + _rng.nextDouble() * 0.4 : _rng.nextDouble() * 0.15,
            payloadSizeBytes: payload,
            packetsPerSecond: _rng.nextInt(500) + 20,
            protocol: proto,
            country: country,
            connectionCount: count,
            tlsVersion: (proto == 'TLS' || proto == 'MTProto') ? 'TLS 1.3' : null,
            cipherSuites: proto == 'TLS'
                ? ['TLS_AES_256_GCM_SHA384', 'TLS_CHACHA20_POLY1305_SHA256']
                : null,
            decisionReason: blocked
                ? 'High entropy + anomalous IAT pattern detected by NetGuard'
                : 'Trusted domain — valid cert chain, clean TLD',
            shieldNetReasons: blocked
                ? [
                    'Entropy: ${entropy.toStringAsFixed(2)} (threshold: 4.0)',
                    'IAT delay: ${iat.toStringAsFixed(0)}ms (anomalous burst)',
                    'TLD risk score elevated',
                    'Data destination: $country — outside expected region',
                  ]
                : null,
            iptablesDropped: blocked,
            merkleVerified: blocked,
            merkleHash: blocked ? _randomHex(64) : null,
            merkleBlockHeight: blocked ? '${1000000 + _rng.nextInt(50000)}' : null,
            merkleTimestamp: blocked ? ts.toIso8601String() : null,
            featureVector42: List.generate(42, (_) => _rng.nextDouble() * 2 - 1),
            featureNames: {
              'url_entropy': entropy,
              'iat_delay_ms': iat,
              'tld_risk': risk,
              'payload_kb': payload / 1024.0,
              'packets_per_sec': (_rng.nextInt(500) + 20).toDouble(),
              'dest_port': port.toDouble(),
              'connection_count': count.toDouble(),
            },
          ));
        }
      }
    }

    logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return logs;
  }

  // ── Mock Apps List ────────────────────────────────────────────
  static List<AppFirewallRule> mockApps() {
    final apps = [
      ('com.android.chrome', 'Chrome', '🌐', false, 8521034, 245098432, 0.05),
      ('com.whatsapp', 'WhatsApp', '💬', false, 12034567, 89012345, 0.08),
      ('com.instagram.android', 'Instagram', '📸', false, 45098765, 156034987, 0.22),
      ('org.telegram.messenger', 'Telegram', '✈️', false, 5034987, 34098765, 0.06),
      ('com.google.android.gm', 'Gmail', '📧', false, 1034567, 8034987, 0.04),
      ('net.one97.paytm', 'Paytm', '💳', false, 512098, 2034987, 0.15),
      ('com.phonepe.app', 'PhonePe', '💰', false, 234098, 1234987, 0.12),
      ('com.snapchat.android', 'Snapchat', '👻', false, 23098765, 78034987, 0.35),
      ('com.truecaller', 'Truecaller', '📱', false, 134987, 3034987, 0.45),
      ('com.shareit.free', 'ShareIt', '🔗', false, 8034987, 67098765, 0.72),
      ('com.cleanmaster.mguard', 'CM Security', '🛡️', false, 234987, 15098765, 0.68),
      ('com.android.settings', 'Settings', '⚙️', true, 0, 45234, 0.0),
      ('com.android.phone', 'Phone', '📞', true, 1234, 234987, 0.01),
      ('com.android.systemui', 'System UI', '📲', true, 5234, 678234, 0.0),
    ];

    return apps.map((a) {
      final risk = a.$7;
      return AppFirewallRule(
        packageName: a.$1,
        appName:     a.$2,
        appIcon:     a.$3,
        isSystemApp: a.$4,
        isActive:    true,
        allowWifi:        risk < 0.6,
        allowMobile:      risk < 0.5,
        allowBackground:  risk < 0.4,
        uploadBytes:  a.$5,
        downloadBytes: a.$6,
        riskScore:   risk,
        recentHosts: [
          'graph.facebook.com',
          'api.${a.$2.toLowerCase().replaceAll(' ', '')}.com',
          'cdn.example.net',
        ],
      );
    }).toList();
  }

  // ── Mock Telemetry Stream ─────────────────────────────────────
  static TelemetryData mockTelemetry({bool connected = false}) {
    if (!connected) return TelemetryData.initial();
    return TelemetryData(
      latencyMs: 8 + _rng.nextDouble() * 6,
      engineLoadPercent: 15 + _rng.nextDouble() * 35,
      packetsPerSecond: 450 + _rng.nextInt(800),
      activeConnections: 8 + _rng.nextInt(24),
      blockedToday: 127 + _rng.nextInt(50),
      scansToday: 2847 + _rng.nextInt(200),
      uploadMbps: 0.5 + _rng.nextDouble() * 4,
      downloadMbps: 1.2 + _rng.nextDouble() * 8,
      isVpnConnected: true,
      serverLocation: 'Mumbai, IN',
      timestamp: DateTime.now(),
    );
  }

  static String _randomHex(int length) {
    const chars = '0123456789abcdef';
    return List.generate(length, (_) => chars[_rng.nextInt(chars.length)]).join();
  }
}
