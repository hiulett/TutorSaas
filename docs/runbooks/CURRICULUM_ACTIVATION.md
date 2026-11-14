# Activación y rollback del currículo en base (CUR-24)

El contenido de las 140 lecciones vive en PostgreSQL desde CUR-03, pero la app
puede leerlo de dos sitios:

| `app_config.curriculum_source` | La app lee |
|---|---|
| `dart` (valor actual) | el catálogo empaquetado (`lesson_catalog.dart`) |
| `db` | `get_curriculum_pack` por nivel, con caída al catálogo si falla |

El flag permite encender y apagar **sin publicar una versión nueva**. Este
runbook es el procedimiento y la evidencia de que funciona.

---

## 1 · Cuándo se puede encender

La puerta es `scripts/check_curriculum_activation.py`. Comprueba, contra
producción:

1. Que el catálogo Dart conserva sus 140 lecciones, 20 por nivel.
2. Que `get_curriculum_pack` devuelve **las mismas lecciones en el mismo orden**
   que el catálogo en los 7 niveles. Un orden distinto cambiaría la Ruta del
   alumno.
3. Que cada lección del pack existe en `lessons` como publicada y con versión.
4. Que `content_version` es positivo (etiqueta de caché).
5. Que el flag conmuta `dart → db → dart`, rechaza valores inválidos y se
   audita. Se restaura en el `finally` aunque el checker falle.

```sh
python scripts/check_curriculum_activation.py
```

Si imprime `PROBLEMA`, **no se enciende**. El caso real de esta sesión: 8
lecciones de A1 estaban desplazadas de unidad/posición (las movió un checker
anterior de unidades y no las devolvió). Se repararon con
`scripts/fix_curriculum_order.py`; la causa se cerró haciendo que la prueba de
unidades trabaje solo con unidades de prueba.

## 2 · Encender

```sh
python scripts/set_curriculum_source.py db
```

El script ejecuta la puerta primero y aborta si falla. Después escribe el flag
por `admin_set_curriculum_source`, que exige la capacidad `publish` y deja
registro en `content_audit_logs` (`action = set_curriculum_source`).

## 3 · Apagar (rollback)

```sh
python scripts/set_curriculum_source.py dart
```

No comprueba nada a propósito: el rollback tiene que funcionar aunque el
contenido de la base esté roto, que es cuando se necesita. Tarda segundos. La
app vuelve al catálogo como máximo 60 s después (ventana de caché del flag en
`CurriculumRepository`); reiniciar la app lo aplica al instante. No hay que
publicar nada.

## 4 · Red de seguridad en la app (CUR-24)

`CurriculumRepository.getLevelPack` cae al catálogo **completo del nivel** ante
cualquiera de estos casos, y deja el motivo en `lastSourceReason`:

| Motivo | Cuándo |
|---|---|
| `flag_dart` | el flag está apagado (comportamiento normal) |
| `remote_disabled` | interruptor local de emergencia |
| `empty_pack` | el nivel llegó sin unidades |
| `incomplete_pack` | le faltan lecciones que la app ya conoce |
| `unknown_pack` | trae lecciones que la app todavía no sabe renderizar |
| `duplicated_pack` | la misma lección aparece dos veces |
| `wrong_level` | el pack es de otro nivel |
| `network` | RPC caído, sin sesión o error de red |

La Ruta que consume la app (`curriculumLevelLessonsProvider`) vuelve a
comprobar que todas las lecciones del pack se pueden renderizar; si no, sirve
el catálogo entero. Enseñar 19 de 20 es peor que repetir el catálogo.

**Límite conocido:** los renderers siguen en código y la pantalla de
conversación todavía lee `LessonCatalog` por id. Por eso una lección **nueva**
creada solo en la base no se muestra aún: se considera `unknown_pack` y el nivel
entero cae al catálogo. Abrir eso es CUR-17 en adelante (renderers por datos).

## 5 · Despliegue gradual

El flag es global, no por porcentaje. La activación progresiva de esas
características se hace por **versión/canal**: primero un build interno con el
flag en `db`, luego el canal de producción. Un rollout por cohortes (10 % →
50 % → 100 %) exigiría un segundo flag por usuario y no está implementado.

## 6 · Evidencia (13-nov-2026)

```
python scripts/check_curriculum_activation.py
OK · 7 niveles y 140 lecciones identicas al catalogo; flag reversible

python scripts/set_curriculum_source.py db
curriculum_source: dart -> db (auditado en content_audit_logs)

python scripts/set_curriculum_source.py dart
curriculum_source: db -> dart (auditado en content_audit_logs)
```

Estado final del flag: `dart`, a propósito, hasta que el build con el
repositorio conectado esté en producción.

Pruebas de la app (`flutter test`, 805 en verde):

- con flag `dart`, la Ruta recibe el catálogo exacto (ids y orden) en los 7
  niveles: conectar el repositorio no cambia el comportamiento;
- con flag `db`, recibe el pack y su orden;
- pack caído, vacío, incompleto, duplicado o con ids desconocidos → catálogo;
- rollback: `db → dart` tras la ventana de caché, e inmediato con
  `invalidateSource()`.
