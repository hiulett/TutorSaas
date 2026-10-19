# Implementación en Flutter de la Internacionalización

> Documento de diseño de implementación. Complementa `02_Architecture.md` (patrón objetivo) y `03_Database_Changes.md` (migración DB).
> No modifica código: contiene **pseudo-código Dart** orientativo que debe adaptarse al estilo real del proyecto.

---

## 0. Resumen de los cambios

| # | Componente | Archivo actual | Cambio |
|---|---|---|---|
| a | Detección del dispositivo | `lib/core/i18n/language_settings.dart` | `deviceLocaleProvider` |
| b | Modelo `UserLanguageSettings` | `lib/core/i18n/language_settings.dart` | campo `followDeviceLanguage` |
| c | Resolución del locale | `lib/app/app.dart` | usar `effectiveUiLanguageProvider` |
| d | Sección "Language" | `lib/features/dashboard/presentation/screens/settings_screen.dart` | switch + selector |
| e | Sincronización al arrancar | `lib/core/i18n/language_settings.dart` | `_syncFromSupabase()` |
| f | Actualización dinámica | `lib/app/app.dart` | `locale` reactivo (Riverpod) |

---

## (a) Detección del idioma del dispositivo

Fuente: `PlatformDispatcher.instance.locale` — no requiere `context` y expone el locale del SO.

```dart
// lib/core/i18n/language_settings.dart (añadir)

import 'dart:ui';

/// Locales con ARB disponible. Fuente única para normalizar.
const List<String> kSupportedUiLocales = ['es', 'en', 'pt'];

/// Normaliza un código de idioma de dispositivo a una locale soportada.
/// Fallback a 'es' si no está soportada (coincide con default del modelo).
String normalizeUiLocale(String? code) {
  if (code == null) return 'es';
  final lower = code.toLowerCase();
  return kSupportedUiLocales.contains(lower) ? lower : 'es';
}

/// Idioma del dispositivo, normalizado. Independiente de preferencias.
final deviceLocaleProvider = Provider<String>((ref) {
  return normalizeUiLocale(PlatformDispatcher.instance.locale.languageCode);
});
```

> Para testear: `PlatformDispatcher` puede falsearse con un `FakePlatformDispatcher` (vía `TestWidgetsFlutterBinding`) — se recomienda inyectar el dispatcher si se quiere unit-testing (la arquitectura objetivo lo lista en `02_Architecture.md` §4.2).

---

## (b) `followDeviceLanguage` en `UserLanguageSettings`

Se extiende el modelo, prefs, `toJson` y `copyWith`:

```dart
class UserLanguageSettings {
  final String uiLanguage;
  final String learningLanguage;
  final bool aiExplanationsInNative;
  final bool followDeviceLanguage;          // NUEVO

  const UserLanguageSettings({
    this.uiLanguage = 'es',
    this.learningLanguage = 'en',
    this.aiExplanationsInNative = true,
    this.followDeviceLanguage = true,       // NUEVO default: seguir dispositivo
  });

  UserLanguageSettings copyWith({
    String? uiLanguage,
    String? learningLanguage,
    bool? aiExplanationsInNative,
    bool? followDeviceLanguage,
  }) => UserLanguageSettings(
    uiLanguage: uiLanguage ?? this.uiLanguage,
    learningLanguage: learningLanguage ?? this.learningLanguage,
    aiExplanationsInNative: aiExplanationsInNative ?? this.aiExplanationsInNative,
    followDeviceLanguage: followDeviceLanguage ?? this.followDeviceLanguage,
  );

  Map<String, dynamic> toJson() => {
    'ui_language': uiLanguage,
    'learning_language': learningLanguage,
    'ai_explanations_native': aiExplanationsInNative,
    'follow_device_language': followDeviceLanguage,   // NUEVO → columna 03_Database_Changes
  };
}
```

Carga desde prefs (extender `_load()`):

```dart
Future<void> _load() async {
  final prefs = await SharedPreferences.getInstance();
  state = UserLanguageSettings(
    uiLanguage: prefs.getString('ui_language') ?? 'es',
    learningLanguage: prefs.getString('learning_language') ?? 'en',
    aiExplanationsInNative: prefs.getBool('ai_explanations_native') ?? true,
    followDeviceLanguage: prefs.getBool('follow_device_language') ?? true,
  );
}
```

Nuevo setter (escribe prefs, muta estado, persiste a Supabase):

```dart
Future<void> setFollowDeviceLanguage(bool value) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('follow_device_language', value);
  state = state.copyWith(followDeviceLanguage: value);
  _persistToSupabase();   // ahora debe incluir los 4 campos (toJson)
}
```

> Nota: `setAiExplanationsInNative` hoy **no** persiste a Supabase (brecha G8 en `01_Current_Audit.md`). Al tocar `toJson()` se aprovecha para que también persista: basta llamar `_persistToSupabase()` desde ese setter.

---

## (c) Resolución del locale en `app.dart`

Se introduce `effectiveUiLanguageProvider` que aplica la regla:
`follow ? device : uiLanguage`, y `app.dart` deja de leer `s.uiLanguage` directamente.

