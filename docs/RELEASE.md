# Release y publicación

_Actualizado: 18-oct-2026._

---

## 1. Versión actual

```
versionName 1.0.21 · versionCode 22   (pubspec.yaml: version: 1.0.21+22)
AAB   104,0 MB
APK   131,9 MB
```

Artefactos en `build/app/outputs/`:

```
bundle/release/app-release.aab
flutter-apk/app-release.apk
```

---

## 2. Compilar

```sh
flutter analyze && flutter test          # 0 errores · 155 tests
flutter gen-l10n                          # si tocaste algún .arb

flutter build appbundle --release         # Play
flutter build apk --release               # instalación directa
```

Firma: `android/key.properties` apunta a `upload-keystore.jks` (alias `upload`).
El SHA-1 de esa clave es el que debe estar registrado en Google Cloud para
Google Sign-In:

```
14:13:F7:29:2E:C0:EA:F4:7B:A0:8F:B4:0A:2A:DB:C0:29:C1:1F:4C
```

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
