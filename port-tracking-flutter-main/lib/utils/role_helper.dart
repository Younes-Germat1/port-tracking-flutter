import 'package:flutter/material.dart';

class RoleHelper {
  static Color getColor(String role) {
    switch (role) {
      case 'ADMIN': return const Color(0xFFDC2626);
      case 'IMPORTATEUR': return const Color(0xFF2563EB);
      case 'ADII': return const Color(0xFF16A34A);
      case 'OPERATEUR': return const Color(0xFFD97706);
      case 'INSPECTEUR': return const Color(0xFF7C3AED);
      default: return const Color(0xFF6B7280);
    }
  }

  static Color getBgColor(String role) {
    switch (role) {
      case 'ADMIN': return const Color(0xFFFEE2E2);
      case 'IMPORTATEUR': return const Color(0xFFDBEAFE);
      case 'ADII': return const Color(0xFFDCFCE7);
      case 'OPERATEUR': return const Color(0xFFFEF3C7);
      case 'INSPECTEUR': return const Color(0xFFF3E8FF);
      default: return const Color(0xFFF3F4F6);
    }
  }

  static String getLabel(String role) {
    switch (role) {
      case 'ADMIN': return 'Administrateur';
      case 'IMPORTATEUR': return 'Importateur';
      case 'ADII': return 'Agent ADII';
      case 'OPERATEUR': return 'Opérateur Port';
      case 'INSPECTEUR': return 'Inspecteur';
      default: return role;
    }
  }

  static IconData getIcon(String role) {
    switch (role) {
      case 'ADMIN': return Icons.admin_panel_settings_outlined;
      case 'IMPORTATEUR': return Icons.business_outlined;
      case 'ADII': return Icons.verified_outlined;
      case 'OPERATEUR': return Icons.forklift;
      case 'INSPECTEUR': return Icons.search_outlined;
      default: return Icons.person_outline;
    }
  }

  static bool canAccessFiches(String role) =>
      ['ADMIN', 'IMPORTATEUR', 'ADII', 'OPERATEUR'].contains(role);

  static bool canAccessInspections(String role) =>
      ['ADMIN', 'ADII', 'INSPECTEUR'].contains(role);

  static bool canAccessConteneurs(String role) =>
      ['ADMIN', 'OPERATEUR', 'ADII'].contains(role);

  static bool isAdmin(String role) => role == 'ADMIN';
}