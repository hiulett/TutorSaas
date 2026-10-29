import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/mission_providers.dart';
import '../widgets/mission_card.dart';

/// Pantalla de misiones (issue #109 · P-24).
///
/// Pestañas Diarias / Semanales. Solo se listan los tipos con flujo real
/// (`daily` y `weekly`); secretas, eventos, gremio y `secondary` quedan
/// ocultas hasta que exista un flujo (ver `MissionVisibility`).
class MissionsScreen extends ConsumerWidget {
  const MissionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.screenBg,
        body: SafeArea(
          child: Column(
            children: [
              _Header(title: l10n?.missions_title ?? 'Misiones'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TabBar(
                  indicatorColor: AppColors.manaCyan,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: AppColors.manaCyan,
                  unselectedLabelColor: AppColors.onSurfaceVariant,
                  dividerColor: Colors.transparent,
                  labelStyle: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                  ),
                  tabs: [
                    Tab(
                      text: (l10n?.missions_tab_daily ?? 'Diarias')
                          .toUpperCase(),
                    ),
                    Tab(
                      text: (l10n?.missions_tab_weekly ?? 'Semanales')
                          .toUpperCase(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _MissionTab(
                      type: 'daily',
                      emptyText:
                          l10n?.missions_empty_daily ??
                          'Aún no tienes misiones diarias. Llegan cada día a las 00:05 UTC.',
                    ),
                    _MissionTab(
                      type: 'weekly',
                      emptyText:
                          l10n?.missions_empty_weekly ??
                          'Aún no tienes misiones semanales. Se asignan con el ciclo diario de 00:05 UTC.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;

  const _Header({required this.title});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.onSurface,
            ),
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  l10n?.missions_reset_hint ??
                      'Renovación automática: 00:05 UTC',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 9,
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MissionTab extends ConsumerWidget {
  final String type;
  final String emptyText;

  const _MissionTab({required this.type, required this.emptyText});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = type == 'weekly'
        ? ref.watch(weeklyMissionsProvider)
        : ref.watch(dailyMissionsProvider);

    return async.when(
      data: (missions) {
        if (missions.isEmpty) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              GlassCard(
                blur: 20,
                opacity: AppColors.glassOpacity,
                padding: const EdgeInsets.all(20),
                child: Text(
                  emptyText,
                  style: const TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          );
        }
        return RefreshIndicator(
          color: AppColors.manaCyan,
          onRefresh: () async => ref.invalidate(activeMissionsProvider),
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            itemCount: missions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) =>
                MissionCard(mission: missions[index]),
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(
          color: AppColors.runeViolet,
          strokeWidth: 2,
        ),
      ),
      error: (error, stack) {
        debugPrint('Error cargando misiones ($type): $error');
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            GlassCard(
              blur: 20,
              opacity: AppColors.glassOpacity,
              padding: const EdgeInsets.all(20),
              onTap: () => ref.invalidate(activeMissionsProvider),
              child: Row(
                children: [
                  const Icon(
                    Icons.wifi_off_rounded,
                    color: AppColors.errorRed,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n?.missions_load_error ??
                          'No pudimos cargar tus misiones. Toca para reintentar.',
                      style: const TextStyle(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Text(
                    l10n?.missions_retry ?? 'REINTENTAR',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.manaCyan,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
