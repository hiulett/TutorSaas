# TutorSaas — Web Admin (Command Deck)

Panel administrativo para gestionar lecciones, planes, economía y configuración del
juego. React + Vite con Supabase (JS client).

## Requisitos

- Node.js 18+
- Un proyecto Supabase (por defecto `sipiumfdpvnszthykyog`)

## Configuración

1. Instala dependencias:

   ```sh
   npm install
   ```

2. Crea el archivo `.env` a partir de la plantilla y rellena con tu proyecto:

   ```sh
   cp .env.example .env
   # VITE_SUPABASE_URL=https://TU_PROYECTO.supabase.co
   # VITE_SUPABASE_ANON_KEY=tu_anon_key_publica
   ```

   > Las claves nunca se versionan (`.env` está en `.gitignore`).

3. Ejecuta en desarrollo:

   ```sh
   npm run dev
   ```

## Scripts

| Script | Descripción |
|---|---|
| `npm run dev` | Servidor de desarrollo Vite (HMR) |
| `npm run build` | Build de producción (`dist/`) |
| `npm run lint` | Lint (oxlint) |

## Acceso y roles

- El login usa **Supabase Auth** (email + contraseña). El registro público está
  deshabilitado: las cuentas se crean desde el Dashboard de Supabase.
- Solo los usuarios con `app_metadata.role = "admin"` pueden entrar y escribir.
  Se asigna en: Dashboard → Authentication → Users → editar usuario → **App Metadata**:

  ```json
  { "role": "admin" }
  ```

  La escritura se protege además por **RLS** (migración `20260813_admin_rls.sql`):
  `INSERT/UPDATE/DELETE` solo con `role=admin`, `SELECT` para autenticados.

## Qué gestiona

| Sección | Tabla(s) |
|---|---|
| Panel Principal | Métricas reales (conteos de Supabase) |
| Lecciones y Escenarios | `scenarios`, `cefr_levels` |
| Niveles CEFR | `cefr_levels` |
| Usuarios y Progreso | `users`, `user_language_profiles`, `speech_dna_metrics` |
| Planes y Membresías | `subscription_plans` (estamento, maná, `stripe_price_id`) |
| Economía y Config | `ai_action_costs`, `mana_potions`, `mana_gems`, `prestige_ladder`, `cosmetic_catalog.price_gold` |
| Ajustes de IA | `system_ai_settings` |

## Arquitectura

- **`src/lib/supabaseClient.js`** — cliente Supabase (claves desde `.env`).
- **`src/services/adminService.js`** — capa de datos (CRUD + métricas).
- **`src/pages/`** — páginas por sección.
- **`src/components/ConfigTable.jsx`** — tabla CRUD genérica para las tablas de configuración.
- **`src/data/catalogData.js`** — catálogos legacy/seed (ya no se mezclan con la DB en `getScenarios`).

## Pagos (Stripe)

El panel expone `stripe_price_id` por plan. El checkout y el webhook viven en
`supabase/functions/stripe-checkout` y `stripe-webhook` (ver `APPLY_SECRETS.md`).
