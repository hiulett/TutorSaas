import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/models/learning_evidence_summary.dart';
import '../providers/dashboard_providers.dart';

/// Evidencia de aprendizaje (R3 / #74).
///
/// #314: cada dimensión es una fila con etiqueta + chip de estado explícito
/// (DOMINADO / EN DESARROLLO / SIN DATOS...). Ningún porcentaje va suelto: el
/// detalle dice sobre cuántas observaciones se calculó y, cuando el RPC lo
/// permite, la comparación real (primera → última semana).
///
/// `learning_evidence()` no devuelve rangos min/max, así que no se inventan:
/// se muestra el tamaño de muestra real (`delayed_attempts`) o el número de
/// semanas activas. Tampoco devuelve bloqueos (el desbloqueo por nivel no está
/// en este RPC), así que no se pinta un chip BLOQUEADO sin dato que lo respalde.
/// La única decisión de UI es el umbral de dominio de la retención
/// (ver [_dominatedRetentionPercent]).
class LearningEvidenceCard extends ConsumerWidget {
  const LearningEvidenceCard({super.key});

  /// Retención a 7 días desde la que la evidencia se marca como dominio.
  /// Es un umbral de presentación: no cambia el dato, solo su lectura.
  static const int _dominatedRetentionPercent = 85;

  /// Por debajo de estos repasos diferidos el porcentaje es ruido de muestra.
  static const int _minRetentionSample = 10;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(learningEvidenceProvider);
    final raw = async.value ?? const <String, dynamic>{};
    final summary = LearningEvidenceSummary.fromMap(raw);

    // Campos que ya devuelve `learning_evidence()`; solo lectura en la tarjeta.
    final int? attempts = (raw['delayed_attempts'] as num?)?.toInt();
    final int? successes = (raw['delayed_success'] as num?)?.toInt();

    final muted = GoogleFonts.inter(
      fontSize: 10,
      color: AppColors.onSurfaceVariant,
    );

    return GlassCard(
      blur: 20,
      opacity: AppColors.glassOpacity,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.insights_rounded,
                color: AppColors.manaCyan,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.evidence_title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            l10n.evidence_disclaimer,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: muted,
          ),
          const SizedBox(height: 12),
          _EvidenceRow(
            item: _retentionItem(summary, attempts, successes, l10n),
          ),
          const SizedBox(height: 10),
          _EvidenceRow(item: _progressItem(summary, l10n)),
          const SizedBox(height: 10),
          _EvidenceRow(item: _transferItem(summary, l10n)),
        ],
      ),
    );
  }

  /// Retención a 7 días. Si el RPC trae el tamaño de muestra se muestra; si
  /// no, se omite en vez de inventar un rango.
  _EvidenceItem _retentionItem(
    LearningEvidenceSummary summary,
    int? attempts,
    int? successes,
    AppLocalizations l10n,
  ) {
    if (!summary.hasRetention) {
      return _EvidenceItem(
        icon: Icons.school_rounded,
        label: l10n.evidence_retention,
        detail: l10n.evidence_no_data,
        state: _EvidenceState.noData,
      );
    }

    final int percent = summary.retentionPercent!;
    final String sample = attempts == null
        ? ''
        : successes == null
        ? '$attempts repasos a 7+ días'
        : '$successes/$attempts repasos a 7+ días';

    return _EvidenceItem(
      icon: Icons.school_rounded,
      label: l10n.evidence_retention,
      detail: sample.isEmpty ? '$percent%' : '$percent% · $sample',
      state: attempts != null && attempts < _minRetentionSample
          ? _EvidenceState.smallSample
          : percent >= _dominatedRetentionPercent
          ? _EvidenceState.dominated
          : _EvidenceState.developing,
    );
  }

  /// Progreso comparable: primera vs última semana, con las semanas reales.
  _EvidenceItem _progressItem(
    LearningEvidenceSummary summary,
    AppLocalizations l10n,
  ) {
    if (!summary.hasComparableProgress) {
      final String weeks = summary.weeksActive == 1
          ? '1 semana activa'
          : '${summary.weeksActive} semanas activas';
      return _EvidenceItem(
        icon: Icons.trending_up_rounded,
        label: l10n.evidence_progress,
        // Semanas reales para decir cuánto falta, sin inventar ceros.
        detail: summary.weeksActive > 0
            ? '${l10n.evidence_needs_weeks} · $weeks'
            : l10n.evidence_no_data,
        state: _EvidenceState.noData,
      );
    }

    final int first = summary.firstWeekCompleted!;
    final int last = summary.lastWeekCompleted!;
    final int delta = last - first;
    final String deltaText = delta > 0 ? '+$delta' : '$delta';

    return _EvidenceItem(
      icon: Icons.trending_up_rounded,
      label: l10n.evidence_progress,
      detail: '${l10n.evidence_progress_value(first, last)} · $deltaText',
      state: delta > 0
          ? _EvidenceState.developing
          : delta == 0
          ? _EvidenceState.stable
          : _EvidenceState.needsReview,
    );
  }

  /// Transferencia: tipos de misión con ≥2 plantillas distintas completadas.
  _EvidenceItem _transferItem(
    LearningEvidenceSummary summary,
    AppLocalizations l10n,
  ) {
    if (!summary.hasTransfer) {
      return _EvidenceItem(
        icon: Icons.swap_horiz_rounded,
        label: l10n.evidence_transfer,
        detail: l10n.evidence_no_data,
        state: _EvidenceState.noData,
      );
    }

    return _EvidenceItem(
      icon: Icons.swap_horiz_rounded,
      label: l10n.evidence_transfer,
      detail: l10n.evidence_transfer_value(summary.transferTypes),
      state: summary.transferTypes >= 2
          ? _EvidenceState.dominated
          : _EvidenceState.developing,
    );
  }
}

