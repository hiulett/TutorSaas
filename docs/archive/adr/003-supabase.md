# ADR-003: Supabase como Backend-as-a-Service

## Estado
Aceptado

## Contexto
TutorSaas necesita un backend que proporcione:
- Base de datos relacional con relaciones complejas (usuarios, perfiles, conversaciones, mensajes, vocabulario, logros)
- Autenticación (email/password + Google OAuth)
- Seguridad a nivel de fila (RLS)
- Realtime para salas de voz grupales
- Storage para avatares y assets
- Escalabilidad sin gestión de servidores

## Opciones Consideradas
1. **Supabase** — PostgreSQL gestionado, Auth, RLS, Realtime, Storage
2. **Firebase** — Firestore (NoSQL), Auth, Realtime, Storage
3. **Backend propio** — Node.js + Express + PostgreSQL, gestionado por el equipo
4. **AWS Amplify** — GraphQL, Auth, Storage

## Decisión
Se adopta **Supabase** como Backend-as-a-Service.

## Consecuencias
**Positivas:**
- **PostgreSQL estructurado** — mejor para relaciones complejas (conversaciones↔mensajes↔correcciones, usuarios↔perfiles↔idiomas) que Firestore (NoSQL)
- **RLS granular** — políticas de seguridad a nivel de fila más expresivas que Firebase Security Rules
- **Realtime nativo** — WebSockets basados en Postgres para salas de voz
- **Trigger `handle_new_user()`** — sincronización automática de `auth.users → public.users`
- **Cero gestión de servidores** — escalabilidad automática
- **SQL directo** — migraciones con control de versiones
- **MCP tools** — integración con herramientas de IA

**Negativas:**
- Menos ecosistema de extensiones que Firebase (Cloud Functions, ML Kit, Analytics)
- Sin equivalente a Firebase Cloud Messaging (notificaciones push)
- Realtime no es tan maduro como Firebase Realtime Database
- Dependencia de servicio externo

## Referencias
- [Supabase vs Firebase](https://supabase.com/alternatives/supabase-vs-firebase)
- [Supabase Documentation](https://supabase.com/docs)
