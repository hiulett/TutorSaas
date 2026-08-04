import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/cyber_manhwa_background.dart';
import '../../data/models/hunter_catalog.dart';

class StatusWindowModal extends StatefulWidget {
  final String currentRank;
  final String equippedTitleCode;
  final int manaBalance;
  final int totalXp;
  final Function(HunterTitleItem title)? onTitleEquipped;

  const StatusWindowModal({
    super.key,
    this.currentRank = 'B',
    this.equippedTitleCode = 'oido_halcon_abismo_c',
    this.manaBalance = 450,
    this.totalXp = 2450,
    this.onTitleEquipped,
  });

  static void show(BuildContext context, {
    String currentRank = 'B',
    String equippedTitleCode = 'oido_halcon_abismo_c',
    int manaBalance = 450,
    int totalXp = 2450,
    Function(HunterTitleItem title)? onTitleEquipped,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatusWindowModal(
        currentRank: currentRank,
        equippedTitleCode: equippedTitleCode,
        manaBalance: manaBalance,
        totalXp: totalXp,
        onTitleEquipped: onTitleEquipped,
      ),
    );
  }

  @override
  State<StatusWindowModal> createState() => _StatusWindowModalState();
}

class _StatusWindowModalState extends State<StatusWindowModal> {
  late String _equippedCode;

  @override
  void initState() {
    super.initState();
    _equippedCode = widget.equippedTitleCode;
  }

  @override
  Widget build(BuildContext context) {
    final activeTitle = HunterCatalog.titles.firstWhere(
      (t) => t.code == _equippedCode,
      orElse: () => HunterCatalog.titles.first,
    );

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.88,
        decoration: const BoxDecoration(
          color: AppColors.statusWindowBg,
          border: Border(
            top: BorderSide(color: AppColors.manaCyan, width: 2),
          ),
        ),
        child: CyberManhwaBackground(
          bgMode: CyberBgMode.hunterStatus,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
          // Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('📊', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 8),
                  Text(
                    'VENTANA DE ESTADO DEL CAZADOR',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close_rounded, color: AppColors.onSurface.withValues(alpha: 0.7)),
              ),
            ],
          ),
          Divider(color: AppColors.onSurface.withValues(alpha: 0.12)),
          const SizedBox(height: 10),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rank & Class Hero Card
                  GlassCard(
                    blur: 20,
                    opacity: AppColors.glassOpacity,
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [AppColors.runeViolet, AppColors.manaCyan],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.runeViolet.withValues(alpha: 0.5),
                                blurRadius: 15,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              widget.currentRank,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: AppColors.onSurface,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CAZADOR DE RANGO ${widget.currentRank}',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.manaCyan,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${activeTitle.icon} ${activeTitle.name}',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    '🔮 ${widget.manaBalance} Maná',
                                    style: const TextStyle(fontSize: 11, color: AppColors.runeViolet, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    '⚡ ${widget.totalXp} XP Total',
                                    style: const TextStyle(fontSize: 11, color: AppColors.royalGold, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  Text(
                    '🛡️ ATRIBUTOS DEL MONARCA (11 MÉTRICAS)',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Attributes Grid
                  _buildAttributeRow('✍️ Precisión Gramatical', '88%', 0.88, AppColors.manaCyan),
                  _buildAttributeRow('⚡ Latencia de Respuesta', '1.4s (Rango A)', 0.90, AppColors.royalGold),
                  _buildAttributeRow('🎧 Agudeza Auditiva A Ciegas', '4 Lecciones', 0.60, AppColors.runeViolet),
                  _buildAttributeRow('📚 Capacidad Léxica SRS', '142 Palabras', 0.70, AppColors.manaCyan),
                  _buildAttributeRow('🎙️ Precisión Fonética', '91%', 0.91, AppColors.emeraldGreen),
                  _buildAttributeRow('🌪️ Volumen de Oratoria', '1,840 Palabras', 0.65, AppColors.guildAmber),
                  _buildAttributeRow('🛡️ Presencia Social (Salas)', '120 Minutos', 0.75, AppColors.presencePink),

                  const SizedBox(height: 24),
                  Text(
                    '📜 INVENTARIO DE TÍTULOS LEGENDARIOS (EQUIPABLES)',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Titles Inventory List
                  ...HunterCatalog.titles.map((title) {
                    final bool isEquipped = title.code == _equippedCode;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: isEquipped
                            ? AppColors.runeViolet.withValues(alpha: 0.25)
                            : AppColors.onSurface.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(
                          color: isEquipped ? AppColors.runeViolet : AppColors.onSurface.withValues(alpha: 0.12),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(title.icon, style: const TextStyle(fontSize: 20)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      title.name,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: isEquipped ? AppColors.onSurface : AppColors.onSurface.withValues(alpha: 0.7),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: title.color.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(AppRadius.md),
                                      ),
                                      child: Text(
                                        'RANGO ${title.rankTier}',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: title.color,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  title.description,
                                  style: TextStyle(fontSize: 10, color: AppColors.onSurface.withValues(alpha: 0.54)),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: isEquipped
                                ? null
                                : () {
                                    setState(() {
                                      _equippedCode = title.code;
                                    });
                                    if (widget.onTitleEquipped != null) {
                                      widget.onTitleEquipped!(title);
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isEquipped ? AppColors.onSurface.withValues(alpha: 0.12) : AppColors.runeViolet,
                              foregroundColor: AppColors.onSurface,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              minimumSize: const Size(60, 30),
                            ),
                            child: Text(
                              isEquipped ? 'Equipado' : 'Equipar',
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  ),
),
);
}

  Widget _buildAttributeRow(String name, String valueText, double progress, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: TextStyle(fontSize: 12, color: AppColors.onSurface.withValues(alpha: 0.7), fontWeight: FontWeight.w500)),
              Text(valueText, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.onSurface.withValues(alpha: 0.10),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }
}
