import React, { useState } from 'react';
import GlassCard from '../components/GlassCard';
import { Layers, Plus, Edit3, Trash2, Save, X } from 'lucide-react';

const EMPTY_FORM = {
  code: '',
  name: '',
  description: '',
  color: '#a855f7',
  difficultyRange: '1 - 2',
};

export default function CefrLevelsManager({ cefrLevels = [], onSaveLevel, onDeleteLevel }) {
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingLevel, setEditingLevel] = useState(null); // nivel o null (crear)
  const [form, setForm] = useState(EMPTY_FORM);

  const openCreate = () => {
    setEditingLevel(null);
    setForm(EMPTY_FORM);
    setIsModalOpen(true);
  };

  const openEdit = (lvl) => {
    setEditingLevel(lvl);
    setForm({
      code: lvl.code,
      name: lvl.name,
      description: lvl.description || '',
      color: lvl.color || '#a855f7',
      difficultyRange: lvl.difficultyRange || '1 - 2',
    });
    setIsModalOpen(true);
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    if (!form.code.trim() || !form.name.trim()) return;
    if (onSaveLevel) onSaveLevel(form);
    setIsModalOpen(false);
  };

  const handleDelete = (lvl) => {
    const ok = window.confirm(`¿Eliminar el nivel ${lvl.code} (${lvl.name})?`);
    if (ok && onDeleteLevel) onDeleteLevel(lvl.code);
  };

  const input = (key, label, placeholder) => (
    <div>
      <label className="form-label">{label}</label>
      <input
        type="text"
        value={form[key]}
        placeholder={placeholder}
        required={key === 'code' || key === 'name'}
        onChange={(e) => setForm({ ...form, [key]: e.target.value })}
        className="cyber-input"
      />
    </div>
  );

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '24px' }}>
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', flexWrap: 'wrap', gap: '16px' }}>
        <div>
          <h1 style={{ fontSize: '26px', fontWeight: '800', color: '#fff' }}>Gestión de Niveles CEFR</h1>
          <p style={{ color: 'var(--text-muted)', fontSize: '14px', marginTop: '4px' }}>
            Administra los niveles del marco europeo (A1 a C2): crea, edita y elimina.
          </p>
        </div>
        <button className="btn-primary" onClick={openCreate}>
          <Plus style={{ width: '18px', height: '18px' }} />
          <span>Crear Nuevo Nivel CEFR</span>
        </button>
      </div>

      {cefrLevels.length === 0 ? (
        <div style={{ padding: '24px', textAlign: 'center', color: 'var(--text-muted)', fontSize: '13px', border: '1px dashed var(--border-glass)', borderRadius: '12px' }}>
          No hay niveles CEFR en la base de datos.
        </div>
      ) : (
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(320px, 1fr))', gap: '20px' }}>
          {cefrLevels.map((lvl) => (
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

              <div style={{ display: 'flex', gap: '8px' }}>
                <button className="btn-primary" onClick={() => openEdit(lvl)} style={{ flex: 1, justifyContent: 'center' }}>
                  <Edit3 style={{ width: '16px', height: '16px' }} />
                  <span>Editar</span>
                </button>
                <button className="btn-secondary" onClick={() => handleDelete(lvl)} style={{ justifyContent: 'center', color: '#fca5a5' }}>
                  <Trash2 style={{ width: '16px', height: '16px' }} />
                  <span>Eliminar</span>
                </button>
              </div>
            </GlassCard>
          ))}
        </div>
      )}

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
          <GlassCard style={{ width: '100%', maxWidth: '520px', padding: '32px' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
              <h2 style={{ fontSize: '20px', fontWeight: '800', color: '#fff' }}>
                {editingLevel ? `Editar Nivel ${editingLevel.code}` : 'Crear Nuevo Nivel CEFR'}
              </h2>
              <button className="btn-secondary" onClick={() => setIsModalOpen(false)}><X style={{ width: '16px', height: '16px' }} /></button>
            </div>
            <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px' }}>
                {input('code', 'Código (ej. C2)', 'C2')}
                {input('name', 'Nombre', 'Maestría')}
              </div>
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px' }}>
                <div>
                  <label className="form-label">Color</label>
                  <input
                    type="color"
                    value={form.color}
                    onChange={(e) => setForm({ ...form, color: e.target.value })}
                    style={{ width: '100%', height: '40px', border: '1px solid var(--border-glass)', borderRadius: '8px', background: 'transparent', cursor: 'pointer' }}
                  />
                </div>
                {input('difficultyRange', 'Rango Dificultad', '1 - 2')}
              </div>
              <div>
                <label className="form-label">Descripción pedagógica</label>
                <textarea
                  rows="3"
                  value={form.description}
                  onChange={(e) => setForm({ ...form, description: e.target.value })}
                  className="cyber-input"
                />
              </div>
              <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '12px', marginTop: '12px' }}>
                <button type="button" className="btn-secondary" onClick={() => setIsModalOpen(false)}>Cancelar</button>
                <button type="submit" className="btn-primary">
                  <Save style={{ width: '16px', height: '16px' }} />
                  <span>Guardar Nivel</span>
                </button>
              </div>
            </form>
          </GlassCard>
        </div>
      )}
    </div>
  );
}
