// Validación de entrada y política de cobro del `llm-proxy` (P-18 / #103).
//
// Este módulo es puro a propósito: no importa Supabase ni lee `Deno.env` en
// top-level, así que se puede probar con `deno test` sin red ni credenciales.
// `index.ts` importa estas funciones; aquí vive la única copia de los topes.

// Issue #9: límite de audio por transcripción (10 MB). Vive en `index.ts`
// porque solo lo usa `handleTranscribe`.

// P-07: límites de entrada (tokens de prompt bajo control del servidor).
export const MAX_MESSAGES = 40;
export const MAX_CHARS_PER_MESSAGE = 4000;
export const MAX_TOTAL_CHARS = 24000;

// P-07: acciones que NO se cobran (evaluaciones internas y chat de gremio).
export const FREE_ACTIONS: ReadonlySet<string> = new Set([
  'goal_eval',
  'carisma_eval',
  'guild_chat',
  'stt_transcribe',
]);

/// Modos de cobro de maná (`MANA_CHARGE_MODE`).
export type ManaChargeMode = 'capability' | 'all' | 'off';

/// Normaliza `MANA_CHARGE_MODE`; un valor desconocido cae en `capability`
/// (el modo de transición seguro: no cobra dos veces a las builds viejas).
export function normalizeManaChargeMode(value: string | null | undefined): ManaChargeMode {
  const mode = (value ?? '').trim().toLowerCase();
  if (mode === 'all' || mode === 'off') return mode;
  return 'capability';
}

/// P-07: ¿hay que cobrar este turno?
/// - `capability`: solo si el cliente declara `server_mana`.
/// - `all`: siempre (estado final; cierra el hueco de clientes modificados).
/// - `off`: nunca (rollback de emergencia).
export function shouldCharge(capabilities: string[], mode: ManaChargeMode): boolean {
  if (mode === 'off') return false;
  if (mode === 'capability') return capabilities.includes('server_mana');
  return true;
}

/// Solo acepta strings cortos y como mucho 10 capacidades.
export function normalizeCapabilities(value: unknown): string[] {
  if (!Array.isArray(value)) return [];
  return value
    .filter((item): item is string => typeof item === 'string' && item.length <= 40)
    .slice(0, 10);
}

/// Devuelve un mensaje de error si el prompt excede los topes de P-07.
export function validateMessages(messages: unknown[]): string | null {
  if (messages.length === 0) return 'messages array is empty';
  if (messages.length > MAX_MESSAGES) return `too many messages (max ${MAX_MESSAGES})`;
  let total = 0;
  for (const message of messages) {
    const content = (message as { content?: unknown })?.content;
    if (typeof content !== 'string') return 'each message content must be a string';
    if (content.length > MAX_CHARS_PER_MESSAGE) {
      return `message too long (max ${MAX_CHARS_PER_MESSAGE} chars)`;
    }
    total += content.length;
  }
  if (total > MAX_TOTAL_CHARS) return `conversation too long (max ${MAX_TOTAL_CHARS} chars)`;
  return null;
}
