import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/scan_result.dart';
import '../models/threat_log.dart';
import '../models/app_firewall_rules.dart';
import 'mock_data_service.dart';

class SecurityService extends ChangeNotifier {
  static const String _baseUrl = 'http://localhost:8000';
  static const String _apiKey = 'angad_dev_key_change_me_in_production';

  bool _useRealBackend = false; // Flip to true when real backend is up

  // ── State ──────────────────────────────────────────────────────
  List<ThreatLog> _logs = [];
  List<AppFirewallRule> _apps = [];
  int _blockedCount = 0;
  int _scansCount = 0;
  int _phishingBlocked = 0;
  int _dataLeaksPrevented = 0;

  List<ThreatLog> get logs => List.unmodifiable(_logs);
  List<AppFirewallRule> get apps => List.unmodifiable(_apps);
  int get blockedCount => _blockedCount;
  int get scansCount => _scansCount;
  int get phishingBlocked => _phishingBlocked;
  int get dataLeaksPrevented => _dataLeaksPrevented;

  // ─────────────────────────────────────────────────────────────
  Future<void> initialize() async {
    _logs = MockDataService.mockLogs();
    _apps = MockDataService.mockApps();
    _blockedCount = 127;
    _scansCount = 2847;
    _phishingBlocked = 89;
    _dataLeaksPrevented = 23;
    notifyListeners();
  }

  // ── ShieldNet Scan ─────────────────────────────────────────────
  Future<ScanResult> scanUrl(String url, {int depth = 0}) async {
    _scansCount++;
    notifyListeners();

    if (_useRealBackend) {
      try {
        final response = await http.post(
          Uri.parse('$_baseUrl/api/v1/scan'),
          headers: {
            'Content-Type': 'application/json',
            'X-API-Key': _apiKey,
          },
          body: jsonEncode({'url': url, 'depth': depth}),
        ).timeout(const Duration(seconds: 30));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final result = ScanResult.fromJson(data);
          _processScanResult(result);
          return result;
        }
      } catch (e) {
        debugPrint('Backend unreachable, using mock: $e');
      }
    }

    // Simulated 15ms Tier 0 response
    await Future.delayed(const Duration(milliseconds: 200));
    final result = MockDataService.mockScan(url);
    _processScanResult(result);
    return result;
  }

  void _processScanResult(ScanResult result) {
    if (result.isBlocked) {
      _blockedCount++;
      if (result.category == ThreatCategory.phishing) _phishingBlocked++;
      if (result.category == ThreatCategory.dataLeak) _dataLeaksPrevented++;
    }
    notifyListeners();
  }

  // ── App Firewall Rules ─────────────────────────────────────────
  void updateAppRule(String packageName, {
    bool? allowWifi,
    bool? allowMobile,
    bool? allowBackground,
  }) {
    final idx = _apps.indexWhere((a) => a.packageName == packageName);
    if (idx == -1) return;
    _apps[idx] = _apps[idx].copyWith(
      allowWifi: allowWifi,
      allowMobile: allowMobile,
      allowBackground: allowBackground,
    );
    notifyListeners();
  }

  // ── Logs Management ────────────────────────────────────────────
  void addLog(ThreatLog log) {
    _logs.insert(0, log);
    if (_logs.length > 500) _logs.removeLast();
    notifyListeners();
  }

  void submitFeedback(String logId, bool isCorrect) {
    final idx = _logs.indexWhere((l) => l.id == logId);
    if (idx == -1) return;
    _logs[idx] = _logs[idx].copyWith(userFeedback: isCorrect);
    notifyListeners();
    // TODO: POST to /feedback endpoint when backend is up
  }

  // ── Quick Stats ───────────────────────────────────────────────
  List<ThreatLog> get blockedLogs =>
      _logs.where((l) => l.severity == LogSeverity.blocked || l.severity == LogSeverity.critical).toList();

  List<AppFirewallRule> get blockedApps => _apps.where((a) => a.isPartiallyBlocked).toList();
  List<AppFirewallRule> get systemApps => _apps.where((a) => a.isSystemApp).toList();
  List<AppFirewallRule> get activeApps => _apps.where((a) => a.isActive && !a.isSystemApp).toList();
}
