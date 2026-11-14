import React, { useEffect, useMemo, useState } from 'react';
import { supabase } from '../lib/supabaseClient';

const FIELD = {
  width: '100%',
  padding: '8px 10px',
  borderRadius: '8px',
  border: '1px solid var(--border-glass)',
  background: 'rgba(255, 255, 255, 0.04)',
  color: '#fff',
  fontSize: '13px',
};

const BTN = {
  padding: '6px 12px',
  borderRadius: '9px',
  border: '1px solid var(--border-glass)',
  background: 'rgba(255, 255, 255, 0.06)',
  color: '#fff',
  cursor: 'pointer',
  fontSize: '12px',
};

const LABEL = {
  display: 'block',
  fontSize: '11px',
  letterSpacing: '0.06em',
  textTransform: 'uppercase',
  color: 'var(--text-muted)',
  fontFamily: 'var(--font-mono)',
  marginBottom: '4px',
};

const TEMPLATES = {
  conversation: () => ({ activity_type: 'conversation', payload: { goals: [''] }, instructions: '' }),
  mcq: () => ({
    activity_type: 'mcq',
    payload: { question: '', options: ['', ''], correct: '' },
    instructions: '',
  }),
  fill_blank: () => ({
    activity_type: 'fill_blank',
    payload: { text_with_gaps: '', answers: [''] },
    instructions: '',
  }),
  order_words: () => ({
    activity_type: 'order_words',
    payload: { tokens: ['', ''], correct_order: ['', ''] },
    instructions: '',
  }),
};

const splitList = (value) =>
  value
    .split(',')
    .map((item) => item.trim())
    .filter(Boolean);

