import React, { useState, useEffect } from 'react';
import GlassCard from '../components/GlassCard';
import UserDetailModal from '../components/UserDetailModal';
import { Users, Fingerprint, Award, Flame, Clock, Zap, Search, Activity, Edit3, Save, X, UserCheck, Eye, Sparkles, Trash2 } from 'lucide-react';

export default function UserBiometricsManager({ users, onSaveUser, onDeleteUser }) {
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedUser, setSelectedUser] = useState(null);
  const [editingUser, setEditingUser] = useState(null);
  const [detailedUserModal, setDetailedUserModal] = useState(null);
  const [displayNameInput, setDisplayNameInput] = useState('');
  const [xpInput, setXpInput] = useState(0);
  const [streakInput, setStreakInput] = useState(0);
  const [languageFilter, setLanguageFilter] = useState('ALL');
  const [page, setPage] = useState(1);
  const pageSize = 10;

  const filteredUsers = users.filter(
    (u) =>
      (languageFilter === 'ALL' || (u.nativeLanguage || '') === languageFilter) &&
      (u.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
        (u.displayName && u.displayName.toLowerCase().includes(searchTerm.toLowerCase())) ||
        u.level.toLowerCase().includes(searchTerm.toLowerCase()))
  );

  const languages = [...new Set(users.map((u) => u.nativeLanguage).filter(Boolean))].sort();
  const totalPages = Math.max(1, Math.ceil(filteredUsers.length / pageSize));
  const paginatedUsers = filteredUsers.slice((page - 1) * pageSize, page * pageSize);

  useEffect(() => {
    setPage(1);
  }, [searchTerm, languageFilter]);

  const handleOpenEdit = (usr) => {
    setEditingUser(usr);
    setDisplayNameInput(usr.displayName === 'Sin display_name' ? '' : usr.displayName);
    setXpInput(usr.xp || 0);
    setStreakInput(usr.streak || 0);
  };

  const handleSaveUserEdit = async () => {
    if (!editingUser || !displayNameInput.trim()) return;
    const updated = {
      ...editingUser,
      displayName: displayNameInput.trim(),
      name: displayNameInput.trim(),
      xp: parseInt(xpInput, 10) || 0,
      streak: parseInt(streakInput, 10) || 0,
    };
    if (onSaveUser) {
      await onSaveUser(updated);
    }
    setEditingUser(null);
  };

  const handleDelete = (usr) => {
    const ok = window.confirm(`¿Eliminar el perfil de "${usr.displayName || usr.name}" (${usr.id})? Se borrará su progreso de idioma.`);
    if (ok && onDeleteUser) onDeleteUser(usr.id);
  };

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '24px' }}>
      {/* Header */}
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', flexWrap: 'wrap', gap: '16px' }}>
        <div>
          <h1 style={{ fontSize: '26px', fontWeight: '800', color: '#fff' }}>Gestión de Estudiantes & Biometría del Habla</h1>
          <p style={{ color: 'var(--text-muted)', fontSize: '14px', marginTop: '4px' }}>
            Monitorea el campo <code style={{ color: 'var(--primary-purple)', background: 'rgba(168,85,247,0.1)', padding: '2px 6px', borderRadius: '4px' }}>user.display_name</code>, consumo de minutos IA por plan, nivel CEFR, XP, racha y Speech DNA.
          </p>
        </div>
      </div>

      {/* Search + Language Filter */}
      <div style={{ display: 'flex', gap: '12px', flexWrap: 'wrap' }}>
        <div style={{ position: 'relative', maxWidth: '400px', flex: 1 }}>
          <Search style={{ position: 'absolute', left: '14px', top: '50%', transform: 'translateY(-50%)', width: '18px', height: '18px', color: 'var(--text-muted)' }} />
          <input
            type="text"
            placeholder="Buscar estudiante por User Name o nivel..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="cyber-input"
            style={{ paddingLeft: '42px' }}
          />
        </div>
        <div>
          <label className="form-label">Idioma nativo</label>
          <select
            value={languageFilter}
            onChange={(e) => setLanguageFilter(e.target.value)}
            className="cyber-input"
            style={{ appearance: 'auto' }}
          >
            <option value="ALL">Todos</option>
            {languages.map((lang) => (
              <option key={lang} value={lang}>{lang || 'Sin asignar'}</option>
            ))}
          </select>
        </div>
      </div>

      {/* Users Table */}
      <GlassCard padding="24px">
        <div className="table-responsive">
          <table className="admin-table">
            <thead>
              <tr>
                <th>UUID Estudiante</th>
                <th>User Name (<code style={{ color: 'var(--secondary-teal)' }}>user.display_name</code>)</th>
                <th>Nivel CEFR</th>
                <th>Puntos XP</th>
                <th>Racha</th>
                <th>Práctica Hablada</th>
                <th>Huella de Voz (DNA)</th>
                <th>Plan Contratado</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              {paginatedUsers.map((usr) => (
                <tr key={usr.id}>
                  <td>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                      <img src={usr.avatarUrl} alt={usr.name} style={{ width: '36px', height: '36px', borderRadius: '50%', background: 'rgba(255,255,255,0.1)' }} />
                      <div style={{ fontFamily: 'var(--font-mono)', fontSize: '12px', color: 'var(--text-muted)' }}>
                        {usr.id.slice(0, 12)}...
                      </div>
                    </div>
                  </td>
                  <td>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                      <UserCheck style={{ width: '16px', height: '16px', color: 'var(--secondary-teal)' }} />
                      <span style={{ fontWeight: '700', color: usr.displayName !== 'Sin display_name' ? '#fff' : 'var(--text-muted)', fontSize: '14px' }}>
                        {usr.displayName}
                      </span>
                    </div>
                  </td>
                  <td>
                    <span className={`badge-level badge-${usr.level.toLowerCase()}`}>
                      {usr.level}
                    </span>
                  </td>
                  <td style={{ fontFamily: 'var(--font-mono)', fontWeight: '700', color: 'var(--primary-purple)' }}>
                    {usr.xp} XP
                  </td>
                  <td>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '4px', color: '#f97316', fontWeight: '600' }}>
                      <Flame style={{ width: '16px', height: '16px' }} />
                      <span>{usr.streak} días</span>
                    </div>
                  </td>
                  <td style={{ fontFamily: 'var(--font-mono)', fontSize: '13px' }}>
                    <div>{usr.practiceMinutes ?? '—'} / {usr.audioLimitMinutes ?? '—'} min</div>
                    <div style={{ fontSize: '10px', color: 'var(--text-muted)' }}>{usr.remainingMinutes ?? '—'} min rest.</div>
                  </td>
                  <td>
                    <div style={{ fontSize: '12px' }}>
                      <span style={{ color: 'var(--secondary-teal)', fontWeight: '700' }}>{usr.clarityScore != null ? `${usr.clarityScore}% Claridad` : '— Claridad'}</span>
                      <div style={{ color: 'var(--text-muted)', fontSize: '11px', fontFamily: 'var(--font-mono)' }}>{usr.wpm != null ? `${usr.wpm} WPM` : '— WPM'}</div>
                    </div>
                  </td>
                  <td>
                    <span style={{
                      padding: '4px 10px',
                      borderRadius: '12px',
                      fontSize: '11px',
                      fontWeight: '700',
                      background: 'rgba(168, 85, 247, 0.2)',
                      color: 'var(--primary-purple)',
                      border: '1px solid var(--primary-purple)',
                    }}>
                      {usr.plan}
                    </span>
                  </td>
                  <td>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                      <button className="btn-primary" onClick={() => setDetailedUserModal(usr)} style={{ padding: '6px 12px', fontSize: '12px' }}>
                        <Eye style={{ width: '14px', height: '14px' }} />
                        <span>Ver Detalle & Membresía</span>
                      </button>

                      <button className="btn-secondary" onClick={() => handleOpenEdit(usr)} style={{ padding: '6px 12px', fontSize: '12px' }}>
                        <Edit3 style={{ width: '14px', height: '14px', color: '#a855f7' }} />
                        <span>Editar</span>
                      </button>

                      <button className="btn-secondary" onClick={() => handleDelete(usr)} style={{ padding: '6px 12px', fontSize: '12px', color: '#fca5a5' }}>
                        <Trash2 style={{ width: '14px', height: '14px' }} />
                        <span>Eliminar</span>
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        {filteredUsers.length > pageSize && (
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginTop: '14px', gap: '12px', flexWrap: 'wrap' }}>
            <span style={{ fontSize: '12px', color: 'var(--text-muted)' }}>
              {filteredUsers.length} estudiantes · Página {page} de {totalPages}
            </span>
            <div style={{ display: 'flex', gap: '8px' }}>
              <button className="btn-secondary" disabled={page <= 1} onClick={() => setPage((p) => Math.max(1, p - 1))}>
                ← Anterior
              </button>
              <button className="btn-secondary" disabled={page >= totalPages} onClick={() => setPage((p) => Math.min(totalPages, p + 1))}>
                Siguiente →
              </button>
            </div>
          </div>
        )}
      </GlassCard>

      {/* Detailed User Modal */}
      {detailedUserModal && (
        <UserDetailModal
          user={detailedUserModal}
          onClose={() => setDetailedUserModal(null)}
          onUpgradeOffer={(u) => {
            alert(`¡Promoción de Upgrade generada exitosamente para ${u.displayName}!`);
            setDetailedUserModal(null);
          }}
        />
      )}

      {/* Edit User Modal */}
      {editingUser && (
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
          <GlassCard style={{ width: '100%', maxWidth: '480px', padding: '28px', border: '1px solid var(--border-glass-glow)' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                <Edit3 style={{ color: 'var(--primary-purple)', width: '22px', height: '22px' }} />
                <h2 style={{ fontSize: '18px', fontWeight: '800', color: '#fff' }}>Editar Estudiante</h2>
              </div>
              <button className="btn-secondary" onClick={() => setEditingUser(null)}><X style={{ width: '16px', height: '16px' }} /></button>
            </div>

            <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
              <div>
                <label className="form-label">UUID de Supabase DB</label>
                <div style={{ fontFamily: 'var(--font-mono)', fontSize: '12px', color: 'var(--text-muted)', background: 'rgba(255,255,255,0.05)', padding: '8px 12px', borderRadius: '8px' }}>
                  {editingUser.id}
                </div>
              </div>

              <div>
                <label className="form-label">Nombre (user.display_name)</label>
                <input
                  type="text"
                  value={displayNameInput}
                  onChange={(e) => setDisplayNameInput(e.target.value)}
                  placeholder="Ej. Carlos Mendoza"
                  className="cyber-input"
                  style={{ width: '100%' }}
                />
              </div>

              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px' }}>
                <div>
                  <label className="form-label">Puntos XP</label>
                  <input
                    type="number"
                    value={xpInput}
                    onChange={(e) => setXpInput(e.target.value)}
                    className="cyber-input"
                  />
                </div>
                <div>
                  <label className="form-label">Racha (días)</label>
                  <input
                    type="number"
                    value={streakInput}
                    onChange={(e) => setStreakInput(e.target.value)}
                    className="cyber-input"
                  />
                </div>
              </div>

              <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '12px', marginTop: '12px' }}>
                <button className="btn-secondary" onClick={() => setEditingUser(null)}>Cancelar</button>
                <button className="btn-primary" onClick={handleSaveUserEdit}>
                  <Save style={{ width: '16px', height: '16px' }} />
                  <span>Guardar en DB</span>
                </button>
              </div>
            </div>
          </GlassCard>
        </div>
      )}
    </div>
  );
}
