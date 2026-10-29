// Pruebas de validación de entrada y de maná del `llm-proxy` (P-18 / #103).
// Ejecutar: deno test supabase/functions/llm-proxy/validation_test.ts
//
// Sin red ni credenciales: `validation.ts` es puro y no importa Supabase.
// Lo que se protege aquí es lo que decide cuánto se cobra y qué se acepta.

import { assert, assertEquals } from 'jsr:@std/assert@1';
import {
  FREE_ACTIONS,
  MAX_CHARS_PER_MESSAGE,
  MAX_MESSAGES,
  MAX_TOTAL_CHARS,
  normalizeCapabilities,
  normalizeManaChargeMode,
  shouldCharge,
  validateMessages,
} from './validation.ts';

// ── Maná ─────────────────────────────────────────────────────────────────────

Deno.test('modo capability: solo cobra si el cliente declara server_mana', () => {
  assertEquals(shouldCharge(['server_mana'], 'capability'), true);
  assertEquals(shouldCharge([], 'capability'), false);
  assertEquals(shouldCharge(['other'], 'capability'), false);
});

Deno.test('modo all cobra siempre y off nunca cobra', () => {
  assertEquals(shouldCharge([], 'all'), true);
  assertEquals(shouldCharge(['server_mana'], 'all'), true);
  assertEquals(shouldCharge(['server_mana'], 'off'), false);
  assertEquals(shouldCharge([], 'off'), false);
});

Deno.test('un MANA_CHARGE_MODE desconocido cae en el modo de transición', () => {
  assertEquals(normalizeManaChargeMode(''), 'capability');
  assertEquals(normalizeManaChargeMode(null), 'capability');
  assertEquals(normalizeManaChargeMode('  OFF '), 'off');
  assertEquals(normalizeManaChargeMode('All'), 'all');
  assertEquals(normalizeManaChargeMode('cobrar-todo'), 'capability');
});

Deno.test('las evaluaciones internas y el chat de gremio son gratuitas', () => {
  for (const action of ['goal_eval', 'carisma_eval', 'guild_chat', 'stt_transcribe']) {
    assert(FREE_ACTIONS.has(action), `${action} debe ser gratuita`);
  }
  assert(!FREE_ACTIONS.has('free_chat_turn'));
  assert(!FREE_ACTIONS.has('correction_turn'));
});

// ── Capacidades del cliente (entrada manipulable) ────────────────────────────

Deno.test('normalizeCapabilities descarta lo que no es string corto', () => {
  assertEquals(normalizeCapabilities(undefined), []);
  assertEquals(normalizeCapabilities('server_mana'), []);
  assertEquals(normalizeCapabilities({ 0: 'server_mana' }), []);
  assertEquals(
    normalizeCapabilities(['server_mana', 42, null, { a: 1 }, 'x'.repeat(41)]),
    ['server_mana'],
  );
});

Deno.test('normalizeCapabilities limita a 10 entradas', () => {
  const many = Array.from({ length: 25 }, (_, i) => `cap_${i}`);
  assertEquals(normalizeCapabilities(many).length, 10);
});

// ── Mensajes ─────────────────────────────────────────────────────────────────

Deno.test('un prompt válido pasa la validación', () => {
  assertEquals(
    validateMessages([
      { role: 'system', content: 'You are a tutor.' },
      { role: 'user', content: 'Hello' },
    ]),
    null,
  );
});

Deno.test('una lista vacía se rechaza', () => {
  assertEquals(validateMessages([]), 'messages array is empty');
});

Deno.test('demasiados mensajes se rechazan', () => {
  const messages = Array.from({ length: MAX_MESSAGES + 1 }, () => ({ content: 'hi' }));
  assertEquals(
    validateMessages(messages),
    `too many messages (max ${MAX_MESSAGES})`,
  );
});

Deno.test('un mensaje demasiado largo se rechaza', () => {
  const error = validateMessages([{ content: 'x'.repeat(MAX_CHARS_PER_MESSAGE + 1) }]);
  assertEquals(error, `message too long (max ${MAX_CHARS_PER_MESSAGE} chars)`);
});

Deno.test('content que no es string se rechaza (no se cuela un objeto)', () => {
  assertEquals(
    validateMessages([{ content: { injected: true } }]),
    'each message content must be a string',
  );
  assertEquals(validateMessages([{ content: null }]), 'each message content must be a string');
});

Deno.test('el total de caracteres tiene tope (prompt bombing)', () => {
  const perMessage = MAX_CHARS_PER_MESSAGE;
  const count = Math.floor(MAX_TOTAL_CHARS / perMessage) + 1;
  const messages = Array.from({ length: count }, () => ({ content: 'x'.repeat(perMessage) }));
  assertEquals(
    validateMessages(messages),
    `conversation too long (max ${MAX_TOTAL_CHARS} chars)`,
  );
});
