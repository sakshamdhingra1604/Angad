import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/threat_log.dart';

class MerkleTreeBadge extends StatelessWidget {
  final ThreatLog log;
  final bool expanded;

  const MerkleTreeBadge({super.key, required this.log, this.expanded = false});

  @override
  Widget build(BuildContext context) {
    if (log.merkleVerified != true) return const SizedBox.shrink();

    if (!expanded) return _buildCompactBadge(context);
    return _buildExpandedCard(context);
  }

  Widget _buildCompactBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.cryptoPurpleDim,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cryptoPurple.withValues(alpha: 0.4)),
        boxShadow: [BoxShadow(color: AppColors.cryptoPurple.withValues(alpha: 0.15), blurRadius: 8)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.hub_rounded, color: AppColors.cryptoPurple, size: 12),
          const SizedBox(width: 4),
          Text(
            'MERKLE VERIFIED',
            style: TextStyle(
              color: AppColors.cryptoPurple,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.cryptoPurpleDim, AppColors.charcoalMid],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cryptoPurple.withValues(alpha: 0.35)),
        boxShadow: [BoxShadow(color: AppColors.cryptoPurple.withValues(alpha: 0.1), blurRadius: 16)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.hub_rounded, color: AppColors.cryptoPurple, size: 16),
              const SizedBox(width: 8),
              Text(
                'Secured via Merkle Tree',
                style: TextStyle(
                  color: AppColors.cryptoPurple,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.cryptoPurple.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'VERIFIED ✓',
                  style: TextStyle(
                    color: AppColors.cryptoPurple,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _HashRow(label: 'Merkle Hash', value: log.merkleHash ?? '--'),
          const SizedBox(height: 8),
          _HashRow(label: 'Block Height', value: '#${log.merkleBlockHeight ?? '--'}'),
          const SizedBox(height: 8),
          _HashRow(label: 'Recorded At', value: _formatTime(log.merkleTimestamp)),
          const SizedBox(height: 12),
          // Mini Merkle tree visualization
          _MerkleTreeVisualization(hash: log.merkleHash ?? ''),
          const SizedBox(height: 8),
          Text(
            'This blocked IP has been cryptographically verified and permanently stored in the global threat ledger. The hash is immutable and cannot be altered.',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 10,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(String? iso) {
    if (iso == null) return '--';
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} IST';
    } catch (_) {
      return '--';
    }
  }
}

class _HashRow extends StatelessWidget {
  final String label;
  final String value;

  const _HashRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(label, style: const TextStyle(
            color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w500,
          )),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.cryptoPurple,
              fontSize: 11,
              fontFamily: 'JetBrains Mono',
              overflow: TextOverflow.ellipsis,
            ),
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}

class _MerkleTreeVisualization extends StatelessWidget {
  final String hash;

  const _MerkleTreeVisualization({required this.hash});

  @override
  Widget build(BuildContext context) {
    // Show a stylized mini Merkle tree with truncated hashes
    final h = hash.isNotEmpty ? hash : '0' * 64;
    final h1 = h.substring(0, 8);
    final h2 = h.length > 8 ? h.substring(8, 16) : '--------';
    final h3 = h.length > 16 ? h.substring(16, 24) : '--------';
    final root = h.substring(0, min(16, h.length));

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.charcoal,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cryptoPurple.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          // Root
          _MerkleNode(hash: root, isRoot: true),
          const SizedBox(height: 4),
          // Connector lines
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 40, height: 1, color: AppColors.cryptoPurple.withValues(alpha: 0.3)),
              Container(width: 40, height: 1, color: AppColors.cryptoPurple.withValues(alpha: 0.3)),
            ],
          ),
          const SizedBox(height: 4),
          // Leaf nodes
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _MerkleNode(hash: h1),
              const SizedBox(width: 16),
              _MerkleNode(hash: h2),
              const SizedBox(width: 16),
              _MerkleNode(hash: h3),
            ],
          ),
        ],
      ),
    );
  }

  int min(int a, int b) => a < b ? a : b;
}

class _MerkleNode extends StatelessWidget {
  final String hash;
  final bool isRoot;

  const _MerkleNode({required this.hash, this.isRoot = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isRoot ? AppColors.cryptoPurple.withValues(alpha: 0.2) : AppColors.cryptoPurpleDim.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.cryptoPurple.withValues(alpha: isRoot ? 0.6 : 0.3)),
      ),
      child: Text(
        hash,
        style: TextStyle(
          color: isRoot ? AppColors.cryptoPurple : AppColors.cryptoPurple.withValues(alpha: 0.7),
          fontSize: 9,
          fontFamily: 'JetBrains Mono',
        ),
      ),
    );
  }
}
