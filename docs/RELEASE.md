# Release y publicación

_Actualizado: 29-oct-2026 (versión, comandos y pistas verificados)._

---

## 1. Versión actual

```
versionName 1.0.21 · versionCode 22   (pubspec.yaml: version: 1.0.21+22)
AAB   104,2 MB (medido en local, master; no re-medido el 29-oct)
APK   (medir con `flutter build apk --release`)
```

Artefactos en `build/app/outputs/`:

```
bundle/release/app-release.aab
flutter-apk/app-release.apk
```

---

## 2. Compilar

```sh
flutter analyze                           # 0 errores · 0 warnings
flutter test                              # 702 pruebas
flutter gen-l10n                          # si tocaste algún .arb

flutter build appbundle --release         # Play
flutter build apk --release               # instalación directa
```

Firma: `android/key.properties` apunta a `upload-keystore.jks` (alias `upload`).

### Google Sign-In (SHA-1)

El cliente OAuth de Android se identifica por **package name + SHA-1**:

| Dato | Valor |
|---|---|
| Package | `com.tutorsaas.tutorsaas` |
| SHA-1 de la upload key | `14:13:F7:29:2E:C0:EA:F4:7B:A0:8F:B4:0A:2A:DB:C0:29:C1:1F:4C` |
| SHA-256 de la upload key | `1B:76:97:18:6A:AB:F5:1D:76:52:32:F1:50:57:4E:D9:CE:CF:21:68:52:C0:8C:45:1A:00:F9:71:F5:C8:E3:E8` |

En **Google Cloud → APIs & Services → Credentials** debe existir un cliente
OAuth de tipo **Android** con ese package y el SHA-1 de la upload key. Para
probar en local, anade tambien el SHA-1 de la debug key:

```sh
keytool -list -v -alias androiddebugkey -keystore %USERPROFILE%\.android\debug.keystore -storepass android
```

El `serverClientId` del codigo (`auth_repository_impl.dart`) es el cliente
**Web** `879543775149-f9fqcrpbgq9qbk16i2rkbi78spo9jceo.apps.googleusercontent.com`;
no se cambia al rotar la firma.

Sintoma si falta el SHA-1: `ApiException: 10` (DEVELOPER_ERROR) al pulsar el
boton de Google en una build firmada. La app ahora muestra un mensaje
explicito en ese caso.

## 2.1 CI/CD

| Workflow | Cuándo | Qué hace |
|---|---|---|
| `.github/workflows/ci.yml` | push/PR a `master` | `pub get` + `gen-l10n` + `analyze --no-fatal-infos` (0 warnings) + `test`; `web_admin`: `npm ci`, lint, test y build |
| `.github/workflows/release.yml` | tag `v*` o manual | AAB firmado, comprobación de presupuesto y artifact; subida a pista interna si hay credenciales |

Secretos de `release.yml` (todos opcionales salvo que quieras firmar/subir):

| Secreto | Uso |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | keystore de subida en base64 |
| `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`, `ANDROID_STORE_PASSWORD` | credenciales del keystore |
| `PLAY_SERVICE_ACCOUNT_JSON` | cuenta de servicio de Play para la pista interna |

Sin `ANDROID_KEYSTORE_BASE64` el AAB se firma con debug (solo pruebas locales).
Presupuesto de tamaño: **150 MB** de AAB; el job falla si se supera.

---

## 3. Publicar en Play

1. Play Console → **Probar y publicar → Pruebas internas → Crear versión**.
2. Subir el `.aab`.
3. Notas de versión.
4. **Revisar → Iniciar implementación**.
5. Añadir la cuenta como tester de la pista.

| Pista | Última versión |
|---|---|
| internal | 1.0.18+19 |
| alpha | 1.0.19+20 |
| beta | vacía |
| production | vacía |

> El versionCode debe ser mayor que el último subido. El 21 nunca se publicó;
> el 22 es el actual.

Pistas comprobadas el 29-oct-2026 con la Play Developer API (`internal` y
`alpha` con una release completada cada una; `beta` y `production` sin
releases).

---

## 4. Checklist antes de publicar

- [ ] `flutter analyze` sin errores.
- [ ] `flutter test` en verde.
- [ ] `flutter gen-l10n` ejecutado si hubo cambios en ARB.
- [ ] Versión subida en `pubspec.yaml`.
- [ ] Probado en dispositivo físico (no solo emulador).
- [ ] Suscripciones y license testers revisados si se tocó el flujo de compra.
- [ ] Sin secretos en el diff (`git diff | grep -i "sk_\|api_key"`).

---

## 5. Pruebas de compra

Procedimiento completo, matriz de 10 casos y runbook en
[runbooks/PURCHASE_TESTING.md](runbooks/PURCHASE_TESTING.md).

Resumen:

1. Cuenta en **license testers** de Play.
2. Build en una pista (internal) e instalación **desde Play**.
3. Comprar → debe salir el diálogo con **[TEST]**.
4. Verificar `user_subscriptions` y `revenuecat_events`.

---

## 6. Backend

```sh
supabase functions deploy <nombre> --project-ref sipiumfdpvnszthykyog --use-api
supabase secrets set NOMBRE=valor --project-ref ...
```

⚠️ **No usar `supabase db push`**: el repo no reproduce el esquema (ver
[runbooks/MIGRATION_STATUS.md](runbooks/MIGRATION_STATUS.md)). Los cambios de
esquema se aplican por el SQL Editor o por MCP y se guardan como archivo con la
versión real del historial.

---

## 7. Admin web

```sh
cd web_admin
npm ci && npm run build      # genera dist/
npx vercel --prod            # o cualquier hosting estático
```

Variables en `web_admin/.env` (no se commitea).
