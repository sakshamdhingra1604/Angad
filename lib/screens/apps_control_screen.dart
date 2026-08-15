import 'package:flutter/material.dart';
import '../models/app_firewall_rules.dart';
import '../services/mock_data_service.dart';
import '../theme/app_colors.dart';


enum _AppFilter { all, blocked, user, system }

class AppsControlScreen extends StatefulWidget {
  const AppsControlScreen({super.key});

  @override
  State<AppsControlScreen> createState() => _AppsControlScreenState();
}

class _AppsControlScreenState extends State<AppsControlScreen> {
  List<AppFirewallRule> _apps = [];
  List<AppFirewallRule> _filtered = [];
  String _search = '';
  _AppFilter _filter = _AppFilter.all;
  bool _searching = false;
  final _searchCtrl = TextEditingController();
  String? _expandedPkg;

  @override
  void initState() {
    super.initState();
    _apps = MockDataService.mockApps();
    _applyFilter();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _applyFilter() {
    var list = _apps.where((a) {
      final matchSearch = _search.isEmpty ||
          a.appName.toLowerCase().contains(_search.toLowerCase()) ||
          a.packageName.toLowerCase().contains(_search.toLowerCase());

      final matchFilter = switch (_filter) {
        _AppFilter.blocked => !a.allowWifi || !a.allowMobile,
        _AppFilter.user    => !a.isSystemApp,
        _AppFilter.system  => a.isSystemApp,
        _AppFilter.all     => true,
      };
      return matchSearch && matchFilter;
    }).toList();

    setState(() => _filtered = list);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.charcoal,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────────
            _buildHeader(),
            const Divider(height: 1, color: AppColors.border),

            // ── Filter chips ─────────────────────────────────────
            _buildFilterBar(),

            // ── App list ─────────────────────────────────────────
            Expanded(
              child: _filtered.isEmpty
                  ? _buildEmpty()
                  : ListView.separated(
                      itemCount: _filtered.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, color: AppColors.border),
                      itemBuilder: (_, i) => _AppRow(
                        app: _filtered[i],
                        isExpanded: _expandedPkg == _filtered[i].packageName,
                        onExpandToggle: () => setState(() {
                          _expandedPkg =
                              _expandedPkg == _filtered[i].packageName
                                  ? null
                                  : _filtered[i].packageName;
                        }),
                        onChanged: (updated) {
                          final idx = _apps
                              .indexWhere((a) => a.packageName == updated.packageName);
                          if (idx != -1) {
                            setState(() {
                              _apps[idx] = updated;
                              _applyFilter();
                            });
                          }
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          if (!_searching) ...[
            Text('Apps',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w800)),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.search_rounded,
                  color: AppColors.textSecondary),
              onPressed: () => setState(() => _searching = true),
            ),
            IconButton(
              icon: const Icon(Icons.filter_list_rounded,
                  color: AppColors.textSecondary),
              onPressed: _showFilterSheet,
            ),
          ] else ...[
            Expanded(
              child: TextField(
                controller: _searchCtrl,
                autofocus: true,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'Search apps...',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (v) {
                  _search = v;
                  _applyFilter();
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded,
                  color: AppColors.textSecondary),
              onPressed: () {
                _searchCtrl.clear();
                _search = '';
                _applyFilter();
                setState(() => _searching = false);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: _AppFilter.values.map((f) {
          final active = _filter == f;
          final label = switch (f) {
            _AppFilter.all     => 'All (${_apps.length})',
            _AppFilter.blocked => 'Blocked',
            _AppFilter.user    => 'User Apps',
            _AppFilter.system  => 'System Apps',
          };
          return GestureDetector(
            onTap: () {
              _filter = f;
              _applyFilter();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: active ? AppColors.saffron : AppColors.charcoalLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: active ? AppColors.saffron : AppColors.border,
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: active ? Colors.white : AppColors.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.charcoalMid,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filter Apps',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            ..._AppFilter.values.map((f) {
              final label = switch (f) {
                _AppFilter.all     => 'All Apps',
                _AppFilter.blocked => 'Blocked Apps',
                _AppFilter.user    => 'User Apps Only',
                _AppFilter.system  => 'System Apps Only',
              };
              return ListTile(
                title: Text(label,
                    style: const TextStyle(color: AppColors.textPrimary)),
                trailing: _filter == f
                    ? const Icon(Icons.check_rounded,
                        color: AppColors.saffron)
                    : null,
                onTap: () {
                  _filter = f;
                  _applyFilter();
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.apps_rounded, color: AppColors.textHint, size: 48),
          const SizedBox(height: 12),
          Text('No apps found',
              style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
        ],
      ),
    );
  }
}

// ── Single App Row ──────────────────────────────────────────────
class _AppRow extends StatelessWidget {
  final AppFirewallRule app;
  final bool isExpanded;
  final VoidCallback onExpandToggle;
  final ValueChanged<AppFirewallRule> onChanged;

  const _AppRow({
    required this.app,
    required this.isExpanded,
    required this.onExpandToggle,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isBlocked = !app.allowWifi || !app.allowMobile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main row
        InkWell(
          onTap: onExpandToggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // App icon (letter fallback)
                _AppIcon(app: app),
                const SizedBox(width: 12),

                // Name + tags
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app.appName,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(
                                color: isExpanded
                                    ? AppColors.saffron
                                    : AppColors.textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          _Tag(
                            label: app.isSystemApp ? 'System' : 'User app',
                            color: app.isSystemApp
                                ? AppColors.gold
                                : AppColors.infoBlue,
                          ),
                          const SizedBox(width: 5),
                          if (isBlocked)
                            _Tag(label: 'Blocked', color: AppColors.threatRed),
                        ],
                      ),
                    ],
                  ),
                ),

                // Wi-Fi toggle icon
                _NetIcon(
                  icon: Icons.wifi_rounded,
                  enabled: app.allowWifi,
                  onTap: () => onChanged(app.copyWith(allowWifi: !app.allowWifi)),
                ),
                const SizedBox(width: 8),

                // Mobile data toggle icon
                _NetIcon(
                  icon: Icons.signal_cellular_alt_rounded,
                  enabled: app.allowMobile,
                  onTap: () => onChanged(app.copyWith(allowMobile: !app.allowMobile)),
                ),
                const SizedBox(width: 4),

                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textMuted,
                  size: 20,
                ),
              ],
            ),
          ),
        ),

        // Expanded detail panel
        if (isExpanded) _AppDetail(app: app, onChanged: onChanged),
      ],
    );
  }
}

