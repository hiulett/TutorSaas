import { describe, it, expect, vi, beforeEach } from 'vitest';

// ── Mock de supabase: resultados por tabla ─────────────────────────────────
const resultsByTable = {};
function setData(table, data) {
  resultsByTable[table] = { data, error: null };
}
function setError(table, error) {
  resultsByTable[table] = { data: null, error };
}

const chain = (table, opts = {}) => ({
  select: (cols, countOpts) => chain(table, { ...opts, head: !!countOpts?.head }),
  order: () => chain(table, opts),
  eq: () => chain(table, opts),
  gt: () => chain(table, opts),
  gte: () => chain(table, opts),
  in: () => chain(table, opts),
  maybeSingle: () => {
    const r = resultsByTable[table]?.data;
    return Promise.resolve(Array.isArray(r) ? (r[0] ?? null) : (r ?? null));
  },
  then: (onFulfilled) => {
    const base = resultsByTable[table] ?? { data: [], error: null };
    const result = opts.head ? { ...base, count: Array.isArray(base.data) ? base.data.length : 0 } : base;
    return Promise.resolve(result).then(onFulfilled);
  },
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

  it('getOnlineUsers cuenta presencia activa y agrupa por sección', async () => {
    setData('user_presence', [
      { user_id: 'u1', section: 'dashboard' },
      { user_id: 'u2', section: 'dashboard' },
      { user_id: 'u3', section: 'voice_room' },
      { user_id: 'u4', section: 'background' },
    ]);

    const result = await adminService.getOnlineUsers();
    expect(result.online).toBe(4);
    expect(result.bySection).toEqual([
      { section: 'dashboard', count: 2 },
      { section: 'voice_room', count: 1 },
      { section: 'background', count: 1 },
    ]);
  });

  it('getOnlineUsers devuelve 0 ante error', async () => {
    setError('user_presence', new Error('boom'));
    const result = await adminService.getOnlineUsers();
    expect(result).toEqual({ online: 0, bySection: [] });
  });
});
