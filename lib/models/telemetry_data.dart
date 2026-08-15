import 'dart:math';

class TelemetryData {
  final double latencyMs;
  final double engineLoadPercent;
  final int packetsPerSecond;
  final int activeConnections;
  final int blockedToday;
  final int scansToday;
  final double uploadMbps;
  final double downloadMbps;
  final bool isVpnConnected;
  final String serverLocation;
  final DateTime timestamp;

  const TelemetryData({
    required this.latencyMs,
    required this.engineLoadPercent,
    required this.packetsPerSecond,
    required this.activeConnections,
    required this.blockedToday,
    required this.scansToday,
    required this.uploadMbps,
    required this.downloadMbps,
    required this.isVpnConnected,
    required this.serverLocation,
    required this.timestamp,
  });

  factory TelemetryData.initial() => TelemetryData(
    latencyMs: 0,
    engineLoadPercent: 0,
    packetsPerSecond: 0,
    activeConnections: 0,
    blockedToday: 0,
    scansToday: 0,
    uploadMbps: 0,
    downloadMbps: 0,
    isVpnConnected: false,
    serverLocation: 'Mumbai, IN',
    timestamp: DateTime.now(),
  );

  factory TelemetryData.fromJson(Map<String, dynamic> json) => TelemetryData(
    latencyMs: (json['latency_ms'] ?? 0.0).toDouble(),
    engineLoadPercent: (json['engine_load'] ?? 0.0).toDouble(),
    packetsPerSecond: json['pps'] ?? 0,
    activeConnections: json['active_connections'] ?? 0,
    blockedToday: json['blocked_today'] ?? 0,
    scansToday: json['scans_today'] ?? 0,
    uploadMbps: (json['upload_mbps'] ?? 0.0).toDouble(),
    downloadMbps: (json['download_mbps'] ?? 0.0).toDouble(),
    isVpnConnected: json['vpn_connected'] ?? false,
    serverLocation: json['server_location'] ?? 'Mumbai, IN',
    timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
  );

  String get latencyLabel => '${latencyMs.toStringAsFixed(0)}ms';
  String get engineLoadLabel => '${engineLoadPercent.toStringAsFixed(0)}%';
  String get ppsLabel => _formatNumber(packetsPerSecond);

  String _formatNumber(int n) {
    if (n < 1000) return '$n';
    if (n < 1000000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '${(n / 1000000).toStringAsFixed(1)}M';
  }
}

class PpsDataPoint {
  final DateTime time;
  final double value;
  const PpsDataPoint(this.time, this.value);
}

class WaveBuffer {
  final int maxPoints;
  final List<PpsDataPoint> _points = [];
  final _random = Random();

  WaveBuffer({this.maxPoints = 60});

  List<PpsDataPoint> get points => List.unmodifiable(_points);

  void add(double value) {
    _points.add(PpsDataPoint(DateTime.now(), value));
    if (_points.length > maxPoints) _points.removeAt(0);
  }

  void addNoise(double baseValue) {
    final noise = (_random.nextDouble() - 0.5) * baseValue * 0.3;
    add((baseValue + noise).clamp(0, double.infinity));
  }

  void clear() => _points.clear();
}
