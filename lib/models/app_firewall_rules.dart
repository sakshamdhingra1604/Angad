class AppFirewallRule {
  final String packageName;
  final String appName;
  final String appIcon;    // emoji or asset path
  final bool isSystemApp;
  final bool isActive;

  // Network access toggles (true = allowed)
  final bool allowWifi;
  final bool allowMobile;
  final bool allowBackground;

  // Live traffic stats (fetched from NetGuard backend)
  final int uploadBytes;
  final int downloadBytes;
  final int activeConnections;
  final double riskScore;
  final List<String> recentHosts;

  const AppFirewallRule({
    required this.packageName,
    required this.appName,
    this.appIcon = '',
    this.isSystemApp = false,
    this.isActive = true,
    this.allowWifi = true,
    this.allowMobile = true,
    this.allowBackground = true,
    this.uploadBytes = 0,
    this.downloadBytes = 0,
    this.activeConnections = 0,
    this.riskScore = 0.0,
    this.recentHosts = const [],
  });

  AppFirewallRule copyWith({
    bool? allowWifi,
    bool? allowMobile,
    bool? allowBackground,
    bool? isActive,
    int? uploadBytes,
    int? downloadBytes,
  }) {
    return AppFirewallRule(
      packageName:       packageName,
      appName:           appName,
      appIcon:           appIcon,
      isSystemApp:       isSystemApp,
      isActive:          isActive       ?? this.isActive,
      allowWifi:         allowWifi      ?? this.allowWifi,
      allowMobile:       allowMobile    ?? this.allowMobile,
      allowBackground:   allowBackground?? this.allowBackground,
      uploadBytes:       uploadBytes    ?? this.uploadBytes,
      downloadBytes:     downloadBytes  ?? this.downloadBytes,
      activeConnections: activeConnections,
      riskScore:         riskScore,
      recentHosts:       recentHosts,
    );
  }

  // Convenience: is this app currently blocked on any network?
  bool get isPartiallyBlocked => !allowWifi || !allowMobile;
  bool get isFullyBlocked     => !allowWifi && !allowMobile;

  String get uploadFormatted   => _formatBytes(uploadBytes);
  String get downloadFormatted => _formatBytes(downloadBytes);

  String _formatBytes(int bytes) {
    if (bytes < 1024)           return '${bytes} B';
    if (bytes < 1024 * 1024)   return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}
