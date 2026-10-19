# Graph Report - .  (2026-07-23)

## Corpus Check
- Large corpus: 188 files · ~1,159,535 words. Semantic extraction will be expensive (many Claude tokens). Consider running on a subfolder.

## Summary
- 103 nodes · 84 edges · 25 communities (10 shown, 15 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- System Architecture & Business Context
- Implementation Plan & Repair Strategy
- Voice Chat Architecture & Latency
- Database Schema & Tables
- Database Repair & CEFR Seeding
- Frontend Routing & Lesson Repair
- Data Model & UI Corrections
- Internationalization & Onboarding
- Web Admin Tooling & Linting
- Dashboard UI & Fallback Repairs
- Flutter App Core Setup
- Graphify Knowledge Graph Rules
- Graphify Workflow Specification
- iOS Launch Assets
- Web Admin App Component
- Web Admin GlassCard Component
- Web Admin Navbar Component
- Web Admin Sidebar Component
- Web Admin User Detail Modal
- Web Admin Overview Page
- Web Admin AI Settings
- Web Admin CEFR Manager
- Web Admin Lesson Manager
- Web Admin Subscriptions Manager
- Web Admin Biometrics Manager

## God Nodes (most connected - your core abstractions)
1. `Plan de Implementación — Corrección de Inconsistencias` - 14 edges
2. `Diccionario de Datos del Esquema Postgres` - 7 edges
3. `FASE 1: Reparación de Base de Datos (Ejecutar primero)` - 6 edges
4. `FASE 2: Reparación de Código Frontend (Crítico)` - 6 edges
5. `FASE 5: Correcciones del Modelo de Datos` - 5 edges
6. `Arquitectura de Voz y Alternativas STT para TutorSaas` - 5 edges
7. `3. Alternativas STT Evaluadas` - 5 edges
8. `1. RESUMEN EJECUTIVO` - 4 edges
9. `FASE 3: Reparación del Motor de Recomendaciones` - 4 edges
10. `FASE 6: Correcciones de Internacionalización` - 4 edges

## Surprising Connections (you probably didn't know these)
- None detected - all connections are within the same source files.

## Import Cycles
- None detected.

## Communities (25 total, 15 thin omitted)

### Community 0 - "System Architecture & Business Context"
Cohesion: 0.10
Nodes (19): 10. SEGURIDAD Y CONFIGURACIÓN, 11. MATRIZ DE RIESGOS TÉCNICOS Y DEUDA TÉCNICA, 12. GUÍA PARA FUTURAS IA Y PROMPT CONTEXT EXPORT, 1. RESUMEN EJECUTIVO, 2. DESCRIPCIÓN GENERAL DEL NEGOCIO, 3. MODELO DE NEGOCIO Y MONETIZACIÓN, 4. ARQUITECTURA GENERAL DEL SISTEMA, 5. ARQUITECTURA FRONTEND (FLUTTER) (+11 more)

### Community 1 - "Implementation Plan & Repair Strategy"
Cohesion: 0.12
Nodes (15): Convenciones, FASE 3: Reparación del Motor de Recomendaciones, FASE 7: Corrección de Nivel de Corrección, FASE 8: Limpieza de Código y Pruebas, ORDEN DE EJECUCIÓN RECOMENDADO, Plan de Implementación — Corrección de Inconsistencias, RESUMEN DE DEPENDENCIAS, Tarea L-1 🟡: Separar cases de correction level (+7 more)

### Community 2 - "Voice Chat Architecture & Latency"
Cohesion: 0.18
Nodes (10): 1. Causa Raíz del Corte de Audio en la Implementación Anterior, 2. Nueva Arquitectura: Grabación Raw + Groq Cloud Whisper STT, 3. Alternativas STT Evaluadas, 4. Configuración de Llaves de API, A. Groq Cloud API (Implementación Actual), Arquitectura de Voz y Alternativas STT para TutorSaas, B. Self-Hosted `faster-whisper` (100% Gratuito), C. On-Device Whisper (`whisper_flutter_plus` / `sherpa_onnx`) (+2 more)

### Community 3 - "Database Schema & Tables"
Cohesion: 0.25
Nodes (8): 1. `users`, 2. `user_language_profiles`, 3. `conversations`, 4. `messages`, 5. `daily_stats`, 6. ARQUITECTURA BACKEND Y BASE DE DATOS (SUPABASE), 6. `user_vocabulary` & `vocabulary_items`, Diccionario de Datos del Esquema Postgres

### Community 4 - "Database Repair & CEFR Seeding"
Cohesion: 0.33
Nodes (6): FASE 1: Reparación de Base de Datos (Ejecutar primero), Tarea DB-1 🟠: Poblar niveles CEFR faltantes (incluyendo C2), Tarea DB-2 🟠: Eliminar escenarios duplicados, Tarea DB-3 🟠: Re-poblar scenario_objectives, Tarea DB-4 🟠: Seed de achievements, Tarea DB-5 🟠: Verificar RLS policies

### Community 5 - "Frontend Routing & Lesson Repair"
Cohesion: 0.33
Nodes (6): FASE 2: Reparación de Código Frontend (Crítico), Tarea C-1 🔴: Router — Extraer scenarioId y pasarlo a ConversationScreen, Tarea C-2 🔴: LessonCatalog — Manejar null correctamente + agregar nivel C2, Tarea C-3 🔴: DashboardCar — Pasar scenarioTitle en la navegación, Tarea C-4 🔴: ConversationScreen — Manejar null de LessonData, Tarea C-5 🔴: ConversationNotifier — Manejar session sin scenarioId

### Community 6 - "Data Model & UI Corrections"
Cohesion: 0.40
Nodes (5): FASE 5: Correcciones del Modelo de Datos, Tarea D-2 🟡: Dashboard — Mostrar nivel C2 correctamente en LessonCard, Tarea D-3 🟡: Onboarding — Agregar C2 como opción de nivel, Tarea D-4 🟡: ConversationNotifier — Incluir C2 en system prompt, Tarea M-1 🟡: Completar UserSettings con interests y motivation

### Community 7 - "Internationalization & Onboarding"
Cohesion: 0.50
Nodes (4): FASE 6: Correcciones de Internacionalización, Tarea I-1 🟡: Texto dinámico en onboarding según idioma seleccionado, Tarea I-2 🟡: Verificar que todos los textos de onboarding se adapten al idioma, Tarea I-3 🟡: Onboarding — Agregar C2 en _buildStudyPlan y _buildPlacementResultPage

### Community 8 - "Web Admin Tooling & Linting"
Cohesion: 0.50
Nodes (3): Expanding the Oxlint configuration, React Compiler, React + Vite

### Community 9 - "Dashboard UI & Fallback Repairs"
Cohesion: 0.67
Nodes (3): FASE 4: Correcciones del Dashboard (Fallback y UI), Tarea D-1 🟡: Corregir fallback mock con IDs válidos, Tarea D-2 🟡: Mejorar MicPulseButton para abrir con lección por defecto

## Knowledge Gaps
- **74 isolated node(s):** `App`, `GlassCard`, `Navbar`, `Sidebar`, `UserDetailModal` (+69 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **15 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Plan de Implementación — Corrección de Inconsistencias` connect `Implementation Plan & Repair Strategy` to `Database Repair & CEFR Seeding`, `Frontend Routing & Lesson Repair`, `Data Model & UI Corrections`, `Internationalization & Onboarding`, `Dashboard UI & Fallback Repairs`?**
  _High betweenness centrality (0.132) - this node is a cross-community bridge._
- **Why does `FASE 1: Reparación de Base de Datos (Ejecutar primero)` connect `Database Repair & CEFR Seeding` to `Implementation Plan & Repair Strategy`?**
  _High betweenness centrality (0.035) - this node is a cross-community bridge._
- **Why does `FASE 2: Reparación de Código Frontend (Crítico)` connect `Frontend Routing & Lesson Repair` to `Implementation Plan & Repair Strategy`?**
  _High betweenness centrality (0.035) - this node is a cross-community bridge._
- **What connects `App`, `GlassCard`, `Navbar` to the rest of the system?**
  _74 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `System Architecture & Business Context` be split into smaller, more focused modules?**
  _Cohesion score 0.1 - nodes in this community are weakly interconnected._
- **Should `Implementation Plan & Repair Strategy` be split into smaller, more focused modules?**
  _Cohesion score 0.125 - nodes in this community are weakly interconnected._