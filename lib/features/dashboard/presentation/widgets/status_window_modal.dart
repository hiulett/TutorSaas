import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.88,
        decoration: const BoxDecoration(
          color: Color(0xFF060A14),
          border: Border(
            top: BorderSide(color: AppColors.tertiaryTeal, width: 2),
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
                    style: GoogleFonts.orbitron(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, color: Colors.white70),
              ),
            ],
          ),
          const Divider(color: Colors.white12),
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
                    opacity: 0.1,
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [AppColors.primaryPurple, AppColors.tertiaryTeal],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryPurple.withValues(alpha: 0.5),
                                blurRadius: 15,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              widget.currentRank,
                              style: GoogleFonts.orbitron(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
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
                                style: GoogleFonts.orbitron(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.tertiaryTeal,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${activeTitle.icon} ${activeTitle.name}',
                                style: GoogleFonts.hankenGrotesk(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    '🔮 ${widget.manaBalance} Maná',
                                    style: const TextStyle(fontSize: 11, color: AppColors.primaryPurple, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    '⚡ ${widget.totalXp} XP Total',
                                    style: const TextStyle(fontSize: 11, color: Colors.amber, fontWeight: FontWeight.bold),
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
                    style: GoogleFonts.orbitron(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Attributes Grid
                  _buildAttributeRow('✍️ Precisión Gramatical', '88%', 0.88, AppColors.tertiaryTeal),
                  _buildAttributeRow('⚡ Latencia de Respuesta', '1.4s (Rango A)', 0.90, Colors.amber),
                  _buildAttributeRow('🎧 Agudeza Auditiva A Ciegas', '4 Lecciones', 0.60, AppColors.primaryPurple),
                  _buildAttributeRow('📚 Capacidad Léxica SRS', '142 Palabras', 0.70, Colors.lightBlueAccent),
                  _buildAttributeRow('🎙️ Precisión Fonética', '91%', 0.91, Colors.greenAccent),
                  _buildAttributeRow('🌪️ Volumen de Oratoria', '1,840 Palabras', 0.65, Colors.orangeAccent),
                  _buildAttributeRow('🛡️ Presencia Social (Salas)', '120 Minutos', 0.75, Colors.pinkAccent),

                  const SizedBox(height: 24),
                  Text(
                    '📜 INVENTARIO DE TÍTULOS LEGENDARIOS (EQUIPABLES)',
                    style: GoogleFonts.orbitron(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
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
                            ? AppColors.primaryPurple.withValues(alpha: 0.25)
                            : Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isEquipped ? AppColors.primaryPurple : Colors.white12,
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
                                        color: isEquipped ? Colors.white : Colors.white70,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: title.color.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(6),
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
                                  style: const TextStyle(fontSize: 10, color: Colors.white54),
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
                              backgroundColor: isEquipped ? Colors.white12 : AppColors.primaryPurple,
                              foregroundColor: Colors.white,
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
              Text(name, style: const TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w500)),
              Text(valueText, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }
}
