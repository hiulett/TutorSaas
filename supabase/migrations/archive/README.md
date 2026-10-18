# Semillas archivadas

Estos 32 archivos se movieron aquí el 2026-10-18 (issue #26). **No se ejecutan** con `supabase db push`: el CLI solo lee `migrations/*.sql` de primer nivel.

## Por qué

El currículo existe en tres formas a la vez:

| Fuente | Contenido |
|---|---|
| `lib/features/dashboard/data/models/lesson_catalog.dart` | **140 lecciones** (autoridad real: es lo que renderiza y lanza la app) |
| `20260805_apply_official_120_curriculum.sql` | 480 filas (120 × 4 idiomas) — mismo contenido que el catálogo |
| Los archivos de esta carpeta | ~6.480 filas de plantilla generada, con títulos y frases de relleno |

Los dos últimos se ejecutaron a mano desde el SQL Editor. Al vivir dentro de `migrations/` daban la impresión de formar parte del esquema reproducible, cuando en realidad no lo estaban.

## Qué queda como canónico

- **Currículo de la app:** `lesson_catalog.dart`.
- **Escenarios en base de datos** (para el panel admin y `lesson-generator`): `20260805_apply_official_120_curriculum.sql`.

## Advertencia

Los archivos archivados contienen `TRUNCATE ... CASCADE` sobre `scenarios`. **No deben ejecutarse** en producción: arrastrarían `conversations`, `messages` y `lesson_progress`.

Si en algún momento se necesita reconstruir la base desde cero, el camino es el volcado de `docs/schema/README.md`, no estas semillas.
