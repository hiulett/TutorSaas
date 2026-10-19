import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/app.dart';
import 'core/constants/api_constants.dart';
import 'core/utils/error_tracker.dart';

import 'core/widgets/configuration_error_widget.dart';
import 'core/theme/app_theme.dart';

void main() async {
  debugPrint('App Main: Iniciando...');
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('App Main: Widgets Binding inicializado.');

  // Issue #53: las tipografías van empaquetadas en `assets/google_fonts/`.
  // Sin esta bandera, google_fonts intenta descargarlas en el primer arranque
  // y, sin red, la excepción queda sin manejar (además de renderizar con la
  // fuente del sistema).
  GoogleFonts.config.allowRuntimeFetching = false;

  // Initialize Error Tracking & Analytics
  await ErrorTracker.init();
  debugPrint('App Main: Error Tracker inicializado.');

  String? initError;

  try {
    debugPrint('App Main: Inicializando Supabase...');
    if (ApiConstants.supabaseUrl.contains('placeholder')) {
      throw 'URL de Supabase no configurada (valor placeholder)';
    }

    await Supabase.initialize(
      url: ApiConstants.supabaseUrl,
      publishableKey: ApiConstants.supabaseAnonKey,
    );
    debugPrint('App Main: Supabase inicializado correctamente.');
  } catch (e, stack) {
    debugPrint('App Main: ERROR en Supabase: $e');
    initError = e.toString();
    ErrorTracker.logError('App Init Failed: $initError', stackTrace: stack);
  }

  if (initError != null) {
    runApp(MaterialApp(
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: ConfigurationErrorWidget(error: initError),
    ));
    return;
  }

  // Issue #44: se eliminó el "benchmark" de latencia simulado (4 Future.delayed
  // con éxito hardcodeado). No medía nada real y arrancaba un isolate inútil.

  runApp(
    const ProviderScope(
      child: TutorSaaSApp(),
    ),
  );
}
