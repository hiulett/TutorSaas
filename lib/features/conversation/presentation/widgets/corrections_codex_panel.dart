// Códice de correcciones — registro aparte del chat.
//
// Referencias de diseño:
// - docs/product-audit/stitch/stitch_chat_c.png: timeline `TURNO n · TIPO`,
//   `ERR:` tachado y `FIX:` en oro.
// - docs/product-audit/stitch/stitch_chat_b.png: panel «REGISTRO DE
//   CORRECCIONES» con contador.
//
// El mock pinta además un EXP por turno (`+15 MANA EXP`); `TurnCorrection` no
// expone esa cifra, así que aquí no se inventa.
//
// Sin estado ni animaciones: es un `StatelessWidget` que solo compone
// `Container`/`Text`, así que puede vivir en una hoja o en un panel lateral
// sin añadir `Ticker`s en bucle.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../corrections/domain/models/turn_correction.dart';

/// Registro «códice» de las correcciones de la sesión, agrupadas por turno.
///
/// A diferencia de `CorrectionChip` (una píldora bajo la burbuja), aquí el
/// alumno revisa la sesión completa. [level] se aplica **por turno** mediante
/// `correctionsForLevel`, igual que en el chip: aplicarlo a la lista completa
/// dejaría el códice con una sola fila, porque ese helper recorta a 1–3
/// correcciones. El nivel también decide si se muestra `explanation`.
///
/// El panel crece con el contenido ([Column] sin scroll): el padre debe
/// darle un alto acotado o un `ScrollView`.
class CorrectionsCodexPanel extends StatelessWidget {
  const CorrectionsCodexPanel({
    super.key,
    required this.corrections,
    required this.level,
  });

  /// Correcciones de la sesión, en orden de registro.
  final List<TurnCorrection> corrections;

  /// Valor de `user_settings.correction_level`
  /// (ver `normalizeCorrectionLevel`).
  final String level;

  @override
  Widget build(BuildContext context) {
    final sections = _buildSections(corrections, level);
    final visibleCount = sections.fold<int>(
      0,
      (total, section) => total + section.corrections.length,
    );
    final showExplanation = showsCorrectionExplanation(level);
    final tickColor = AppColors.medievalAgedGold.withValues(alpha: 0.55);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.medievalBg,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: AppColors.medievalAgedGold.withValues(alpha: 0.3),
        ),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(count: visibleCount),
                const SizedBox(height: 10),
                Container(
                  height: 1,
                  color: AppColors.medievalAgedGold.withValues(alpha: 0.16),
                ),
                const SizedBox(height: 10),
                if (sections.isEmpty)
                  _EmptyState(
                    message: corrections.isEmpty
                        ? 'Aún no hay correcciones en esta sesión'
                        : 'Sin correcciones visibles con tu nivel actual',
                  )
                else
                  for (var index = 0; index < sections.length; index++)
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: index == sections.length - 1 ? 0 : 10,
                      ),
                      child: _TurnTimeline(
                        section: sections[index],
                        isLast: index == sections.length - 1,
                        showExplanation: showExplanation,
                      ),
                    ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: _CornerTick(color: tickColor, top: true, left: true),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: _CornerTick(color: tickColor, top: true, left: false),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: _CornerTick(color: tickColor, top: false, left: true),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: _CornerTick(color: tickColor, top: false, left: false),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Encabezado y contador
// ─────────────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.royalGold.withValues(alpha: 0.08),
            borderRadius: AppRadius.card,
            border: Border.all(
              color: AppColors.royalGold.withValues(alpha: 0.3),
            ),
          ),
          child: const Icon(
            Icons.auto_stories_rounded,
            size: 16,
            color: AppColors.royalGold,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CÓDIGO DE ERRORES',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 15,
                  height: 1.1,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  color: AppColors.medievalText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'REGISTRO DE LA SESIÓN',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 8,
                  height: 1.2,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.6,
                  color: AppColors.medievalTextDim,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _CountChip(count: count),
      ],
    );
  }
}

