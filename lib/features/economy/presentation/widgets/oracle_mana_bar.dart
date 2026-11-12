import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/segmented_bar.dart';
import '../../../../core/widgets/animated_counter.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/models/mana_budget.dart';
import '../providers/economy_providers.dart';

/// Barra única de MANÁ (FASE B).
///
/// Saldo = asignación mensual del plan + maná comprado (porciones/gemas) − usado.
/// Toda acción IA descuenta el costo configurable (ai_action_costs); nada se
/// gana jugando. Se recarga al renovar el ciclo (expira en `expires_at`).
///
/// En el plan GRATUITO la barra refleja el MANÁ DIARIO (daily_limit=200):
/// el consumo de lecciones descuenta `daily_used` y la barra muestra lo que
/// queda del día, reiniciando cada día.
///
/// #338: el widget se monta a 150 dp de ancho en la conversación
/// (`_kConversationManaBarWidth`, `compact: true`) y sin ancho fijo en el HUD
/// del dashboard. Saldo y coste por turno son anclas intrínsecas (no se
/// comprimen ni se eliden); lo único elástico es el texto de estado (elipsis)
/// y la caducidad es lo primero que cede sitio: salta de línea en el `Wrap` y
/// solo se elide si no cabe ni en una línea entera.
class OracleManaBar extends ConsumerWidget {
  final bool showLabel;
  final bool compact;

  /// Oculta las dos líneas de detalle (saldo repetido + coste/caducidad) y
  /// deja solo la cabecera `MANÁ 16364 / 17000` con la barra. La conversación
  /// lo usa así: a pantalla completa esas dos líneas pesaban ~36 dp y
  /// repetían un dato que ya está en la cabecera.
  final bool showSubLabels;

  /// Coste de la próxima acción de IA (P-26). Permite mostrar los turnos que
  /// quedan: mazmorra 12, chat libre 8, Oráculo 15 (`ai_action_costs`).
  final int costPerTurn;

  const OracleManaBar({
    super.key,
    this.showLabel = true,
    this.compact = false,
    this.showSubLabels = true,
    this.costPerTurn = ManaBudget.defaultCostPerTurn,
  });

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    final dd = dt.day.toString().padLeft(2, '0');
    final mm = dt.month.toString().padLeft(2, '0');
    return '$dd/$mm';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final manaAsync = ref.watch(manaStateProvider);
    final mana =
        manaAsync.value ??
        const {
          'allowance': 1800,
          'purchased': 0,
          'used': 0,
          'remaining': 1800,
          'expires_at': null,
          'plan': 'Plan Gratuito',
          'is_free': true,
          'daily_limit': 200,
          'daily_used': 0,
          'daily_remaining': 200,
        };
    final bool isFree = mana['is_free'] as bool? ?? true;
    final int allowance = mana['allowance'] as int? ?? 1800;
    final int purchased = mana['purchased'] as int? ?? 0;
    final int remaining = mana['remaining'] as int? ?? 0;
    final int available = allowance + purchased;

    // Maná diario (plan free): tope diario y lo que queda hoy.
    final int dailyLimit = mana['daily_limit'] as int? ?? 200;
    final int dailyRemaining = mana['daily_remaining'] as int? ?? 0;

    final DateTime? expiresAt = mana['expires_at'] is String
        ? DateTime.tryParse(mana['expires_at'] as String)
        : null;

    // Qué muestra la barra según el plan:
    //   free  → maná diario (dailyRemaining/dailyLimit), se recarga cada día.
    //   pago  → saldo mensual (remaining/available), se recarga al renovar.
    final int barValue = isFree ? dailyRemaining : remaining;
    final int barMax = isFree ? dailyLimit : available;
    final double progress = barMax > 0
        ? (barValue / barMax).clamp(0.0, 1.0)
        : 0.0;
    final bool exhausted = barValue <= 0;

    final budget = ManaBudget.fromState(mana, costPerTurn: costPerTurn);

    final double titleSize = compact ? 9 : 10;
    final double numSize = compact ? 10 : 11;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showLabel) ...[
          Row(
            children: [
              const Icon(
                Icons.bolt_rounded,
                color: AppColors.runeViolet,
                size: 13,
              ),
              const SizedBox(width: 6),
              // #338: la etiqueta es el `Expanded` que absorbe el hueco; la
              // cifra queda intrínseca para que el saldo nunca se elida.
              // A 150 dp y escala 1.1 la fila mide ~146 px (13 de icono + 6 +
              // 28 de "MANÁ" + 8 + 91 de "16368 / 17000"): cabe.
              Expanded(
                child: Text(
                  l10n?.mana_label ?? 'MANÁ',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: titleSize,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // #338: a textScaler 2.0 la cifra no cabe junto al icono y la
              // etiqueta (36 px de overflow). Se deja encoger con
              // `FittedBox` antes que recortar el saldo: se lee más pequeño,
              // pero se lee entero.
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    '$barValue / $barMax',
                    maxLines: 1,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: numSize,
                      fontWeight: FontWeight.bold,
                      color: exhausted
                          ? AppColors.crimsonRed
                          : AppColors.runeViolet,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
        ],
        Tooltip(
          message:
              l10n?.mana_tooltip ??
              'MANÁ: energía para toda acción IA (Oráculo, mazmorras, chats). '
                  'Se adquiere con tu plan y porciones/gemas; expira con el ciclo.',
          child: SegmentedBar(
            value: progress,
            segments: compact ? 10 : 20,
            height: compact ? 5 : 7,
            color: exhausted ? AppColors.crimsonRed : AppColors.runeViolet,
          ),
        ),
        if (showLabel && showSubLabels) ...[
          const SizedBox(height: 4),
          // #338: solo quedan aquí dos piezas y no compiten: el saldo es un
          // ancla intrínseca (≈35 px a escala 1.1 con 5 dígitos, nunca se
          // comprime) y el estado es el único elástico, con elipsis.
          Row(
            children: [
              AnimatedCounter(
                target: barValue,
                duration: const Duration(milliseconds: 600),
                style: GoogleFonts.jetBrainsMono(
                  fontWeight: FontWeight.bold,
                  fontSize: numSize,
                  color: AppColors.manaCyan,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  exhausted
                      ? (l10n?.mana_empty_warning ??
                            'Sin maná para el próximo turno')
                      : budget.isLow
                      ? (l10n?.mana_low_warning(budget.turnsLeft) ??
                            'Te quedan ${budget.turnsLeft} turnos hoy')
                      : isFree
                      ? (l10n?.mana_daily_available ?? 'maná disponible hoy')
                      : (l10n?.mana_available ?? 'maná disponible'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: (exhausted || budget.isLow)
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: exhausted
                        ? AppColors.crimsonRed
                        : budget.isLow
                        ? AppColors.royalGold
                        : AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          // #338: coste por turno y caducidad bajan a una tercera línea en un
          // `Wrap` que no compite por ancho. A 150 dp caben juntos (≈128 px a
          // escala 1.1: `12/turno` + `expira 12/11`); si el hueco se estrecha,
          // la fecha salta de línea en vez de recortar el coste y solo se
          // elide cuando no cabe ni en una línea entera. El coste nunca se
          // elide: es ancla intrínseca.
          Wrap(
            spacing: 8,
            runSpacing: 2,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                l10n?.mana_cost_per_turn(budget.costPerTurn) ??
                    '${budget.costPerTurn}/turno',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: titleSize,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              if (!isFree && expiresAt != null)
                Text(
                  l10n?.mana_expires(_formatDate(expiresAt)) ??
                      'expira ${_formatDate(expiresAt)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: titleSize,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