class _AppIcon extends StatelessWidget {
  final AppFirewallRule app;
  const _AppIcon({required this.app});

  @override
  Widget build(BuildContext context) {
    // Attempt real icon via installed_apps; fallback to letter
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.charcoalLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          app.appName.isNotEmpty ? app.appName[0].toUpperCase() : '?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: _letterColor(app.appName),
          ),
        ),
      ),
    );
  }

  Color _letterColor(String name) {
    final colors = [
      AppColors.saffron, AppColors.gold, AppColors.safeGreen,
      AppColors.infoBlue, AppColors.threatRed, AppColors.amber,
    ];
    return colors[name.codeUnitAt(0) % colors.length];
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  const _Tag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _NetIcon extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  const _NetIcon({required this.icon, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        icon,
        size: 22,
        color: enabled ? AppColors.safeGreen : AppColors.textHint,
      ),
    );
  }
}

class _AppDetail extends StatelessWidget {
  final AppFirewallRule app;
  final ValueChanged<AppFirewallRule> onChanged;
  const _AppDetail({required this.app, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.charcoalMid,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App info
          _SectionHeader('APP INFO'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _InfoItem('Package', app.packageName)),
              Expanded(child: _InfoItem('Type', app.isSystemApp ? 'System' : 'User')),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 16),

          // Network controls
          _SectionHeader('NETWORK CONTROLS'),
          const SizedBox(height: 10),
          _ToggleRow(
            label: 'Wi-Fi Access',
            subtitle: 'Allow this app to use Wi-Fi',
            value: app.allowWifi,
            onChanged: (v) => onChanged(app.copyWith(allowWifi: v)),
          ),
          const SizedBox(height: 8),
          _ToggleRow(
            label: 'Mobile Data',
            subtitle: 'Allow this app to use mobile data',
            value: app.allowMobile,
            onChanged: (v) => onChanged(app.copyWith(allowMobile: v)),
          ),
          const SizedBox(height: 8),
          _ToggleRow(
            label: 'Background Activity',
            subtitle: 'Allow network access when app is in background',
            value: app.allowBackground,
            onChanged: (v) => onChanged(app.copyWith(allowBackground: v)),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.saffron,
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.5,
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  const _InfoItem(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textHint, fontSize: 11)),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
      ],
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500)),
              Text(subtitle,
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 12)),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.saffron,
          activeTrackColor: AppColors.saffronDim,
          inactiveThumbColor: AppColors.textMuted,
          inactiveTrackColor: AppColors.charcoalLight,
        ),
      ],
    );
  }
}
