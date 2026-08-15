import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_colors.dart';

/// Represents one hour-bucket of connection data from NetGuard
class HourlyConnData {
  final int hour;        // 0–23
  final int blocked;     // connections blocked this hour
  final int allowed;     // connections allowed this hour

  const HourlyConnData({
    required this.hour,
    required this.blocked,
    required this.allowed,
  });

  int get total => blocked + allowed;
}

/// Bar histogram showing blocked vs allowed connections per hour
/// Backend: NetGuard exposes per-hour connection counts via its API.
class ConnectionHistogram extends StatelessWidget {
  final List<HourlyConnData> data; // last 8 hours
  final bool isLive;

  const ConnectionHistogram({
    super.key,
    required this.data,
    this.isLive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.charcoalMid,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Connection Activity',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Last 8 hours — blocked vs allowed',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (isLive) _LiveDot(),
            ],
          ),

          const SizedBox(height: 20),

          if (!isLive)
            _OfflinePlaceholder()
          else ...[
            // Legend
            Row(
              children: [
                _LegendDot(AppColors.threatRed, 'Blocked'),
                const SizedBox(width: 16),
                _LegendDot(AppColors.safeGreen, 'Allowed'),
              ],
            ),
            const SizedBox(height: 16),

            // Bar chart
            SizedBox(
              height: 140,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceEvenly,
                  maxY: _maxY.toDouble(),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      tooltipPadding: const EdgeInsets.all(8),
                      tooltipMargin: 8,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final h = data[groupIndex];
                        final label = rodIndex == 0
                            ? 'Blocked: ${h.blocked}'
                            : 'Allowed: ${h.allowed}';
                        return BarTooltipItem(
                          label,
                          TextStyle(
                            color: rodIndex == 0
                                ? AppColors.threatRed
                                : AppColors.safeGreen,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (val, meta) {
                          final idx = val.toInt();
                          if (idx < 0 || idx >= data.length) {
                            return const SizedBox.shrink();
                          }
                          final h = data[idx].hour;
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              '${h}h',
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 11,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                        interval: _yInterval,
                        getTitlesWidget: (val, meta) => Text(
                          val.toInt().toString(),
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: _yInterval,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: AppColors.border.withValues(alpha: 0.5),
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(data.length, (i) {
                    final d = data[i];
                    return BarChartGroupData(
                      x: i,
                      barsSpace: 3,
                      barRods: [
                        BarChartRodData(
                          toY: d.blocked.toDouble(),
                          color: AppColors.threatRed,
                          width: 10,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4)),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: _maxY.toDouble(),
                            color: AppColors.charcoalLight,
                          ),
                        ),
                        BarChartRodData(
                          toY: d.allowed.toDouble(),
                          color: AppColors.safeGreen,
                          width: 10,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4)),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: _maxY.toDouble(),
                            color: AppColors.charcoalLight,
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Summary totals
            Row(
              children: [
                _SummaryChip(
                  value: data.fold(0, (s, d) => s + d.blocked).toString(),
                  label: 'Total Blocked',
                  color: AppColors.threatRed,
                ),
                const SizedBox(width: 10),
                _SummaryChip(
                  value: data.fold(0, (s, d) => s + d.allowed).toString(),
                  label: 'Total Allowed',
                  color: AppColors.safeGreen,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  int get _maxY {
    final mx = data.fold(0, (prev, d) => d.total > prev ? d.total : prev);
    return mx == 0 ? 10 : ((mx / 5).ceil() * 5);
  }

  double get _yInterval {
    final max = _maxY;
    if (max <= 10) return 2;
    if (max <= 50) return 10;
    if (max <= 100) return 20;
    return 50;
  }
}

class _LiveDot extends StatefulWidget {
  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.safeGreenDim,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.safeGreen
                    .withValues(alpha: 0.4 + 0.6 * _ctrl.value),
              ),
            ),
            const SizedBox(width: 5),
            Text('LIVE',
                style: TextStyle(
                  color: AppColors.safeGreen,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                )),
          ],
        ),
      ),
    );
  }
}

class _OfflinePlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.charcoalLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bar_chart_rounded, color: AppColors.textHint, size: 32),
          const SizedBox(height: 8),
          Text(
            'Activate protection to see live activity',
            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot(this.color, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 5),
        Text(label, style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _SummaryChip({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style: TextStyle(
                    color: color, fontSize: 20, fontWeight: FontWeight.w800)),
            Text(label,
                style: const TextStyle(
                    color: AppColors.textMuted, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
