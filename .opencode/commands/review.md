---
description: Revisa el diff actual sin editar (bug, seguridad, tests)
agent: reviewer
---

Revisa los cambios actuales de este repositorio.

Resumen del diff:

!`git diff --stat`

Instrucciones:

1. Inspecciona los hunks reales con `git diff -- <archivo>` solo de los archivos que aparecen arriba.
2. Busca, en este orden: bugs y regresiones, problemas de seguridad o datos, tests que faltan.
3. Contrasta con las reglas de `AGENTS.md` (Android únicamente, pipeline de voz intacto, `.arb` editados a mano, sin `supabase db push`).
4. Si el diff toca el esquema o RPC, verifica contra producción con el MCP `supabase` (solo lectura).

Formato de salida (máximo 400 palabras):

| Severidad | Archivo:línea | Problema | Arreglo sugerido |
|---|---|---|---|

Termina con una línea: `Veredicto: aprobar | corregir antes de commit`.
No edites archivos.
