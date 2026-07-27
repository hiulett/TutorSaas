# Arquitectura de Voz y Alternativas STT para TutorSaas

Este documento contiene el análisis técnico detallado sobre la arquitectura de voz de TutorSaas, la causa raíz del problema de corte de audio, y las alternativas gratuitas y cloud disponibles.

---

## 1. Causa Raíz del Corte de Audio en la Implementación Anterior

El sistema anterior utilizaba la librería `speech_to_text`, la cual envuelve los motores de reconocimiento de voz nativos del sistema operativo (Google Voice Typing en Android y SFSpeechRecognizer en iOS).

### Problemas Detectados:
1. **Detección de Silencio (VAD) Rígida del Sistema Operativo**:
   - Los teclados de voz del SO tienen un umbral de pausa de 1.5 a 2.0 segundos.
   - Cuando un estudiante de idiomas hace una pausa natural para pensar una palabra o estructura gramatical, el sistema operativo interpreta la pausa como "fin de frase" y finaliza la sesión de escucha automáticamente (`status: done`).
2. **Sin acceso al Audio Raw**:
   - `speech_to_text` no graba un archivo de audio real, solo devuelve cadenas de texto reconocidas. Si el reconocimiento nativo falla o se detiene, el audio pronunciado por el usuario se pierde irremediablemente.
3. **Condiciones de Carrera en Gestos**:
   - Los parches con retrasos temporales (`Future.delayed`) en el botón no pueden prevenir que el motor del SO ya haya cerrado el canal de audio internamente.

---

## 2. Nueva Arquitectura: Grabación Raw + Groq Cloud Whisper STT

La nueva implementación sustituye la escucha nativa del SO por la **grabación directa de audio en alta fidelidad** y su posterior envío a un modelo STT de alta velocidad.

```
┌───────────────────────────────────────────────────────────────────────────┐
│                        FLUTTER CLIENT (APP MOBILE)                         │
└───────────────────────────────────────────────────────────────────────────┘
                                      │
               ┌──────────────────────┴──────────────────────┐
               ▼                                             ▼
     [ Hold-to-Talk Mode ]                         [ Tap-to-Talk Mode ]
     • Press & Hold: Inicia graba                  • Tap: Inicia grabación
     • Release: Detiene y transcribe               • Tap de nuevo / Stop: Transcribe
               │                                             │
               └──────────────────────┬──────────────────────┘
                                      │
                                      ▼
             [ Grabador Local (`record` package - Audio AAC/m4a) ]
                                      │
                                      ▼
               [ API Groq Cloud (whisper-large-v3-turbo) ]
               • Transcripción ultra rápida (< 200ms)
               • Cero cortes por pausas de pensamiento
                                      │
                                      ▼
                       [ LLM (DeepSeek) + TTS Stream ]
```

---

## 3. Alternativas STT Evaluadas

### A. Groq Cloud API (Implementación Actual)
- **Modelo**: `whisper-large-v3-turbo`
- **Ventajas**: Latencia ultra baja (~100-200ms), precisión líder en la industria, soporta acentos e idiomas mixtos.
- **Capa Gratuita**: 2,000 peticiones diarias / 7,200 segundos por hora ($0.00/mes).
- **Costo en pago**: $0.03 USD por hora de audio (12 veces más barato que OpenAI Whisper).

### B. Self-Hosted `faster-whisper` (100% Gratuito)
- **Tecnología**: Servicio FastAPI / Docker ejecutando `faster-whisper` (CTranslate2).
- **Ventajas**: 100% gratuito, cero límites de API, control total sobre el backend.
- **Costo**: $0.00 USD en cuotas de API (solo costo del servidor VPS si aplica).

### C. On-Device Whisper (`whisper_flutter_plus` / `sherpa_onnx`)
- **Tecnología**: Inclusión de modelos de IA cuantizados en el binario móvil.
- **Ventajas**: Funciona 100% offline sin necesidad de servidores.
- **Desventajas**: Incrementa el tamaño del ejecutable (APK/IPA) entre 40 MB y 140 MB.

### D. Cloudflare Workers AI (`@cf/openai/whisper`)
- **Ventajas**: Servidores serverless gratuitos hasta 10,000 ejecuciones diarias.

---

## 4. Configuración de Llaves de API

Las llaves de API se gestionan de forma centralizada en `lib/core/constants/api_constants.dart`:
- `groqApiKey`: Llave de acceso a la API de Groq Cloud STT.
- `deepseekApiKey`: Llave de acceso al LLM de conversación.