class _CountChip extends StatelessWidget {
  const _CountChip({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: count == 1 ? '1 corrección' : '$count correcciones',
      child: ExcludeSemantics(
        child: Container(
          key: const Key('corrections-codex-count'),
          constraints: const BoxConstraints(minWidth: 26),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.runeViolet.withValues(alpha: 0.16),
            borderRadius: AppRadius.card,
            border: Border.all(
              color: AppColors.runeViolet.withValues(alpha: 0.45),
            ),
          ),
          child: Text(
            '$count',
            maxLines: 1,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              height: 1.2,
              fontWeight: FontWeight.w700,
              color: AppColors.runeVioletText,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Timeline por turno
// ─────────────────────────────────────────────────────────────────────────────

class _TurnTimeline extends StatelessWidget {
  const _TurnTimeline({
    required this.section,
    required this.isLast,
    required this.showExplanation,
  });

  final _TurnSection section;
  final bool isLast;
  final bool showExplanation;

  @override
  Widget build(BuildContext context) {
    final accent = _visualFor(section.corrections.first.type).accent;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 12,
            child: Column(
              children: [
                const SizedBox(height: 9),
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent,
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.45),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1,
                      color: AppColors.outlineVariant.withValues(alpha: 0.35),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _TurnCard(
              section: section,
              showExplanation: showExplanation,
            ),
          ),
        ],
      ),
    );
  }
}

class _TurnCard extends StatelessWidget {
  const _TurnCard({required this.section, required this.showExplanation});

  final _TurnSection section;
  final bool showExplanation;

  @override
  Widget build(BuildContext context) {
    final distinctTypes = <CorrectionType>[];
    for (final correction in section.corrections) {
      if (!distinctTypes.contains(correction.type)) {
        distinctTypes.add(correction.type);
      }
    }
    final accent = _visualFor(distinctTypes.first).accent;

    return Container(
      key: ValueKey('corrections-codex-turn-${section.number}'),
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 9),
      decoration: BoxDecoration(
        color: AppColors.medievalStone.withValues(alpha: 0.55),
        borderRadius: AppRadius.card,
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'TURNO ${section.number}',
                maxLines: 1,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 9.5,
                  height: 1.2,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: AppColors.medievalTextDim,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    for (final type in distinctTypes)
                      _TypeChip(visual: _visualFor(type)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          for (var index = 0; index < section.corrections.length; index++) ...[
            if (index > 0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: Container(
                  height: 1,
                  color: AppColors.onSurface.withValues(alpha: 0.06),
                ),
              ),
            _CorrectionBlock(
              correction: section.corrections[index],
              showExplanation: showExplanation,
            ),
          ],
        ],
      ),
    );
  }
}

class _CorrectionBlock extends StatelessWidget {
  const _CorrectionBlock({
    required this.correction,
    required this.showExplanation,
  });

  final TurnCorrection correction;
  final bool showExplanation;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'ERR: ',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 9,
                  height: 1.3,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: AppColors.medievalTextDim,
                ),
              ),
              TextSpan(
                text: correction.original,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  height: 1.35,
                  color: AppColors.medievalTextDim,
                  decoration: TextDecoration.lineThrough,
                  decorationColor: AppColors.medievalTextDim,
                ),
              ),
            ],
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 3),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'FIX: ',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 9,
                  height: 1.3,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: AppColors.royalGold,
                ),
              ),
              TextSpan(
                text: correction.corrected,
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                  color: AppColors.royalGold,
                ),
              ),
            ],
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (showExplanation && correction.explanation.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            correction.explanation,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 11,
              height: 1.35,
              color: AppColors.medievalText,
            ),
          ),
        ],
      ],
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.visual});

  final _TypeVisual visual;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: visual.accent.withValues(alpha: 0.14),
        borderRadius: AppRadius.card,
        border: Border.all(color: visual.accent.withValues(alpha: 0.45)),
      ),
      child: Text(
        visual.label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.jetBrainsMono(
          fontSize: 8.5,
          height: 1.2,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          color: visual.onAccent,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Estado vacío y adornos
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('corrections-codex-empty'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.medievalStone.withValues(alpha: 0.6),
              borderRadius: AppRadius.card,
              border: Border.all(
                color: AppColors.royalGold.withValues(alpha: 0.2),
              ),
            ),
            child: Icon(
              Icons.auto_stories_rounded,
              size: 22,
              color: AppColors.royalGold.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 12,
              height: 1.4,
              color: AppColors.medievalTextDim,
            ),
          ),
        ],
      ),
    );
  }
}

