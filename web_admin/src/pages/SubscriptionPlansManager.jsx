import React, { useState } from 'react';
import GlassCard from '../components/GlassCard';
import { CreditCard, Edit3, Save, X, Plus, Clock, ShieldCheck, Zap, Sparkles, CheckCircle2, AlertCircle, ArrowUp, Hash, RefreshCw, Trash2 } from 'lucide-react';

export default function SubscriptionPlansManager({ plans, onSavePlan, onDeletePlan }) {
  const [editingPlan, setEditingPlan] = useState(null);
  const [formData, setFormData] = useState({
    id: '',
    name: '',
    price: '',
    priceAnnual: '',
    billingCycle: 'monthly',
    monthlyAudioMinutesLimit: 300,
    orderIndex: 1,
    description: '',
    tag: '',
    featuresStr: '',
    className: 'plebeyo',
    manaAllowance: 18000,
    stripePriceId: '',
    stripePriceAnnualId: '',
  });

  const sortedPlans = [...plans].sort((a, b) => (a.orderIndex || 1) - (b.orderIndex || 1));

  const handleEdit = (plan) => {
    setEditingPlan(plan);
    setFormData({
      id: plan.id,
      name: plan.name,
      price: plan.price,
      priceAnnual: plan.priceAnnual || plan.price_annual || '',
      billingCycle: plan.billingCycle || plan.billing_cycle || 'monthly',
      monthlyAudioMinutesLimit: plan.monthlyAudioMinutesLimit || 300,
      orderIndex: plan.orderIndex || 1,
      description: plan.description || '',
      tag: plan.tag || '',
      featuresStr: (plan.features || []).join('\n'),
      className: plan.className || plan.class_name || 'plebeyo',
      manaAllowance: plan.manaAllowance || ((plan.monthlyAudioMinutesLimit || 300) * 60),
      stripePriceId: plan.stripePriceId || plan.stripe_price_id || '',
      stripePriceAnnualId: plan.stripePriceAnnualId || plan.stripe_price_annual_id || '',
    });
  };

  const handleCreateNew = () => {
    setEditingPlan({ id: '' });
    setFormData({
      id: `plan_${Date.now().toString().slice(-4)}`,
      name: '',
      price: '$1.99',
      priceAnnual: '',
      billingCycle: 'monthly',
      monthlyAudioMinutesLimit: 300,
      orderIndex: sortedPlans.length + 1,
      description: '',
      tag: '',
      featuresStr: 'Conversaciones IA ilimitadas\nCorrección gramatical avanzada\nSpeech DNA completo',
      className: 'noble',
      manaAllowance: 18000,
      stripePriceId: '',
      stripePriceAnnualId: '',
    });
  };

  const handleSave = async () => {
    if (!formData.name.trim() || !formData.price.trim() || !formData.id.trim()) return;
    const updatedPlan = {
      id: formData.id.toLowerCase().replace(/\s+/g, '_'),
      name: formData.name.trim(),
      price: formData.price.trim(),
      priceAnnual: formData.priceAnnual.trim() || null,
      billingCycle: formData.billingCycle,
      monthlyAudioMinutesLimit: parseInt(formData.monthlyAudioMinutesLimit, 10) || 300,
      orderIndex: parseInt(formData.orderIndex, 10) || 1,
      description: formData.description.trim(),
      tag: formData.tag.trim() || null,
      features: formData.featuresStr.split('\n').filter((f) => f.trim().length > 0),
      isActive: true,
      className: formData.className,
      manaAllowance: parseInt(formData.manaAllowance, 10) || ((parseInt(formData.monthlyAudioMinutesLimit, 10) || 300) * 60),
      stripePriceId: formData.stripePriceId.trim() || null,
      stripePriceAnnualId: formData.stripePriceAnnualId.trim() || null,
    };

    if (onSavePlan) {
      await onSavePlan(updatedPlan);
    }
    setEditingPlan(null);
  };

  const handleDelete = (plan) => {
    const ok = window.confirm(`¿Eliminar el plan "${plan.name}" (${plan.id})? Se desactivará y dejará de mostrarse.`);
    if (ok && onDeletePlan) onDeletePlan(plan.id);
  };

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '24px' }}>
      {/* Header */}
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', flexWrap: 'wrap', gap: '16px' }}>
        <div>
          <h1 style={{ fontSize: '26px', fontWeight: '800', color: '#fff' }}>Gestión de Planes de Membresía y Límites de Tiempo IA</h1>
          <p style={{ color: 'var(--text-muted)', fontSize: '14px', marginTop: '4px' }}>
            Edita los precios, orden de visualización (<code style={{ color: 'var(--secondary-teal)' }}>order_index</code>), límites de minutos y características.
          </p>
        </div>
        <button className="btn-primary" onClick={handleCreateNew}>
          <Plus style={{ width: '18px', height: '18px' }} />
          <span>Crear Nuevo Plan en DB</span>
        </button>
      </div>

      {/* Empty State if 0 plans in DB */}
      {sortedPlans.length === 0 ? (
        <GlassCard padding="48px" style={{ textAlign: 'center', display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '16px' }}>
          <div style={{ padding: '16px', borderRadius: '50%', background: 'rgba(168, 85, 247, 0.1)', color: 'var(--primary-purple)' }}>
            <AlertCircle style={{ width: '48px', height: '48px' }} />
          </div>
          <h2 style={{ fontSize: '20px', fontWeight: '800', color: '#fff' }}>No hay planes de membresía en la base de datos</h2>
          <p style={{ color: 'var(--text-muted)', fontSize: '14px', maxWidth: '500px' }}>
            Actualmente la tabla <code style={{ color: 'var(--secondary-teal)' }}>subscription_plans</code> en Supabase PostgreSQL no contiene registros. Haz clic abajo para crear tu primer plan o ejecutar la migración SQL.
          </p>
          <button className="btn-primary" onClick={handleCreateNew} style={{ marginTop: '8px' }}>
            <Plus style={{ width: '18px', height: '18px' }} />
            <span>Crear Primer Plan en DB</span>
          </button>
        </GlassCard>
      ) : (
        /* Grid of Subscription Plans sorted by orderIndex */
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(300px, 1fr))', gap: '20px' }}>
          {sortedPlans.map((p) => (
            <GlassCard key={p.id} padding="24px" style={{ position: 'relative', border: p.tag ? '1px solid var(--border-glass-glow)' : '1px solid var(--border-glass)' }}>
              {/* Order Index & Badge Header */}
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '12px' }}>
                <span style={{
                  padding: '2px 8px',
                  borderRadius: '8px',
                  fontSize: '11px',
                  fontWeight: '800',
                  background: 'rgba(56, 189, 248, 0.15)',
                  color: 'var(--secondary-teal)',
                  border: '1px solid rgba(56, 189, 248, 0.3)',
                  fontFamily: 'var(--font-mono)',
                }}>
                  Posición #{p.orderIndex || 1}
                </span>

                {p.tag && (
                  <span style={{
                    padding: '3px 8px',
                    borderRadius: '10px',
                    fontSize: '11px',
                    fontWeight: '800',
                    background: 'rgba(168, 85, 247, 0.2)',
                    color: 'var(--primary-purple)',
                    border: '1px solid var(--primary-purple)',
                  }}>
                    {p.tag}
                  </span>
                )}
              </div>

              <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '16px' }}>
                <div style={{ padding: '10px', borderRadius: '12px', background: 'rgba(168,85,247,0.15)', color: 'var(--primary-purple)' }}>
                  <CreditCard style={{ width: '24px', height: '24px' }} />
                </div>
                <div>
                  <h3 style={{ fontSize: '18px', fontWeight: '800', color: '#fff' }}>{p.name}</h3>
                  <span style={{ fontSize: '12px', color: 'var(--text-muted)' }}>ID: {p.id}</span>
                  {p.updatedAt && (
                    <div style={{ fontSize: '11px', color: 'var(--text-muted)', marginTop: '2px', fontFamily: 'var(--font-mono)' }}>
                      Editado {new Date(p.updatedAt).toLocaleString()} · {p.updatedBy.slice(0, 8)}
                    </div>
                  )}
                </div>
              </div>

                <div style={{ marginBottom: '16px' }}>
                  <div style={{ fontSize: '32px', fontWeight: '900', color: '#fff', fontFamily: 'var(--font-mono)' }}>
                    {p.price}
                  </div>
                  <div style={{ fontSize: '12px', color: 'var(--text-muted)', marginTop: '2px' }}>
                    {p.billingCycle || p.billing_cycle || 'monthly'} {p.billing ? `— ${p.billing}` : ''}
                  </div>
                </div>

              {/* AI Time Limit Highlight */}
              <div style={{ background: 'rgba(56, 189, 248, 0.1)', border: '1px solid rgba(56, 189, 248, 0.3)', borderRadius: '12px', padding: '12px', marginBottom: '16px' }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: '8px', color: 'var(--secondary-teal)', fontWeight: '700', fontSize: '13px' }}>
                  <Clock style={{ width: '16px', height: '16px' }} />
                  <span>Límite de Conversación IA</span>
                </div>
                <div style={{ fontSize: '16px', fontWeight: '800', color: '#fff', marginTop: '4px', fontFamily: 'var(--font-mono)' }}>
                  {p.monthlyAudioMinutesLimit} min/mes ({Math.round(p.monthlyAudioMinutesLimit / 60)} hrs)
                </div>
              </div>

              {/* Estamento + Maná + Stripe */}
              <div style={{ display: 'flex', gap: '12px', flexWrap: 'wrap', marginBottom: '16px' }}>
                <div style={{ flex: 1, minWidth: '140px', background: 'rgba(168, 85, 247, 0.1)', border: '1px solid rgba(168, 85, 247, 0.3)', borderRadius: '12px', padding: '12px' }}>
                  <div style={{ fontSize: '11px', color: 'var(--text-muted)', textTransform: 'uppercase', letterSpacing: '0.5px' }}>Estamento</div>
                  <div style={{ fontSize: '16px', fontWeight: '800', color: '#fff', marginTop: '4px', fontFamily: 'var(--font-mono)' }}>
                    {(p.className || 'plebeyo').toUpperCase()}
                  </div>
                </div>
                <div style={{ flex: 1, minWidth: '140px', background: 'rgba(56, 189, 248, 0.1)', border: '1px solid rgba(56, 189, 248, 0.3)', borderRadius: '12px', padding: '12px' }}>
                  <div style={{ fontSize: '11px', color: 'var(--text-muted)', textTransform: 'uppercase', letterSpacing: '0.5px' }}>Maná / Mes</div>
                  <div style={{ fontSize: '16px', fontWeight: '800', color: '#fff', marginTop: '4px', fontFamily: 'var(--font-mono)' }}>
                    {(p.manaAllowance || 1800).toLocaleString()}
                  </div>
                </div>
                {p.stripePriceId && (
                  <div style={{ flex: 1, minWidth: '160px', background: 'rgba(56, 189, 248, 0.05)', border: '1px solid rgba(56, 189, 248, 0.2)', borderRadius: '12px', padding: '12px' }}>
                    <div style={{ fontSize: '11px', color: 'var(--text-muted)', textTransform: 'uppercase', letterSpacing: '0.5px' }}>Stripe Price (mensual)</div>
                    <div style={{ fontSize: '12px', fontWeight: '700', color: 'var(--secondary-teal)', marginTop: '4px', fontFamily: 'var(--font-mono)', overflowWrap: 'anywhere' }}>
                      {p.stripePriceId}
                    </div>
                  </div>
                )}
                <div style={{ flex: 1, minWidth: '140px', background: 'rgba(245, 158, 11, 0.08)', border: '1px solid rgba(245, 158, 11, 0.3)', borderRadius: '12px', padding: '12px' }}>
                  <div style={{ fontSize: '11px', color: 'var(--text-muted)', textTransform: 'uppercase', letterSpacing: '0.5px' }}>Precio Anual</div>
                  <div style={{ fontSize: '16px', fontWeight: '800', color: '#fbbf24', marginTop: '4px', fontFamily: 'var(--font-mono)' }}>
                    {p.priceAnnual || '—'}
                  </div>
                </div>
                {p.stripePriceAnnualId && (
                  <div style={{ flex: 1, minWidth: '160px', background: 'rgba(56, 189, 248, 0.05)', border: '1px solid rgba(56, 189, 248, 0.2)', borderRadius: '12px', padding: '12px' }}>
                    <div style={{ fontSize: '11px', color: 'var(--text-muted)', textTransform: 'uppercase', letterSpacing: '0.5px' }}>Stripe Price (anual)</div>
                    <div style={{ fontSize: '12px', fontWeight: '700', color: 'var(--secondary-teal)', marginTop: '4px', fontFamily: 'var(--font-mono)', overflowWrap: 'anywhere' }}>
                      {p.stripePriceAnnualId}
                    </div>
                  </div>
                )}
              </div>

              <p style={{ fontSize: '13px', color: 'var(--text-muted)', marginBottom: '16px', minHeight: '38px' }}>
                {p.description}
              </p>

              <div style={{ borderTop: '1px solid var(--border-glass)', paddingTop: '16px', marginBottom: '20px' }}>
                <div style={{ fontSize: '12px', fontWeight: '700', color: '#fff', marginBottom: '10px', textTransform: 'uppercase', letterSpacing: '0.5px' }}>Características Incluidas</div>
                <ul style={{ listStyle: 'none', padding: 0, margin: 0, display: 'flex', flexDirection: 'column', gap: '8px' }}>
                  {p.features.map((f, idx) => (
                    <li key={idx} style={{ display: 'flex', alignItems: 'flex-start', gap: '8px', fontSize: '12px', color: 'var(--text-muted)' }}>
                      <CheckCircle2 style={{ width: '14px', height: '14px', color: 'var(--secondary-teal)', shrink: 0, marginTop: '2px' }} />
                      <span>{f}</span>
                    </li>
                  ))}
                </ul>
              </div>

              <div style={{ display: 'flex', gap: '8px' }}>
                <button className="btn-primary" onClick={() => handleEdit(p)} style={{ flex: 1, justifyContent: 'center' }}>
                  <Edit3 style={{ width: '16px', height: '16px' }} />
                  <span>Editar</span>
                </button>
                <button className="btn-secondary" onClick={() => handleDelete(p)} style={{ justifyContent: 'center', color: '#fca5a5' }}>
                  <Trash2 style={{ width: '16px', height: '16px' }} />
                  <span>Eliminar</span>
                </button>
              </div>
            </GlassCard>
          ))}
        </div>
      )}

      {/* Modal for Editing / Creating Plan */}
      {editingPlan && (
        <div style={{
          position: 'fixed',
          inset: 0,
          zIndex: 1000,
          background: 'rgba(6, 13, 32, 0.85)',
          backdropFilter: 'blur(16px)',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          padding: '24px',
        }}>
          <GlassCard style={{ width: '100%', maxWidth: '550px', padding: '32px', border: '1px solid var(--border-glass-glow)' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                <CreditCard style={{ color: 'var(--primary-purple)', width: '24px', height: '24px' }} />
                <h2 style={{ fontSize: '20px', fontWeight: '800', color: '#fff' }}>
                  {editingPlan.name ? `Editar Membresía (${editingPlan.id})` : 'Crear Nueva Membresía'}
                </h2>
              </div>
              <button className="btn-secondary" onClick={() => setEditingPlan(null)}><X style={{ width: '16px', height: '16px' }} /></button>
            </div>

            <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px' }}>
                <div>
                  <label className="form-label">ID / Código del Plan</label>
                  <input
                    type="text"
                    value={formData.id}
                    onChange={(e) => setFormData({ ...formData, id: e.target.value })}
                    placeholder="Ej. monthly, annual, pro"
                    className="cyber-input"
                  />
                </div>
                <div>
                  <label className="form-label">Nombre del Plan</label>
                  <input
                    type="text"
                    value={formData.name}
                    placeholder="Ej. Plan Pro Avanzado"
                    onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                    className="cyber-input"
                  />
                </div>
              </div>

              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr 1fr', gap: '12px' }}>
                <div>
                  <label className="form-label">Precio Mostrado</label>
                  <input
                    type="text"
                    value={formData.price}
                    placeholder="Ej. $1.99"
                    onChange={(e) => setFormData({ ...formData, price: e.target.value })}
                    className="cyber-input"
                  />
                </div>
                <div style={{ gridColumn: 'span 2' }}>
                  <label className="form-label">Ciclo de Facturación</label>
                  <div className="cyber-input" style={{ color: 'var(--text-muted)', paddingTop: '12px', fontSize: '12px' }}>
                    Mensual o Anual — el ciclo se elige al comprar
                  </div>
                </div>
                <div>
                  <label className="form-label">Minutos IA / Mes</label>
                  <input
                    type="number"
                    value={formData.monthlyAudioMinutesLimit}
                    onChange={(e) => setFormData({ ...formData, monthlyAudioMinutesLimit: e.target.value })}
                    className="cyber-input"
                  />
                </div>
                <div>
                  <label className="form-label">Orden (Posición)</label>
                  <input
                    type="number"
                    value={formData.orderIndex}
                    min={1}
                    onChange={(e) => setFormData({ ...formData, orderIndex: e.target.value })}
                    className="cyber-input"
                  />
                </div>
              </div>

              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: '12px' }}>
                <div>
                  <label className="form-label">Estamento</label>
                  <select
                    value={formData.className}
                    onChange={(e) => setFormData({ ...formData, className: e.target.value })}
                    className="cyber-input"
                    style={{ appearance: 'auto' }}
                  >
                    <option value="plebeyo">Plebeyo</option>
                    <option value="noble">Noble</option>
                    <option value="realeza">Realeza</option>
                  </select>
                </div>
                <div>
                  <label className="form-label">Maná / Mes</label>
                  <input
                    type="number"
                    value={formData.manaAllowance}
                    onChange={(e) => setFormData({ ...formData, manaAllowance: e.target.value })}
                    className="cyber-input"
                  />
                </div>
                <div>
                  <label className="form-label">Stripe Price ID (mensual)</label>
                  <input
                    type="text"
                    placeholder="price_..."
                    value={formData.stripePriceId}
                    onChange={(e) => setFormData({ ...formData, stripePriceId: e.target.value })}
                    className="cyber-input"
                  />
                </div>
                <div>
                  <label className="form-label">Precio Anual</label>
                  <input
                    type="text"
                    placeholder="Ej. $49.99"
                    value={formData.priceAnnual}
                    onChange={(e) => setFormData({ ...formData, priceAnnual: e.target.value })}
                    className="cyber-input"
                  />
                </div>
                <div>
                  <label className="form-label">Stripe Price Anual ID</label>
                  <input
                    type="text"
                    placeholder="price_..."
                    value={formData.stripePriceAnnualId}
                    onChange={(e) => setFormData({ ...formData, stripePriceAnnualId: e.target.value })}
                    className="cyber-input"
                  />
                </div>
              </div>

              <div>
                <label className="form-label">Etiqueta Destacada (Badge Tag)</label>
                <input
                  type="text"
                  placeholder="Ej. AHORRA 33% o POPULAR"
                  value={formData.tag}
                  onChange={(e) => setFormData({ ...formData, tag: e.target.value })}
                  className="cyber-input"
                />
              </div>

              <div>
                <label className="form-label">Descripción Breve</label>
                <input
                  type="text"
                  value={formData.description}
                  placeholder="Ej. Práctica diaria de 10 minutos con tutor IA"
                  onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                  className="cyber-input"
                />
              </div>

              <div>
                <label className="form-label">Características (una por línea)</label>
                <textarea
                  rows={4}
                  value={formData.featuresStr}
                  onChange={(e) => setFormData({ ...formData, featuresStr: e.target.value })}
                  className="cyber-input"
                  style={{ resize: 'vertical' }}
                />
              </div>

              <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '12px', marginTop: '12px' }}>
                <button className="btn-secondary" onClick={() => setEditingPlan(null)}>Cancelar</button>
                <button className="btn-primary" onClick={handleSave}>
                  <Save style={{ width: '16px', height: '16px' }} />
                  <span>Guardar Plan en Supabase DB</span>
                </button>
              </div>
            </div>
          </GlassCard>
        </div>
      )}
    </div>
  );
}
