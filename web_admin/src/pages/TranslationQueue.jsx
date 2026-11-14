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

const FIELD = {
  width: '100%',
  padding: '6px 8px',
  borderRadius: '8px',
  border: '1px solid var(--border-glass)',
  background: 'rgba(255, 255, 255, 0.04)',
  color: '#fff',
  fontSize: '13px',
};

const TH = { padding: '8px', color: 'var(--text-muted)', fontFamily: 'var(--font-mono)', textAlign: 'left' };

export default function TranslationQueue() {
  const [levels, setLevels] = useState([]);
  const [levelId, setLevelId] = useState('');
  const [status, setStatus] = useState('identical');
  const [data, setData] = useState(null);
  const [edits, setEdits] = useState({});
  const [capabilities, setCapabilities] = useState([]);
  const [error, setError] = useState(null);
  const [notice, setNotice] = useState(null);
  const [busy, setBusy] = useState(false);

  const load = useCallback(async () => {
    const { data: payload, error: rpcError } = await supabase.rpc('admin_translations', {
      p_level: levelId || null,
      p_status: status,
      p_limit: 200,
    });
    if (rpcError) {
      setError(rpcError.message);
      return;
    }
    setError(null);
    setData(payload);
    setEdits({});
  }, [levelId, status]);

  useEffect(() => {
    supabase.rpc('admin_units').then(({ data: payload }) => {
      const fetched = payload?.levels || [];
      setLevels(fetched);
    });
    supabase.rpc('admin_session').then(({ data: session }) => {
      setCapabilities(session?.capabilities || []);
    });
  }, []);

  useEffect(() => {
    load();
  }, [load]);

  const canPublish = capabilities.includes('publish');

  const saveTranslation = async (row) => {
    const key = `${row.lesson_id}:${row.order_index}`;
    const value = (edits[key] ?? '').trim();
    if (!value) {
      setError('La traducción no puede quedar vacía.');
      return;
    }
    setBusy(true);
    try {
      // Cargar la lección, sustituir la frase y guardar borrador: la corrección
      // es contenido, así que pasa por el camino normal y queda auditada.
      const { data: lesson, error: loadError } = await supabase.rpc('admin_lesson', {
        p_lesson_id: row.lesson_id,
      });
      if (loadError) {
        setError(loadError.message);
        return;
      }
      const phrases = (lesson.phrases || []).map((phrase) =>
        phrase.order_index === row.order_index ? { ...phrase, translation: value } : phrase,
      );
      const { error: saveError } = await supabase.rpc('admin_save_lesson', {
        p_lesson: {
          id: lesson.id,
          unit_id: lesson.unit_id,
          title: lesson.title,
          category: lesson.category,
          difficulty: lesson.difficulty,
          order_index: lesson.order_index,
          main_objective: lesson.main_objective,
          scenario_context: lesson.scenario_context,
          assistant_role: lesson.assistant_role,
          user_role: lesson.user_role,
          initial_message: lesson.initial_message,
          objectives: lesson.objectives || [],
          phrases,
          activities: lesson.activities || [],
        },
      });
      if (saveError) {
        setError(saveError.message);
        return;
      }
      setError(null);
      setNotice(`Borrador guardado en «${lesson.title}». Publícalo desde el editor para que llegue a la app.`);
      await load();
    } finally {
      setBusy(false);
    }
  };

  const publishLesson = async (lessonId) => {
    setBusy(true);
    try {
      const { data: published, error: rpcError } = await supabase.rpc('admin_publish_lesson', {
        p_lesson_id: lessonId,
        p_changelog: 'Corrección de traducción (CUR-15)',
      });
      if (rpcError) setError(rpcError.message);
      else {
        setError(null);
        setNotice(`Publicada la versión ${published.version}.`);
        await load();
      }
    } finally {
      setBusy(false);
    }
  };

  if (error && !data) {
    return (
      <div className="glass-panel" style={{ padding: '24px' }}>
        <h2 style={{ fontSize: '16px', color: '#fff', marginBottom: '8px' }}>No se pudo cargar la cola</h2>
        <p style={{ fontSize: '13px', color: 'var(--text-muted)' }}>{error}</p>
      </div>
    );
  }

  const totals = data?.totals || {};
  const rows = data?.rows || [];

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '18px' }}>
      <header style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-end', gap: '12px' }}>
        <div>
          <h1 style={{ fontSize: '24px', fontWeight: '800', color: '#fff' }}>Traducciones</h1>
          <p style={{ fontSize: '13px', color: 'var(--text-muted)' }}>
            {totals.identical ?? 0} idénticas · {totals.pending ?? 0} sin traducir · {totals.ok ?? 0} correctas
          </p>
        </div>
        <div style={{ display: 'flex', gap: '8px' }}>
          <select value={levelId} onChange={(event) => setLevelId(event.target.value)} style={{ ...FIELD, width: '160px' }}>
            <option value="">Todos los niveles</option>
            {levels.map((level) => (
              <option key={level.id} value={level.id}>
                {level.cefr} · {level.name}
              </option>
            ))}
          </select>
          <select value={status} onChange={(event) => setStatus(event.target.value)} style={{ ...FIELD, width: '150px' }}>
            <option value="identical">Idénticas</option>
            <option value="pending">Sin traducir</option>
            <option value="ok">Correctas</option>
            <option value="all">Todas</option>
          </select>
        </div>
      </header>

      {error ? (
        <div className="glass-panel" style={{ padding: '10px', borderColor: 'rgba(255, 99, 99, 0.5)', fontSize: '13px', color: '#fff' }}>
          {error}
        </div>
      ) : null}
      {notice ? (
        <div className="glass-panel" style={{ padding: '10px', borderColor: 'rgba(45, 212, 191, 0.4)', fontSize: '13px', color: '#fff' }}>
          {notice}
        </div>
      ) : null}

      <section className="glass-panel" style={{ padding: '16px' }}>
        {rows.length === 0 ? (
          <p style={{ fontSize: '13px', color: 'var(--text-muted)' }}>No hay frases en este estado.</p>
        ) : (
          <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: '13px' }}>
            <thead>
              <tr>
                <th style={TH}>Nivel</th>
                <th style={TH}>Lección</th>
                <th style={TH}>Frase</th>
                <th style={TH}>Traducción</th>
                <th style={TH}>Acciones</th>
              </tr>
            </thead>
            <tbody>
              {rows.map((row) => {
                const key = `${row.lesson_id}:${row.order_index}`;
                return (
                  <tr key={key} style={{ borderTop: '1px solid var(--border-glass)' }}>
                    <td style={{ padding: '8px', fontFamily: 'var(--font-mono)', color: 'var(--text-muted)' }}>{row.level}</td>
                    <td style={{ padding: '8px', color: '#fff' }}>
                      {row.lesson_title}
                      {row.has_draft ? (
                        <span style={{ marginLeft: '6px', fontSize: '10px', color: 'var(--primary-purple)' }}>borrador</span>
                      ) : null}
                    </td>
                    <td style={{ padding: '8px', color: 'var(--text-muted)' }}>{row.phrase}</td>
                    <td style={{ padding: '8px', minWidth: '220px' }}>
                      <input
                        style={FIELD}
                        placeholder={row.translation || 'Sin traducir'}
                        value={edits[key] ?? ''}
                        onChange={(event) => setEdits((current) => ({ ...current, [key]: event.target.value }))}
                      />
                    </td>
                    <td style={{ padding: '8px' }}>
                      <div style={{ display: 'flex', gap: '6px' }}>
                        <button type="button" style={BTN} disabled={busy} onClick={() => saveTranslation(row)}>
                          Guardar borrador
                        </button>
                        {row.has_draft && canPublish ? (
                          <button type="button" style={BTN} disabled={busy} onClick={() => publishLesson(row.lesson_id)}>
                            Publicar
                          </button>
                        ) : null}
                      </div>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        )}
      </section>

      <p style={{ fontSize: '11px', color: 'var(--text-muted)' }}>
        La corrección se guarda como borrador y se publica aparte: cambiar una traducción es cambiar contenido y pasa
        por revisión y auditoría, no por un atajo sobre lo publicado.
      </p>
    </div>
  );
}
