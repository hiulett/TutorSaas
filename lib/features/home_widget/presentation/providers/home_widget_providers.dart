import 'dart:async';
import 'dart:io';
import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

import '../../../../core/i18n/language_settings.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../dashboard/domain/models/daily_goal_progress.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../data/home_widget_bridge.dart';
import '../../domain/models/home_widget_launch.dart';
import '../../domain/models/home_widget_snapshot.dart';

final homeWidgetBridgeProvider = Provider<HomeWidgetBridge>((ref) {
  return const HomeWidgetBridgeImpl();
});

/// Textos del widget en el idioma de la app (no en el del sistema): el widget
/// vive fuera de Flutter, así que se guardan ya resueltos.
HomeWidgetLabels homeWidgetLabelsFor(String languageCode) {
  final code = supportedUiLanguages.contains(languageCode)
      ? languageCode
      : 'es';
  final l10n = lookupAppLocalizations(Locale(code));
  return HomeWidgetLabels(
    streakLabel: l10n.widget_streak_label,
    minutesLabel: l10n.widget_minutes_label,
    minutesUnit: l10n.widget_minutes_unit,
    practice: l10n.widget_practice,
    emptyTitle: l10n.widget_empty_title,
    emptyBody: l10n.widget_empty_body,
  );
}

final homeWidgetLabelsProvider = Provider<HomeWidgetLabels>((ref) {
  return homeWidgetLabelsFor(ref.watch(effectiveUiLanguageProvider));
});

/// Ruta pedida por el último toque en el widget (la consume `TutorSaaSApp`,
/// que es quien tiene el `GoRouter`).
final homeWidgetTapRouteProvider = StateProvider<String?>((ref) => null);

class HomeWidgetSync {
  HomeWidgetSync(this._ref);

  final Ref _ref;

  /// Publica la foto actual. `null` significa "sin datos": sesión cerrada o la
  /// meta diaria aún no respondió. Nunca se inventan ceros.
  Future<void> publish(DailyGoalProgress? progress) async {
    final now = DateTime.now();
    final labels = _ref.read(homeWidgetLabelsProvider);
    final bridge = _ref.read(homeWidgetBridgeProvider);
    final snapshot = progress == null
        ? HomeWidgetSnapshot.empty(labels: labels, now: now)
        : HomeWidgetSnapshot.fromProgress(
            progress: progress,
            labels: labels,
            now: now,
          );
    await bridge.save(snapshot);
    await bridge.scheduleDayRollovers(now);
  }
}

/// Mantiene el widget alineado con la meta diaria del servidor.
///
/// Se dispara en el arranque, tras cerrar una sesión de práctica (el dashboard
/// invalida la meta) y al cerrar sesión (el provider de meta pasa a `null`).
/// No abre la app ni mantiene un isolate: solo escribe datos y repinta.
final homeWidgetSyncProvider = Provider<void>((ref) {
  if (!Platform.isAndroid) return;
  final sync = HomeWidgetSync(ref);
  ref.listen<AsyncValue<DailyGoalProgress?>>(dailyGoalProgressProvider, (
    previous,
    next,
  ) {
    next.when(
      data: (progress) => unawaited(sync.publish(progress)),
      loading: () {},
      error: (error, stackTrace) {
        debugPrint(
          'HomeWidgetSync: sin meta diaria, el widget queda vacío: $error',
        );
        unawaited(sync.publish(null));
      },
    );
  }, fireImmediately: true);
});

/// Escucha los toques del widget: botón "Practicar" → `/conversation`, resto
/// del widget → `/home`.
final homeWidgetTapSyncProvider = Provider<void>((ref) {
  if (!Platform.isAndroid) return;
  final notifier = ref.read(homeWidgetTapRouteProvider.notifier);

  void handle(Uri? uri) {
    final route = HomeWidgetLaunch.routeFor(uri);
    if (route == null) return;
    notifier.state = route;
  }

  unawaited(() async {
    try {
      handle(await HomeWidget.initiallyLaunchedFromHomeWidget());
    } catch (e) {
      debugPrint('HomeWidgetTap: no se pudo leer el arranque del widget: $e');
    }
  }());

  final subscription = HomeWidget.widgetClicked.listen(
    handle,
    onError: (Object error) {
      debugPrint('HomeWidgetTap: error del canal del widget: $error');
    },
  );
  ref.onDispose(subscription.cancel);
});