/// Estado de una dimensión. El vocabulario es explícito: nunca "un porcentaje
/// suelto" sin decir si es dominio, desarrollo, muestra o ausencia de datos.
enum _EvidenceState {
  dominated,
  developing,
  stable,
  needsReview,
  smallSample,
  noData,
}

extension _EvidenceStateStyle on _EvidenceState {
  String get chip => switch (this) {
    _EvidenceState.dominated => 'DOMINADO',
    _EvidenceState.developing => 'EN DESARROLLO',
    _EvidenceState.stable => 'ESTABLE',
    _EvidenceState.needsReview => 'A REVISAR',
    _EvidenceState.smallSample => 'MUESTRA PEQUEÑA',
    _EvidenceState.noData => 'SIN DATOS',
  };

  Color get color => switch (this) {
    _EvidenceState.dominated => AppColors.emeraldGreen,
    _EvidenceState.developing => AppColors.royalGold,
    _EvidenceState.stable => AppColors.manaCyan,
    _EvidenceState.needsReview => AppColors.crimsonRed,
    _EvidenceState.smallSample => AppColors.runeViolet,
    _EvidenceState.noData => AppColors.onSurfaceVariant,
  };
}

class _EvidenceItem {
  const _EvidenceItem({
    required this.icon,
    required this.label,
    required this.detail,
    required this.state,
  });

  final IconData icon;
  final String label;
  final String detail;
  final _EvidenceState state;
}

class _EvidenceRow extends StatelessWidget {
  const _EvidenceRow({required this.item});

  final _EvidenceItem item;

  @override
  Widget build(BuildContext context) {
    final color = item.state.color;
    // A 2.0x el chip no cabe junto a la etiqueta en 232 dp útiles (312 dp - 48
    // de márgenes - 32 de padding): se apila debajo en vez de recortar texto.
    final bool stacked = MediaQuery.textScalerOf(context).scale(1) >= 1.6;
    final chip = _StatusChip(state: item.state);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(item.icon, size: 14, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                item.label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                  height: 1.25,
                ),
              ),
            ),
            if (!stacked) ...[const SizedBox(width: 6), chip],
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 22, top: 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (stacked) ...[chip, const SizedBox(height: 4)],
              Text(
                item.detail,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 9,
                  color: AppColors.onSurfaceVariant,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.state});

  final _EvidenceState state;

  @override
  Widget build(BuildContext context) {
    final color = state.color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: color.withValues(alpha: 0.55)),
      ),
      child: Text(
        state.chip,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.jetBrainsMono(
          fontSize: 8,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.6,
          color: color,
          height: 1.2,
        ),
      ),
    );
  }
}
