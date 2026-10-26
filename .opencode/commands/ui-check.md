---
description: Audita UI contra paleta, tipografía, radios, i18n y overflow
agent: design-auditor
---

Audita la interfaz indicada: $ARGUMENTS

Si no indico pantalla, revisa solo lo que haya cambiado en el diff actual (`git diff --stat`).

Comprueba, en este orden:

1. Paleta y radios: solo `AppColors` y radios de 4 px (excepciones: avatares y orbes).
2. Tipografía: Space Grotesk (títulos), Inter (cuerpo), JetBrains Mono (datos). Nada nuevo.
3. i18n: ninguna cadena hardcodeada; claves presentes en `app_en/es/pt.arb`.
4. Overflow y escalado: textos largos y `textScale` 1.5 en es/en/pt.
5. Trampa `GlassCard`: el tap debe ir en `onTap:`, no en un `GestureDetector` externo.

Salida (máximo 400 palabras): tabla `Severidad | Archivo:línea | Problema | Arreglo`.
No edites archivos; no ejecutes `flutter build`.
