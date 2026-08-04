import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/system_window.dart';

class ConversationalTacticsNavigator extends StatefulWidget {
  final String scenarioId;
  final String scenarioTitle;
  final Function(String tactic) onStart;

  const ConversationalTacticsNavigator({
    super.key,
    required this.scenarioId,
    required this.scenarioTitle,
    required this.onStart,
  });

  static void show(
    BuildContext context, {
    required String scenarioId,
    required String scenarioTitle,
    required Function(String tactic) onStart,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ConversationalTacticsNavigator(
        scenarioId: scenarioId,
        scenarioTitle: scenarioTitle,
        onStart: onStart,
      ),
    );
  }

  @override
  State<ConversationalTacticsNavigator> createState() => _ConversationalTacticsNavigatorState();
}

class _ConversationalTacticsNavigatorState extends State<ConversationalTacticsNavigator> {
  String _selectedTactic = 'fluency';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SystemWindow(
        title: 'TACTICAL CONFIGURATION',
        subtitle: 'SELECT CONVERSATIONAL FOCUS',
        icon: Icons.shield_rounded,
        showCloseButton: true,
        accentColor: AppColors.manaCyan,
        onClose: () => Navigator.pop(context),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Escenario: ${widget.scenarioTitle.toUpperCase()}',
              style: GoogleFonts.jetBrainsMono(
                color: AppColors.onSurface.withValues(alpha: 0.7),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Tactic 1: Fluency
            _buildTacticCard(
              id: 'fluency',
              title: '🗣️ ENFOQUE EN FLUIDEZ (VELOCIDAD)',
              desc: 'Ignora pequeños errores gramaticales. Enfócate en hablar rápido y fluido. Bonus: +15% DEX XP.',
            ),
            const SizedBox(height: 12),

            // Tactic 2: Grammar
            _buildTacticCard(
              id: 'grammar',
              title: '🧠 PRECISIÓN GRAMATICAL (CONTROL)',
              desc: 'La IA analizará minuciosamente tu estructura de enunciados. Bonus: +15% INT XP.',
            ),
            const SizedBox(height: 12),

            // Tactic 3: Hints
            _buildTacticCard(
              id: 'hints',
              title: '💡 PERGAMINO DE TRADUCCIÓN (ASISTIDO)',
              desc: 'Habilita pistas y traducciones automáticas en tiempo real en la pantalla durante la conversación.',
            ),
            const SizedBox(height: 24),

            // Action Button
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                widget.onStart(_selectedTactic);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.manaCyan,
                foregroundColor: AppColors.voidBg,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              child: Text(
                'INICIAR MAZMORRA',
                style: GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTacticCard({
    required String id,
    required String title,
    required String desc,
  }) {
    final isSelected = _selectedTactic == id;
    final activeColor = isSelected ? AppColors.manaCyan : AppColors.onSurface.withValues(alpha: 0.10);

    return GestureDetector(
      onTap: () => setState(() => _selectedTactic = id),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.manaCyan.withValues(alpha: 0.05) : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: activeColor,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.spaceGrotesk(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isSelected ? AppColors.manaCyan : AppColors.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              desc,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.onSurfaceVariant,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
