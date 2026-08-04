# Auditoría 05 — Diagnóstico del Servicio de IA (Error de Conexión)

**Fecha:** 2026-08-01
**Ámbito:** Conectividad de la app con los proveedores de IA (DeepSeek LLM + Groq STT)
**Estado:** Preparación de diagnóstico — captura pendiente del usuario (log / error en pantalla)

---

## 1. Hallazgo

El usuario reporta un **error de conexión con la IA**. El diagnóstico definitivo requiere una **captura pendiente** (mensaje de error exacto, stacktrace o logs); este documento establece el checklist de verificación y qué esperar cuando se disponga de la captura.

Contexto de la integración:

| Elemento | Detalle | Referencia |
|---|---|---|
| **LLM (DeepSeek)** | Llamada con Dio, `ApiConstants.deepseekBaseUrl` / `deepseekApiKey` | `conversation_repository_impl.dart` |
| **STT (Groq)** | `transcribeAudio(audioPath)` (Whisper, `en` forzado) | `conversation_repository_impl.dart` |
| **Reintentos** | `connectionTimeout` / `sendTimeout` / `connectionError` → retry | `conversation_repository_impl.dart` |
| **Claves** | `ApiConstants` inyecta claves vía `--dart-define` | `lib/core/.../api_constants.dart` |
| **Placement AI (nuevo)** | Llama DeepSeek igual, timeouts 30s / 60s | `lib/core/ai/placement_ai.dart` |

## 2. Causa raíz (hipótesis a confirmar)

Aún sin confirmar hasta recibir la captura. Hipótesis probables, por prioridad:

1. **Claves de API vacías o incorrectas en runtime** (`ApiConstants` no las recibe porque faltan los `--dart-define` al lanzar).
2. **Fallo de autenticación** (header `Authorization: Bearer` ausente o con clave inválida → 401/403).
3. **Timeout de conexión/recepción** (DeepSeek lento o red limitada; no alcanza el retry con backoff).
4. **Reintentos agotados** sin backoff suficiente en un proveedor caído/rate-limited (429).
5. **Respuesta truncada o no parseable** por límite de tokens (el LLM emite contenido incompleto que rompe el parseo).
6. **Problemas de red del dispositivo** (proxy corporativo, VPN, modo offline).

## 3. Checklist de diagnóstico

Verificación punto por punto (todo con `debugPrint` / logs de error existentes en los `catch`):

### 3.1. `ApiConstants` — valores reales en runtime

- **Cómo verificar:** en el constructor o primer uso, loguear `baseUrl` (sin la clave completa) y si `apiKey` está presente: `debugPrint('deepseek key set: ${key.isNotEmpty}')`.
- **Qué esperar:** si `apiKey.isEmpty` → el error es de configuración de build (`--dart-define` faltante en el comando `flutter run`).

### 3.2. Manejo de excepciones en el `catch`

- **Cómo verificar:** revisar que cada llamada a DeepSeek/Groq tenga `try-catch` con `debugPrint` del error (`DioException`, tipo, `error.response?.statusCode`).
- **Qué esperar:** la captura debe mostrar el **tipo de excepción** (connectionTimeout, receiveTimeout, badCertificate, connectionError, 401, 403, 429, 500) que apunta directo a la causa.

### 3.3. Reintentos y backoff

- **Cómo verificar:** localizar la lógica de retry en `conversation_repository_impl.dart` (condiciones `connectionTimeout` / `sendTimeout` / `connectionError`) y confirmar el número de intentos y el retardo.
- **Qué esperar:** si todos los intentos fallan con el mismo error de red, el problema es de red/timeout, no de credenciales. Si falla en el intento 1 con 401/403, los reintentos no ayudan: es autenticación.

### 3.4. Autenticación (Bearer key)

- **Cómo verificar:** en los `options.headers` de Dio, confirmar `'Authorization': 'Bearer ${ApiConstants.deepseekApiKey}'` (y el equivalente para Groq).
- **Qué esperar:** `401 Unauthorized` / `403` → clave incorrecta o revocada. Ausencia del header → bug de código.

