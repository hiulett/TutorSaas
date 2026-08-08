import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../onboarding/domain/models/cefr_rank.dart';
import '../../domain/models/mission_models.dart';

/// Rareza de una misión del gremio (derivada del rango RPG).
enum QuestRarity {
  common('COMÚN', AppColors.rarityCommon),
  uncommon('POCO COMÚN', AppColors.rarityUncommon),
  rare('RARO', AppColors.rarityRare),
  epic('ÉPICO', AppColors.rarityEpic),
  legendary('LEGENDARIO', AppColors.rarityLegendary),
  guild('ESPECIAL DEL GREMIO', AppColors.guildAmber);

  final String label;
  final Color color;
  const QuestRarity(this.label, this.color);

  /// Rareza editorial desde BD ([rarity]: common|uncommon|rare|epic|legendary|guild).
  /// Si no se provee, deriva del rango del gremio.
  static QuestRarity fromRank(String? gameRank, {String? rarity}) {
    switch (rarity?.trim().toLowerCase()) {
      case 'common':
        return QuestRarity.common;
      case 'uncommon':
        return QuestRarity.uncommon;
      case 'rare':
        return QuestRarity.rare;
      case 'epic':
        return QuestRarity.epic;
      case 'legendary':
        return QuestRarity.legendary;
      case 'guild':
        return QuestRarity.guild;
    }
    switch (gameRank?.trim().toUpperCase()) {
      case 'E':
        return QuestRarity.common;
      case 'D':
        return QuestRarity.uncommon;
      case 'C':
        return QuestRarity.rare;
      case 'B':
        return QuestRarity.epic;
      case 'A':
        return QuestRarity.legendary;
      case 'S':
      case 'SS':
      case 'SSS':
        return QuestRarity.guild;
      default:
        return QuestRarity.common;
    }
  }
}

/// Estado visual de un pergamino de misión.
enum QuestStatus {
  available('DISPONIBLE', AppColors.emeraldGreen),
  accepted('ACEPTADA', AppColors.manaCyan),
  inProgress('EN PROGRESO', AppColors.runeViolet),
  completed('COMPLETADA', AppColors.royalGold),
  repeatable('REPETIBLE', AppColors.rarityEpic),
  blocked('BLOQUEADA', AppColors.crimsonRed),
  recommended('RECOMENDADA', AppColors.guildAmber),
  special('ESPECIAL', AppColors.rarityLegendary);

  final String label;
  final Color color;
  const QuestStatus(this.label, this.color);
}

/// Estado derivado de una misión del pool para un jugador dado.
QuestStatus questStatusFor({
  required GuildQuest quest,
  required String playerRank,
  required bool isCompleted,
  required bool isActive,
  required bool isRecommended,
}) {
  if (isCompleted) return QuestStatus.completed;
  if (isActive) return QuestStatus.inProgress;
  if (isRecommended) return QuestStatus.recommended;
  if (!CefrRank.canAcceptRank(playerRank, quest.gameRank)) return QuestStatus.blocked;
  return QuestStatus.available;
}

/// Orden inteligente del tablón: recomendadas (rango del jugador) primero,
/// luego aceptables, y bloqueadas al final. Desempata por rango menor requerido.
List<GuildQuest> sortQuestSmart({
  required List<GuildQuest> quests,
  required String playerRank,
  required String recommendedRank,
}) {
  int priority(GuildQuest q) {
    if (q.gameRank == recommendedRank) return 0;
    if (CefrRank.canAcceptRank(playerRank, q.gameRank)) return 1;
    return 2;
  }

  final sorted = [...quests]..sort((a, b) {
    final pa = priority(a);
    final pb = priority(b);
    if (pa != pb) return pa - pb;
    final ra = CefrRank.rankIndex(a.gameRank ?? '');
    final rb = CefrRank.rankIndex(b.gameRank ?? '');
    return (ra < 0 ? 99 : ra).compareTo(rb < 0 ? 99 : rb);
  });
  return sorted;
}

/// Pergamino de misión: reutiliza `assets/images/avatars/Mision.png` como base
/// y superpone los datos de la misión. Diseño discreto, estilo tablón medieval.
/// Animación de entrada (fade + leve rotación) y badge NUEVA/RECOMENDADA.
class MissionParchment extends StatefulWidget {
  final GuildQuest quest;
  final String playerRank;
  final QuestStatus status;
  final bool isRecommended;

  /// Marca la misión como "nueva" (badge NUEVA).
  final bool isNew;
  final VoidCallback onTap;
  final double? width;

  /// Progreso 0.0–1.0 de la misión activa (mini-barra). Null si no aplica.
  final double? progress;

  /// Etiqueta de progreso (p.ej. "3/5"). Null si no aplica.
  final String? progressLabel;

  /// Índice en la cuadrícula (delay de la animación de entrada).
  final int index;

  const MissionParchment({
    super.key,
    required this.quest,
    required this.playerRank,
    required this.status,
    this.isRecommended = false,
    this.isNew = false,
    required this.onTap,
    this.width,
    this.progress,
    this.progressLabel,
    this.index = 0,
  });

  @override
  State<MissionParchment> createState() => _MissionParchmentState();
}

