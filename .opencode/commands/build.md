# Build

Compila y verifica tipos del proyecto Flutter.

```sh
flutter analyze
```

- Es la puerta de calidad: `flutter analyze` (lint + typecheck). El bar es **0 errores** (35 warnings + 128 infos son la línea base; no perseguirlos, pero no añadir nuevos).
- Nunca ejecutes `build_runner` ni `gen-l10n` "por si acaso": solo cuando cambien modelos o `.arb`.
- Tras editar `lib/l10n/app_*.arb`, ejecuta antes `flutter gen-l10n` para regenerar los localizations.
- Tras cambiar modelos freezed/json_serializable, ejecuta `dart run build_runner build --delete-conflicting-outputs`.
- Loop rápido: reutiliza el build previo, no hace falta rebuild completo del bundle.
