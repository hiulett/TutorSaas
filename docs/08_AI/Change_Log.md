# Fase 8 — IA · Change_Log

> Registro de cambios de la Fase 8.

## 2026-07-30

### IA-01 · Seguridad de API keys (implementado)
- `api_constants.dart`: `deepseekApiKey` y `groqApiKey` → `defaultValue: ''` (se inyectan vía `--dart-define`/`config.json`). Eliminados los valores reales del repo.
- `conversation_repository_impl.dart`: eliminados los 2 bloques de fallback con la clave real `sk-592...` (líneas de `getTutorResponseStream` y `evaluateGoals`).
- Creado `config.sample.json` (plantilla sin secretos) para que el desarrollador copie a `config.json`.
- `.gitignore`: añadidos `config.json`, `*.key`, `.env`.
- Verificado: 0 secretos en `lib/` (grep `sk-592...`/`gsk_6dm...` = 0) · build OK · tests 13/13.

### ✅ Claves rotadas y proxy seguro (2026-08)
- Claves de DeepSeek y Groq **rotadas** por el usuario en sus consolas.
- Edge Function `supabase/functions/llm-proxy`: las claves viven solo como
  secrets de la función (`DEEPSEEK_API_KEY`, `GROQ_API_KEY`); el APK no las contiene.
- Referencias a claves antiguas eliminadas de `docs/deployment.md`, `Change_Log.md`,
  `MASTER_AUDIT.md` y `MASTER_AUDIT_V2.md`.

### ⚠️ Acción pendiente del usuario (fuera del repo)
- Crear `config.json` local a partir de `config.sample.json` y ejecutar: `flutter run --dart-define-from-file=config.json`.

---

## 2026-07-30 (implementaciones previas)