class _MissionParchmentState extends State<MissionParchment>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<double> _rotation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    // Delay escalonado por índice para efecto "pergaminos clavados".
    final delay = Duration(milliseconds: (widget.index * 60).clamp(0, 600));
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _rotation = Tween<double>(begin: -0.03, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    Future.delayed(delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  QuestRarity get _rarity => QuestRarity.fromRank(widget.quest.gameRank, rarity: widget.quest.rarity);

  @override
  Widget build(BuildContext context) {
    final rarityColor = _rarity.color;
    return GestureDetector(
      onTap: widget.onTap,
      child: FadeTransition(
        opacity: _opacity,
        child: Transform.rotate(
          angle: _rotation.value,
          child: Container(
            width: widget.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              // Marco de rareza discreto (borde + sombra suave), nunca fluorescente.
              border: Border.all(color: rarityColor.withValues(alpha: 0.45), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: rarityColor.withValues(alpha: 0.15),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Pergamino base (se reutiliza el asset del proyecto).
                  Image.asset(
                    'assets/images/avatars/Mision.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: AppColors.medievalDarkWood),
                  ),
                  // Overlay oscuro suave para legibilidad del texto.
                  Container(color: AppColors.voidBg.withValues(alpha: 0.38)),
                  // ── Efectos de estado ─────────────────────────────────────
                  // Sello de cera rojo para misiones bloqueadas.
                  if (widget.status == QuestStatus.blocked)
                    Positioned(
                      right: 10,
                      top: 10,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.crimsonRed,
                          border: Border.all(color: AppColors.crimsonRed.withValues(alpha: 0.7), width: 1.5),
                          boxShadow: [
                            BoxShadow(color: AppColors.crimsonRed.withValues(alpha: 0.4), blurRadius: 6),
                          ],
                        ),
                        child: const Icon(Icons.lock_rounded, size: 12, color: Colors.white),
                      ),
                    ),
                  // Pergamino "enrollado": franjas laterales para completadas.
                  if (widget.status == QuestStatus.completed)
                    Row(
                      children: [
                        Container(width: 4, height: double.infinity, color: AppColors.medievalAgedGold.withValues(alpha: 0.5)),
                        const Spacer(),
                        Container(width: 4, height: double.infinity, color: AppColors.medievalAgedGold.withValues(alpha: 0.5)),
                      ],
                    ),
                  // ── Contenido (overlays sobre el pergamino) ──────────────────
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Fila superior: tipo + sello de rareza
                        Row(
                          children: [
                            Expanded(
                              child: _tag(widget.quest.questType.toUpperCase(), AppColors.medievalText),
                            ),
                            const SizedBox(width: 4),
                            // Sello discreto de rareza (punto pequeño)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: rarityColor,
                                border: Border.all(color: rarityColor.withValues(alpha: 0.6), width: 0.6),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Badge NUEVA / RECOMENDADA (badge superior derecho)
                        if (widget.isNew || widget.isRecommended) ...[
                          Align(
                            alignment: Alignment.centerLeft,
                            child: _pulsingBadge(
                              widget.isNew ? 'NUEVA' : 'RECOMENDADA',
                              widget.isNew ? AppColors.manaCyan : AppColors.guildAmber,
                            ),
                          ),
                          const SizedBox(height: 4),
                        ],
                        // Nombre de la misión
                        Text(
                          widget.quest.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.medievalText,
                            height: 1.15,
                          ),
                        ),
                        const Spacer(),
                        // Fila: rango + dificultad
                        Row(
                          children: [
                            _miniIcon(Icons.military_tech_rounded, widget.quest.gameRank ?? '-', AppColors.medievalAgedGoldLight),
                            const Spacer(),
                            _miniIcon(Icons.speed_rounded, '${widget.quest.targetValue}', AppColors.medievalTextDim),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Fila: XP + oro
                        Row(
                          children: [
                            _miniIcon(Icons.auto_awesome_rounded, '${widget.quest.xpReward} XP', AppColors.manaCyanLight),
                            const Spacer(),
                            _miniIcon(Icons.diamond_rounded, '${widget.quest.gemReward}', AppColors.royalGoldLight),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Estado (badge inferior)
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: widget.status.color.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(3),
                              border: Border.all(color: widget.status.color.withValues(alpha: 0.5), width: 0.7),
                            ),
                            child: Text(
                              widget.status.label,
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 7,
                                fontWeight: FontWeight.bold,
                                color: widget.status.color,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                        ),
                        // ── Mini-barra de progreso (misiones activas) ──────────
                        if (widget.progress != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(2),
                                  child: Container(
                                    height: 4,
                                    color: AppColors.voidBg.withValues(alpha: 0.5),
                                    child: FractionallySizedBox(
                                      alignment: Alignment.centerLeft,
                                      widthFactor: widget.progress!.clamp(0.0, 1.0),
                                      child: Container(color: widget.status.color),
                                    ),
                                  ),
                                ),
                              ),
                              if (widget.progressLabel != null) ...[
                                const SizedBox(width: 4),
                                Text(
                                  widget.progressLabel!,
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 7,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.medievalText,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _pulsingBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: color.withValues(alpha: 0.6), width: 0.8),
      ),
      child: Text(
        label,
        style: GoogleFonts.jetBrainsMono(
          fontSize: 7,
          fontWeight: FontWeight.bold,
          color: color,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  Widget _tag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.voidBg.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.jetBrainsMono(
          fontSize: 7,
          fontWeight: FontWeight.bold,
          color: color,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  Widget _miniIcon(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 10, color: color),
        const SizedBox(width: 2),
        Text(
          label,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 8,
            fontWeight: FontWeight.bold,
            color: AppColors.medievalText,
          ),
        ),
      ],
    );
  }
}