### 3.5. Timeouts (connect / receive)

- **Cómo verificar:** valores de `connectTimeout` / `receiveTimeout` en el `BaseOptions` de cada repositorio y comparar con el tiempo real del proveedor. `placement_ai.dart` usa 30s / 60s.
- **Qué esperar:** `connectionTimeout` → el host no responde (DNS/red). `receiveTimeout` → el stream no terminó a tiempo (respuesta larga o truncada).

### 3.6. Configuración del proveedor (modelo, stream)

- **Cómo verificar:** confirmar el `model` enviado (`deepseek-chat`), el flag `stream: true` y el formato del cuerpo en `conversation_repository_impl.dart` y `placement_ai.dart`.
- **Qué esperar:** `400 Bad Request` con mensaje del proveedor → cuerpo mal formado o modelo incorrecto. Si el stream corta a mitad, revisar límite de `max_tokens`.

### 3.7. Consumo de tokens (respuesta truncada)

- **Cómo verificar:** en la captura, si la respuesta llega cortada o el parseo falla después de un fragmento, revisar `max_tokens` y `usage` devuelto por el proveedor.
- **Qué esperar:** respuesta con `finish_reason: length` → aumentar `max_tokens` o reducir contexto enviado.

### 3.8. Manejo de red (proxy / offline)

- **Cómo verificar:** desde el dispositivo, probar conectividad general (otra app con red, o `ping`/`curl` en la máquina) y detectar proxies/VPN.
- **Qué esperar:** si todo falla por red pero el resto de la app funciona (Supabase OK), el problema está acotado a dominios de DeepSeek/Groq bloqueados o a timeouts específicos de esos hosts.

## 4. Evidencia

| Elemento | Referencia |
|---|---|
| Llamada a DeepSeek con Dio | `conversation_repository_impl.dart` |
| Claves / base URL | `ApiConstants` (`deepseekBaseUrl`, `deepseekApiKey`) — inyectadas vía `--dart-define` |
| STT por Groq | `transcribeAudio(audioPath)` en `conversation_repository_impl.dart` |
| Reintentos (timeouts / connectionError) | `conversation_repository_impl.dart` |
| Placement AI (nuevo motor, timeouts 30s/60s) | `lib/core/ai/placement_ai.dart` |
| **Captura pendiente** | Log de error del usuario (pendiente de aportar) |

## 5. Archivos afectados

- `lib/core/.../conversation_repository_impl.dart` (DeepSeek LLM + Groq STT, reintentos).
- `lib/core/.../api_constants.dart` (`ApiConstants`, claves vía `--dart-define`).
- `lib/core/ai/placement_ai.dart` (motor nuevo de placement, mismas llamadas DeepSeek).
- Clientes que invocan estos repositorios (conversation / onboarding) — solo para observabilidad del error en UI.

## 6. Riesgos y mitigaciones

| Riesgo | Mitigación |
|---|---|
| **Claves expuestas en logs** | Nunca loguear el valor completo de `apiKey`; solo un booleano `isNotEmpty`. |
| **Cambiar reintentos sin saber la causa** | No tocar la lógica de retry hasta tener la captura; el checklist anterior clasifica el error primero. |
| **Fallos intermitentes (rate limit)** | Si la captura muestra 429, considerar backoff exponencial y respeto del header `Retry-After`. |
| **Conclusión apresurada** | Esperar la captura del usuario antes de modificar cualquier config de IA. |

## 7. Notas de cierre

- No se modifica código en esta auditoría; es un **plan de diagnóstico** a la espera de la captura del usuario.
- **Qué aportar para cerrar:** mensaje de error exacto que muestra la app (texto de la pantalla) y/o logs de consola (`debugPrint`) del momento del fallo.
- Con la captura se clasificará el error contra el checklist (secciones 3.1–3.8) y se emitirá la corrección puntual.
