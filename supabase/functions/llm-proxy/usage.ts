// Helpers puros del registro de uso de IA (P-14 / #99).
//
// Se separan de index.ts para poder probarlos sin levantar el servidor HTTP.
// No guardan texto de conversaciones: solo metadatos y contadores.

export const DEFAULT_PRICE_INPUT_USD_PER_1M = 0.27;
export const DEFAULT_PRICE_OUTPUT_USD_PER_1M = 1.10;
export const DEFAULT_PRICE_STT_USD_PER_MINUTE = 0.000667;

export interface AiPrices {
  inputUsdPer1M: number;
  outputUsdPer1M: number;
  sttUsdPerMinute: number;
}

export interface ChatUsage {
  inputTokens: number | null;
  outputTokens: number | null;
}

const ACTION_CODE_RE = /^[a-z][a-z0-9_]{2,39}$/;
const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

/// Normaliza el `action_code` que manda el cliente. No se confía en el valor
/// (P-07 lo validará además contra `ai_action_costs`); aquí solo se evita
/// guardar basura o texto libre.
export function normalizeActionCode(value: unknown, fallback = 'unknown'): string {
  const raw = typeof value === 'string' ? value.trim().toLowerCase() : '';
  return ACTION_CODE_RE.test(raw) ? raw : fallback;
}

/// `conversation_id` solo se guarda si es un UUID válido (la columna es UUID).
export function normalizeUuid(value: unknown): string | null {
  const raw = typeof value === 'string' ? value.trim() : '';
  return UUID_RE.test(raw) ? raw : null;
}

function priceFromEnv(name: string, fallback: number): number {
  const parsed = Number(Deno.env.get(name));
  return Number.isFinite(parsed) && parsed >= 0 ? parsed : fallback;
}

export function readPrices(): AiPrices {
  return {
    inputUsdPer1M: priceFromEnv('AI_PRICE_INPUT_PER_1M', DEFAULT_PRICE_INPUT_USD_PER_1M),
    outputUsdPer1M: priceFromEnv('AI_PRICE_OUTPUT_PER_1M', DEFAULT_PRICE_OUTPUT_USD_PER_1M),
    sttUsdPerMinute: priceFromEnv('AI_PRICE_STT_PER_MINUTE', DEFAULT_PRICE_STT_USD_PER_MINUTE),
  };
}

export function estimateChatCostUsd(
  usage: ChatUsage,
  prices: AiPrices = readPrices(),
): number | null {
  if (usage.inputTokens == null && usage.outputTokens == null) return null;
  const input = (usage.inputTokens ?? 0) / 1_000_000 * prices.inputUsdPer1M;
  const output = (usage.outputTokens ?? 0) / 1_000_000 * prices.outputUsdPer1M;
  return round6(input + output);
}

export function estimateTranscribeCostUsd(
  audioSeconds: number | null,
  prices: AiPrices = readPrices(),
): number | null {
  if (audioSeconds == null || !Number.isFinite(audioSeconds) || audioSeconds < 0) return null;
  return round6((audioSeconds / 60) * prices.sttUsdPerMinute);
}

export function round6(value: number): number {
  return Math.round(value * 1_000_000) / 1_000_000;
}

/// Extrae `usage` de una respuesta JSON de chat completions (no streaming).
export function extractUsageFromChatResponse(data: unknown): ChatUsage {
  const usage = (data as { usage?: Record<string, unknown> } | null)?.usage;
  return {
    inputTokens: numberOrNull(usage?.prompt_tokens),
    outputTokens: numberOrNull(usage?.completion_tokens),
  };
}

/// Extrae el último `usage` de un trozo de SSE. Se le pasa el buffer acumulado
/// (acotado por el llamador), no una línea, porque los chunks pueden cortar una
/// línea por la mitad. Devuelve null si aún no ha llegado.
export function extractUsageFromSse(text: string): ChatUsage | null {
  let found: ChatUsage | null = null;
  for (const line of text.split('\n')) {
    const trimmed = line.trim();
    if (!trimmed.startsWith('data:')) continue;
    const payload = trimmed.slice(5).trim();
    if (!payload || payload === '[DONE]') continue;
    try {
      const parsed = JSON.parse(payload) as { usage?: Record<string, unknown> };
      if (!parsed.usage) continue;
      found = {
        inputTokens: numberOrNull(parsed.usage.prompt_tokens),
        outputTokens: numberOrNull(parsed.usage.completion_tokens),
      };
    } catch {
      // Línea incompleta (chunk partido): se ignora y se reintenta en el
      // siguiente fragmento.
    }
  }
  return found;
}

function numberOrNull(value: unknown): number | null {
  return typeof value === 'number' && Number.isFinite(value) ? value : null;
}