export default function ActivityBuilder() {
  const [types, setTypes] = useState([]);
  const [levels, setLevels] = useState([]);
  const [levelId, setLevelId] = useState(null);
  const [lessonId, setLessonId] = useState(null);
  const [lesson, setLesson] = useState(null);
  const [draft, setDraft] = useState(null);
  const [error, setError] = useState(null);
  const [notice, setNotice] = useState(null);
  const [busy, setBusy] = useState(false);

  const loadTypes = () =>
    supabase.rpc('admin_activity_types').then(({ data, error: rpcError }) => {
      if (rpcError) setError(rpcError.message);
      else setTypes(data?.types || []);
    });

  const loadLesson = async (id) => {
    setLessonId(id);
    setNotice(null);
    const { data, error: rpcError } = await supabase.rpc('admin_lesson', { p_lesson_id: id });
    if (rpcError) {
      setError(rpcError.message);
      setLesson(null);
      return;
    }
    setError(null);
    setLesson(data);
  };

  useEffect(() => {
    loadTypes();
    supabase.rpc('admin_units').then(({ data }) => {
      const fetched = data?.levels || [];
      setLevels(fetched);
      setLevelId((current) => current || fetched[0]?.id || null);
    });
  }, []);

  const level = levels.find((item) => item.id === levelId);
  const lessons = useMemo(
    () => (level?.units || []).flatMap((unit) => unit.lessons.map((item) => ({ ...item, unit }))),
    [level],
  );
  const enabledTypes = types.filter((type) => type.is_enabled);

  const toggleType = async (type) => {
    setBusy(true);
    try {
      const { error: rpcError } = await supabase.rpc('admin_set_activity_enabled', {
        p_code: type.code,
        p_enabled: !type.is_enabled,
      });
      if (rpcError) setError(rpcError.message);
      else {
        setError(null);
        await loadTypes();
      }
    } finally {
      setBusy(false);
    }
  };

  const addActivity = (code) => {
    const template = TEMPLATES[code];
    if (!template) return;
    setDraft(template());
  };

  const saveActivity = async () => {
    if (!draft || !lesson) return;
    setBusy(true);
    try {
      const { data, error: rpcError } = await supabase.rpc('admin_save_activity', {
        p_lesson_id: lesson.id,
        p_activity: draft,
      });
      if (rpcError) setError(rpcError.message);
      else {
        setError(null);
        setNotice(
          `Actividad ${data.activity_type} guardada en la versión ${data.version}. Publica la lección para que llegue a la app.`,
        );
        setDraft(null);
        await loadLesson(lesson.id);
      }
    } finally {
      setBusy(false);
    }
  };

  return (
    <div style={{ display: 'flex', gap: '20px', alignItems: 'flex-start' }}>
      <aside className="glass-panel" style={{ width: '250px', padding: '16px', flexShrink: 0 }}>
        <select
          value={levelId || ''}
          onChange={(event) => {
            setLevelId(event.target.value);
            setLesson(null);
          }}
          style={{ ...FIELD, marginBottom: '10px' }}
        >
          {levels.map((item) => (
            <option key={item.id} value={item.id}>
              {item.cefr} · {item.name}
            </option>
          ))}
        </select>
        <div style={{ display: 'flex', flexDirection: 'column', gap: '4px', maxHeight: '60vh', overflowY: 'auto' }}>
          {lessons.map((item) => (
            <button
              key={item.id}
              type="button"
              onClick={() => loadLesson(item.id)}
              style={{
                ...BTN,
                textAlign: 'left',
                borderColor: item.id === lessonId ? 'var(--primary-purple)' : 'transparent',
                background: item.id === lessonId ? 'rgba(168, 85, 247, 0.16)' : 'transparent',
              }}
            >
              <div style={{ color: '#fff', fontSize: '12px' }}>{item.title || item.id}</div>
              <div style={{ color: 'var(--text-muted)', fontSize: '10px', fontFamily: 'var(--font-mono)' }}>
                {item.unit.slug}
              </div>
            </button>
          ))}
        </div>
      </aside>

      <section style={{ flex: 1, minWidth: 0, display: 'flex', flexDirection: 'column', gap: '16px' }}>
        <div className="glass-panel" style={{ padding: '16px' }}>
          <h2 style={{ fontSize: '13px', color: '#fff', fontFamily: 'var(--font-mono)', marginBottom: '10px' }}>
            TIPOS DE ACTIVIDAD
          </h2>
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: '8px' }}>
            {types.map((type) => (
              <span
                key={type.code}
                style={{
                  display: 'inline-flex',
                  alignItems: 'center',
                  gap: '8px',
                  padding: '6px 10px',
                  borderRadius: '10px',
                  border: '1px solid var(--border-glass)',
                  background: type.is_enabled ? 'rgba(45, 212, 191, 0.12)' : 'rgba(255, 255, 255, 0.03)',
                  fontSize: '12px',
                  color: '#fff',
                }}
              >
                {type.code}
                <button type="button" style={{ ...BTN, padding: '2px 8px' }} onClick={() => toggleType(type)} disabled={busy}>
                  {type.is_enabled ? 'deshabilitar' : 'habilitar'}
                </button>
              </span>
            ))}
          </div>
          <p style={{ fontSize: '11px', color: 'var(--text-muted)', marginTop: '8px' }}>
            Solo los tipos habilitados se pueden usar. Los deshabilitados existen para que la app todavía no tenga que
            pintarlos.
          </p>
        </div>

        {!lesson ? (
          <div className="glass-panel" style={{ padding: '24px', color: 'var(--text-muted)', fontSize: '13px' }}>
            Elige una lección para construir actividades.
          </div>
        ) : (
          <>
            <div className="glass-panel" style={{ padding: '16px' }}>
              <h1 style={{ fontSize: '18px', fontWeight: '800', color: '#fff', marginBottom: '4px' }}>{lesson.title}</h1>
              <p style={{ fontSize: '12px', color: 'var(--text-muted)', fontFamily: 'var(--font-mono)' }}>
                {lesson.id} · {lesson.status}
                {lesson.draft_version ? ` · borrador v${lesson.draft_version}` : ''}
              </p>

              <h3 style={{ fontSize: '12px', color: '#fff', fontFamily: 'var(--font-mono)', marginTop: '14px' }}>
                ACTIVIDADES ({lesson.activities.length})
              </h3>
              {lesson.activities.length === 0 ? (
                <p style={{ fontSize: '12px', color: 'var(--text-muted)' }}>Todavía no hay actividades.</p>
              ) : (
                <ul style={{ margin: '8px 0 0 16px', fontSize: '13px', color: '#fff' }}>
                  {lesson.activities.map((activity) => (
                    <li key={`${activity.activity_type}-${activity.order_index}`}>
                      <strong>{activity.activity_type}</strong> #{activity.order_index}
                      {activity.instructions ? ` · ${activity.instructions}` : ''}
                    </li>
                  ))}
                </ul>
              )}

              <div style={{ display: 'flex', gap: '8px', marginTop: '12px' }}>
                {enabledTypes.map((type) => (
                  <button key={type.code} type="button" style={BTN} onClick={() => addActivity(type.code)}>
                    + {type.code}
                  </button>
                ))}
                {enabledTypes.length === 0 ? (
                  <span style={{ fontSize: '12px', color: 'var(--text-muted)' }}>
                    Habilita un tipo arriba para poder añadir actividades.
                  </span>
                ) : null}
              </div>
            </div>

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

            {draft ? (
              <div className="glass-panel" style={{ padding: '16px', display: 'flex', flexDirection: 'column', gap: '10px' }}>
                <h2 style={{ fontSize: '13px', color: '#fff', fontFamily: 'var(--font-mono)' }}>
                  NUEVA · {draft.activity_type}
                </h2>

                {draft.activity_type === 'conversation' ? (
                  <label>
                    <span style={LABEL}>Objetivos de la conversación (separados por coma)</span>
                    <input
                      style={FIELD}
                      value={draft.payload.goals.join(', ')}
                      onChange={(event) =>
                        setDraft({ ...draft, payload: { ...draft.payload, goals: splitList(event.target.value) } })
                      }
                    />
                  </label>
                ) : null}

                {draft.activity_type === 'mcq' ? (
                  <>
                    <label>
                      <span style={LABEL}>Pregunta</span>
                      <input
                        style={FIELD}
                        value={draft.payload.question}
                        onChange={(event) =>
                          setDraft({ ...draft, payload: { ...draft.payload, question: event.target.value } })
                        }
                      />
                    </label>
                    <label>
                      <span style={LABEL}>Opciones (separadas por coma)</span>
                      <input
                        style={FIELD}
                        value={draft.payload.options.join(', ')}
                        onChange={(event) =>
                          setDraft({ ...draft, payload: { ...draft.payload, options: splitList(event.target.value) } })
                        }
                      />
                    </label>
                    <label>
                      <span style={LABEL}>Respuesta correcta</span>
                      <input
                        style={FIELD}
                        value={draft.payload.correct}
                        onChange={(event) =>
                          setDraft({ ...draft, payload: { ...draft.payload, correct: event.target.value } })
                        }
                      />
                    </label>
                  </>
                ) : null}

                {draft.activity_type === 'fill_blank' ? (
                  <>
                    <label>
                      <span style={LABEL}>Texto con huecos (usa ___ para el hueco)</span>
                      <input
                        style={FIELD}
                        value={draft.payload.text_with_gaps}
                        onChange={(event) =>
                          setDraft({ ...draft, payload: { ...draft.payload, text_with_gaps: event.target.value } })
                        }
                      />
                    </label>
                    <label>
                      <span style={LABEL}>Respuestas (separadas por coma)</span>
                      <input
                        style={FIELD}
                        value={draft.payload.answers.join(', ')}
                        onChange={(event) =>
                          setDraft({ ...draft, payload: { ...draft.payload, answers: splitList(event.target.value) } })
                        }
                      />
                    </label>
                  </>
                ) : null}

                {draft.activity_type === 'order_words' ? (
                  <>
                    <label>
                      <span style={LABEL}>Fichas de palabras (separadas por coma)</span>
                      <input
                        style={FIELD}
                        value={draft.payload.tokens.join(', ')}
                        onChange={(event) =>
                          setDraft({ ...draft, payload: { ...draft.payload, tokens: splitList(event.target.value) } })
                        }
                      />
                    </label>
                    <label>
                      <span style={LABEL}>Orden correcto (separado por coma)</span>
                      <input
                        style={FIELD}
                        value={draft.payload.correct_order.join(', ')}
                        onChange={(event) =>
                          setDraft({
                            ...draft,
                            payload: { ...draft.payload, correct_order: splitList(event.target.value) },
                          })
                        }
                      />
                    </label>
                  </>
                ) : null}

                <label>
                  <span style={LABEL}>Instrucciones para el alumno</span>
                  <input
                    style={FIELD}
                    value={draft.instructions || ''}
                    onChange={(event) => setDraft({ ...draft, instructions: event.target.value })}
                  />
                </label>

                <div style={{ display: 'flex', gap: '8px' }}>
                  <button type="button" style={BTN} onClick={saveActivity} disabled={busy}>
                    Guardar actividad
                  </button>
                  <button type="button" style={BTN} onClick={() => setDraft(null)} disabled={busy}>
                    Cancelar
                  </button>
                </div>
              </div>
            ) : null}
          </>
        )}
      </section>
    </div>
  );
}
