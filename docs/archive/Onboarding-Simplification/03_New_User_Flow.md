# Flujo Nuevo Simplificado del Onboarding

**Fecha:** 2026-08-02
**Objetivo:** documentar el recorrido del nuevo usuario tras la simplificación post-i18n.

---

## 1. Idea central

**El idioma de interfaz YA NO se pregunta durante el onboarding.** Se detecta automáticamente a partir del idioma del dispositivo (`followDeviceLanguage` + `deviceLocaleProvider`) y se aplica a la app en `app.dart` (`effectiveUiLanguageProvider`). El usuario que quiera cambiarlo lo hace después, desde **Configuración**.

Eliminar esa pregunta quita **un paso de fricción** y deja el onboarding enfocado en lo que la app sí necesita saber: **dónde empiezas, a dónde vas y quién eres** (nativo → objetivo → país → nivel → personaje).

---

## 2. Los 7 pasos conceptuales

> El widget implementa el cuestionario en un `PageView` de 5 pasos (`onboarding_screen.dart:343-353`) precedido por la bienvenida y seguido por la tarjeta del héroe. A efectos conceptuales (y de documentación de producto), el flujo tiene **7 pasos**:

```
1. BIENVENIDA        WelcomeScreen  →  /splash, /

2. IDIOMA NATIVO     Paso 0  _buildNativeLanguagePage       (8 idiomas: es/en/fr/de/pt/it/zh/ja)
   └─ (ANTES: también preguntaba idioma de interfaz → ❌ eliminado)

3. IDIOMA OBJETIVO   Paso 2  _buildTargetLanguagePage       (4 idiomas: en/fr/de/it)

4. PAÍS              Paso 1  _buildCountryPage              (autocomplete ISO completo, sin "sugeridos")

5. EVALUACIÓN ORÁCULO Paso 3 _buildAiClassificationPage     (por VOZ, /oracle-test — opcional)
   │   └─ devuelve cefrLevel + gameRank al flujo
   │   └─ si se omite → A1

6. PERSONAJE         Paso 4  _buildCharacterCreationPage     (CharacterCreationWizard: 8 clases + avatar)

7. TARJETA DEL
   AVENTURERO        _buildHeroWelcomeScreen                (resumen héroe → /home)
```

**Nota de implementación:** en el `PageView` el **País** es el paso físico 1 (va entre idioma nativo e idioma objetivo, `onboarding_screen.dart:348`). El diagrama conceptual de producto lo muestra después del objetivo por claridad de lectura; el orden de código es: **0 nativo → 1 país → 2 objetivo → 3 oráculo → 4 personaje**.

---

## 3. Detalle paso a paso

### 3.1 Bienvenida
`WelcomeScreen` (primera pantalla, vía `/splash`). Sin preguntas: entrada temática al "Sistema".

### 3.2 Idioma nativo (Paso 0)
Una sola pregunta: **¿cuál es tu idioma nativo?** (8 opciones).
El idioma de interfaz se comunica como un aviso informativo (`SystemSnack`, `onboarding_screen.dart:78-91`) — ya no como pregunta.

### 3.3 Idioma objetivo (Paso 2)
¿Qué idioma quieres aprender? (en/fr/de/it). Al completar, se persiste `learningLanguage`.

### 3.4 País (Paso 1)
Autocomplete sobre el **catálogo ISO completo** (`CountryCatalog`), sin atajos "sugeridos". Se guarda `country_code`.

### 3.5 Evaluación del Oráculo (Paso 3 — opcional)
- Conversación **por voz** vía `/oracle-test` (`context.push('/oracle-test')`).
- Devuelve `cefrLevel` y `gameRank`, que alimentan la tarjeta del aventurero.
- Si se omite → default `A1` (línea 171).
- ❌ Ya no existe la alternativa escrita `/oracle-quiz` (eliminada por duplicada y huérfana — ver Doc 02).

### 3.6 Creación del personaje (Paso 4)
Wizard con **8 clases** + selección de avatar. Guarda `character_class` y `avatar_index`.

### 3.7 Tarjeta del Aventurero
Resumen final: nombre, clase, píldoras **CEFR** y **rango** + descripción del rango. CTA "Entrar al Reino" → `/home`. El `paywall` se presenta **post-sesión** (UX-02), no aquí.

---

## 4. Antes vs. Ahora

| Aspecto | Antes | Ahora |
|---|---|---|
| Idioma de interfaz | Switch manual en el Paso 0 | ❌ No se pregunta — detección automática por dispositivo |
| `uiLanguage` al completar | Se forzaba al idioma nativo | ❌ No se persiste (la interfaz sigue al dispositivo) |
| Evaluación | `/oracle-test` (voz) + `/oracle-quiz` (escrita, duplicada) | ✅ Solo `/oracle-test` (voz, canónica) |
| Pasos del cuestionario | 5 (con switch extra en el paso 0) | 5 (mismo PageView, paso 0 reducido a una pregunta) |
| Rutas internas del router | `/splash`, `/onboarding`, `/oracle-test`, `/oracle-quiz`, `/disruption` | ✅ `/splash`, `/onboarding`, `/oracle-test`, `/disruption` |

---

## 5. Diagrama de texto (flujo completo)

```
          ┌─────────────┐
          │  BIENVENIDA │  WelcomeScreen
          └──────┬──────┘
                 ▼
          ┌─────────────┐   idioma nativo
          │ IDIOMA NATIVO│  (es/en/fr/de/pt/it/zh/ja)
          └──────┬──────┘
                 ▼
          ┌─────────────┐   idioma a aprender
          │IDIOMA OBJET.│  (en/fr/de/it)
          └──────┬──────┘
                 ▼
          ┌─────────────┐   autocomplete ISO completo
          │    PAÍS     │   (sin "sugeridos")
          └──────┬──────┘
                 ▼
          ┌─────────────┐   ┌─────────────────────────┐
          │EVAL. ORÁCULO│──►│ /oracle-test (VOZ)      │
          │  (opcional) │   │ devuelve cefr + rank    │
          └──────┬──────┘   └─────────────────────────┘
                 │  (si se omite → A1)
                 ▼
          ┌─────────────┐
          │  PERSONAJE  │   CharacterCreationWizard (8 clases + avatar)
          └──────┬──────┘
                 ▼
          ┌─────────────┐
          │ TARJETA DEL │   nombre · clase · CEFR · rango
          │ AVENTURERO  │
          └──────┬──────┘
                 ▼
                 /home   (Dashboard — paywall post-sesión)
```

---

## 6. Qué NO se pregunta nunca más

1. **Idioma de la interfaz** — se detecta automáticamente; se cambia en Configuración.
2. Nada sobre **premium/paywall** — se ofrece tras la primera sesión.
3. El **quiz escrito** de nivel — la evaluación es solo por voz (Oráculo).
