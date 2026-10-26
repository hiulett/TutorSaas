---
description: Actualiza un documento de docs/product-audit con evidencia actual
agent: doc-auditor
---

Actualiza la auditoría para: $ARGUMENTS

Si no indico documento, detecta qué cambió con `git diff --stat` y actualiza solo
los documentos afectados.

Protocolo:

1. Abre el documento objetivo (o `docs/product-audit/00-INDICE.md` para orientarte).
2. Verifica cada afirmación que vayas a tocar contra el código; si es de datos, usa el MCP `supabase` en solo lectura.
3. Actualiza cifras, estados (V/P/D/NV), referencias `archivo:línea` y la fecha de medición.
4. Si cambia un hallazgo, refléjalo también en `19-MATRIZ-DE-TRAZABILIDAD.md`.

Límites:
- Solo editas `docs/product-audit/`.
- No inventes datos ni usuarios. Si falta evidencia, escribe "no verificable" y qué haría falta.
- No ejecutes DDL, migraciones ni `supabase db push`.

Salida (máximo 250 palabras): documentos tocados, secciones y qué quedó pendiente de verificar.
