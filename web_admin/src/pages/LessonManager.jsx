import React, { useState } from 'react';
import GlassCard from '../components/GlassCard';
import { Plus, Edit2, Trash2, CheckCircle, Sparkles, BookOpen, MessageSquare, Flag } from 'lucide-react';

export default function LessonManager({ lessons, onSaveLesson, onDeleteLesson }) {
  const [selectedLevelFilter, setSelectedLevelFilter] = useState('ALL');
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingLesson, setEditingLesson] = useState(null);

  // Form State
  const [id, setId] = useState('');
  const [title, setTitle] = useState('');
  const [category, setCategory] = useState('social');
  const [level, setLevel] = useState('A1');
  const [difficulty, setDifficulty] = useState(1);
  const [description, setDescription] = useState('');
  const [assistantRole, setAssistantRole] = useState('');
  const [userRole, setUserRole] = useState('');
  const [initialAssistantMessage, setInitialAssistantMessage] = useState('');
  const [mainObjective, setMainObjective] = useState('');
  const [goalsText, setGoalsText] = useState('');
  const [phrasesText, setPhrasesText] = useState('');

  const filteredLessons = selectedLevelFilter === 'ALL'
    ? lessons
    : lessons.filter((l) => l.level === selectedLevelFilter);

  const handleOpenCreate = () => {
    setEditingLesson(null);
    setId(`lesson_${Date.now().toString().slice(-4)}`);
    setTitle('');
    setCategory('social');
    setLevel('A1');
    setDifficulty(1);
    setDescription('');
    setAssistantRole('Tutor de IA');
    setUserRole('Estudiante');
    setInitialAssistantMessage("Hello! Let's practice speaking today.");
    setMainObjective('Practica tu conversación y fluidez.');
    setGoalsText("1. Saludar e iniciar diálogo | hello\n2. Preguntar cómo está | how\n3. Decir tus preferencias | like\n4. Usar vocabulario clave | good\n5. Despedirte adecuadamente | bye");
    setPhrasesText("Nice to meet you | Mucho gusto\nHow are you? | ¿Cómo estás?\nI would like to... | Me gustaría...\nCould you repeat that? | ¿Podrías repetir eso?");
    setIsModalOpen(true);
  };

  const handleOpenEdit = (lesson) => {
    setEditingLesson(lesson);
    setId(lesson.id);
    setTitle(lesson.title);
    setCategory(lesson.category || 'social');
    setLevel(lesson.level || 'A1');
    setDifficulty(lesson.difficulty || 1);
    setDescription(lesson.description || '');
    setAssistantRole(lesson.assistantRole || '');
    setUserRole(lesson.userRole || '');
    setInitialAssistantMessage(lesson.initialAssistantMessage || '');
    setMainObjective(lesson.mainObjective || '');
    
    // Format Goals to Text
    const gText = lesson.goals
      ? lesson.goals.map((g, idx) => `${idx + 1}. ${g.text} | ${g.keyword}`).join('\n')
      : '';
    setGoalsText(gText);

    // Format Phrases to Text
    const pText = lesson.usefulPhrases
      ? lesson.usefulPhrases.map((p) => `${p.phrase} | ${p.translation}`).join('\n')
      : '';
    setPhrasesText(pText);

    setIsModalOpen(true);
  };

  const handleSubmitForm = (e) => {
    e.preventDefault();

    // Parse Goals
    const parsedGoals = goalsText.split('\n').filter((l) => l.trim().length > 0).map((line, idx) => {
      const parts = line.split('|');
      const text = parts[0]?.replace(/^\d+\.\s*/, '').trim() || line.trim();
      const keyword = parts[1]?.trim() || text.split(' ').pop() || 'key';
      return { id: `g${idx + 1}`, text, keyword };
    });

    // Parse Phrases
    const parsedPhrases = phrasesText.split('\n').filter((l) => l.trim().length > 0).map((line, idx) => {
      const parts = line.split('|');
      const phrase = parts[0]?.trim() || line.trim();
      const translation = parts[1]?.trim() || 'Traducción';
      return { id: `p${idx + 1}`, phrase, translation };
    });

    const newLessonObj = {
      id,
      title,
      category,
      level,
      difficulty: Number(difficulty),
      description,
      assistantRole,
      userRole,
      initialAssistantMessage,
      mainObjective,
      goals: parsedGoals,
      usefulPhrases: parsedPhrases,
    };

    onSaveLesson(newLessonObj);
    setIsModalOpen(false);
  };

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '24px' }}>
      {/* Header & Controls */}
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', flexWrap: 'wrap', gap: '16px' }}>
        <div>
          <h1 style={{ fontSize: '26px', fontWeight: '800', color: '#fff' }}>Gestión de Lecciones y Escenarios</h1>
          <p style={{ color: 'var(--text-muted)', fontSize: '14px', marginTop: '4px' }}>
            Crea y edita roleplays conversacionales, definiendo objetivos, metas (Brújula 🧭) y frases clave sugeridas por nivel.
          </p>
        </div>
        <button className="btn-primary" onClick={handleOpenCreate}>
          <Plus style={{ width: '18px', height: '18px' }} />
          <span>Crear Nueva Lección</span>
        </button>
      </div>

      {/* Level Filters */}
      <div style={{ display: 'flex', gap: '10px', flexWrap: 'wrap' }}>
        {['ALL', 'A1', 'A2', 'B1', 'B2', 'C1'].map((lvl) => (
          <button
            key={lvl}
            onClick={() => setSelectedLevelFilter(lvl)}
            className={selectedLevelFilter === lvl ? 'btn-teal' : 'btn-secondary'}
            style={{ padding: '8px 16px', fontSize: '13px', fontFamily: 'var(--font-mono)' }}
          >
            {lvl === 'ALL' ? 'Todos los Niveles' : `Nivel ${lvl}`}
          </button>
        ))}
      </div>

      {/* Lessons Table */}
      <GlassCard padding="24px">
        <div className="table-responsive">
          <table className="admin-table">
            <thead>
              <tr>
                <th>ID</th>
                <th>Título del Escenario</th>
                <th>Nivel</th>
                <th>Categoría</th>
                <th>Rol del Asistente</th>
                <th>Metas Configuradas</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              {filteredLessons.map((lesson) => (
                <tr key={lesson.id}>
                  <td style={{ fontFamily: 'var(--font-mono)', color: 'var(--secondary-teal)', fontSize: '13px' }}>
                    {lesson.id}
                  </td>
                  <td style={{ fontWeight: '600', color: '#fff' }}>{lesson.title}</td>
                  <td>
                    <span className={`badge-level badge-${lesson.level.toLowerCase()}`}>
                      {lesson.level}
                    </span>
                  </td>
                  <td style={{ textTransform: 'capitalize', color: 'var(--text-muted)' }}>{lesson.category}</td>
                  <td style={{ color: 'var(--text-main)', fontSize: '13px' }}>{lesson.assistantRole || 'Tutor IA'}</td>
                  <td>
                    <span style={{ fontSize: '12px', color: '#10b981', fontWeight: '600' }}>
                      ✓ {lesson.goals?.length || 5} Metas
                    </span>
                  </td>
                  <td>
                    <div style={{ display: 'flex', gap: '8px' }}>
                      <button
                        className="btn-secondary"
                        onClick={() => handleOpenEdit(lesson)}
                        style={{ padding: '6px 10px', fontSize: '12px' }}
                      >
                        <Edit2 style={{ width: '14px', height: '14px', color: 'var(--secondary-teal)' }} />
                        <span>Editar</span>
                      </button>
                      <button
                        className="btn-secondary"
                        onClick={() => onDeleteLesson(lesson.id)}
                        style={{ padding: '6px 10px', fontSize: '12px' }}
                      >
                        <Trash2 style={{ width: '14px', height: '14px', color: '#ef4444' }} />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </GlassCard>

      {/* Modal Editor Form */}
      {isModalOpen && (
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
          <GlassCard style={{ width: '100%', maxWidth: '800px', maxHeight: '90vh', overflowY: 'auto', padding: '32px', border: '1px solid var(--border-glass-glow)' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px', borderBottom: '1px solid var(--border-glass)', paddingBottom: '16px' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                <Sparkles style={{ color: 'var(--primary-purple)', width: '24px', height: '24px' }} />
                <h2 style={{ fontSize: '20px', fontWeight: '800', color: '#fff' }}>
                  {editingLesson ? 'Editar Lección / Escenario' : 'Crear Nueva Lección'}
                </h2>
              </div>
              <button className="btn-secondary" onClick={() => setIsModalOpen(false)}>✕ Cerrar</button>
            </div>

            <form onSubmit={handleSubmitForm} style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px' }}>
                <div>
                  <label style={{ fontSize: '12px', color: 'var(--text-muted)', display: 'block', marginBottom: '6px' }}>ID de Lección</label>
                  <input type="text" value={id} onChange={(e) => setId(e.target.value)} required className="cyber-input" />
                </div>
                <div>
                  <label style={{ fontSize: '12px', color: 'var(--text-muted)', display: 'block', marginBottom: '6px' }}>Título del Escenario</label>
                  <input type="text" value={title} onChange={(e) => setTitle(e.target.value)} required className="cyber-input" placeholder="Ej. Pedir comida en un café" />
                </div>
              </div>

              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: '16px' }}>
                <div>
                  <label style={{ fontSize: '12px', color: 'var(--text-muted)', display: 'block', marginBottom: '6px' }}>Nivel CEFR</label>
                  <select value={level} onChange={(e) => setLevel(e.target.value)} className="cyber-select">
                    <option value="A1">A1 — Principiante</option>
                    <option value="A2">A2 — Elemental</option>
                    <option value="B1">B1 — Intermedio</option>
                    <option value="B2">B2 — Intermedio Alto</option>
                    <option value="C1">C1 — Avanzado</option>
                  </select>
                </div>
                <div>
                  <label style={{ fontSize: '12px', color: 'var(--text-muted)', display: 'block', marginBottom: '6px' }}>Categoría</label>
                  <select value={category} onChange={(e) => setCategory(e.target.value)} className="cyber-select">
                    <option value="social">Social & Amigos</option>
                    <option value="food">Comida & Cafés</option>
                    <option value="travel">Viajes & Hoteles</option>
                    <option value="business">Negocios & Trabajo</option>
                    <option value="tech">Tecnología & IA</option>
                  </select>
                </div>
                <div>
                  <label style={{ fontSize: '12px', color: 'var(--text-muted)', display: 'block', marginBottom: '6px' }}>Dificultad (1-5)</label>
                  <input type="number" min="1" max="5" value={difficulty} onChange={(e) => setDifficulty(e.target.value)} className="cyber-input" />
                </div>
              </div>

              <div>
                <label style={{ fontSize: '12px', color: 'var(--text-muted)', display: 'block', marginBottom: '6px' }}>Objetivo Principal</label>
                <input type="text" value={mainObjective} onChange={(e) => setMainObjective(e.target.value)} className="cyber-input" placeholder="Ej. Ordenar una bebida y pagar con tarjeta" />
              </div>

              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px' }}>
                <div>
                  <label style={{ fontSize: '12px', color: 'var(--text-muted)', display: 'block', marginBottom: '6px' }}>Rol del Asistente (IA)</label>
                  <input type="text" value={assistantRole} onChange={(e) => setAssistantRole(e.target.value)} className="cyber-input" placeholder="Ej. Friendly Barista (Sam)" />
                </div>
                <div>
                  <label style={{ fontSize: '12px', color: 'var(--text-muted)', display: 'block', marginBottom: '6px' }}>Rol del Usuario</label>
                  <input type="text" value={userRole} onChange={(e) => setUserRole(e.target.value)} className="cyber-input" placeholder="Ej. Customer" />
                </div>
              </div>

              <div>
                <label style={{ fontSize: '12px', color: 'var(--text-muted)', display: 'block', marginBottom: '6px' }}>Mensaje Inicial del Asistente</label>
                <textarea rows="2" value={initialAssistantMessage} onChange={(e) => setInitialAssistantMessage(e.target.value)} className="cyber-input" placeholder="Ej. Welcome to StarCafé! What can I get for you?" />
              </div>

              {/* Dynamic Goals & Phrases textareas */}
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px' }}>
                <div>
                  <label style={{ fontSize: '12px', color: 'var(--secondary-teal)', fontWeight: '600', display: 'block', marginBottom: '6px' }}>
                    Metas del Escenario (1 por línea: Texto | Keyword)
                  </label>
                  <textarea rows="5" value={goalsText} onChange={(e) => setGoalsText(e.target.value)} className="cyber-input" style={{ fontFamily: 'var(--font-mono)', fontSize: '12px' }} />
                </div>
                <div>
                  <label style={{ fontSize: '12px', color: 'var(--primary-purple)', fontWeight: '600', display: 'block', marginBottom: '6px' }}>
                    Frases Clave Sugeridas (1 por línea: Frase | Traducción)
                  </label>
                  <textarea rows="5" value={phrasesText} onChange={(e) => setPhrasesText(e.target.value)} className="cyber-input" style={{ fontFamily: 'var(--font-mono)', fontSize: '12px' }} />
                </div>
              </div>

              <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '12px', marginTop: '12px' }}>
                <button type="button" className="btn-secondary" onClick={() => setIsModalOpen(false)}>Cancelar</button>
                <button type="submit" className="btn-primary">Guardar Lección</button>
              </div>
            </form>
          </GlassCard>
        </div>
      )}
    </div>
  );
}
