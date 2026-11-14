import React, { useEffect, useState } from 'react';
import { supabase } from '../lib/supabaseClient';

const CARD_STYLE = {
  padding: '20px',
  borderRadius: '16px',
  border: '1px solid var(--border-glass)',
  background: 'rgba(255, 255, 255, 0.03)',
};

const VALUE_STYLE = {
  fontSize: '28px',
  fontWeight: '800',
  color: '#fff',
  fontFamily: 'var(--font-mono)',
};

const LABEL_STYLE = {
  fontSize: '11px',
  letterSpacing: '0.08em',
  textTransform: 'uppercase',
  color: 'var(--text-muted)',
  fontFamily: 'var(--font-mono)',
};

function Kpi({ label, value, hint, tone }) {
  return (
    <div style={CARD_STYLE}>
      <div style={LABEL_STYLE}>{label}</div>
      <div style={{ ...VALUE_STYLE, color: tone || '#fff' }}>{value}</div>
      {hint ? (
        <div style={{ fontSize: '12px', color: 'var(--text-muted)', marginTop: '4px' }}>{hint}</div>
      ) : null}
    </div>
  );
}

export default function CurriculumDashboard() {
  const [stats, setStats] = useState(null);
  const [error, setError] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let active = true;
    supabase
      .rpc('admin_curriculum_stats')
      .then(({ data, error: rpcError }) => {
        if (!active) return;
        if (rpcError) {
          setError(rpcError.message);
        } else {
          setStats(data);
        }
        setLoading(false);
      });
    return () => {
      active = false;
    };
  }, []);

  if (loading) {
    return (
      <div style={{ color: 'var(--text-muted)', fontFamily: 'var(--font-mono)', fontSize: '13px' }}>
        Cargando currículo...
      </div>
    );
  }

  if (error) {
    return (
      <div className="glass-panel" style={{ padding: '24px', borderColor: 'rgba(255, 99, 99, 0.4)' }}>
        <h2 style={{ fontSize: '16px', color: '#fff', marginBottom: '8px' }}>No se pudieron cargar los conteos</h2>
        <p style={{ fontSize: '13px', color: 'var(--text-muted)' }}>{error}</p>
        <p style={{ fontSize: '12px', color: 'var(--text-muted)', marginTop: '8px' }}>
          Comprueba que el RPC <code>admin_curriculum_stats</code> está aplicado y que tu rol tiene la
          capacidad <code>read</code>.
        </p>
      </div>
    );
  }

  const totals = stats.totals || {};
  const levels = stats.levels || [];
  const pendingEditorial = (totals.identical || 0) + (totals.weak || 0);

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '24px' }}>
      <header>
        <h1 style={{ fontSize: '24px', fontWeight: '800', color: '#fff' }}>Currículo</h1>
        <p style={{ fontSize: '13px', color: 'var(--text-muted)' }}>
          {totals.levels || 0} niveles · {totals.units || 0} unidades · {totals.lessons || 0} lecciones ·{' '}
          {totals.versions || 0} versiones publicadas
        </p>
      </header>

      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(180px, 1fr))', gap: '16px' }}>
        <Kpi label="Lecciones" value={totals.lessons || 0} hint={`${totals.published || 0} publicadas`} />
        <Kpi label="Objetivos" value={totals.objectives || 0} hint={`${totals.weak || 0} para revisar`} tone="var(--secondary-teal)" />
        <Kpi label="Frases" value={totals.phrases || 0} hint={`${totals.identical || 0} sin traducir`} tone="var(--secondary-teal)" />
        <Kpi label="Actividades" value={totals.activities || 0} hint={totals.activities ? 'listas' : 'sin construir'} />
        <Kpi
          label="Deuda editorial"
          value={pendingEditorial}
          hint="idénticas + objetivos débiles"
          tone={pendingEditorial ? 'var(--primary-purple)' : '#fff'}
        />
      </div>

      <section className="glass-panel" style={{ padding: '20px' }}>
        <h2 style={{ fontSize: '14px', color: '#fff', marginBottom: '12px', fontFamily: 'var(--font-mono)' }}>
          POR NIVEL
        </h2>
        <div style={{ overflowX: 'auto' }}>
          <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: '13px' }}>
            <thead>
              <tr style={{ textAlign: 'left', color: 'var(--text-muted)', fontFamily: 'var(--font-mono)' }}>
                <th style={{ padding: '8px' }}>Nivel</th>
                <th style={{ padding: '8px' }}>Unidades</th>
                <th style={{ padding: '8px' }}>Lecciones</th>
                <th style={{ padding: '8px' }}>Publicadas</th>
                <th style={{ padding: '8px' }}>Objetivos</th>
                <th style={{ padding: '8px' }}>Frases</th>
                <th style={{ padding: '8px' }}>Idénticas</th>
                <th style={{ padding: '8px' }}>Débiles</th>
                <th style={{ padding: '8px' }}>Actividades</th>
              </tr>
            </thead>
            <tbody>
              {levels.map((level) => (
                <tr key={level.id} style={{ borderTop: '1px solid var(--border-glass)', color: '#fff' }}>
                  <td style={{ padding: '8px' }}>
                    <strong>{level.cefr}</strong>{' '}
                    <span style={{ color: 'var(--text-muted)' }}>{level.name}</span>
                  </td>
                  <td style={{ padding: '8px' }}>{level.units}</td>
                  <td style={{ padding: '8px' }}>{level.lessons}</td>
                  <td style={{ padding: '8px' }}>{level.published}</td>
                  <td style={{ padding: '8px' }}>{level.objectives}</td>
                  <td style={{ padding: '8px' }}>{level.phrases}</td>
                  <td style={{ padding: '8px', color: level.identical ? 'var(--primary-purple)' : 'inherit' }}>
                    {level.identical}
                  </td>
                  <td style={{ padding: '8px', color: level.weak ? 'var(--secondary-teal)' : 'inherit' }}>
                    {level.weak}
                  </td>
                  <td style={{ padding: '8px' }}>{level.activities}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </section>
    </div>
  );
}