```dart
// lib/core/i18n/language_settings.dart

/// Locale efectivo de la UI aplicando followDeviceLanguage.
/// Es lo ÚNICO que alimenta MaterialApp.locale.
final effectiveUiLanguageProvider = Provider<Locale>((ref) {
  final settings = ref.watch(userLanguageProvider);
  final device = ref.watch(deviceLocaleProvider);

  if (settings.followDeviceLanguage) {
    // Locale del dispositivo normalizado (es/en/pt; fallback 'es').
    return Locale(normalizeUiLocale(device));
  }
  return Locale(normalizeUiLocale(settings.uiLanguage));
});
```

```dart
// lib/app/app.dart — estado actual (referencia) vs objetivo

// HOY:   final uiLanguage = ref.watch(userLanguageProvider.select((s) => s.uiLanguage));
// OBJETIVO:
final uiLocale = ref.watch(effectiveUiLanguageProvider);

return MaterialApp.router(
  title: 'Dungeon of English',
  theme: AppTheme.darkTheme,
  darkTheme: AppTheme.darkTheme,
  themeMode: ThemeMode.dark,
  routerConfig: router,
  debugShowCheckedModeBanner: false,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: uiLocale,                          // ya resuelto (Locale)
);
```

---

## (d) Sección "Language" en Settings

En `settings_screen.dart` se añade una nueva sección `_SectionHeader(title: 'LANGUAGE')` entre las existentes, con:

1. **Switch "Usar idioma del dispositivo"** → `setFollowDeviceLanguage(bool)`.
   - `true`: la UI muestra un texto informativo y **oculta** el selector de interfaz.
   - `false`: muestra el selector de idioma de interfaz (`es`/`en`/`pt`).
2. **Selector "Idioma de la interfaz"** (visible solo si `followDeviceLanguage == false`).
3. **Selector "Idioma que aprendo"** → `setLearningLanguage(code)`.

Pseudo-código del widget de la sección:

```dart
// Dentro de settings_screen.dart (ConsumerState)

class _LanguageSection extends ConsumerWidget {
  const _LanguageSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(userLanguageProvider);
    final notifier = ref.read(userLanguageProvider.notifier);

    return GlassCard(
      blur: 20,
      opacity: AppColors.glassOpacity,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Switch "Seguir idioma del dispositivo" ---
          Row(
            children: [
              const Icon(Icons.devices_rounded, color: AppColors.manaCyan, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.follow_device_language,
                  style: GoogleFonts.spaceGrotesk(...),
                ),
              ),
              Switch(
                value: settings.followDeviceLanguage,
                activeColor: AppColors.manaCyan,
                onChanged: (val) => notifier.setFollowDeviceLanguage(val),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.follow_device_language_desc,
            style: GoogleFonts.inter(color: AppColors.onSurface.withValues(alpha: 0.54), fontSize: 11),
          ),
          const Divider(color: AppColors.onSurface.withValues(alpha: 0.12), height: 24),

          // --- Selector de interfaz (solo si NO sigue al dispositivo) ---
          if (!settings.followDeviceLanguage) ...[
            _LanguageOptionTile(
              icon: Icons.translate_rounded,
              label: AppLocalizations.of(context)!.interface_language,
              value: settings.uiLanguage.toUpperCase(),
              onTap: () => _showInterfaceLanguageSheet(context, ref, settings.uiLanguage),
            ),
            const SizedBox(height: 12),
          ],

          // --- Selector de idioma de aprendizaje (siempre visible) ---
          _LanguageOptionTile(
            icon: Icons.school_rounded,
            label: AppLocalizations.of(context)!.learning_language,
            value: settings.learningLanguage.toUpperCase(),
            onTap: () => _showLearningLanguageSheet(context, ref, settings.learningLanguage),
          ),
        ],
      ),
    );
  }
}

// Bottom sheet del selector de interfaz (es/en/pt → lista kSupportedUiLocales)
void _showInterfaceLanguageSheet(BuildContext context, WidgetRef ref, String current) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.sheetBackground,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(4.0),
        topRight: Radius.circular(4.0),
      ),
    ),
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(sheetContext)!.interface_language,
              style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onSurface),
            ),
            const SizedBox(height: 16),
            // kSupportedUiLocales == ['es', 'en', 'pt'] (+ futuros idiomas)
            ...kSupportedUiLocales.map((code) => _buildOption(
              title: code.toUpperCase(),
              description: '',   // nombre nativo si se desea
              isActive: current == code,
              icon: Icons.language_rounded,
              onTap: () {
                ref.read(userLanguageProvider.notifier).setUiLanguage(code);
                Navigator.pop(sheetContext);
              },
            )),
          ],
        ),
      ),
    ),
  );
}
```

> Al elegir idioma manualmente conviene además fijar `followDeviceLanguage = false` (si no, la detección volverá a mandar en el próximo arranque). La arquitectura lo contempla en el flujo de `setUiLanguage` (`02_Architecture.md` §4.3).

---

## (e) Sincronización al arrancar desde Supabase

