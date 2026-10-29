import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/dashboard_providers.dart';

/// P-27 (#112): tarjeta de retorno tras ≥3 días sin practicar.
///
/// - Recuerda en qué lección se quedó y cuántas metas le faltan.
/// - Un solo botón primario ("Continuar") y un descarte ("Ahora no").
/// - Tono positivo: no reprocha la racha perdida.
class WelcomeBackCard extends ConsumerStatefulWidget {
  const WelcomeBackCard({super.key});

  @override
  ConsumerState<WelcomeBackCard> createState() => _WelcomeBackCardState();
}

class _WelcomeBackCardState extends ConsumerState<WelcomeBackCard> {
  String _todayKey = '';
  bool _dismissedToday = false;
  bool _prefsLoaded = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _todayKey = '${now.year}-${now.month}-${now.day}';
    _loadDismissed();
  }

  Future<void> _loadDismissed() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString('welcome_back_dismissed_${user.id}');
      if (!mounted) return;
      setState(() {
        _dismissedToday = stored == _todayKey;
        _prefsLoaded = true;
      });
    } catch (e) {
      debugPrint('welcome_back prefs read failed: $e');
      if (mounted) setState(() => _prefsLoaded = true);
    }
  }

  Future<void> _dismiss() async {
    setState(() => _dismissedToday = true);
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('welcome_back_dismissed_${user.id}', _todayKey);
    } catch (e) {
      debugPrint('welcome_back prefs write failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(welcomeBackProvider).value;

    if (!_prefsLoaded || _dismissedToday) return const SizedBox.shrink();
    if (state == null || !state.shouldShow) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        borderColor: AppColors.royalGold.withValues(alpha: 0.45),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.waving_hand_rounded,
                  color: AppColors.royalGold,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n?.welcome_back_title ?? 'BIENVENIDO DE VUELTA',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: AppColors.royalGold,
                    ),
                  ),
                ),
                Text(
                  l10n?.welcome_back_days(state.daysAway) ??
                      '${state.daysAway} días',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n?.welcome_back_lesson(state.lessonTitle) ??
                  'Te quedaste en ${state.lessonTitle}',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              state.lessonCompleted
                  ? (l10n?.welcome_back_completed ??
                        'La completaste. Puedes repetirla o seguir con la siguiente.')
                  : (l10n?.welcome_back_goals(state.goalsRemaining) ??
                        'Te faltan ${state.goalsRemaining} metas'),
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            if (state.streakReset) ...[
              const SizedBox(height: 2),
              Text(
                l10n?.welcome_back_streak_reset ??
                    'Empecemos una racha nueva hoy.',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.manaCyan,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () => context.push(
                      '/conversation?scenarioId=${state.lessonId}'
                      '&scenarioTitle=${Uri.encodeComponent(state.lessonTitle)}',
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.royalGold,
                      foregroundColor: AppColors.voidBg,
                      minimumSize: const Size(48, 42),
                    ),
                    child: Text(
                      l10n?.welcome_back_continue ?? 'CONTINUAR',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: _dismiss,
                  style: TextButton.styleFrom(
                    minimumSize: const Size(48, 42),
                    foregroundColor: AppColors.onSurfaceVariant,
                  ),
                  child: Text(
                    l10n?.welcome_back_later ?? 'Ahora no',
                    style: GoogleFonts.inter(fontSize: 11),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
