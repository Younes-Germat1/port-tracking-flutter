import 'package:flutter/material.dart';

class StatutBadge extends StatelessWidget {
  final String statut;

  const StatutBadge({super.key, required this.statut});

  @override
  Widget build(BuildContext context) {
    final config = _getConfig(statut);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: config['bg'] as Color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        config['label'] as String,
        style: TextStyle(
          color: config['color'] as Color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Map<String, dynamic> _getConfig(String statut) {
    switch (statut) {
      case 'EN_ATTENTE':
        return {
          'label': 'En Attente',
          'color': const Color(0xFFB45309),
          'bg': const Color(0xFFFEF3C7),
        };
      case 'APPROUVEE':
        return {
          'label': 'Approuvée',
          'color': const Color(0xFF065F46),
          'bg': const Color(0xFFD1FAE5),
        };
      case 'REJETEE':
        return {
          'label': 'Rejetée',
          'color': const Color(0xFF991B1B),
          'bg': const Color(0xFFFEE2E2),
        };
      case 'PLACEE':
        return {
          'label': 'Placée',
          'color': const Color(0xFF1E40AF),
          'bg': const Color(0xFFDBEAFE),
        };
      case 'DEDOUANEE':
        return {
          'label': 'Dédouanée',
          'color': const Color(0xFF6B21A8),
          'bg': const Color(0xFFF3E8FF),
        };
      case 'LIBEREE':
        return {
          'label': 'Libérée',
          'color': const Color(0xFF374151),
          'bg': const Color(0xFFF3F4F6),
        };
      default:
        return {
          'label': statut,
          'color': const Color(0xFF374151),
          'bg': const Color(0xFFF3F4F6),
        };
    }
  }
}