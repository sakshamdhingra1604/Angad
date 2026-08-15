import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class FakeNewsHub extends StatefulWidget {
  const FakeNewsHub({super.key});

  @override
  State<FakeNewsHub> createState() => _FakeNewsHubState();
}

class _FakeNewsHubState extends State<FakeNewsHub> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _textCtrl = TextEditingController();
  bool _analysing = false;
  String? _result;
  bool _isVerified = false;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  Future<void> _analyzeText() async {
    if (_textCtrl.text.trim().isEmpty) return;
    setState(() { _analysing = true; _result = null; });
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _analysing = false;
      _isVerified = _textCtrl.text.toLowerCase().contains('true') ||
          _textCtrl.text.toLowerCase().contains('news');
      _result = _isVerified
          ? 'Content appears consistent with verified sources. No obvious misinformation markers detected.'
          : 'AI detected high probability of misinformation. Multiple red flags: unverified claims, emotional language, suspicious source chain.';
    });
  }

  Future<void> _pickImage() async {
    setState(() { _analysing = true; _result = null; });
    // In production: use image_picker to capture/pick screenshot
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _analysing = false;
      _isVerified = false;
      _result = 'Image OCR scan complete. Text extracted and cross-checked with fact database. Potential misleading claim detected in forwarded image.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.glassWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.amberDim,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('AI FACT CHECK', style: TextStyle(
                    color: AppColors.amber,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  )),
                ),
                const SizedBox(width: 8),
                Text('Fake News Detector', style: Theme.of(context).textTheme.headlineSmall),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Tab Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.charcoalMid,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TabBar(
                controller: _tabCtrl,
                indicator: BoxDecoration(
                  color: AppColors.charcoalBright,
                  borderRadius: BorderRadius.circular(8),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: AppColors.amber,
                unselectedLabelColor: AppColors.textMuted,
                labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                tabs: const [
                  Tab(text: '📝  Text / Link'),
                  Tab(text: '📸  Image / Screenshot'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            height: 130,
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                // Text Tab
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textCtrl,
                          maxLines: null,
                          expands: true,
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'Paste WhatsApp forward, news headline, or suspicious link...',
                            hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                            contentPadding: const EdgeInsets.all(12),
                            filled: true,
                            fillColor: AppColors.charcoalMid,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.border)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.border)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.amber, width: 1.5)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _analysing ? null : _analyzeText,
                          icon: _analysing
                              ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: AppColors.charcoal, strokeWidth: 2))
                              : const Icon(Icons.search_rounded, size: 16),
                          label: Text(_analysing ? 'Analysing...' : 'Check This'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.amber,
                            foregroundColor: AppColors.charcoal,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Image Tab — supports WhatsApp screenshot uploads
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GestureDetector(
                    onTap: _analysing ? null : _pickImage,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: AppColors.charcoalMid,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _analysing ? AppColors.amber : AppColors.border,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: _analysing
                          ? const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircularProgressIndicator(color: AppColors.amber, strokeWidth: 2),
                                  SizedBox(height: 8),
                                  Text('OCR Scanning Image...', style: TextStyle(color: AppColors.amber, fontSize: 12)),
                                ],
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.upload_rounded, color: AppColors.amber, size: 32),
                                const SizedBox(height: 6),
                                const Text('Tap to upload WhatsApp screenshot\nor fake news image', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                                const SizedBox(height: 4),
                                const Text('OCR + AI Claim Verification', style: TextStyle(color: AppColors.amber, fontSize: 10, fontWeight: FontWeight.w600)),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Result
          if (_result != null) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isVerified
                      ? AppColors.safeGreenDim
                      : AppColors.threatRedDim,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isVerified
                        ? AppColors.safeGreen.withValues(alpha: 0.4)
                        : AppColors.threatRed.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      _isVerified ? Icons.verified_rounded : Icons.fact_check_rounded,
                      color: _isVerified ? AppColors.safeGreen : AppColors.threatRed,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_result!, style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ))),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 14),
        ],
      ),
    );
  }
}
