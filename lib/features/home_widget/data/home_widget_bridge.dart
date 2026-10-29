import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import '../domain/models/home_widget_snapshot.dart';

/// Puente entre Dart y el widget nativo de pantalla de inicio (P-36 / #121).
///
/// El widget solo lee `SharedPreferences` (lo que escribe `home_widget`) y se
/// repinta con `updatePeriodMillis` o con los avisos programados. Nunca abre la
/// app para refrescarse.
abstract class HomeWidgetBridge {
  /// Publica [snapshot] y repinta el widget.
  Future<void> save(HomeWidgetSnapshot snapshot);

  /// Programa repintados en las próximas medianoches para que el widget pase a
  /// su estado vacío al cambiar de día aunque la app no se abra.
  Future<void> scheduleDayRollovers(DateTime now, {int days});
}

class HomeWidgetBridgeImpl implements HomeWidgetBridge {
  const HomeWidgetBridgeImpl();

  /// Nombre de la clase Kotlin; `home_widget` lo resuelve contra el
  /// `applicationId` (`com.tutorsaas.tutorsaas.DungeonWidgetProvider`).
  static const String androidProvider = 'DungeonWidgetProvider';

  /// Dos semanas cubren un usuario que no abre la app en varios días. Al abrir
  /// la app se vuelve a programar la ventana desde hoy.
  static const int dayRolloverHorizon = 14;

  @override
  Future<void> save(HomeWidgetSnapshot snapshot) async {
    if (!Platform.isAndroid) return;
    try {
      final data = snapshot.toWidgetData();
      await Future.wait(
        data.entries.map(
          (entry) => HomeWidget.saveWidgetData<Object>(entry.key, entry.value),
        ),
      );
      await HomeWidget.updateWidget(androidName: androidProvider);
    } catch (e) {
      debugPrint(
        'HomeWidgetBridge: no se pudo guardar el estado del widget: $e',
      );
    }
  }

  @override
  Future<void> scheduleDayRollovers(
    DateTime now, {
    int days = dayRolloverHorizon,
  }) async {
    if (!Platform.isAndroid) return;
    try {
      final times = <DateTime>[
        for (var day = 1; day <= days; day++)
          DateTime(now.year, now.month, now.day + day),
      ];
      await HomeWidget.scheduleWidgetUpdates(
        times,
        androidName: androidProvider,
      );
    } catch (e) {
      debugPrint(
        'HomeWidgetBridge: no se pudo programar el cambio de día del widget: $e',
      );
    }
  }
}
