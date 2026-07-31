# ADR-006: Voice Pipeline — record → Groq STT → DeepSeek LLM → flutter_tts TTS

## Estado
Aceptado

## Contexto
TutorSaas requiere un pipeline de voz que permita conversación natural con IA con latencia < 1 segundo. El pipeline debe:
- Capturar audio del usuario sin cortes por pausas de pensamiento
- Transcribir audio a texto con alta precisión
- Generar respuesta de IA contextualizada
- Sintetizar voz de vuelta al usuario

## Opciones Evaluadas

### Captura de Audio
1. **`record` package (Hold-to-Talk)** — Graba AAC/m4a raw, control total
2. **`speech_to_text` nativo** — Usa VAD del SO, corta en pausas >1.5s
3. **`audio_session` + raw capture** — Demasiado bajo nivel

### STT (Speech-to-Text)
1. **Groq Whisper-large-v3-turbo** — ~200ms latencia, $0.03/hora, 12x más barato que OpenAI
2. **OpenAI Whisper API** — Más caro, latencia similar
3. **Self-hosted faster-whisper** — Gratuito pero requiere servidor
4. **On-device Whisper** — Offline pero +40-140MB APK

### LLM (Generación de Respuesta)
1. **DeepSeek Chat** — Streaming SSE, económico, ~250ms TTFT
2. **OpenAI GPT-4o** — Más caro, mayor latencia
3. **Groq LLaMA** — Alternativa de respaldo
4. **Claude API** — Excelente calidad pero más caro

### TTS (Text-to-Speech)
1. **flutter_tts (on-device)** — Sin latencia de red, ~300ms
2. **ElevenLabs API** — Voz más natural pero latencia de red
3. **Google Cloud TTS** — Similar a ElevenLabs
4. **Edge TTS** — Alternativa cloud

## Decisión

**Pipeline final:**
1. `record` package (AAC/m4a, Hold-to-Talk)
2. Groq Cloud Whisper-large-v3-turbo (language:'en' forzado)
3. DeepSeek Chat Completions (SSE streaming)
4. flutter_tts (rate: 0.48, on-device)

## Consecuencias
**Positivas:**
- Latencia total ~850ms–1.1s (objetivo <1.5s cumplido)
- Sin cortes por VAD del SO (Hold-to-Talk da control total al usuario)
- Groq es 12x más barato que OpenAI Whisper
- flutter_tts elimina latencia de red para TTS
- DeepSeek es significativamente más barato que GPT-4 para volumen alto

**Negativas:**
- Dependencia total de Groq y DeepSeek (si fallan, sin STT/LLM)
- TTS on-device suena menos natural que ElevenLabs
- Sin modo offline completo
- flutter_tts requiere engine de voz del SO (varía por dispositivo)
- `language:'en'` forzado puede dar precisión reducida con acentos fuertes

## Referencias
- [Groq Cloud API](https://console.groq.com/docs)
- [DeepSeek API](https://platform.deepseek.com/)
- [flutter_tts](https://pub.dev/packages/flutter_tts)
- [record package](https://pub.dev/packages/record)
