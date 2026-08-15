import 'dart:async';
import 'package:flutter/foundation.dart';

enum VpnState { disconnected, connecting, connected, disconnecting, error }

enum VpnDropReason { networkLoss, serverTimeout, authFailure, unknown }

class VpnService extends ChangeNotifier {
  VpnState _state = VpnState.disconnected;
  VpnState get state => _state;
  bool get isConnected => _state == VpnState.connected;
  bool get isConnecting => _state == VpnState.connecting;

  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  Timer? _reconnectTimer;
  DateTime? _connectedAt;

  VpnDropReason? _lastDropReason;
  VpnDropReason? get lastDropReason => _lastDropReason;

  String get statusLabel {
    switch (_state) {
      case VpnState.disconnected: return 'Protection Off';
      case VpnState.connecting: return 'Establishing Tunnel...';
      case VpnState.connected: return 'Protected';
      case VpnState.disconnecting: return 'Disconnecting...';
      case VpnState.error: return 'Connection Failed';
    }
  }

  String get uptimeLabel {
    if (_connectedAt == null || !isConnected) return '--:--:--';
    final diff = DateTime.now().difference(_connectedAt!);
    final h = diff.inHours.toString().padLeft(2, '0');
    final m = (diff.inMinutes % 60).toString().padLeft(2, '0');
    final s = (diff.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  // ─────────────────────────────────────────────────────────────
  Future<bool> toggle() async {
    if (_state == VpnState.connected || _state == VpnState.connecting) {
      return await disconnect();
    } else {
      return await connect();
    }
  }

  Future<bool> connect() async {
    if (_state == VpnState.connected) return true;
    _state = VpnState.connecting;
    _reconnectAttempts = 0;
    notifyListeners();

    // Simulate connection handshake (~1.2s)
    await Future.delayed(const Duration(milliseconds: 1200));
    _state = VpnState.connected;
    _connectedAt = DateTime.now();
    notifyListeners();
    return true;
  }

  Future<bool> disconnect() async {
    _reconnectTimer?.cancel();
    _state = VpnState.disconnecting;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));
    _state = VpnState.disconnected;
    _connectedAt = null;
    notifyListeners();
    return true;
  }

  // Called when VPN drops unexpectedly
  void onVpnDrop(VpnDropReason reason) {
    _lastDropReason = reason;
    _state = VpnState.error;
    notifyListeners();
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      _state = VpnState.error;
      notifyListeners();
      return;
    }
    final delay = Duration(seconds: 2 * (1 << _reconnectAttempts)); // Exponential backoff
    _reconnectTimer = Timer(delay, () async {
      _reconnectAttempts++;
      _state = VpnState.connecting;
      notifyListeners();
      final success = await connect();
      if (!success) _scheduleReconnect();
    });
  }

  @override
  void dispose() {
    _reconnectTimer?.cancel();
    super.dispose();
  }
}
