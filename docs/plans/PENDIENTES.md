# Pendientes transversales

_Actualizado: 13-nov-2026 (al cerrar CUR-05)._

Cosas que no son una historia de la épica [#419](https://github.com/hiulett/TutorSaas/issues/419)
pero que se pierden si solo viven en una conversación. El backlog de currículo
sigue en la épica; esto es lo demás.

## Necesitan tu mano

- **Rotar las claves expuestas** en el chat (`sb_secret_…`, `sk_…` de RevenueCat
  y la de Stitch) y **actualizar el header del webhook** de RevenueCat en el
  mismo minuto. Queda para el final, a propósito.
- **Registrar con su versión real las migraciones aplicadas a mano.** `20261113150000`
  (currículo), `20261113163000` (`review_reason`) y `20261113170000`
  (`get_curriculum_pack`) se aplicaron por el SQL Editor, así que
  `supabase_migrations.schema_migrations` no las conoce. Hay que anotarlas en
  [docs/runbooks/MIGRATION_STATUS.md](../runbooks/MIGRATION_STATUS.md) y
  renombrar los archivos si la versión real difiere.

## Funcional, no bloquea

- Mover el CTA `PROBAR GRATIS` arriba: hoy vive tras cuatro tarjetas, fuera del pliegue.
- Limpiar las filas de sandbox de `payments` antes de mirar ARPU; hoy lo contaminan.
- Verificar **en dispositivo** el estado gratuito del splash y de la tarjeta de maná.
- `app_config.curriculum_source` (`dart` | `db`) sigue sin implementar: hasta que
  exista, el contenido está duplicado entre el catálogo Dart y PostgreSQL.

## Currículo

- Segunda mitad de la fase 3 y fase 4: **CUR-06** (vista materializada),
  **CUR-08** a **CUR-15**, **CUR-16** (repositorio Flutter con caché) y
  **CUR-25** (rúbrica de colocación).
- **Deuda editorial**: 481 traducciones idénticas y 519 objetivos débiles ya
  marcados. Corregirlos es **CUR-15**; las marcas existen para poder priorizar.
- El contenido ya está importado, pero **nadie lo consume** hasta CUR-16: la app
  sigue leyendo el catálogo Dart.

## Verificado, para no repetirlo

- `lesson_progress` en producción: 36 filas, 9 `lesson_id` distintos, y los 9
  están dentro de las 140 lecciones importadas. El progreso histórico no se rompe.
