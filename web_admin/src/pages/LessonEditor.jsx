import React, { useCallback, useEffect, useMemo, useState } from 'react';
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
  padding: '8px 14px',
  borderRadius: '10px',
  border: '1px solid var(--border-glass)',
  background: 'rgba(255, 255, 255, 0.06)',
  color: '#fff',
  cursor: 'pointer',
  fontSize: '13px',
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

const COMPETENCIES = [
  'speaking',
  'vocabulary',
  'grammar',
  'listening',
  'reading',
  'writing',
  'pronunciation',
  'communication',
];

function translationStatus(phrase, translation) {
  const text = (translation || '').trim();
  if (!text) return 'pending';
  return text.toLowerCase() === (phrase || '').trim().toLowerCase() ? 'identical' : 'ok';
}

export default function LessonEditor() {
  const [levels, setLevels] = useState([]);
  const [levelId, setLevelId] = useState(null);
  const [lessonId, setLessonId] = useState(null);
  const [lesson, setLesson] = useState(null);
  const [capabilities, setCapabilities] = useState([]);
  const [error, setError] = useState(null);
  const [notice, setNotice] = useState(null);
  const [busy, setBusy] = useState(false);

  useEffect(() => {
    supabase.rpc('admin_units').then(({ data, error: rpcError }) => {
      if (rpcError) {
        setError(rpcError.message);
        return;
      }
      const fetched = data?.levels || [];
      setLevels(fetched);
      setLevelId((current) => current || fetched[0]?.id || null);
    });
    supabase.rpc('admin_session').then(({ data }) => {
      setCapabilities(data?.capabilities || []);
    });
  }, []);

  const level = levels.find((item) => item.id === levelId);
  const lessons = useMemo(
    () => (level?.units || []).flatMap((unit) => unit.lessons.map((item) => ({ ...item, unit }))),
    [level],
  );

  const loadLesson = useCallback(async (id) => {
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
  }, []);

  const update = (patch) => setLesson((current) => ({ ...current, ...patch }));

  const updateObjective = (index, patch) => {
    const objectives = lesson.objectives.map((item, position) =>
      position === index ? { ...item, ...patch } : item,
    );
    update({ objectives });
  };

  const updatePhrase = (index, patch) => {
    const phrases = lesson.phrases.map((item, position) =>
      position === index ? { ...item, ...patch } : item,
    );
    update({ phrases: phrases.map((item, position) => ({ ...item, order_index: position + 1 })) });
  };

  const save = async () => {
    setBusy(true);
    try {
      const { data, error: rpcError } = await supabase.rpc('admin_save_lesson', {
        p_lesson: {
          id: lesson.id,
          unit_id: lesson.unit_id,
          title: lesson.title,
          category: lesson.category,
          difficulty: lesson.difficulty === null ? null : Number(lesson.difficulty),
          order_index: lesson.order_index,
          main_objective: lesson.main_objective,
          scenario_context: lesson.scenario_context,
          assistant_role: lesson.assistant_role,
          user_role: lesson.user_role,
          initial_message: lesson.initial_message,
          objectives: lesson.objectives.map((item, position) => ({
            ...item,
            order_index: position + 1,
          })),
          phrases: lesson.phrases.map((item, position) => ({
            ...item,
            order_index: position + 1,
            translation_status: translationStatus(item.phrase, item.translation),
          })),
          activities: lesson.activities || [],
        },
      });
      if (rpcError) setError(rpcError.message);
      else {
        setError(null);
        setNotice(`Borrador guardado en la versión ${data.draft_version}.`);
        await loadLesson(lesson.id);
      }
    } finally {
      setBusy(false);
    }
  };

  const publish = async () => {
    setBusy(true);
    try {
      const { data, error: rpcError } = await supabase.rpc('admin_publish_lesson', {
        p_lesson_id: lesson.id,
        p_changelog: notice || null,
      });
      if (rpcError) setError(rpcError.message);
      else {
        setError(null);
        setNotice(`Publicada la versión ${data.version}.`);
        await loadLesson(lesson.id);
      }
    } finally {
      setBusy(false);
    }
  };

  const canPublish = capabilities.includes('publish');

  if (error && !lesson) {
    return (
      <div className="glass-panel" style={{ padding: '24px' }}>
        <h2 style={{ fontSize: '16px', color: '#fff', marginBottom: '8px' }}>No se pudo cargar</h2>
        <p style={{ fontSize: '13px', color: 'var(--text-muted)' }}>{error}</p>
      </div>
    );
  }

  return (
    <div style={{ display: 'flex', gap: '20px', alignItems: 'flex-start' }}>
      <aside className="glass-panel" style={{ width: '260px', padding: '16px', flexShrink: 0 }}>
        <select
          value={levelId || ''}
          onChange={(event) => {
            setLevelId(event.target.value);
            setLesson(null);
          }}
          style={{ ...FIELD, marginBottom: '12px' }}
        >
          {levels.map((item) => (
            <option key={item.id} value={item.id}>
              {item.cefr} · {item.name}
            </option>
          ))}
        </select>

        <div style={{ display: 'flex', flexDirection: 'column', gap: '4px', maxHeight: '65vh', overflowY: 'auto' }}>
          {lessons.map((item) => (
            <button
              key={item.id}
              type="button"
              onClick={() => loadLesson(item.id)}
              style={{
                ...BTN,
                textAlign: 'left',
                padding: '6px 8px',
                fontSize: '12px',
                borderColor: item.id === lessonId ? 'var(--primary-purple)' : 'transparent',
                background: item.id === lessonId ? 'rgba(168, 85, 247, 0.16)' : 'transparent',
              }}
            >
              <div style={{ color: '#fff' }}>{item.title || item.id}</div>
              <div style={{ color: 'var(--text-muted)', fontSize: '10px', fontFamily: 'var(--font-mono)' }}>
                {item.unit.slug} · {item.status}
              </div>
            </button>
          ))}
        </div>
      </aside>

      <section style={{ flex: 1, minWidth: 0 }}>
        {!lesson ? (
          <div className="glass-panel" style={{ padding: '24px', color: 'var(--text-muted)', fontSize: '13px' }}>
            Elige una lección para editarla.
          </div>
        ) : (
          <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
            <header style={{ display: 'flex', justifyContent: 'space-between', gap: '12px', alignItems: 'center' }}>
              <div>
                <h1 style={{ fontSize: '20px', fontWeight: '800', color: '#fff' }}>{lesson.title || lesson.id}</h1>
                <p style={{ fontSize: '12px', color: 'var(--text-muted)', fontFamily: 'var(--font-mono)' }}>
                  {lesson.id} · {lesson.status}
                  {lesson.published_version ? ` · publicada v${lesson.published_version}` : ''}
                  {lesson.draft_version ? ` · borrador v${lesson.draft_version}` : ''}
                </p>
              </div>
              <div style={{ display: 'flex', gap: '8px' }}>
                <button type="button" style={BTN} onClick={save} disabled={busy}>
                  Guardar borrador
                </button>
                <button
                  type="button"
                  style={{ ...BTN, borderColor: canPublish ? 'var(--secondary-teal)' : 'var(--border-glass)', opacity: canPublish ? 1 : 0.5 }}
                  onClick={publish}
                  disabled={busy || !canPublish}
                  title={canPublish ? 'Publicar el borrador' : 'Tu rol no publica'}
                >
                  Publicar
                </button>
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

            <div className="glass-panel" style={{ padding: '16px', display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px' }}>
              <label>
                <span style={LABEL}>Título</span>
                <input style={FIELD} value={lesson.title || ''} onChange={(event) => update({ title: event.target.value })} />
              </label>
              <label>
                <span style={LABEL}>Categoría</span>
                <input style={FIELD} value={lesson.category || ''} onChange={(event) => update({ category: event.target.value })} />
              </label>
              <label>
                <span style={LABEL}>Dificultad (1-6)</span>
                <input
                  style={FIELD}
                  type="number"
                  min="1"
                  max="6"
                  value={lesson.difficulty ?? ''}
                  onChange={(event) => update({ difficulty: event.target.value === '' ? null : Number(event.target.value) })}
                />
              </label>
              <label>
                <span style={LABEL}>Objetivo principal</span>
                <input style={FIELD} value={lesson.main_objective || ''} onChange={(event) => update({ main_objective: event.target.value })} />
              </label>
              <label style={{ gridColumn: '1 / -1' }}>
                <span style={LABEL}>Contexto</span>
                <input style={FIELD} value={lesson.scenario_context || ''} onChange={(event) => update({ scenario_context: event.target.value })} />
              </label>
              <label>
                <span style={LABEL}>Rol del asistente</span>
                <input style={FIELD} value={lesson.assistant_role || ''} onChange={(event) => update({ assistant_role: event.target.value })} />
              </label>
              <label>
                <span style={LABEL}>Rol del alumno</span>
                <input style={FIELD} value={lesson.user_role || ''} onChange={(event) => update({ user_role: event.target.value })} />
              </label>
              <label style={{ gridColumn: '1 / -1' }}>
                <span style={LABEL}>Mensaje inicial</span>
                <input style={FIELD} value={lesson.initial_message || ''} onChange={(event) => update({ initial_message: event.target.value })} />
              </label>
            </div>

            <div className="glass-panel" style={{ padding: '16px' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '10px' }}>
                <h2 style={{ fontSize: '13px', color: '#fff', fontFamily: 'var(--font-mono)' }}>OBJETIVOS</h2>
                <button
                  type="button"
                  style={{ ...BTN, padding: '4px 10px', fontSize: '12px' }}
                  onClick={() =>
                    update({
                      objectives: [
                        ...lesson.objectives,
                        { code: `g${lesson.objectives.length + 1}`, description: '', competency: 'speaking' },
                      ],
                    })
                  }
                >
                  + Objetivo
                </button>
              </div>
              {lesson.objectives.map((objective, index) => (
                <div key={`${objective.code}-${index}`} style={{ display: 'grid', gridTemplateColumns: '70px 1fr 150px 30px', gap: '8px', marginBottom: '8px' }}>
                  <input style={FIELD} value={objective.code || ''} onChange={(event) => updateObjective(index, { code: event.target.value })} />
                  <input style={FIELD} value={objective.description || ''} onChange={(event) => updateObjective(index, { description: event.target.value })} />
                  <select style={FIELD} value={objective.competency || 'speaking'} onChange={(event) => updateObjective(index, { competency: event.target.value })}>
                    {COMPETENCIES.map((competency) => (
                      <option key={competency} value={competency}>
                        {competency}
                      </option>
                    ))}
                  </select>
                  <button
                    type="button"
                    style={{ ...BTN, padding: '4px' }}
                    onClick={() => update({ objectives: lesson.objectives.filter((_, position) => position !== index) })}
                  >
                    ×
                  </button>
                </div>
              ))}
            </div>

            <div className="glass-panel" style={{ padding: '16px' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '10px' }}>
                <h2 style={{ fontSize: '13px', color: '#fff', fontFamily: 'var(--font-mono)' }}>FRASES</h2>
                <button
                  type="button"
                  style={{ ...BTN, padding: '4px 10px', fontSize: '12px' }}
                  onClick={() => update({ phrases: [...lesson.phrases, { phrase: '', translation: '' }] })}
                >
                  + Frase
                </button>
              </div>
              {lesson.phrases.map((phrase, index) => {
                const status = translationStatus(phrase.phrase, phrase.translation);
                return (
                  <div key={index} style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 110px 30px', gap: '8px', marginBottom: '8px', alignItems: 'center' }}>
                    <input style={FIELD} value={phrase.phrase || ''} onChange={(event) => updatePhrase(index, { phrase: event.target.value })} />
                    <input style={FIELD} value={phrase.translation || ''} onChange={(event) => updatePhrase(index, { translation: event.target.value })} />
                    <span
                      style={{
                        fontSize: '11px',
                        fontFamily: 'var(--font-mono)',
                        color: status === 'identical' ? 'var(--primary-purple)' : status === 'pending' ? '#ffb4b4' : 'var(--secondary-teal)',
                      }}
                    >
                      {status}
                    </span>
                    <button
                      type="button"
                      style={{ ...BTN, padding: '4px' }}
                      onClick={() => update({ phrases: lesson.phrases.filter((_, position) => position !== index) })}
                    >
                      ×
                    </button>
                  </div>
                );
              })}
              <p style={{ fontSize: '11px', color: 'var(--text-muted)', marginTop: '8px' }}>
                <strong>identical</strong> significa que la traducción repite la frase: se guarda así, sin corregirla
                (la corrección es trabajo de la cola de traducciones).
              </p>
            </div>
          </div>
        )}
      </section>
    </div>
  );
}
