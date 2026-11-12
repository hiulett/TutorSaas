import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/glass_card.dart';

/// Cabecera de escena de la conversación: el NPC como personaje, no como
/// avatar diminuto.
///
/// Composición (de arriba abajo, todo dentro de un [GlassCard]):
/// - fila superior: volver (izquierda), nameplate `NOMBRE · NPC LV.n`, chip
///   `EN VIVO` y repetir audio del NPC (derecha);
/// - retrato enmarcado en cian (radio 4) a la izquierda y, a su derecha,
///   título del escenario (2 líneas máx.), nivel CEFR, `n/m OBJETIVOS` y una
///   barra fina de progreso.
///
/// Presupuesto de alto: ~176 dp con `textScaler` 1.0 y por debajo de 200 dp
/// con 1.3. El widget no crea animaciones propias (ni periódicas ni de bucle):
/// el punto de `EN VIVO` es estático para respetar la reducción de movimiento
/// del sistema y no dejar `Ticker`s vivos.
class ConversationSceneHeader extends StatelessWidget {
  const ConversationSceneHeader({
    super.key,
    required this.title,
    required this.level,
    required this.npcName,
    this.npcLevel,
    this.avatarAsset = 'assets/images/avatars/oracle_01.webp',
    this.progress,
    this.completedGoals = 0,
    this.totalGoals = 0,
    this.onReplay,
    this.onExit,
  });

  /// Título del escenario (p. ej. «Ordering coffee at a cafe»).
  final String title;

  /// Nivel CEFR del escenario (p. ej. «A1»).
  final String level;

  /// Nombre o rol del NPC (p. ej. «BARISTA»).
  final String npcName;

  /// Etiqueta de nivel del NPC (p. ej. «LV.12»). Si ya empieza por «NPC» se
  /// usa tal cual.
  final String? npcLevel;

  /// Retrato del NPC.
  final String avatarAsset;

  /// Progreso de la misión, 0..1. Si es `null` se deriva de
  /// [completedGoals] / [totalGoals]; sin objetivos no se pinta la barra.
  final double? progress;

  /// Objetivos completados (para `n/m OBJETIVOS`).
  final int completedGoals;

  /// Objetivos totales de la escena.
  final int totalGoals;

  /// Repite el audio del NPC.
  final VoidCallback? onReplay;

  /// Vuelve atrás.
  final VoidCallback? onExit;

  /// Retrato: suficientemente grande para leerse como personaje sin romper el
  /// presupuesto de alto de la cabecera.
  static const double _portraitWidth = 40;
  static const double _portraitHeight = 48;

  String get _semanticLabel =>
      'Escena: ${title.trim().isEmpty ? 'conversación' : title.trim()}';

  /// `BARISTA · NPC LV.12`; si no hay nivel, solo el nombre.
  String get _nameplateLabel {
    final name = npcName.trim().toUpperCase();
    final base = name.isEmpty ? 'NPC' : name;
    final rawLevel = npcLevel?.trim() ?? '';
    if (rawLevel.isEmpty) return base;
    final upperLevel = rawLevel.toUpperCase();
    final levelLabel = upperLevel.startsWith('NPC')
        ? upperLevel
        : 'NPC $upperLevel';
    return '$base · $levelLabel';
  }

  String get _levelLabel {
    final value = level.trim().toUpperCase();
    return value.isEmpty ? '—' : value;
  }

