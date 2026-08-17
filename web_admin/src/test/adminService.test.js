import { describe, it, expect, vi, beforeEach } from 'vitest';

// ── Mock de supabase: resultados por tabla ─────────────────────────────────
const resultsByTable = {};
function setData(table, data) {
  resultsByTable[table] = { data, error: null };
}
function setError(table, error) {
  resultsByTable[table] = { data: null, error };
}

const chain = (table) => ({
  select: () => chain(table),
  order: () => chain(table),
  eq: () => chain(table),
  gt: () => chain(table),
  maybeSingle: () => {
    const r = resultsByTable[table]?.data;
    return Promise.resolve(Array.isArray(r) ? (r[0] ?? null) : (r ?? null));
  },
  then: (onFulfilled) => Promise.resolve(resultsByTable[table] ?? { data: [], error: null }).then(onFulfilled),
});

vi.mock('../lib/supabaseClient', () => ({
  supabase: {
    from: vi.fn((table) => chain(table)),
  },
}));

import { adminService } from '../services/adminService';

describe('adminService', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    Object.keys(resultsByTable).forEach((k) => delete resultsByTable[k]);
  });

  it('getSubscriptionPlans mapea estamento, maná, precios y stripe', async () => {
    setData('subscription_plans', [{
      id: 'noble',
      name: 'NOBLE',
      price: '$4.99',
      price_annual: '$49.99',
      billing_cycle: 'monthly',
      monthly_audio_minutes_limit: 300,
      order_index: 1,
      description: '',
      badge_tag: null,
      features: [],
      is_active: true,
      class_name: 'noble',
      mana_allowance: 18000,
      stripe_price_id: 'price_m',
      stripe_price_annual_id: 'price_a',
    }]);

    const plans = await adminService.getSubscriptionPlans();
    expect(plans).toHaveLength(1);
    expect(plans[0].className).toBe('noble');
    expect(plans[0].manaAllowance).toBe(18000);
    expect(plans[0].priceAnnual).toBe('$49.99');
    expect(plans[0].stripePriceAnnualId).toBe('price_a');
  });

  it('getScenarios devuelve SOLO filas de la DB (sin mezclar seeds)', async () => {
    setData('scenarios', [
      { id: 7, title: 'En el café', difficulty_level: 'A2', category: 'social', assistant_role: 'Barista' },
    ]);

    const scenarios = await adminService.getScenarios();
    expect(scenarios).toHaveLength(1);
    expect(scenarios[0].id).toBe('7');
    expect(scenarios[0].level).toBe('A2');
  });

  it('getScenarios devuelve [] ante error', async () => {
    setError('scenarios', new Error('boom'));
    const scenarios = await adminService.getScenarios();
    expect(scenarios).toEqual([]);
  });

  it('getCefrDistribution cuenta perfiles por nivel CEFR real', async () => {
    setData('user_language_profiles', [
      { cefr_level_id: 1 },
      { cefr_level_id: 1 },
      { cefr_level_id: 2 },
    ]);
    setData('cefr_levels', [
      { id: 1, code: 'A1', name: 'Principiante', color: '#fff' },
      { id: 2, code: 'A2', name: 'Elemental', color: '#eee' },
    ]);

    const dist = await adminService.getCefrDistribution();
    expect(dist).toEqual([
      { code: 'A1', name: 'Principiante', color: '#fff', count: 2, pct: 67 },
      { code: 'A2', name: 'Elemental', color: '#eee', count: 1, pct: 33 },
    ]);
  });
});
