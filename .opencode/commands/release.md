---
description: Prepara un release Android (analyze, test, l10n, checklist)
agent: release-captain
---

Prepara el release. Argumento: $ARGUMENTS (por ejemplo `1.0.22+23`).

Pasos obligatorios, en orden:

1. `flutter analyze` → debe dar **0 errores**. Anota warnings/infos nuevos respecto a la línea base (35/128).
2. `flutter test` → 159 pruebas en verde (o el número actual si cambió).
3. Si hay `.arb` modificados: `flutter gen-l10n` y confirma que no hay claves sin traducir inesperadas.
4. Si hay modelos `freezed`/`json` modificados: `dart run build_runner build --delete-conflicting-outputs`.
5. Sube `version` en `pubspec.yaml` solo si te lo pido explícitamente.
6. Revisa el checklist de `docs/RELEASE.md` y el estado de migraciones en `docs/runbooks/MIGRATION_STATUS.md`.

No ejecutes `flutter build appbundle` ni subas nada a Play: eso lo autorizo aparte.
No toques `supabase db push`.

Salida (máximo 300 palabras): checklist con ✅/❌ por paso, riesgos abiertos y el comando exacto que falta ejecutar a mano.
