# Pendientes transversales

_Actualizado: 13-nov-2026 (al cerrar CUR-24)._

Cosas que no son una historia de la épica [#419](https://github.com/hiulett/TutorSaas/issues/419)
pero que se pierden si solo viven en una conversación. El backlog de currículo
sigue en la épica; esto es lo demás.

## Necesitan tu mano

- **Conceder el primer `superadmin`**: `admin_users` está vacío a propósito, así
  que hoy nadie puede entrar al portal.
  `select public.admin_set_role('<tu-uuid>', 'superadmin');` — el uuid sale de
  `select id from auth.users where email = '…';`
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
- **Verificar en dispositivo la Ruta con el flag `db`.** El interruptor ya existe y
  la puerta de activación está en verde
  ([runbook](../runbooks/CURRICULUM_ACTIVATION.md)), pero el build con el
  repositorio conectado todavía no está en producción. Hasta entonces el flag se
  queda en `dart`.
- **Rollout por cohortes**: el flag es global. El 10 % → 50 % → 100 % del plan
  §20 necesita un flag por usuario que no está implementado; hoy la activación
  progresiva se hace por versión/canal.

## Currículo

- Fase 6: **CUR-17** (caché y offline) es la siguiente pieza para que las
  lecciones nuevas creadas solo en la base se puedan renderizar. Mientras tanto,
  un pack con ids que la app no conoce cae al catálogo entero (`unknown_pack`), a
  propósito.
- Fase 7 en adelante: **CUR-18** a **CUR-25**.
- **Deuda editorial**: 481 traducciones idénticas y 519 objetivos débiles ya
  marcados. Corregirlos es **CUR-15**; las marcas existen para poder priorizar.

## Verificado, para no repetirlo

- `lesson_progress` en producción: 36 filas, 9 `lesson_id` distintos, y los 9
  están dentro de las 140 lecciones importadas. El progreso histórico no se rompe.
- **Orden del currículo reparado (CUR-24)**: `check_admin_units.py` movía una
  lección real de A1 y no la devolvía a su sitio; 8 lecciones quedaron
  desplazadas. `fix_curriculum_order.py` recompone unidad/posición desde la
  exportación canónica y el checker ya solo usa unidades de prueba. El pack de
  los 7 niveles es idéntico al catálogo, en orden, verificado contra producción.
- Flag `curriculum_source`: conmutado `dart → db → dart` contra producción el
  13-nov-2026, auditado y restaurado a `dart`. Ver
  [CURRICULUM_ACTIVATION.md](../runbooks/CURRICULUM_ACTIVATION.md).
