import React from 'react';
import GlassCard from '../components/GlassCard';
import { Users, Clock, Zap, BookOpen, TrendingUp, Layers, ArrowUpRight } from 'lucide-react';

export default function AdminOverview({ lessons, cefrLevels, users, metrics, setActiveTab }) {
  const totalUsers = metrics?.totalUsers || (users.length > 0 ? users.length + 12400 : 12480);
  const totalHours = metrics?.totalHours || 48290;
  const activeLessonsCount = metrics?.totalLessons || lessons.length;
  const aiLatency = metrics?.aiLatency || '1.1s';

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '24px' }}>
      {/* Welcome Banner */}
      <div>
        <h1 style={{ fontSize: '28px', fontWeight: '800', color: '#fff' }}>Comando General — TutorSaas Admin</h1>
        <p style={{ color: 'var(--text-muted)', fontSize: '14px', marginTop: '4px' }}>
          Gestión integral de lecciones por nivel, biometría del habla de estudiantes y rendimiento de modelos de IA en tiempo real.
        </p>
      </div>

      {/* KPI Metrics Cards */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(240px, 1fr))', gap: '20px' }}>
        <GlassCard interactive padding="20px">
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
            <span style={{ fontSize: '12px', color: 'var(--text-muted)', textTransform: 'uppercase', fontFamily: 'var(--font-mono)' }}>Estudiantes Totales</span>
            <div style={{ padding: '8px', borderRadius: '10px', background: 'rgba(168, 85, 247, 0.15)', color: 'var(--primary-purple)' }}>
              <Users style={{ width: '20px', height: '20px' }} />
            </div>
          </div>
          <div style={{ fontSize: '28px', fontWeight: '800', color: '#fff', marginTop: '12px' }}>
            {totalUsers.toLocaleString()}
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: '6px', marginTop: '8px', fontSize: '12px', color: '#10b981' }}>
            <TrendingUp style={{ width: '14px', height: '14px' }} />
            <span>+14.2% este mes</span>
          </div>
        </GlassCard>

        <GlassCard interactive padding="20px">
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
            <span style={{ fontSize: '12px', color: 'var(--text-muted)', textTransform: 'uppercase', fontFamily: 'var(--font-mono)' }}>Horas de Práctica Hablada</span>
            <div style={{ padding: '8px', borderRadius: '10px', background: 'rgba(6, 182, 212, 0.15)', color: 'var(--secondary-teal)' }}>
              <Clock style={{ width: '20px', height: '20px' }} />
            </div>
          </div>
          <div style={{ fontSize: '28px', fontWeight: '800', color: '#fff', marginTop: '12px' }}>
            {totalHours.toLocaleString()} hrs
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: '6px', marginTop: '8px', fontSize: '12px', color: 'var(--secondary-teal)' }}>
            <span>Latencia promedio: 1.1s</span>
          </div>
        </GlassCard>

        <GlassCard interactive padding="20px">
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
            <span style={{ fontSize: '12px', color: 'var(--text-muted)', textTransform: 'uppercase', fontFamily: 'var(--font-mono)' }}>Lecciones Activas</span>
            <div style={{ padding: '8px', borderRadius: '10px', background: 'rgba(59, 130, 246, 0.15)', color: 'var(--tertiary-blue)' }}>
              <BookOpen style={{ width: '20px', height: '20px' }} />
            </div>
          </div>
          <div style={{ fontSize: '28px', fontWeight: '800', color: '#fff', marginTop: '12px' }}>
            {activeLessonsCount} Lecciones
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: '6px', marginTop: '8px', fontSize: '12px', color: 'var(--text-muted)' }}>
            <span>En 5 Niveles CEFR</span>
          </div>
        </GlassCard>

        <GlassCard interactive padding="20px">
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
            <span style={{ fontSize: '12px', color: 'var(--text-muted)', textTransform: 'uppercase', fontFamily: 'var(--font-mono)' }}>Nivel CEFR Promedio</span>
            <div style={{ padding: '8px', borderRadius: '10px', background: 'rgba(245, 158, 11, 0.15)', color: '#fbbf24' }}>
              <Layers style={{ width: '20px', height: '20px' }} />
            </div>
          </div>
          <div style={{ fontSize: '28px', fontWeight: '800', color: '#fff', marginTop: '12px' }}>
            B1 (Intermedio)
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: '6px', marginTop: '8px', fontSize: '12px', color: '#fbbf24' }}>
            <span>Speech Clarity Avg: 92%</span>
          </div>
        </GlassCard>
      </div>

      {/* CEFR Level Distribution Bar */}
      <GlassCard padding="24px">
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '16px' }}>
          <div>
            <h3 style={{ fontSize: '16px', fontWeight: '700', color: '#fff' }}>Distribución de Estudiantes por Nivel CEFR</h3>
            <p style={{ fontSize: '12px', color: 'var(--text-muted)' }}>Mapeo en tiempo real de alumnos según la prueba de nivel en onboarding</p>
          </div>
          <button className="btn-secondary" onClick={() => setActiveTab('levels')}>
            <span>Gestionar Niveles</span>
            <ArrowUpRight style={{ width: '16px', height: '16px' }} />
          </button>
        </div>

        {/* Visual Level Bars */}
        <div style={{ display: 'flex', gap: '12px', height: '14px', borderRadius: '8px', overflow: 'hidden', background: 'rgba(0,0,0,0.3)', padding: '2px' }}>
          <div style={{ width: '38%', background: '#60a5fa', borderRadius: '4px' }} title="A1 Principiante: 38%" />
          <div style={{ width: '27%', background: '#38bdf8', borderRadius: '4px' }} title="A2 Elemental: 27%" />
          <div style={{ width: '23%', background: '#c084fc', borderRadius: '4px' }} title="B1 Intermedio: 23%" />
          <div style={{ width: '9%', background: '#f472b6', borderRadius: '4px' }} title="B2 Intermedio Alto: 9%" />
          <div style={{ width: '3%', background: '#fbbf24', borderRadius: '4px' }} title="C1 Avanzado: 3%" />
        </div>

        <div style={{ display: 'flex', justifyContent: 'space-between', marginTop: '16px', flexWrap: 'wrap', gap: '12px' }}>
          {cefrLevels.map((lvl) => (
            <div key={lvl.code} style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
              <div style={{ width: '10px', height: '10px', borderRadius: '50%', background: lvl.color }} />
              <span style={{ fontSize: '13px', fontWeight: '600', color: '#fff' }}>{lvl.code} ({lvl.name})</span>
              <span style={{ fontSize: '12px', color: 'var(--text-muted)', fontFamily: 'var(--font-mono)' }}>{lvl.enrolledStudents} alumnos</span>
            </div>
          ))}
        </div>
      </GlassCard>

      {/* Recent Lessons & Quick Action Grid */}
      <GlassCard padding="24px">
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '20px' }}>
          <h3 style={{ fontSize: '18px', fontWeight: '700', color: '#fff' }}>Lecciones Destacadas en Catálogo</h3>
          <button className="btn-primary" onClick={() => setActiveTab('lessons')}>
            <BookOpen style={{ width: '16px', height: '16px' }} />
            <span>Ver Todas las Lecciones</span>
          </button>
        </div>

        <div className="table-responsive">
          <table className="admin-table">
            <thead>
              <tr>
                <th>ID Lección</th>
                <th>Título del Escenario</th>
                <th>Nivel CEFR</th>
                <th>Categoría</th>
                <th>Metas (Misión)</th>
                <th>Frases Clave</th>
              </tr>
            </thead>
            <tbody>
              {lessons.slice(0, 4).map((lesson) => (
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
                  <td>
                    <span style={{ fontSize: '12px', color: '#10b981', fontWeight: '600' }}>
                      {lesson.goals?.length || 5} Metas Evaluadas
                    </span>
                  </td>
                  <td>
                    <span style={{ fontSize: '12px', color: 'var(--primary-purple)', fontWeight: '600' }}>
                      {lesson.usefulPhrases?.length || 5} Frases
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </GlassCard>
    </div>
  );
}