  double? get _resolvedProgress {
    final requested = progress;
    if (requested != null) {
      if (requested.isNaN || requested.isInfinite) return 0.0;
      return requested.clamp(0.0, 1.0).toDouble();
    }
    if (totalGoals <= 0) return null;
    return (completedGoals / totalGoals).clamp(0.0, 1.0).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final progressValue = _resolvedProgress;
    final exit = onExit;
    final replay = onReplay;
    return GlassCard(
      key: const Key('conversation-scene-header'),
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
      border: Border.all(color: AppColors.manaCyan.withValues(alpha: 0.32)),
      semanticLabel: _semanticLabel,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Una sola fila: antes había nameplate arriba y retrato 100x120
          // debajo, lo que se comía ~25 % de la pantalla antes del primer
          // mensaje. Ahora el retrato va en línea a 40x48.
          Row(
            children: [
              if (exit != null) ...[
                _SceneIconButton(
                  key: const Key('conversation-scene-exit'),
                  icon: Icons.arrow_back_rounded,
                  tooltip: 'Volver',
                  color: Colors.white70,
                  onTap: exit,
                ),
                const SizedBox(width: 6),
              ],
              _buildPortrait(),
              const SizedBox(width: 8),
              Expanded(child: _buildMissionSummary()),
              const SizedBox(width: 4),
              _buildLiveChip(),
              if (replay != null) ...[
                const SizedBox(width: 2),
                _SceneIconButton(
                  key: const Key('conversation-scene-replay'),
                  icon: Icons.replay_rounded,
                  tooltip: 'Repetir audio del NPC',
                  color: AppColors.manaCyan,
                  onTap: replay,
                ),
              ],
            ],
          ),
          if (progressValue != null) ...[
            const SizedBox(height: 6),
            _buildProgressBar(progressValue),
          ],
        ],
      ),
    );
  }

  // ── Nameplate compacto (línea 2 del resumen) ───────────────────────────

  Widget _buildNameplate() {
    return Container(
      key: const Key('conversation-scene-nameplate'),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: AppColors.surfaceDeep.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.manaCyan.withValues(alpha: 0.45)),
      ),
      // El `Flexible` de dentro es lo que permite elipsis cuando el nombre es
      // largo: un `Row` con hijos no flexibles daría ancho infinito al `Text`.
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.badge_outlined,
            color: AppColors.manaCyanDim,
            size: 10,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              _nameplateLabel,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 8.5,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.7,
                color: AppColors.manaCyanText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveChip() {
    return Container(
      key: const Key('conversation-scene-live'),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.emeraldGreen.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.emeraldGreen.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.emeraldGreen,
              boxShadow: [
                BoxShadow(
                  color: AppColors.emeraldGreen.withValues(alpha: 0.7),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'EN VIVO',
            maxLines: 1,
            softWrap: false,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 8.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              color: AppColors.emeraldGreen,
            ),
          ),
        ],
      ),
    );
  }

  // ── Retrato ────────────────────────────────────────────────────────────

  Widget _buildPortrait() {
    return SizedBox(
      key: const Key('conversation-scene-portrait'),
      width: _portraitWidth,
      height: _portraitHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.monsterPillBg,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: AppColors.manaCyan.withValues(alpha: 0.55)),
          boxShadow: [
            BoxShadow(
              color: AppColors.manaCyan.withValues(alpha: 0.16),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(1),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  avatarAsset,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  excludeFromSemantics: true,
                  errorBuilder: _buildPortraitFallback,
                ),
                // Scrim estático: funde el borde inferior de la imagen con la
                // tarjeta y evita que el retrato «flote» recortado.
                IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.center,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          AppColors.voidBg.withValues(alpha: 0.6),
                        ],
                      ),
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

  Widget _buildPortraitFallback(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  ) {
    debugPrint('Retrato del NPC no disponible ($avatarAsset): $error');
    return const ColoredBox(
      color: AppColors.monsterPillBg,
      child: Center(
        child: Icon(
          Icons.person_rounded,
          color: AppColors.manaCyanDim,
          size: 30,
        ),
      ),
    );
  }

  // ── Resumen de misión (debajo del nameplate, a la derecha del retrato) ─

  Widget _buildMissionSummary() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  title,
                  key: const Key('conversation-scene-title'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                    letterSpacing: 0.2,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            _buildLevelChip(),
          ],
        ),
        const SizedBox(height: 3),
        Row(
          children: [
            Flexible(child: _buildNameplate()),
            if (totalGoals > 0) ...[
              const SizedBox(width: 6),
              Flexible(child: _buildGoalsLabel()),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildLevelChip() {
    return Container(
      key: const Key('conversation-scene-level'),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.royalGold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.royalGold.withValues(alpha: 0.5)),
      ),
      child: Text(
        _levelLabel,
        maxLines: 1,
        softWrap: false,
        style: GoogleFonts.jetBrainsMono(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
          color: AppColors.royalGoldLight,
        ),
      ),
    );
  }

  Widget _buildGoalsLabel() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.flag_rounded, size: 10, color: AppColors.emeraldGreen),
        const SizedBox(width: 3),
        Flexible(
          child: Text(
            '$completedGoals/$totalGoals OBJETIVOS',
            key: const Key('conversation-scene-goals'),
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  /// Barra fina y estática (sin `LinearProgressIndicator`: evita cualquier
  /// animación implícita y respeta el presupuesto de alto).
  Widget _buildProgressBar(double value) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final fillWidth = constraints.maxWidth * value;
          return Stack(
            children: [
              Container(height: 5, color: AppColors.surfaceContainerHigh),
              Container(
                key: const Key('conversation-scene-progress'),
                width: fillWidth,
                height: 5,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.manaCyan, AppColors.emeraldGreen],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Control cuadrado y discreto de la cabecera.
///
/// Se construye con [InkResponse] en lugar de `IconButton` para fijar un lado
/// exacto: el botón de material añade relleno y un área táctil mínima de 48 dp
/// que no caben en el presupuesto de alto de esta cabecera.
///
/// Nota de accesibilidad: 30 dp supera el mínimo de 24 dp de WCAG 2.2 (2.5.8)
/// pero queda por debajo de los 48 dp de UX-03. Subir [_size] a 48 cumple UX-03
/// y deja la cabecera en ~194 dp (dentro del límite), a costa de recortar el
/// nameplate en anchos de 312 dp.
class _SceneIconButton extends StatelessWidget {
  const _SceneIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onTap;

  static const double _size = 30;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkResponse(
        onTap: onTap,
        containedInkWell: true,
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: SizedBox(
          width: _size,
          height: _size,
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}
