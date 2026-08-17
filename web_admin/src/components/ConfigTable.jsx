import React, { useState, useEffect } from 'react';
import GlassCard from './GlassCard';
import { Edit3, Save, X, Plus, Trash2, RefreshCw } from 'lucide-react';
import { supabase } from '../lib/supabaseClient';

/**
 * Tabla de configuración genérica (CRUD) sobre una tabla de Supabase.
 *
 * columns: [{ key, label, type: 'text'|'number'|'boolean'|'select'|'textarea',
 *             options?, default?, readOnly? }]
 * editOnly: true → solo edita filas existentes (sin crear ni borrar).
 */
export default function ConfigTable({
  table,
  title,
  description,
  columns,
  idKey,
  allowCreate = true,
  editOnly = false,
  showMeta = false,
}) {
  const [rows, setRows] = useState([]);
  const [loading, setLoading] = useState(true);
  const [editing, setEditing] = useState(null); // fila o { isNew: true }
  const [form, setForm] = useState({});
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState('');
  const [page, setPage] = useState(1);
  const pageSize = 10;

  useEffect(() => {
    setPage(1);
  }, [rows.length]);

  const pageRows = rows.slice((page - 1) * pageSize, page * pageSize);
  const totalPages = Math.max(1, Math.ceil(rows.length / pageSize));

  const load = async () => {
    setLoading(true);
    const { data, error: e } = await supabase.from(table).select('*').order(columns[0].key, { ascending: true });
    if (!e) setRows(data || []);
    setLoading(false);
  };

  useEffect(() => {
    load();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const openNew = () => {
    const f = {};
    columns.forEach((c) => {
      if (c.readOnly) return;
      f[c.key] = c.default ?? (c.type === 'boolean' ? false : c.type === 'number' ? 0 : '');
    });
    setForm(f);
    setEditing({ isNew: true });
  };

  const openEdit = (row) => {
    const f = {};
    columns.forEach((c) => {
      f[c.key] = row[c.key];
    });
    setForm(f);
    setEditing(row);
  };

  const save = async () => {
    if (busy) return;
    const payload = { ...form };
    columns.forEach((c) => {
      if (c.type === 'number') payload[c.key] = Number(payload[c.key]) || 0;
      if (c.type === 'boolean') payload[c.key] = !!payload[c.key];
    });
    if (!payload[idKey]) return;
    setBusy(true);
    setError('');
    const { error: e } = await supabase.from(table).upsert(payload);
    setBusy(false);
    if (e) {
      setError(e.message);
      return;
    }
    setEditing(null);
    await load();
  };

  const remove = async (id) => {
    const { error: e } = await supabase.from(table).delete().eq(idKey, id);
    if (e) setError(e.message);
    else await load();
  };

  const cellStyle = { padding: '10px 12px', borderBottom: '1px solid var(--border-glass)', fontSize: '13px' };

  return (
    <GlassCard padding="24px">
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', flexWrap: 'wrap', gap: '12px', marginBottom: '16px' }}>
        <div>
          <h3 style={{ fontSize: '18px', fontWeight: '800', color: '#fff' }}>{title}</h3>
          {description && <p style={{ color: 'var(--text-muted)', fontSize: '12px', marginTop: '4px' }}>{description}</p>}
        </div>
        <div style={{ display: 'flex', gap: '8px' }}>
          <button className="btn-secondary" onClick={load}>
            <RefreshCw style={{ width: '16px', height: '16px' }} />
          </button>
          {allowCreate && (
            <button className="btn-primary" onClick={openNew}>
              <Plus style={{ width: '16px', height: '16px' }} />
              <span>Nueva Fila</span>
            </button>
          )}
        </div>
      </div>

      {error && <div style={{ color: '#fca5a5', fontSize: '12px', marginBottom: '12px' }}>{error}</div>}

      <div style={{ overflowX: 'auto' }}>
        <table style={{ width: '100%', borderCollapse: 'collapse' }}>
          <thead>
            <tr>
              {columns.map((c) => (
                <th key={c.key} style={{ ...cellStyle, textAlign: 'left', fontWeight: '700', color: 'var(--secondary-teal)', textTransform: 'uppercase', fontSize: '11px', letterSpacing: '0.5px' }}>
                  {c.label}
                </th>
              ))}
              {showMeta && <th style={{ ...cellStyle, textAlign: 'left' }}>Editado</th>}
              {!editOnly && <th style={{ ...cellStyle, textAlign: 'right' }}>Acciones</th>}
            </tr>
          </thead>
          <tbody>
            {loading ? (
              <tr>
                <td colSpan={columns.length + (showMeta ? 1 : 0) + (editOnly ? 0 : 1)} style={{ ...cellStyle, textAlign: 'center', color: 'var(--text-muted)' }}>
                  Cargando...
                </td>
              </tr>
            ) : rows.length === 0 ? (
              <tr>
                <td colSpan={columns.length + (showMeta ? 1 : 0) + (editOnly ? 0 : 1)} style={{ ...cellStyle, textAlign: 'center', color: 'var(--text-muted)' }}>
                  Sin registros.
                </td>
              </tr>
            ) : (
              pageRows.map((r) => (
                <tr key={String(r[idKey])}>                  {columns.map((c) => (
                    <td key={c.key} style={cellStyle}>
                      {c.type === 'boolean'
                        ? (r[c.key] ? '✓' : '—')
                        : c.type === 'number'
                          ? String(r[c.key] ?? '')
                          : String(r[c.key] ?? '')}
                    </td>
                  ))}
                  {showMeta && (
                    <td style={{ ...cellStyle, fontFamily: 'var(--font-mono)', fontSize: '11px', color: 'var(--text-muted)' }}>
                      {r.updated_at ? new Date(r.updated_at).toLocaleString() : ''}
                      {r.updated_by ? ` · ${String(r.updated_by).slice(0, 8)}` : ''}
                    </td>
                  )}
                  {!editOnly && (
                    <td style={{ ...cellStyle, textAlign: 'right', whiteSpace: 'nowrap' }}>
                      <button className="btn-secondary" style={{ padding: '6px 10px' }} onClick={() => openEdit(r)}>
                        <Edit3 style={{ width: '14px', height: '14px' }} />
                      </button>
                      <button
                        className="btn-secondary"
                        style={{ padding: '6px 10px', marginLeft: '6px', color: '#fca5a5' }}
                        onClick={() => remove(r[idKey])}
                      >
                        <Trash2 style={{ width: '14px', height: '14px' }} />
                      </button>
                    </td>
                  )}
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>

      {/* Paginación */}
      {rows.length > pageSize && (
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginTop: '14px', gap: '12px', flexWrap: 'wrap' }}>
          <span style={{ fontSize: '12px', color: 'var(--text-muted)' }}>
            {rows.length} registros · Página {page} de {totalPages}
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

      {/* Modal edición */}
      {editing && (
        <div style={{ position: 'fixed', inset: 0, zIndex: 1000, background: 'rgba(6, 13, 32, 0.85)', backdropFilter: 'blur(16px)', display: 'flex', alignItems: 'center', justifyContent: 'center', padding: '24px' }}>
          <GlassCard style={{ width: '100%', maxWidth: '560px', padding: '28px', border: '1px solid var(--border-glass-glow)' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '18px' }}>
              <h3 style={{ fontSize: '18px', fontWeight: '800', color: '#fff' }}>
                {editing.isNew ? `Crear en ${table}` : `Editar ${table}`}
              </h3>
              <button className="btn-secondary" onClick={() => setEditing(null)}><X style={{ width: '16px', height: '16px' }} /></button>
            </div>
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '14px' }}>
              {columns.map((c) => (
                <div key={c.key} style={{ gridColumn: c.type === 'textarea' ? '1 / -1' : undefined }}>
                  <label className="form-label">{c.label}</label>
                  {c.type === 'select' ? (
                    <select
                      className="cyber-input"
                      style={{ appearance: 'auto' }}
                      disabled={c.readOnly}
                      value={form[c.key] ?? ''}
                      onChange={(e) => setForm({ ...form, [c.key]: e.target.value })}
                    >
                      {(c.options || []).map((o) => <option key={o} value={o}>{o}</option>)}
                    </select>
                  ) : c.type === 'boolean' ? (
                    <input
                      type="checkbox"
                      checked={!!form[c.key]}
                      disabled={c.readOnly}
                      onChange={(e) => setForm({ ...form, [c.key]: e.target.checked })}
                    />
                  ) : c.type === 'textarea' ? (
                    <textarea className="cyber-input" rows={3} style={{ resize: 'vertical' }} disabled={c.readOnly} value={form[c.key] ?? ''} onChange={(e) => setForm({ ...form, [c.key]: e.target.value })} />
                  ) : (
                    <input
                      className="cyber-input"
                      type={c.type === 'number' ? 'number' : 'text'}
                      disabled={c.readOnly}
                      value={form[c.key] ?? ''}
                      onChange={(e) => setForm({ ...form, [c.key]: e.target.value })}
                    />
                  )}
                </div>
              ))}
            </div>
            <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '12px', marginTop: '20px' }}>
              <button className="btn-secondary" onClick={() => setEditing(null)}>Cancelar</button>
              <button className="btn-primary" onClick={save} disabled={busy}>
                <Save style={{ width: '16px', height: '16px' }} />
                <span>{busy ? 'Guardando...' : 'Guardar'}</span>
              </button>
            </div>
          </GlassCard>
        </div>
      )}
    </GlassCard>
  );
}
