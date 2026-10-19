# Backlog de la auditoría integral

Este directorio contiene el backlog derivado de `docs/archive/auditoria_producto/AUDITORIA_INTEGRAL.md`, listo para publicarse como issues de GitHub.

## Archivos

| Archivo | Propósito |
|---|---|
| `audit-backlog.txt` | 45 issues en formato delimitado (título, labels, cuerpo). Es la fuente de verdad. |
| `create_issues.ps1` | Crea labels e issues vía API de GitHub. Idempotente: omite títulos ya existentes. |

## Cómo publicarlos

Necesitas un **Personal Access Token** con permiso `Issues: Read and write` sobre `hiulett81/TutorSaas` (fine-grained) o scope `repo` (clásico).

```powershell
# 1. Define el token solo en esta sesión de terminal
$env:GITHUB_TOKEN = "github_pat_..."

# 2. Comprueba lo que se va a crear (no llama a la API)
powershell -ExecutionPolicy Bypass -File .github/issues/create_issues.ps1 -DryRun

# 3. Crea labels + issues + epic
powershell -ExecutionPolicy Bypass -File .github/issues/create_issues.ps1
```

Al terminar, el script imprime el número y la URL de cada issue y crea un **epic** con el checklist completo.

## Convenciones

**Prioridad**

| Label | Significado |
|---|---|
| `P0-critico` | Bloquea cobrar o pone en riesgo datos/dinero del usuario |
| `P1-alto` | Rompe una promesa visible del producto |
| `P2-medio` | Mejora relevante |
| `P3-bajo` | Limpieza y deuda menor |

**Área:** `area/backend`, `area/economia`, `area/misiones`, `area/aprendizaje`, `area/ia`, `area/ux`, `area/negocio`, `area/calidad`, `area/producto`, `area/seguridad`.

**Tipo:** `bug`, `mejora`, `deuda-tecnica`, `seguridad`, `producto`.

## Formato de cada issue

Cada entrada incluye:

- **Contexto** — qué está pasando y por qué importa.
- **Evidencia** — rutas y líneas verificables del repositorio.
- **Comportamiento actual** — lo que ocurre hoy.
- **Comportamiento esperado** — lo que debería ocurrir.
- **Criterios de aceptación** — checklist de cierre.

## Para añadir un issue

Añade un bloque nuevo a `audit-backlog.txt` y vuelve a ejecutar el script. Los existentes se omiten por título.

```
=== ISSUE ===
SLUG: mi-slug
TITLE: [P2] Título claro
LABELS: P2-medio, area/ux, mejora
BODY:
## Contexto
...
=== END ===
```
