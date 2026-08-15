import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/telemetry_data.dart';
import '../models/threat_log.dart';
import 'mock_data_service.dart';

class WebsocketService extends ChangeNotifier {
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  // ── Telemetry Stream ──────────────────────────────────────────
  TelemetryData _telemetry = TelemetryData.initial();
  TelemetryData get telemetry => _telemetry;

  final WaveBuffer ppsBuffer = WaveBuffer(maxPoints: 60);
  final WaveBuffer uploadBuffer = WaveBuffer(maxPoints: 60);
  final WaveBuffer downloadBuffer = WaveBuffer(maxPoints: 60);

  // ── Live Log Feed ─────────────────────────────────────────────
  final List<ThreatLog> _liveFeed = [];
  List<ThreatLog> get liveFeed => List.unmodifiable(_liveFeed);

  // ── Internal Timers ───────────────────────────────────────────
  Timer? _telemetryTimer;
  Timer? _logFeedTimer;
  final _rng = Random();

  // ─────────────────────────────────────────────────────────────
  void connect() {
    if (_isConnected) return;
    _isConnected = true;
    _startMockStreams();
    notifyListeners();
  }

  void disconnect() {
    _isConnected = false;
    _telemetryTimer?.cancel();
    _logFeedTimer?.cancel();
    _telemetry = TelemetryData.initial();
    ppsBuffer.clear();
    uploadBuffer.clear();
    downloadBuffer.clear();
    notifyListeners();
  }

  void _startMockStreams() {
    // Telemetry ticks every second
    _telemetryTimer = Timer.periodic(const Duration(milliseconds: 800), (_) {
      _telemetry = MockDataService.mockTelemetry(connected: true);
      ppsBuffer.addNoise(_telemetry.packetsPerSecond.toDouble());
      uploadBuffer.addNoise(_telemetry.uploadMbps * 100);
      downloadBuffer.addNoise(_telemetry.downloadMbps * 100);
      notifyListeners();
    });

    // Simulate occasional live threat events
    _logFeedTimer = Timer.periodic(const Duration(seconds: 12), (_) {
      if (_rng.nextDouble() > 0.4) {
        final logs = MockDataService.mockLogs();
        final newLog = logs[_rng.nextInt(logs.length)];
        _liveFeed.insert(0, newLog);
        if (_liveFeed.length > 50) _liveFeed.removeLast();
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _telemetryTimer?.cancel();
    _logFeedTimer?.cancel();
    super.dispose();
  }
}
