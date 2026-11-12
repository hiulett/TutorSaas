import React from 'react';
import GlassCard from '../components/GlassCard';
import { Users, Clock, BookOpen, MessageSquare, Wifi, ArrowUpRight } from 'lucide-react';

const SECTION_LABELS = {
  welcome: 'Bienvenida',
  splash: 'Splash',
  onboarding: 'Onboarding',
  oracle: 'Oráculo',
  dashboard: 'Comando / Dashboard',
  voice_room: 'Sala de Voz',
  conversation: 'Conversación',
  summary: 'Resumen de Sesión',
  paywall: 'Paywall',
  settings: 'Ajustes',
  profile_edit: 'Perfil',
  guild_hall: 'Salón del Gremio',
  shop: 'Tienda',
  inventory: 'Inventario',
  dungeon_guardian: 'Guardián de Mazmorra',
  disruption: 'Disrupción',
  background: 'En segundo plano',
  app: 'App (otra sección)',
};

export default function AdminOverview({ lessons, cefrDistribution, metrics, onlineUsers, setActiveTab }) {
  const m = metrics || {};
  const ou = onlineUsers || { online: 0, bySection: [] };
  const totalUsers = m.totalUsers ?? 0;
  const totalHours = m.totalHours ?? 0;
  const totalLessons = m.totalLessons ?? 0;
  const totalConversations = m.totalConversations ?? 0;
  const dist = cefrDistribution || [];

  const fmt = (n) => (n > 0 ? n.toLocaleString() : '—');

  const kpis = [
    { label: 'Estudiantes Totales', icon: Users, color: 'var(--primary-purple)', bg: 'rgba(168, 85, 247, 0.15)', value: fmt(totalUsers), hint: 'Perfiles de idioma en Supabase' },
    { label: 'Horas de Práctica', icon: Clock, color: 'var(--secondary-teal)', bg: 'rgba(6, 182, 212, 0.15)', value: totalHours > 0 ? `${totalHours.toLocaleString()} hrs` : '—', hint: 'Estimadas (~15 min por conversación)' },
    { label: 'Conversaciones', icon: MessageSquare, color: '#60a5fa', bg: 'rgba(59, 130, 246, 0.15)', value: fmt(totalConversations), hint: 'Sesiones registradas' },
    { label: 'Lecciones Activas', icon: BookOpen, color: '#fbbf24', bg: 'rgba(245, 158, 11, 0.15)', value: totalLessons > 0 ? String(totalLessons) : '—', hint: 'Escenarios en la tabla scenarios' },
    { label: 'Usuarios Online', icon: Wifi, color: '#34d399', bg: 'rgba(52, 211, 153, 0.15)', value: ou.online > 0 ? String(ou.online) : '—', hint: 'Presencia en vivo (últimos 3 min)' },
  ];

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '24px' }}>
      <div>
        <h1 style={{ fontSize: '28px', fontWeight: '800', color: '#fff' }}>Comando General — TutorSaas Admin</h1>
        <p style={{ color: 'var(--text-muted)', fontSize: '14px', marginTop: '4px' }}>
          Métricas reales desde Supabase. Gestión de lecciones, economía y configuración del juego.
        </p>
      </div>

      {/* KPI Metrics Cards (datos reales) */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(240px, 1fr))', gap: '20px' }}>
        {kpis.map((k) => {
          const Icon = k.icon;
          return (
            <GlassCard interactive key={k.label} padding="20px">
              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                <span style={{ fontSize: '12px', color: 'var(--text-muted)', textTransform: 'uppercase', fontFamily: 'var(--font-mono)' }}>{k.label}</span>
                <div style={{ padding: '8px', borderRadius: '10px', background: k.bg, color: k.color }}>
                  <Icon style={{ width: '20px', height: '20px' }} />
                </div>
              </div>
              <div style={{ fontSize: '28px', fontWeight: '800', color: '#fff', marginTop: '12px' }}>{k.value}</div>
              <div style={{ marginTop: '8px', fontSize: '12px', color: 'var(--text-muted)' }}>{k.hint}</div>
            </GlassCard>
          );
        })}
      </div>

      {/* Live Presence by Section (real-time) */}
      <GlassCard padding="24px">
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '16px' }}>
          <div>
            <h3 style={{ fontSize: '16px', fontWeight: '700', color: '#fff' }}>Usuarios Online por Sección</h3>
            <p style={{ fontSize: '12px', color: 'var(--text-muted)' }}>Dónde están ahora mismo los cazadores conectados (refresco cada 30s)</p>
          </div>
          {ou.online > 0 && (
            <span style={{ display: 'inline-flex', alignItems: 'center', gap: '6px', padding: '6px 12px', borderRadius: '999px', background: 'rgba(52, 211, 153, 0.12)', border: '1px solid rgba(52, 211, 153, 0.35)', color: '#34d399', fontSize: '13px', fontWeight: '700' }}>
              <span style={{ width: '8px', height: '8px', borderRadius: '50%', background: '#34d399' }} />
              {ou.online} online
            </span>
          )}
        </div>

        {ou.bySection.length === 0 ? (
          <div style={{ padding: '24px', textAlign: 'center', color: 'var(--text-muted)', fontSize: '13px', border: '1px dashed var(--border-glass)', borderRadius: '12px' }}>
            Nadie en línea ahora mismo. Los usuarios reportan presencia solo con la app abierta.
          </div>
        ) : (
          <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
            {ou.bySection.map((item) => {
              const pct = ou.online > 0 ? Math.round((item.count / ou.online) * 100) : 0;
              return (
                <div key={item.section}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '4px' }}>
                    <span style={{ fontSize: '13px', fontWeight: '600', color: '#fff' }}>{SECTION_LABELS[item.section] || item.section}</span>
                    <span style={{ fontSize: '12px', color: 'var(--text-muted)', fontFamily: 'var(--font-mono)' }}>{item.count} · {pct}%</span>
                  </div>
                  <div style={{ height: '8px', borderRadius: '4px', background: 'rgba(0,0,0,0.3)', overflow: 'hidden' }}>
                    <div style={{ width: `${Math.max(pct, 2)}%`, height: '100%', background: 'linear-gradient(90deg, #34d399, #00e5ff)', borderRadius: '4px' }} />
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </GlassCard>

      {/* CEFR Level Distribution (real counts) */}
      <GlassCard padding="24px">
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '16px' }}>
          <div>
            <h3 style={{ fontSize: '16px', fontWeight: '700', color: '#fff' }}>Distribución de Estudiantes por Nivel CEFR</h3>
            <p style={{ fontSize: '12px', color: 'var(--text-muted)' }}>Conteo real de perfiles según su nivel asignado</p>
          </div>
          <button className="btn-secondary" onClick={() => setActiveTab('cefr')}>
            <span>Gestionar Niveles</span>
            <ArrowUpRight style={{ width: '16px', height: '16px' }} />
          </button>
        </div>

        {dist.length === 0 ? (
          <div style={{ padding: '24px', textAlign: 'center', color: 'var(--text-muted)', fontSize: '13px', border: '1px dashed var(--border-glass)', borderRadius: '12px' }}>
            Sin datos de distribución todavía (los perfiles aún no tienen nivel CEFR asignado).
          </div>
        ) : (
          <>
            <div style={{ display: 'flex', gap: '12px', height: '14px', borderRadius: '8px', overflow: 'hidden', background: 'rgba(0,0,0,0.3)', padding: '2px' }}>
              {dist.map((lvl) => (
                <div key={lvl.code} style={{ width: `${Math.max(lvl.pct, 2)}%`, background: lvl.color, borderRadius: '4px' }} title={`${lvl.code}: ${lvl.pct}%`} />
              ))}
            </div>
            <div style={{ display: 'flex', justifyContent: 'space-between', marginTop: '16px', flexWrap: 'wrap', gap: '12px' }}>
              {dist.map((lvl) => (
                <div key={lvl.code} style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                  <div style={{ width: '10px', height: '10px', borderRadius: '50%', background: lvl.color }} />
                  <span style={{ fontSize: '13px', fontWeight: '600', color: '#fff' }}>{lvl.code} ({lvl.name})</span>
                  <span style={{ fontSize: '12px', color: 'var(--text-muted)', fontFamily: 'var(--font-mono)' }}>{lvl.count} alumnos · {lvl.pct}%</span>
                </div>
              ))}
            </div>
          </>
        )}
      </GlassCard>

      {/* Recent Lessons (real scenarios table) */}
      <GlassCard padding="24px">
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '20px' }}>
          <h3 style={{ fontSize: '18px', fontWeight: '700', color: '#fff' }}>Escenarios en Supabase</h3>
          <button className="btn-primary" onClick={() => setActiveTab('lessons')}>
            <BookOpen style={{ width: '16px', height: '16px' }} />
            <span>Ver Todas las Lecciones</span>
          </button>
        </div>

        {lessons.length === 0 ? (
          <div style={{ padding: '24px', textAlign: 'center', color: 'var(--text-muted)', fontSize: '13px', border: '1px dashed var(--border-glass)', borderRadius: '12px' }}>
            No hay escenarios en la tabla <code style={{ color: 'var(--secondary-teal)' }}>scenarios</code> todavía.
          </div>
        ) : (
          <div className="table-responsive">
            <table className="admin-table">
              <thead>
                <tr>
                  <th>ID Lección</th>
                  <th>Título del Escenario</th>
                  <th>Nivel CEFR</th>
                  <th>Categoría</th>
                  <th>Metas</th>
                  <th>Frases Clave</th>
                </tr>
              </thead>
              <tbody>
                {lessons.slice(0, 4).map((lesson) => (
                  <tr key={lesson.id}>
                    <td style={{ fontFamily: 'var(--font-mono)', color: 'var(--secondary-teal)', fontSize: '13px' }}>{lesson.id}</td>
                    <td style={{ fontWeight: '600', color: '#fff' }}>{lesson.title}</td>
                    <td>
                      <span className={`badge-level badge-${String(lesson.level).toLowerCase()}`}>{lesson.level}</span>
                    </td>
                    <td style={{ textTransform: 'capitalize', color: 'var(--text-muted)' }}>{lesson.category}</td>
                    <td>
                      <span style={{ fontSize: '12px', color: '#10b981', fontWeight: '600' }}>{lesson.goals?.length || 0} Metas</span>
                    </td>
                    <td>
                      <span style={{ fontSize: '12px', color: 'var(--primary-purple)', fontWeight: '600' }}>{lesson.usefulPhrases?.length || 0} Frases</span>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </GlassCard>
    </div>
  );
}
