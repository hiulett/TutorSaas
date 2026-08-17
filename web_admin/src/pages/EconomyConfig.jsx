import React, { useState } from 'react';
import ConfigTable from '../components/ConfigTable';

const TAB_STYLE = (active) => ({
  padding: '10px 16px',
  borderRadius: '10px',
  border: 'none',
  background: active ? 'linear-gradient(90deg, rgba(168, 85, 247, 0.2), rgba(56, 189, 248, 0.08))' : 'transparent',
  color: active ? '#fff' : 'var(--text-muted)',
  fontWeight: active ? '700' : '500',
  fontSize: '13px',
  cursor: 'pointer',
  borderLeft: active ? '3px solid var(--primary-purple)' : '3px solid transparent',
});

const actionCostColumns = [
  { key: 'action_code', label: 'Código', type: 'text' },
  { key: 'label', label: 'Etiqueta', type: 'text' },
  { key: 'cost_mana', label: 'Costo Maná', type: 'number', default: 10 },
  { key: 'description', label: 'Descripción', type: 'text' },
  { key: 'is_active', label: 'Activo', type: 'boolean', default: true },
];

const potionColumns = [
  { key: 'id', label: 'ID', type: 'text' },
  { key: 'name', label: 'Nombre', type: 'text' },
  { key: 'mana_amount', label: 'Maná', type: 'number', default: 25 },
  { key: 'price_usd', label: 'Precio USD', type: 'number', default: 0.99 },
  { key: 'description', label: 'Descripción', type: 'text' },
  { key: 'order_index', label: 'Orden', type: 'number', default: 1 },
  { key: 'is_active', label: 'Activo', type: 'boolean', default: true },
];

const gemColumns = [
  { key: 'id', label: 'ID', type: 'text' },
  { key: 'name', label: 'Nombre', type: 'text' },
  { key: 'mana_amount', label: 'Maná', type: 'number', default: 40 },
  { key: 'price_usd', label: 'Precio USD', type: 'number', default: 0.99 },
  { key: 'badge', label: 'Badge', type: 'text' },
  { key: 'order_index', label: 'Orden', type: 'number', default: 1 },
  { key: 'is_active', label: 'Activo', type: 'boolean', default: true },
];

const ladderColumns = [
  { key: 'tier_code', label: 'Código', type: 'text' },
  { key: 'tier_order', label: 'Orden', type: 'number', default: 1 },
  { key: 'name_es', label: 'Nombre ES', type: 'text' },
  { key: 'name_en', label: 'Nombre EN', type: 'text' },
  { key: 'name_pt', label: 'Nombre PT', type: 'text' },
  { key: 'aura_xp_threshold', label: 'Aura XP', type: 'number', default: 0 },
  { key: 'min_radar', label: 'Radar mín.', type: 'number', default: 0 },
  { key: 'ceiling_class', label: 'Techo', type: 'select', options: ['plebeyo', 'noble', 'realeza'], default: 'plebeyo' },
  { key: 'segment', label: 'Segmento', type: 'select', options: ['comun', 'noble', 'real'], default: 'comun' },
  { key: 'is_active', label: 'Activo', type: 'boolean', default: true },
];

const goldColumns = [
  { key: 'id', label: 'ID', type: 'text', readOnly: true },
  { key: 'name', label: 'Nombre', type: 'text' },
  { key: 'category', label: 'Categoría', type: 'text' },
  { key: 'price_gold', label: 'Precio Oro', type: 'number', default: 0 },
];

const TABS = [
  { id: 'costs', label: 'Costos de IA', icon: '⚡' },
  { id: 'potions', label: 'Porciones de Maná', icon: '🧪' },
  { id: 'gems', label: 'Gemas de Maná', icon: '💎' },
  { id: 'ladder', label: 'Escalera de Prestigio', icon: '👑' },
  { id: 'gold', label: 'Precios en Oro', icon: '🪙' },
];

export default function EconomyConfig() {
  const [tab, setTab] = useState('costs');

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
      <div>
        <h1 style={{ fontSize: '26px', fontWeight: '800', color: '#fff' }}>Economía y Configuración del Juego</h1>
        <p style={{ color: 'var(--text-muted)', fontSize: '14px', marginTop: '4px' }}>
          Todo editable desde la DB: costos por acción IA, productos de maná, escalera de prestigio y precios en oro.
        </p>
      </div>

      <div style={{ display: 'flex', gap: '4px', flexWrap: 'wrap', background: 'rgba(255,255,255,0.02)', border: '1px solid var(--border-glass)', borderRadius: '12px', padding: '6px' }}>
        {TABS.map((t) => (
          <button key={t.id} style={TAB_STYLE(tab === t.id)} onClick={() => setTab(t.id)}>
            <span style={{ marginRight: '6px' }}>{t.icon}</span>
            {t.label}
          </button>
        ))}
      </div>

      {tab === 'costs' && (
        <ConfigTable
          table="ai_action_costs"
          title="Costos por Acción IA"
          description="Maná que cuesta cada acción. El RPC consume_mana lo lee aquí en cada turno."
          columns={actionCostColumns}
          idKey="action_code"
          showMeta
        />
      )}
      {tab === 'potions' && (
        <ConfigTable
          table="mana_potions"
          title="Porciones de Maná"
          description="Consumibles de pago real (+maná). Se venden en la tienda."
          columns={potionColumns}
          idKey="id"
          showMeta
        />
      )}
      {tab === 'gems' && (
        <ConfigTable
          table="mana_gems"
          title="Packs de Gemas de Maná"
          description="Productos de pago real que otorgan maná directo."
          columns={gemColumns}
          idKey="id"
          showMeta
        />
      )}
      {tab === 'ladder' && (
        <ConfigTable
          table="prestige_ladder"
          title="Escalera de Prestigio"
          description="Títulos ganados con Aura. ceiling_class limita el techo por estamento; min_radar es prerequisito."
          columns={ladderColumns}
          idKey="tier_code"
          showMeta
        />
      )}
      {tab === 'gold' && (
        <ConfigTable
          table="cosmetic_catalog"
          title="Precios en Oro de los Cosméticos"
          description="price_gold > 0 aparece en la Tienda de Oro. La categoría define el tipo de ítem en el inventario."
          columns={goldColumns}
          idKey="id"
          allowCreate={false}
          editOnly
          showMeta
        />
      )}
    </div>
  );
}
