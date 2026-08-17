# tutorsaas

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Despliegue

Hay 3 componentes desplegables: la **app Flutter**, el **admin web** (`web_admin/`)
y el **backend Supabase** (Base de datos + Edge Functions). El CI actual
(`.github/workflows/ci.yml`) solo corre `flutter analyze` + `flutter test`; **no
hay CD automatizado** — el despliegue se hace manualmente con los scripts de abajo.

### 0. Configuración previa (una vez por entorno)

```sh
# 1. Loguear Supabase CLI (pide un access token de
#    https://supabase.com/dashboard/account/tokens)
supabase login

# 2. App Flutter: crea config.json en la raíz desde la plantilla
#    (config.json está en .gitignore, NO se commitea)
copy config.sample.json config.json   # Windows
# cp config.sample.json config.json   # Linux/macOS
# Rellena SOLO SUPABASE_URL y SUPABASE_ANON_KEY. Las claves de IA (DeepSeek/Groq)
# ya NO van en el cliente: viven como secrets de la Edge Function llm-proxy.

# 3. Admin web: crea .env desde la plantilla (NO se commitea)
copy web_admin\.env.example web_admin\.env   # Windows
# cp web_admin/.env.example web_admin/.env   # Linux/macOS
```

### 1. Backend — Supabase (migraciones + edge functions)

```sh
# Aplicar migraciones pendientes al proyecto remoto
# (si una DDL falla con "read-only transaction", aplica el archivo desde el
# SQL Editor de Supabase o desde una branch de la base de datos)
supabase db push --project-ref sipiumfdpvnszthykyog

# Deploy de una Edge Function (llm-proxy, stripe-webhook, etc.)
supabase functions deploy llm-proxy --project-ref sipiumfdpvnszthykyog

# Configurar los secrets de llm-proxy (OBLIGATORIO antes de usarlo)
supabase secrets set \
  DEEPSEEK_API_KEY=<tu-clave-deepseek> \
  DEEPSEEK_BASE_URL=https://api.deepseek.com/v1 \
  GROQ_API_KEY=<tu-clave-groq> \
  GROQ_STT_URL=https://api.groq.com/openai/v1/audio/transcriptions \
  --project-ref sipiumfdpvnszthykyog

# Verificar que quedaron seteados y que la función los ve
supabase secrets list --project-ref sipiumfdpvnszthykyog
curl -s https://sipiumfdpvnszthykyog.supabase.co/functions/v1/llm-proxy/health \
  -H "apikey: <ANON_KEY>" -H "Authorization: Bearer <ANON_KEY>"
# Debe responder: {"ok":true,"hasDeepSeek":true,"hasGroq":true}
```

### 2. App Flutter (Android / iOS)

```sh
# Requiere config.json en la raíz (paso 0.2)
flutter build apk --release --dart-define-from-file=config.json              # APK
flutter build appbundle --release --dart-define-from-file=config.json        # Play Store (recomendado)
flutter build ios --release --dart-define-from-file=config.json              # iOS (macOS + Xcode)
```

Subir el AppBundle a Google Play Console, o el IPA a TestFlight/Transporter. Para
iterar rápido antes de publicar: `flutter run -d <device>`.

### 3. Admin web (`web_admin/`)

```sh
cd web_admin
npm ci            # instalar dependencias
npm run build     # genera el bundle estático en dist/
npm run lint      # oxlint
npm run test      # vitest (loop rápido)
```

`web_admin/dist/` es un sitio estático; súbelo a cualquier host (Vercel, Netlify,
Firebase Hosting). Ejemplo con Vercel:

```sh
cd web_admin
npx vercel --prod   # publica dist/ automáticamente
# o, alternativamente:
npx netlify deploy --prod --dir=dist
```

### 4. CI/CD (estado actual y CD propuesto)

- **Actual**: `.github/workflows/ci.yml` corre `flutter analyze` y `flutter test`
  en cada push/PR a `main`. No publica nada.
- **CD propuesto**: añadir un job que genere el artefacto y lo publique, por
  ejemplo `flutter build appbundle` + `r0adkll/upload-google-play` para Play Store,
  o `npm run build` + vercel/netlify para `web_admin/`. Las claves deben pasarse
  como **secrets de GitHub Actions**, nunca hardcodeadas.

### 5. Seguridad (qué NO commitear)

- `config.json` y `web_admin/.env` — ignorados por `.gitignore`, contienen claves reales.
- ⚠️ Las claves DeepSeek/Groq **estuvieron expuestas** en el historial de git
  (`docs/deployment.md`, `supabase/functions/llm-proxy/APPLY_SECRETS.md`).
  **ROTÁRALAS** (console.groq.com y platform.deepseek.com) antes de producción.
- Usa siempre placeholders (`<tu-clave-...>`) o secrets del proveedor CI; nunca
  claves reales en archivos versionados.
