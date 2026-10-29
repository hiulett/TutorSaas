// Pruebas de las plantillas del email de reactivación (issue #107).
// Ejecutar: deno test supabase/functions/reactivation-email/templates_test.ts

import {
  assertEquals,
  assertStringIncludes,
} from 'jsr:@std/assert@1';
import { normalizeLocale, renderEmail } from './templates.ts';

const base = {
  name: 'Aria',
  streak: 12,
  daysInactive: 7,
  appUrl: 'https://play.google.com/store/apps/details?id=com.tutorsaas.tutorsaas',
  unsubscribeUrl:
    'https://sipiumfdpvnszthykyog.supabase.co/functions/v1/reactivation-email?unsubscribe=abc',
};

Deno.test('renderiza los tres idiomas con el nombre y la racha', () => {
  for (const locale of ['es', 'en', 'pt'] as const) {
    const content = renderEmail(locale, base);
    assertStringIncludes(content.subject, 'Aria');
    assertStringIncludes(content.subject, '12');
    assertStringIncludes(content.html, 'Aria');
    assertStringIncludes(content.html, base.unsubscribeUrl);
    assertStringIncludes(content.text, base.appUrl);
  }
});

Deno.test('escapa el nombre para no inyectar HTML', () => {
  const content = renderEmail('es', { ...base, name: '<script>alert(1)</script>' });
  assertEquals(content.html.includes('<script>'), false);
  assertStringIncludes(content.html, '&lt;script&gt;');
});

Deno.test('usa el nombre genérico cuando no hay nombre', () => {
  const content = renderEmail('es', { ...base, name: '  ', streak: 0 });
  assertStringIncludes(content.text, 'cazador');
  assertStringIncludes(content.subject, 'cazador');
});

Deno.test('normalizeLocale cae a es', () => {
  assertEquals(normalizeLocale('en'), 'en');
  assertEquals(normalizeLocale('pt'), 'pt');
  assertEquals(normalizeLocale('fr'), 'es');
  assertEquals(normalizeLocale(null), 'es');
  assertEquals(normalizeLocale('ES'), 'es');
});
