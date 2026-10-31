import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';

/// UX-23 (#259): destino del dock inferior del dashboard.
///
/// Se extrajo de `dashboard_screen.dart` (`_buildNavItem`) para poder probar la
/// semántica sin levantar la pantalla completa. El aspecto es idéntico.
///
/// El nodo expone rol de pestaña (`SemanticsRole.tab`), `selected` para que
/// TalkBack anuncie cuál está activa y `onTap` para poder activarla. El
/// `GestureDetector` interno queda excluido de semántica para no duplicar la
/// acción ni la etiqueta.
class DashboardDockItem extends StatelessWidget {
  const DashboardDockItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive
        ? AppColors.manaCyan
        : AppColors.onSurfaceVariant.withValues(alpha: 0.6);
    return Expanded(
      child: Semantics(
        selected: isActive,
        button: true,
        role: SemanticsRole.tab,
        label: label,
        onTap: onTap,
        // El texto visible se anuncia una sola vez (el label del nodo).
        excludeSemantics: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          excludeFromSemantics: true,
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.manaCyan.withValues(alpha: 0.12)
                  : Colors.transparent,
              border: Border(
                top: BorderSide(
                  color: isActive ? AppColors.manaCyan : Colors.transparent,
                  width: 4,
                ),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // El icono comparte nodo con el texto: un solo anuncio
                // ("MAZMORRAS, pestaña, seleccionada").
                Icon(icon, color: color, size: 24),
                const SizedBox(height: 3),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    color: color,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
