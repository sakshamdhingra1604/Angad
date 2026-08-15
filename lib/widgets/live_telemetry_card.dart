import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/telemetry_data.dart';
import '../theme/app_colors.dart';

class LiveTelemetryCard extends StatelessWidget {
  final TelemetryData data;
  final WaveBuffer ppsBuffer;
  final WaveBuffer uploadBuffer;
  final WaveBuffer downloadBuffer;

  const LiveTelemetryCard({
    super.key,
    required this.data,
    required this.ppsBuffer,
    required this.uploadBuffer,
    required this.downloadBuffer,
  });

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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.safeGreen,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: AppColors.safeGreenGlow, blurRadius: 6)],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'LIVE TELEMETRY',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textMuted,
                    letterSpacing: 2,
                  ),
                ),
                const Spacer(),
                Text(
                  data.serverLocation,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.infoBlue,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(child: _StatChip(label: 'LATENCY', value: data.latencyLabel, color: AppColors.safeGreen)),
                const SizedBox(width: 8),
                Expanded(child: _StatChip(label: 'ENGINE', value: data.engineLoadLabel, color: AppColors.infoBlue)),
                const SizedBox(width: 8),
                Expanded(child: _StatChip(label: 'PPS', value: data.ppsLabel, color: AppColors.amber)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 72,
            child: _PpsWaveChart(buffer: ppsBuffer),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Row(
              children: [
                _TrafficStat(
                  icon: Icons.arrow_upward_rounded,
                  color: AppColors.infoBlue,
                  value: '${data.uploadMbps.toStringAsFixed(1)} Mbps',
                  label: 'Upload',
                ),
                const SizedBox(width: 16),
                _TrafficStat(
                  icon: Icons.arrow_downward_rounded,
                  color: AppColors.safeGreen,
                  value: '${data.downloadMbps.toStringAsFixed(1)} Mbps',
                  label: 'Download',
                ),
                const Spacer(),
                _TrafficStat(
                  icon: Icons.hub_rounded,
                  color: AppColors.amber,
                  value: '${data.activeConnections}',
                  label: 'Active',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 9, color: color.withValues(alpha: 0.7), letterSpacing: 1.5, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: color,
              fontWeight: FontWeight.w800,
              fontFamily: 'JetBrains Mono',
            ),
          ),
        ],
      ),
    );
  }
}

class _TrafficStat extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  const _TrafficStat({required this.icon, required this.color, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: TextStyle(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
          ],
        ),
      ],
    );
  }
}

class _PpsWaveChart extends StatelessWidget {
  final WaveBuffer buffer;

  const _PpsWaveChart({required this.buffer});

  @override
  Widget build(BuildContext context) {
    final points = buffer.points;
    if (points.isEmpty) {
      return const SizedBox.shrink();
    }

    final spots = List.generate(points.length, (i) {
      return FlSpot(i.toDouble(), points[i].value);
    });

    final maxY = spots.map((s) => s.y).reduce(max);

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (spots.length - 1).toDouble().clamp(1, double.infinity),
        minY: 0,
        maxY: (maxY * 1.3).clamp(1, double.infinity),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.35,
            color: AppColors.safeGreen,
            barWidth: 1.8,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppColors.safeGreen.withValues(alpha: 0.25),
                  AppColors.safeGreen.withValues(alpha: 0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        lineTouchData: const LineTouchData(enabled: false),
      ),
      duration: const Duration(milliseconds: 100),
    );
  }
}
