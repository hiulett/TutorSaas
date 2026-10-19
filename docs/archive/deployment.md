# Deployment — TutorSaas

## Flutter Build

### Build de Desarrollo

```bash
# Ejecutar en modo debug
flutter run --dart-define=SUPABASE_URL=<url> --dart-define=SUPABASE_ANON_KEY=<key> \
  --dart-define=DEEPSEEK_API_KEY=<key> --dart-define=GROQ_API_KEY=<key>
```

### Build de Producción (Android)

```bash
# APK
flutter build apk --release --dart-define-from-file=config.json

# AppBundle (recomendado para Play Store)
flutter build appbundle --release --dart-define-from-file=config.json
```

### Build de Producción (iOS)

```bash
flutter build ios --release --dart-define-from-file=config.json
```

## Configuración de Flavors (opcional)

El proyecto actualmente no usa flavors separados. Se recomienda para separar dev/staging/prod:

```bash
flutter build apk --flavor dev --dart-define-from-file=config.dev.json
flutter build apk --flavor prod --dart-define-from-file=config.prod.json
```

## Archivo config.json

```json
{
  "SUPABASE_URL": "https://sipiumfdpvnszthykyog.supabase.co",
  "SUPABASE_ANON_KEY": "<anon-key>",
  "DEEPSEEK_API_KEY": "<deepseek-api-key>",
  "DEEPSEEK_BASE_URL": "https://api.deepseek.com/v1",
  "GROQ_API_KEY": "<groq-api-key>",
  "GROQ_STT_URL": "https://api.groq.com/openai/v1/audio/transcriptions"
}
```

**⚠️ Seguridad:** No incluir este archivo en el repositorio. Generar por separado para cada entorno.

## API Keys via --dart-define

Todas las claves se definen en `lib/core/constants/api_constants.dart` usando `String.fromEnvironment()`:

| Constante | Variable de Entorno |
|-----------|-------------------|
| `supabaseUrl` | `SUPABASE_URL` |
| `supabaseAnonKey` | `SUPABASE_ANON_KEY` |
| `deepseekApiKey` | `DEEPSEEK_API_KEY` |
| `deepseekBaseUrl` | `DEEPSEEK_BASE_URL` |
| `groqApiKey` | `GROQ_API_KEY` |
| `groqSttUrl` | `GROQ_STT_URL` |

## CI/CD con GitHub Actions

Pipeline propuesto:

### `ci.yml` — Push/PR
```yaml
- name: Setup Flutter
  run: flutter pub get
- name: Analyze
  run: flutter analyze
- name: Test
  run: flutter test
- name: Build APK
  run: flutter build apk --release --dart-define-from-file=config.json
```

### `deploy.yml` — Release
```yaml
- name: Build AppBundle
  run: flutter build appbundle --release --dart-define-from-file=config.prod.json
- name: Deploy to Play Store
  uses: r0adkll/upload-google-play@v1
```

## Variables de Entorno CI/CD

Configurar como secrets de GitHub Actions:
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `DEEPSEEK_API_KEY`
- `GROQ_API_KEY`
- `PLAY_STORE_SERVICE_ACCOUNT_KEY` (para deploy automático)

## Publicación en Stores

### Google Play Store
1. Generar AppBundle: `flutter build appbundle --release --dart-define-from-file=config.prod.json`
2. Subir a Play Console > Release > Production
3. Completar listing y contenido de la ficha

### Apple App Store (iOS pendiente)
1. Generar IPA: `flutter build ios --release --dart-define-from-file=config.prod.json`
2. Subir con Transporter o Xcode
3. Configurar TestFlight y revisión

## EAS Updates (Expo — no aplica)

El proyecto es Flutter nativo, no Expo. No usar EAS.

## Monitoreo Post-Deploy

- `LatencyBenchmark.runPipelineBenchmark()` se ejecuta al inicio de la app
- `ErrorTracker.logError()` registra errores críticos
- Tabla `ai_usage_logs` en Supabase registra tokens y costos