/// Esquina de marco («códice»): dos lados de 1.5 px, sin animación.
class _CornerTick extends StatelessWidget {
  const _CornerTick({
    required this.color,
    required this.top,
    required this.left,
  });

  final Color color;
  final bool top;
  final bool left;

  @override
  Widget build(BuildContext context) {
    final side = BorderSide(color: color, width: 1.5);
    return IgnorePointer(
      child: SizedBox(
        width: 10,
        height: 10,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              top: top ? side : BorderSide.none,
              bottom: top ? BorderSide.none : side,
              left: left ? side : BorderSide.none,
              right: left ? BorderSide.none : side,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Agrupación y estilo de tipo
// ─────────────────────────────────────────────────────────────────────────────

class _TurnSection {
  const _TurnSection({required this.number, required this.corrections});

  /// Ordinal del turno dentro de este registro (1-based).
  final int number;
  final List<TurnCorrection> corrections;
}

/// Agrupa por turno y aplica el nivel de corrección a cada grupo.
///
/// El modelo no guarda el número de turno de la sesión: `turnRef` es opaco
/// (`<conversationId>_<millis>`), así que «TURNO n» es el ordinal del turno
/// dentro de este registro. Sin `turnRef` se agrupa por `messageText` (el
/// mensaje del alumno identifica el turno) y, en último caso, cada corrección
/// queda como entrada propia.
List<_TurnSection> _buildSections(List<TurnCorrection> source, String level) {
  final buckets = <String, List<TurnCorrection>>{};
  final order = <String>[];
  var anonymous = 0;

  for (final correction in source) {
    final turnRef = correction.turnRef?.trim() ?? '';
    final messageText = correction.messageText.trim();
    final String key;
    if (turnRef.isNotEmpty) {
      key = 'turn:$turnRef';
    } else if (messageText.isNotEmpty) {
      key = 'message:$messageText';
    } else {
      key = 'item:$anonymous';
      anonymous++;
    }

    final bucket = buckets[key];
    if (bucket != null) {
      bucket.add(correction);
      continue;
    }
    buckets[key] = <TurnCorrection>[correction];
    order.add(key);
  }

  final sections = <_TurnSection>[];
  for (final key in order) {
    final visible = correctionsForLevel(buckets[key]!, level);
    if (visible.isEmpty) continue;
    sections.add(
      _TurnSection(number: sections.length + 1, corrections: visible),
    );
  }
  return sections;
}

class _TypeVisual {
  const _TypeVisual({
    required this.label,
    required this.accent,
    required this.onAccent,
  });

  final String label;
  final Color accent;
  final Color onAccent;
}

/// Mismos acentos que `_colorFor` de «Mis errores»: un tipo de error se ve
/// igual en toda la app.
_TypeVisual _visualFor(CorrectionType type) {
  switch (type) {
    case CorrectionType.grammar:
      return const _TypeVisual(
        label: 'GRAMÁTICA',
        accent: AppColors.manaCyan,
        onAccent: AppColors.manaCyan,
      );
    case CorrectionType.vocabulary:
      return const _TypeVisual(
        label: 'VOCABULARIO',
        accent: AppColors.runeViolet,
        onAccent: AppColors.runeVioletText,
      );
    case CorrectionType.wordChoice:
      return const _TypeVisual(
        label: 'ELECCIÓN DE PALABRA',
        accent: AppColors.royalGold,
        onAccent: AppColors.royalGoldLight,
      );
    case CorrectionType.pronunciationHint:
      return const _TypeVisual(
        label: 'PRONUNCIACIÓN',
        accent: AppColors.emeraldGreen,
        onAccent: AppColors.emeraldGreen,
      );
    case CorrectionType.typoStt:
      return const _TypeVisual(
        label: 'TRANSCRIPCIÓN',
        accent: AppColors.outline,
        onAccent: AppColors.onSurfaceVariant,
      );
  }
}
