import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';

class CharacterCreationData {
  final String name;
  final String playerClass;
  final int avatarIndex;

  const CharacterCreationData({
    required this.name,
    required this.playerClass,
    this.avatarIndex = 0,
  });
}

class CharacterCreationWizard extends ConsumerStatefulWidget {
  final Function(CharacterCreationData) onComplete;

  const CharacterCreationWizard({super.key, required this.onComplete});

  @override
  ConsumerState<CharacterCreationWizard> createState() => _CharacterCreationWizardState();
}

class _CharacterCreationWizardState extends ConsumerState<CharacterCreationWizard> with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  String _selectedClass = 'warrior';
  int _selectedAvatar = 0;
  late AnimationController _pulseController;

  final List<Map<String, dynamic>> _classes = [
    {'id': 'warrior', 'name': 'Berserker', 'icon': Icons.shield_rounded, 'desc': 'Extrovertido, hablas primero y piensas después. Ideal para perder el miedo a hablar.', 'color': Colors.redAccent},
    {'id': 'mage', 'name': 'Mago Arcano', 'icon': Icons.auto_awesome_rounded, 'desc': 'Analítico, observas y estructuras antes de hablar. Ideal para perfeccionar la gramática.', 'color': AppColors.runeViolet},
    {'id': 'rogue', 'name': 'Pícaro', 'icon': Icons.explore_rounded, 'desc': 'Práctico, aprendes sobre la marcha y te adaptas rápido. Ideal para vocabulario útil.', 'color': AppColors.emeraldGreen},
  ];

  final List<Map<String, dynamic>> _avatars = [
    {'icon': Icons.person, 'color': AppColors.manaCyan},
    {'icon': Icons.face_3_rounded, 'color': AppColors.runeViolet},
    {'icon': Icons.face_4_rounded, 'color': AppColors.emeraldGreen},
    {'icon': Icons.face_5_rounded, 'color': AppColors.royalGold},
    {'icon': Icons.face_6_rounded, 'color': Colors.pinkAccent},
    {'icon': Icons.face_2_rounded, 'color': Colors.orangeAccent},
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  bool get _isValid => _nameController.text.trim().length >= 2;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Center(
            child: Text(
              'CREA TU PERSONAJE',
              style: GoogleFonts.jetBrainsMono(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              'Antes de comenzar tu aventura,\nnecesitamos saber quién eres.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.onSurfaceVariant, height: 1.5),
            ),
          ),
          const SizedBox(height: 24),

          // Name Field
          Text('NOMBRE DEL CAZADOR', style: GoogleFonts.jetBrainsMono(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white70, letterSpacing: 0.8)),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Tu nombre aventurero...',
              hintStyle: GoogleFonts.spaceGrotesk(fontSize: 20, color: Colors.white24),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.05),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: AppColors.manaCyan.withValues(alpha: 0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(color: AppColors.manaCyan),
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 24),

          // Avatar Selection
          Text('AVATAR', style: GoogleFonts.jetBrainsMono(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white70, letterSpacing: 0.8)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(_avatars.length, (i) {
              final av = _avatars[i];
              final isSelected = _selectedAvatar == i;
              return GestureDetector(
                onTap: () => setState(() => _selectedAvatar = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? av['color']!.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.04),
                    border: Border.all(
                      color: isSelected ? av['color']! : Colors.white.withValues(alpha: 0.1),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected ? [BoxShadow(color: av['color']!.withValues(alpha: 0.3), blurRadius: 8)] : null,
                  ),
                  child: Icon(av['icon'] as IconData, color: isSelected ? av['color'] : Colors.white38, size: 24),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),

          // Class Selection
          Text('CLASE', style: GoogleFonts.jetBrainsMono(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white70, letterSpacing: 0.8)),
          const SizedBox(height: 10),
          ..._classes.map((cls) {
            final isSelected = _selectedClass == cls['id'];
            final color = cls['color'] as Color;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () => setState(() => _selectedClass = cls['id'] as String),
                child: GlassCard(
                  blur: 4, opacity: isSelected ? 0.12 : 0.03,
                  border: Border.all(color: isSelected ? color : Colors.white.withValues(alpha: 0.08), width: isSelected ? 2 : 1),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)),
                        child: Icon(cls['icon'] as IconData, color: color, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(cls['name'] as String, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                            const SizedBox(height: 2),
                            Text(cls['desc'] as String, style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
                          ],
                        ),
                      ),
                      Icon(isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded, color: isSelected ? color : Colors.white24, size: 22),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 24),

          // Continue Button
          Center(
            child: ElevatedButton(
              onPressed: _isValid ? () => widget.onComplete(CharacterCreationData(
                name: _nameController.text.trim(),
                playerClass: _selectedClass,
                avatarIndex: _selectedAvatar,
              )) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.manaCyan,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                disabledBackgroundColor: Colors.white12,
              ),
              child: Text(
                'EL ORÁCULO TE ESPERA',
                style: GoogleFonts.jetBrainsMono(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
