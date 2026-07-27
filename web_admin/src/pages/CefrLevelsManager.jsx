import React, { useState } from 'react';
import GlassCard from '../components/GlassCard';
import { Layers, Plus, Users, BookOpen, Sparkles, CheckCircle2 } from 'lucide-react';

export default function CefrLevelsManager({ levels, onAddLevel }) {
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [code, setCode] = useState('');
  const [name, setName] = useState('');
  const [description, setDescription] = useState('');
  const [color, setColor] = useState('#a855f7');
  const [difficultyRange, setDifficultyRange] = useState('1 - 2');

  const handleSubmit = (e) => {
    e.preventDefault();
    const newLvl = {
      code,
      name,
      description,
      color,
      badgeClass: `badge-${code.toLowerCase()}`,
      activeLessons: 0,
      enrolledStudents: 0,
      difficultyRange,
      icon: '⭐',
    };
    onAddLevel(newLvl);
    setIsModalOpen(false);
  };

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '24px' }}>
      {/* Header */}
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', flexWrap: 'wrap', gap: '16px' }}>
        <div>
          <h1 style={{ fontSize: '26px', fontWeight: '800', color: '#fff' }}>Gestión de Niveles CEFR</h1>
          <p style={{ color: 'var(--text-muted)', fontSize: '14px', marginTop: '4px' }}>
            Administra los niveles del marco europeo (A1 a C2), crea nuevos niveles personalizados y configura las reglas de recomendación automática.
          </p>
        </div>
        <button className="btn-primary" onClick={() => setIsModalOpen(true)}>
          <Plus style={{ width: '18px', height: '18px' }} />
          <span>Crear Nuevo Nivel CEFR</span>
        </button>
      </div>

      {/* Levels Grid */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(320px, 1fr))', gap: '20px' }}>
        {levels.map((lvl) => (
          <GlassCard key={lvl.code} interactive padding="24px">
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '16px' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                <div style={{
                  width: '44px',
                  height: '44px',
                  borderRadius: '12px',
                  background: `${lvl.color}22`,
                  border: `1px solid ${lvl.color}66`,
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  fontSize: '20px',
                }}>
                  {lvl.icon || '🎓'}
                </div>
                <div>
                  <h3 style={{ fontSize: '20px', fontWeight: '800', color: '#fff' }}>
                    {lvl.code} — {lvl.name}
                  </h3>
                  <span style={{ fontSize: '11px', color: lvl.color, fontFamily: 'var(--font-mono)', fontWeight: '600' }}>
                    Rango Dificultad: {lvl.difficultyRange}
                  </span>
                </div>
              </div>
            </div>

            <p style={{ fontSize: '13px', color: 'var(--text-muted)', marginBottom: '20px', minHeight: '40px' }}>
              {lvl.description}
            </p>

            <div style={{
              display: 'flex',
              justifyContent: 'space-between',
              paddingTop: '16px',
              borderTop: '1px solid var(--border-glass)',
              fontSize: '13px',
            }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '6px', color: 'var(--text-main)' }}>
                <BookOpen style={{ width: '16px', height: '16px', color: 'var(--primary-purple)' }} />
                <span><strong>{lvl.activeLessons}</strong> Lecciones</span>
              </div>
              <div style={{ display: 'flex', alignItems: 'center', gap: '6px', color: 'var(--text-main)' }}>
                <Users style={{ width: '16px', height: '16px', color: 'var(--secondary-teal)' }} />
                <span><strong>{lvl.enrolledStudents}</strong> Alumnos</span>
              </div>
            </div>
          </GlassCard>
        ))}
      </div>

      {/* Recommendation Algorithm Card */}
      <GlassCard padding="24px">
        <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '16px' }}>
          <Sparkles style={{ color: 'var(--secondary-teal)', width: '22px', height: '22px' }} />
          <h3 style={{ fontSize: '18px', fontWeight: '700', color: '#fff' }}>Motor de Recomendación Inteligente de Lecciones</h3>
        </div>
        <p style={{ fontSize: '13px', color: 'var(--text-muted)', marginBottom: '16px' }}>
          Las lecciones recomendadas en el Dashboard del estudiante se seleccionan dinámicamente mapeando el nivel CEFR actual del usuario y sus intereses seleccionados en Onboarding.
        </p>

        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(220px, 1fr))', gap: '16px' }}>
          <div style={{ padding: '16px', borderRadius: '12px', background: 'rgba(6, 13, 32, 0.5)', border: '1px solid var(--border-glass)' }}>
            <div style={{ fontSize: '12px', color: 'var(--secondary-teal)', fontFamily: 'var(--font-mono)' }}>Estrategia A1/A2</div>
            <div style={{ fontSize: '14px', fontWeight: '600', color: '#fff', marginTop: '4px' }}>Progresión Directa</div>
            <p style={{ fontSize: '11px', color: 'var(--text-muted)', marginTop: '4px' }}>Muestra lecciones del nivel actual más 1 lección del nivel superior inmediato.</p>
          </div>
          <div style={{ padding: '16px', borderRadius: '12px', background: 'rgba(6, 13, 32, 0.5)', border: '1px solid var(--border-glass)' }}>
            <div style={{ fontSize: '12px', color: 'var(--primary-purple)', fontFamily: 'var(--font-mono)' }}>Estrategia B1/B2</div>
            <div style={{ fontSize: '14px', fontWeight: '600', color: '#fff', marginTop: '4px' }}>Misiones de Negocio & Tech</div>
            <p style={{ fontSize: '11px', color: 'var(--text-muted)', marginTop: '4px' }}>Prioriza entrevistas de trabajo, negociación y temas de alta demanda laboral.</p>
          </div>
        </div>
      </GlassCard>

      {/* Modal New Level */}
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
          <GlassCard style={{ width: '100%', maxWidth: '500px', padding: '32px' }}>
            <h2 style={{ fontSize: '20px', fontWeight: '800', color: '#fff', marginBottom: '20px' }}>Crear Nuevo Nivel CEFR</h2>
            <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
              <div>
                <label style={{ fontSize: '12px', color: 'var(--text-muted)', display: 'block', marginBottom: '6px' }}>Código de Nivel (ej. C2)</label>
                <input type="text" value={code} onChange={(e) => setCode(e.target.value)} required className="cyber-input" placeholder="C2" />
              </div>
              <div>
                <label style={{ fontSize: '12px', color: 'var(--text-muted)', display: 'block', marginBottom: '6px' }}>Nombre del Nivel (ej. Maestría)</label>
                <input type="text" value={name} onChange={(e) => setName(e.target.value)} required className="cyber-input" placeholder="Maestría" />
              </div>
              <div>
                <label style={{ fontSize: '12px', color: 'var(--text-muted)', display: 'block', marginBottom: '6px' }}>Descripción pedagógica</label>
                <textarea rows="3" value={description} onChange={(e) => setDescription(e.target.value)} className="cyber-input" />
              </div>
              <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '12px', marginTop: '12px' }}>
                <button type="button" className="btn-secondary" onClick={() => setIsModalOpen(false)}>Cancelar</button>
                <button type="submit" className="btn-primary">Guardar Nivel</button>
              </div>
            </form>
          </GlassCard>
        </div>
      )}
    </div>
  );
}
