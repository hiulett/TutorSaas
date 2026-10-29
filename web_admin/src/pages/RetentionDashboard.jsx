import React from 'react';
import { Activity, Target, CalendarDays, Users } from 'lucide-react';

const pct = (part, total) => (total > 0 ? Math.round((part / total) * 100) : 0);

function Section({ title, icon: Icon, subtitle, children }) {
  return (
    <div className="glass-panel" style={{ padding: '20px', marginBottom: '20px' }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '4px' }}>
        <Icon style={{ width: '18px', height: '18px', color: 'var(--primary-purple)' }} />
        <h3 style={{ margin: 0, fontSize: '15px', fontWeight: '700', color: '#fff' }}>{title}</h3>
      </div>
      {subtitle && (
        <p style={{ margin: '0 0 14px', fontSize: '12px', color: 'var(--text-muted)' }}>{subtitle}</p>
      )}
      {children}
    </div>
  );
}

function Empty({ children }) {
  return <div style={{ fontSize: '12px', color: 'var(--text-muted)', padding: '8px 0' }}>{children}</div>;
}

const th = { textAlign: 'left', fontSize: '11px', color: 'var(--text-muted)', padding: '6px 8px', fontWeight: '600' };
const td = { fontSize: '12px', padding: '6px 8px', color: '#e2e8f0' };

export default function RetentionDashboard({ metrics }) {
  const m = metrics || { funnel: [], activation: [], retention: [], sessions: [] };
  const funnelTop = m.funnel.length > 0 ? Number(m.funnel[0].users) || 0 : 0;

  return (
    <div>
      <h2 style={{ fontSize: '20px', fontWeight: '800', color: '#fff', margin: '0 0 4px' }}>
        Retención y embudo
      </h2>
      <p style={{ fontSize: '13px', color: 'var(--text-muted)', margin: '0 0 20px' }}>
        Agregados de <code>analytics_events</code> (sin PII ni texto de conversación).
      </p>

      <Section
        title="Embudo de onboarding"
        icon={Target}
        subtitle="Usuarios distintos que llegan a cada paso. Los pasos salen de onboarding_step."
      >
        {m.funnel.length === 0 ? (
          <Empty>Sin eventos de onboarding todavía.</Empty>
        ) : (
          <table style={{ width: '100%', borderCollapse: 'collapse' }}>
            <thead>
              <tr><th style={th}>Etapa</th><th style={th}>Usuarios</th><th style={th}>% del inicio</th></tr>
            </thead>
            <tbody>
              {m.funnel.map((row) => (
                <tr key={`${row.ord}-${row.stage}`}>
                  <td style={td}>{row.stage}</td>
                  <td style={td}>{row.users}</td>
                  <td style={td}>{pct(Number(row.users) || 0, funnelTop)}%</td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </Section>

      <Section
        title="Activación (primera sesión < 24 h)"
        icon={Activity}
        subtitle="Por semana de registro: usuarios, con alguna sesión y activados en 24 h."
      >
        {m.activation.length === 0 ? (
          <Empty>Sin datos de activación.</Empty>
        ) : (
          <table style={{ width: '100%', borderCollapse: 'collapse' }}>
            <thead>
              <tr><th style={th}>Semana</th><th style={th}>Usuarios</th><th style={th}>Con sesión</th><th style={th}>Activos 24 h</th></tr>
            </thead>
            <tbody>
              {m.activation.map((row) => (
                <tr key={row.signup_week}>
                  <td style={td}>{row.signup_week}</td>
                  <td style={td}>{row.users}</td>
                  <td style={td}>{row.with_session}</td>
                  <td style={td}>{row.activated_24h} ({pct(Number(row.activated_24h) || 0, Number(row.users) || 0)}%)</td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </Section>

      <Section
        title="Retención D1 / D7 / D30"
        icon={CalendarDays}
        subtitle="Usuarios con actividad en el día 1, 7 o 30 desde su registro."
      >
        {m.retention.length === 0 ? (
          <Empty>Sin datos de retención.</Empty>
        ) : (
          <table style={{ width: '100%', borderCollapse: 'collapse' }}>
            <thead>
              <tr><th style={th}>Cohorte</th><th style={th}>Día</th><th style={th}>Usuarios</th></tr>
            </thead>
            <tbody>
              {m.retention.map((row) => (
                <tr key={`${row.cohort}-${row.day_offset}`}>
                  <td style={td}>{row.cohort}</td>
                  <td style={td}>D{row.day_offset}</td>
                  <td style={td}>{row.users}</td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </Section>

      <Section
        title="Sesiones por usuario y semana"
        icon={Users}
        subtitle="Sesiones iniciadas (session_start) por semana."
      >
        {m.sessions.length === 0 ? (
          <Empty>Sin sesiones registradas.</Empty>
        ) : (
          <table style={{ width: '100%', borderCollapse: 'collapse' }}>
            <thead>
              <tr><th style={th}>Semana</th><th style={th}>Sesiones</th><th style={th}>Usuarios</th><th style={th}>Sesiones/usuario</th></tr>
            </thead>
            <tbody>
              {m.sessions.map((row) => (
                <tr key={row.week}>
                  <td style={td}>{row.week}</td>
                  <td style={td}>{row.sessions}</td>
                  <td style={td}>{row.users}</td>
                  <td style={td}>{row.sessions_per_user ?? '—'}</td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </Section>
    </div>
  );
}
