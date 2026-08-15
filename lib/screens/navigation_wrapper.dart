import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/vpn_service.dart';
import '../theme/app_colors.dart';
import 'home_command_center.dart';
import 'apps_control_screen.dart';
import 'dual_logs_screen.dart';
import 'profile_settings_screen.dart';

class NavigationWrapper extends StatefulWidget {
  const NavigationWrapper({super.key});

  @override
  State<NavigationWrapper> createState() => _NavigationWrapperState();
}

class _NavigationWrapperState extends State<NavigationWrapper> {
  int _currentTab = 0;

  static const _tabs = [
    _TabItem(Icons.graphic_eq_rounded, Icons.graphic_eq_rounded, 'Home'),
    _TabItem(Icons.apps_rounded, Icons.apps_rounded, 'Apps'),
    _TabItem(Icons.receipt_long_rounded, Icons.receipt_long_rounded, 'Logs'),
    _TabItem(Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final vpn = context.watch<VpnService>();

    return Scaffold(
      backgroundColor: AppColors.charcoal,
      body: IndexedStack(
        index: _currentTab,
        children: const [
          HomeCommandCenter(),
          AppsControlScreen(),
          DualLogsScreen(),
          ProfileSettingsScreen(),
        ],
      ),
      bottomNavigationBar: _AngadNavBar(
        currentTab: _currentTab,
        tabs: _tabs,
        isProtected: vpn.isConnected,
        onTabChanged: (i) => setState(() => _currentTab = i),
      ),
    );
  }
}

class _AngadNavBar extends StatelessWidget {
  final int currentTab;
  final List<_TabItem> tabs;
  final bool isProtected;
  final ValueChanged<int> onTabChanged;

  const _AngadNavBar({
    required this.currentTab,
    required this.tabs,
    required this.isProtected,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.charcoalMid,
        border: Border(top: BorderSide(
          color: isProtected ? AppColors.saffron.withValues(alpha: 0.25) : AppColors.border,
          width: 1,
        )),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(tabs.length, (i) {
              final isSelected = i == currentTab;
              final tab = tabs[i];
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onTabChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.saffronDim : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSelected ? tab.selectedIcon : tab.icon,
                        color: isSelected ? AppColors.saffron : AppColors.textMuted,
                        size: 22,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        tab.label,
                        style: TextStyle(
                          color: isSelected ? AppColors.saffron : AppColors.textMuted,
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _TabItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const _TabItem(this.icon, this.selectedIcon, this.label);
}