Nuevo método `_syncFromSupabase()` en `UserLanguageNotifier`. Se invoca en el constructor (o tras detectar sesión en `main.dart`). Regla: **descargar prefs solo si no hay prefs locales previas** (primera sesión en el dispositivo), para no pisar preferencias locales del usuario (reglas de conflicto de `02_Architecture.md` §3.3).

```dart
Future<void> _syncFromSupabase() async {
  try {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user == null) return;                 // sin sesión → solo prefs + detección

    final prefs = await SharedPreferences.getInstance();
    final hasLocal = prefs.containsKey('ui_language') ||
                     prefs.containsKey('follow_device_language');

    // 1) Primera sesión en este dispositivo → descargar remoto y sembrar prefs
    if (!hasLocal) {
      final rows = await client
          .from('user_settings')
          .select('ui_language, learning_language, ai_explanations_native, follow_device_language')
          .eq('user_id', user.id)
          .maybeSingle();

      if (rows != null) {
        final ui = rows['ui_language'] as String?;
        final learn = rows['learning_language'] as String?;
        final native = rows['ai_explanations_native'] as bool?;
        final follow = rows['follow_device_language'] as bool?;

        state = UserLanguageSettings(
          uiLanguage: normalizeUiLocale(ui) ?? 'es',
          learningLanguage: learn ?? 'en',
          aiExplanationsInNative: native ?? true,
          followDeviceLanguage: follow ?? true,
        );
        // Sembrar prefs para futuras sesiones sin red
        await prefs.setString('ui_language', state.uiLanguage);
        await prefs.setString('learning_language', state.learningLanguage);
        await prefs.setBool('ai_explanations_native', state.aiExplanationsInNative);
        await prefs.setBool('follow_device_language', state.followDeviceLanguage);
      } else {
        // 2) No hay fila remota → crear el primer registro con los defaults resueltos
        await _persistToSupabase();
      }
    }
  } catch (e) {
    debugPrint('i18n: _syncFromSupabase falló: $e');   // nunca bloquear el arranque
  }
}
```

Invocación:

```dart
UserLanguageNotifier() : super(const UserLanguageSettings()) {
  _load();            // prefs locales (rápido, sin await en UI)
  _syncFromSupabase(); // si hay sesión: descargar y sembrar prefs
}
```

---

## (f) Actualización dinámica sin reiniciar

Gracias a Riverpod + `MaterialApp.router` con `locale` reactivo, **el cambio es instantáneo y no requiere reiniciar**:

1. `Switch` → `notifier.setFollowDeviceLanguage(bool)` muta `state` (nuevo `UserLanguageSettings`).
2. `effectiveUiLanguageProvider` (que observa `userLanguageProvider` + `deviceLocaleProvider`) se recalcula.
3. `TutorSaaSApp.build` (ConsumerWidget) se re-ejecuta con el nuevo `uiLocale`.
4. `MaterialApp.router` pasa el nuevo `locale` → **Flutter vuelve a construir el árbol con `AppLocalizations` del nuevo idioma** y todas las cadenas `AppLocalizations.of(context)!.clave` se re-traducen al instante.

> Requisito: la UI **debe** consumir textos vía `AppLocalizations.of(context)!.clave` (o en widgets no-context mediante el delegate). Los textos hardcodeados del inventario (`01_Current_Audit.md` §4, ~69 cadenas) **no** se actualizarán en caliente hasta externalizarse — por eso la externalización es un paso obligatorio del plan (paso 7 de `02_Architecture.md` §8).

Pseudo-código de control en `app.dart` (equivale al estado objetivo):

```dart
class TutorSaaSApp extends ConsumerWidget {
  const TutorSaaSApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uiLocale = ref.watch(effectiveUiLanguageProvider);   // reactivo
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Dungeon of English',
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: uiLocale,
    );
  }
}
```

---

## Orden de implementación sugerido

| Paso | Cambio | Depende de |
|---|---|---|
| 1 | Modelo: `followDeviceLanguage` + `toJson` + prefs (b) | — |
| 2 | Providers: `deviceLocaleProvider`, `effectiveUiLanguageProvider` (a, c) | paso 1 |
| 3 | Migración DB + aplicar en SQL Editor (ver `03_Database_Changes.md`) | — |
| 4 | `_syncFromSupabase()` + `_persistToSupabase` de 4 campos (e) | pasos 1, 3 |
| 5 | `app.dart` consume `effectiveUiLanguageProvider` (c, f) | paso 2 |
| 6 | Sección "Language" en Settings (d) + nuevas claves ARB (ver `04_Translation_Strategy.md` §7) | pasos 2, 5 |
| 7 | Retirar `LocaleNotifier`/`t()` y migrar clave `interface_language` → `ui_language` | paso 5 |
| 8 | Externalizar ~69 textos hardcodeados (inventario `01_Current_Audit.md` §4) | paralelo |

**Criterio de aceptación** (heredado de `02_Architecture.md` §8): un dispositivo en francés muestra la UI en francés sin tocarse nada (si FR entra en `kSupportedUiLocales`/ARB), y al desactivar "Seguir idioma del dispositivo" y elegir `es`, la app permanece en español aunque el dispositivo cambie a inglés — sin reiniciar.
