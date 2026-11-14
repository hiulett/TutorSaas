import React, { useCallback, useEffect, useState } from 'react';
import { supabase } from '../lib/supabaseClient';

const BTN = {
  padding: '4px 10px',
  borderRadius: '8px',
  border: '1px solid var(--border-glass)',
  background: 'rgba(255, 255, 255, 0.05)',
  color: '#fff',
  cursor: 'pointer',
  fontSize: '12px',
};

const TH = { padding: '8px', color: 'var(--text-muted)', fontFamily: 'var(--font-mono)', textAlign: 'left' };

function slugify(text) {
  return text
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/(^-|-$)/g, '');
}

export default function UnitsManager() {
  const [levels, setLevels] = useState([]);
  const [levelId, setLevelId] = useState(null);
  const [error, setError] = useState(null);
  const [busy, setBusy] = useState(false);
  const [loading, setLoading] = useState(true);

  const load = useCallback(async () => {
    const { data, error: rpcError } = await supabase.rpc('admin_units');
    if (rpcError) {
      setError(rpcError.message);
      setLoading(false);
      return;
    }
    setError(null);
    const fetched = data?.levels || [];
    setLevels(fetched);
    setLevelId((current) => current || fetched[0]?.id || null);
    setLoading(false);
  }, []);

  useEffect(() => {
    load();
  }, [load]);

  const run = async (fn) => {
    setBusy(true);
    try {
      const { error: rpcError } = await fn();
      if (rpcError) setError(rpcError.message);
      else setError(null);
      await load();
    } finally {
      setBusy(false);
    }
  };

  const level = levels.find((item) => item.id === levelId);
  const units = level?.units || [];

  const moveUnit = (unit, delta) =>
    run(() =>
      supabase.rpc('admin_save_unit', {
        p_unit: {
          id: unit.id,
          level_id: level.id,
          order_index: unit.order_index + delta,
        },
      }),
    );

  const addUnit = () => {
    const title = window.prompt('Título de la nueva unidad');
    if (!title) return;
    const slug = window.prompt('Slug', slugify(title)) || slugify(title);
    run(() =>
      supabase.rpc('admin_save_unit', {
        p_unit: { level_id: level.id, slug, title, order_index: units.length + 1 },
      }),
    );
  };

  const removeUnit = (unit) => {
    if (!window.confirm(`¿Borrar la unidad «${unit.title}»?`)) return;
    run(() => supabase.rpc('admin_delete_unit', { p_id: unit.id }));
  };

  const moveLesson = (lesson, targetUnitId) =>
    run(() =>
      supabase.rpc('admin_move_lesson', {
        p_lesson_id: lesson.id,
        p_unit_id: targetUnitId,
        p_order_index: 1,
      }),
    );

  if (loading) {
    return <div style={{ color: 'var(--text-muted)', fontFamily: 'var(--font-mono)', fontSize: '13px' }}>Cargando unidades...</div>;
  }

  if (error && !level) {
    return (
      <div className="glass-panel" style={{ padding: '24px' }}>
        <h2 style={{ fontSize: '16px', color: '#fff', marginBottom: '8px' }}>No se pudieron cargar las unidades</h2>
        <p style={{ fontSize: '13px', color: 'var(--text-muted)' }}>{error}</p>
      </div>
    );
  }

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
      <header style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-end', gap: '16px' }}>
        <div>
          <h1 style={{ fontSize: '24px', fontWeight: '800', color: '#fff' }}>Unidades</h1>
          <p style={{ fontSize: '13px', color: 'var(--text-muted)' }}>
            Reordena unidades y reasigna lecciones entre ellas.
          </p>
        </div>
        <div style={{ display: 'flex', gap: '8px', alignItems: 'center' }}>
          <select
            value={levelId || ''}
            onChange={(event) => setLevelId(event.target.value)}
            style={{ ...BTN, padding: '8px 12px' }}
          >
            {levels.map((item) => (
              <option key={item.id} value={item.id}>
                {item.cefr} · {item.name}
              </option>
            ))}
          </select>
          <button type="button" style={BTN} onClick={addUnit} disabled={busy}>
            + Unidad
          </button>
        </div>
      </header>

      {error ? (
        <div className="glass-panel" style={{ padding: '12px', borderColor: 'rgba(255, 99, 99, 0.4)', fontSize: '13px', color: '#fff' }}>
          {error}
        </div>
      ) : null}

      {units.map((unit, index) => (
        <section key={unit.id} className="glass-panel" style={{ padding: '16px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', gap: '12px', marginBottom: '10px' }}>
            <div>
              <strong style={{ color: '#fff' }}>{unit.order_index}. {unit.title}</strong>{' '}
              <span style={{ color: 'var(--text-muted)', fontSize: '12px', fontFamily: 'var(--font-mono)' }}>
                {unit.slug} · {unit.lessons.length} lecciones
              </span>
            </div>
            <div style={{ display: 'flex', gap: '6px' }}>
              <button type="button" style={BTN} onClick={() => moveUnit(unit, -1)} disabled={busy || index === 0}>
                ↑
              </button>
              <button
                type="button"
                style={BTN}
                onClick={() => moveUnit(unit, 1)}
                disabled={busy || index === units.length - 1}
              >
                ↓
              </button>
              <button type="button" style={BTN} onClick={() => removeUnit(unit)} disabled={busy}>
                Borrar
              </button>
            </div>
          </div>

          <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: '13px' }}>
            <thead>
              <tr>
                <th style={TH}>#</th>
                <th style={TH}>Lección</th>
                <th style={TH}>Estado</th>
                <th style={TH}>Mover a</th>
              </tr>
            </thead>
            <tbody>
              {unit.lessons.map((lesson) => (
                <tr key={lesson.id} style={{ borderTop: '1px solid var(--border-glass)' }}>
                  <td style={{ padding: '8px', fontFamily: 'var(--font-mono)', color: 'var(--text-muted)' }}>
                    {lesson.order_index}
                  </td>
                  <td style={{ padding: '8px', color: '#fff' }}>
                    {lesson.title || lesson.id}
                    <div style={{ fontSize: '11px', color: 'var(--text-muted)', fontFamily: 'var(--font-mono)' }}>
                      {lesson.id}
                    </div>
                  </td>
                  <td style={{ padding: '8px', color: 'var(--text-muted)' }}>{lesson.status}</td>
                  <td style={{ padding: '8px' }}>
                    <select
                      value={unit.id}
                      onChange={(event) => {
                        const target = event.target.value;
                        if (target !== unit.id) moveLesson(lesson, target);
                      }}
                      disabled={busy}
                      style={{ ...BTN, padding: '4px 8px' }}
                    >
                      {units.map((option) => (
                        <option key={option.id} value={option.id}>
                          {option.title}
                        </option>
                      ))}
                    </select>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </section>
      ))}
    </div>
  );
}
