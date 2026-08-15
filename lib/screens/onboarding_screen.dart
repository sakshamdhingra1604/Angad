import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../theme/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageCtrl = PageController();
  int _currentPage = 0;

  static final _pages = [
    _OnboardPage(
      headline: 'Blocks Threats\nBefore They Reach You',
      subline:
          'Angad\'s AI engine inspects every link and connection in milliseconds — before any data leaves your device. Real-time protection, no compromises.',
      accent: AppColors.saffron,
      icon: Icons.security_rounded,
      statLabel: '< 20ms',
      statDesc: 'Average threat block time',
      badgeLabel: 'REAL-TIME',
    ),
    _OnboardPage(
      headline: 'OS-Level\nFirewall Control',
      subline:
          'NetGuard monitors every outgoing TCP connection at the OS level. Suspicious traffic is dropped before it reaches any server — not after.',
      accent: AppColors.gold,
      icon: Icons.shield_moon_rounded,
      statLabel: '100%',
      statDesc: 'OS-level traffic inspection',
      badgeLabel: 'OS-LEVEL',
    ),
    _OnboardPage(
      headline: 'Per-App Network\nFirewall',
      subline:
          'Take full control of which apps can use Wi-Fi, mobile data, or run in the background. Block data-hungry apps individually with one tap.',
      accent: AppColors.saffron,
      icon: Icons.apps_outage_rounded,
      statLabel: 'Per-App',
      statDesc: 'Granular network control',
      badgeLabel: 'GRANULAR',
    ),
    _OnboardPage(
      headline: 'Two Modes,\nOne Shield',
      subline:
          'Standard Mode delivers clean, plain-language security alerts — designed for everyday users and families. Expert Mode unlocks deep forensics, OS-level logs, and raw connection data — built for developers and security professionals.',
      accent: AppColors.gold,
      icon: Icons.tune_rounded,
      statLabel: '2 Modes',
      statDesc: 'Standard & Expert',
      badgeLabel: 'ADAPTIVE',
    ),
  ];

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageCtrl.nextPage(
          duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  void _skip() => Navigator.of(context).pushReplacementNamed('/login');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.charcoal,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageCtrl,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: _pages.length,
            itemBuilder: (_, i) => _PageView(page: _pages[i]),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Row(
                    children: [
                      // Angad wordmark
                      Text('ANGAD',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 3,
                            color: AppColors.textPrimary,
                          )),
                      const Spacer(),
                      if (_currentPage < _pages.length - 1)
                        GestureDetector(
                          onTap: _skip,
                          child: Text('Skip',
                              style: TextStyle(
                                  color: AppColors.textMuted, fontSize: 14)),
                        ),
                    ],
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 44),
                  child: Column(
                    children: [
                      SmoothPageIndicator(
                        controller: _pageCtrl,
                        count: _pages.length,
                        effect: ExpandingDotsEffect(
                          activeDotColor: _pages[_currentPage].accent,
                          dotColor: AppColors.border,
                          dotHeight: 6,
                          dotWidth: 6,
                          expansionFactor: 3.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _next,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _pages[_currentPage].accent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          child: Text(
                            _currentPage < _pages.length - 1
                                ? 'Continue'
                                : 'Get Started',
                            style: const TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardPage {
  final String headline;
  final String subline;
  final Color accent;
  final IconData icon;
  final String statLabel;
  final String statDesc;
  final String badgeLabel;

  const _OnboardPage({
    required this.headline,
    required this.subline,
    required this.accent,
    required this.icon,
    required this.statLabel,
    required this.statDesc,
    required this.badgeLabel,
  });
}

class _PageView extends StatelessWidget {
  final _OnboardPage page;
  const _PageView({required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 100, 28, 160),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon + badge
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: page.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: page.accent.withValues(alpha: 0.3)),
                ),
                child: Icon(page.icon, color: page.accent, size: 30),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: page.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: page.accent.withValues(alpha: 0.25)),
                ),
                child: Text(
                  page.badgeLabel,
                  style: TextStyle(
                    color: page.accent,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Headline
          Text(
            page.headline,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              height: 1.1,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 18),

          // Body
          Text(
            page.subline,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.7,
            ),
          ),

          const SizedBox(height: 36),

          // Stat chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: page.accent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: page.accent.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  page.statLabel,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: page.accent,
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  page.statDesc,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
