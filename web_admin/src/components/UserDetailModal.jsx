import React from 'react';
import GlassCard from '../components/GlassCard';
import { User, Fingerprint, Award, Flame, Clock, Zap, ShieldCheck, Sparkles, CheckCircle2, TrendingUp, AlertTriangle, ArrowUpRight, X } from 'lucide-react';

export default function UserDetailModal({ user, onClose, onUpgradeOffer }) {
  if (!user) return null;

  const limitMin = user.audioLimitMinutes;
  const usedMin = user.practiceMinutes;
  const usagePercent = limitMin && usedMin != null ? Math.min(100, Math.round((usedMin / limitMin) * 100)) : null;

  return (
    <div style={{
      position: 'fixed',
      inset: 0,
      zIndex: 1000,
      background: 'rgba(6, 13, 32, 0.88)',
      backdropFilter: 'blur(16px)',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      padding: '24px',
    }}>
      <GlassCard style={{ width: '100%', maxWidth: '750px', padding: '32px', border: '1px solid var(--border-glass-glow)', maxHeight: '90vh', overflowY: 'auto' }}>
        {/* Modal Header */}
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px', borderBottom: '1px solid var(--border-glass)', paddingBottom: '16px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
            <img src={user.avatarUrl} alt={user.name} style={{ width: '54px', height: '54px', borderRadius: '50%', border: '2px solid var(--primary-purple)' }} />
            <div>
              <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                <h2 style={{ fontSize: '22px', fontWeight: '800', color: '#fff' }}>{user.name}</h2>
                <span className={`badge-level badge-${user.level.toLowerCase()}`}>{user.level}</span>
              </div>
              <div style={{ fontSize: '13px', color: 'var(--text-muted)', fontFamily: 'var(--font-mono)', marginTop: '2px' }}>
                UUID: {user.id}
              </div>
            </div>
          </div>
          <button className="btn-secondary" onClick={onClose}><X style={{ width: '18px', height: '18px' }} /></button>
        </div>

        {/* Section 1: Membership Plan & AI Audio Usage Meter */}
        <div style={{ marginBottom: '24px' }}>
          <h3 style={{ fontSize: '15px', fontWeight: '700', color: '#fff', marginBottom: '12px', display: 'flex', alignItems: 'center', gap: '8px' }}>
            <Clock style={{ color: 'var(--secondary-teal)', width: '18px', height: '18px' }} />
            <span>Membresía Contratada & Consumo de Audio IA</span>
          </h3>

          <div style={{ background: 'rgba(255,255,255,0.03)', border: '1px solid var(--border-glass)', borderRadius: '16px', padding: '20px' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: '12px', marginBottom: '16px' }}>
              <div>
                <span style={{ fontSize: '12px', color: 'var(--text-muted)', textTransform: 'uppercase', letterSpacing: '0.5px' }}>Plan Actual</span>
                <div style={{ fontSize: '20px', fontWeight: '800', color: 'var(--primary-purple)', marginTop: '2px' }}>{user.plan}</div>
              </div>
              <div style={{ textAlign: 'right' }}>
                <span style={{ fontSize: '12px', color: 'var(--text-muted)', textTransform: 'uppercase', letterSpacing: '0.5px' }}>Límite de Tiempo IA</span>
                <div style={{ fontSize: '18px', fontWeight: '800', color: '#fff', fontFamily: 'var(--font-mono)' }}>{user.audioLimitMinutes ?? '—'} min/mes</div>
              </div>
            </div>

            {/* Progress Meter */}
            <div style={{ marginBottom: '12px' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '12px', marginBottom: '6px' }}>
                <span style={{ color: 'var(--text-muted)' }}>Tiempo Consumido: <strong style={{ color: '#fff' }}>{user.practiceMinutes ?? '—'} min</strong></span>
                <span style={{ color: usagePercent != null && usagePercent > 85 ? '#f97316' : 'var(--secondary-teal)', fontWeight: '700' }}>
                  {usagePercent != null ? `${usagePercent}% consumido (${user.remainingMinutes ?? '—'} min restantes)` : 'Sin límite configurado'}
                </span>
              </div>
              <div style={{ width: '100%', height: '10px', background: 'rgba(255,255,255,0.08)', borderRadius: '5px', overflow: 'hidden' }}>
                <div style={{
                  width: `${usagePercent ?? 0}%`,
                  height: '100%',
                  background: usagePercent != null && usagePercent > 85 ? 'linear-gradient(90deg, #f97316, #ef4444)' : 'linear-gradient(90deg, #a855f7, #38bdf8)',
                  borderRadius: '5px',
                  transition: 'width 0.5s ease',
                }} />
              </div>
            </div>

            {usagePercent != null && usagePercent > 70 && (
              <div style={{ display: 'flex', alignItems: 'center', gap: '10px', background: 'rgba(249, 115, 22, 0.12)', border: '1px solid rgba(249, 115, 22, 0.3)', padding: '10px 14px', borderRadius: '10px', color: '#f97316', fontSize: '13px' }}>
                <AlertTriangle style={{ width: '18px', height: '18px', shrink: 0 }} />
                <span>Candidato para Upgrade: Ha consumido el {usagePercent}% de su tiempo de voz contratado.</span>
              </div>
            )}
          </div>
        </div>

        {/* Section 2: Speech DNA & Learning Progress Grid */}
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px', marginBottom: '24px' }}>
          {/* Speech DNA */}
          <div style={{ background: 'rgba(255,255,255,0.03)', border: '1px solid var(--border-glass)', borderRadius: '16px', padding: '20px' }}>
            <h4 style={{ fontSize: '14px', fontWeight: '700', color: '#fff', marginBottom: '12px', display: 'flex', alignItems: 'center', gap: '8px' }}>
              <Fingerprint style={{ color: 'var(--secondary-teal)', width: '16px', height: '16px' }} />
              <span>Biometría Fonética (Speech DNA)</span>
            </h4>
            <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '12px' }}>
              <div>
                <div style={{ fontSize: '11px', color: 'var(--text-muted)' }}>Claridad Fonética</div>
                <div style={{ fontSize: '22px', fontWeight: '800', color: 'var(--secondary-teal)' }}>{user.clarityScore ?? '—'}%</div>
              </div>
              <div style={{ textAlign: 'right' }}>
                <div style={{ fontSize: '11px', color: 'var(--text-muted)' }}>Velocidad WPM</div>
                <div style={{ fontSize: '22px', fontWeight: '800', color: 'var(--primary-purple)' }}>{user.wpm ?? '—'} WPM</div>
              </div>
            </div>
            <div>
              <div style={{ fontSize: '11px', color: 'var(--text-muted)', marginBottom: '6px' }}>Fonemas a Reforzar</div>
              <div style={{ display: 'flex', gap: '6px', flexWrap: 'wrap' }}>
                {(user.problemPhonemes || []).length > 0
                  ? user.problemPhonemes.map((ph, i) => (
                      <span key={i} style={{ padding: '3px 8px', background: 'rgba(249, 115, 22, 0.15)', border: '1px solid #f97316', borderRadius: '6px', color: '#f97316', fontFamily: 'var(--font-mono)', fontSize: '11px', fontWeight: '700' }}>
                        {ph}
                      </span>
                    ))
                  : <span style={{ color: 'var(--text-muted)', fontSize: '12px' }}>Sin datos</span>}
              </div>
            </div>
          </div>

          {/* Gamification Progress */}
          <div style={{ background: 'rgba(255,255,255,0.03)', border: '1px solid var(--border-glass)', borderRadius: '16px', padding: '20px' }}>
            <h4 style={{ fontSize: '14px', fontWeight: '700', color: '#fff', marginBottom: '12px', display: 'flex', alignItems: 'center', gap: '8px' }}>
              <Award style={{ color: 'var(--primary-purple)', width: '16px', height: '16px' }} />
              <span>Progreso de Gamificación</span>
            </h4>
            <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '12px' }}>
              <div>
                <div style={{ fontSize: '11px', color: 'var(--text-muted)' }}>Puntos XP Totales</div>
                <div style={{ fontSize: '22px', fontWeight: '800', color: 'var(--primary-purple)' }}>{user.xp} XP</div>
              </div>
              <div style={{ textAlign: 'right' }}>
                <div style={{ fontSize: '11px', color: 'var(--text-muted)' }}>Racha Consecutiva</div>
                <div style={{ fontSize: '22px', fontWeight: '800', color: '#f97316' }}>{user.streak} días</div>
              </div>
            </div>
            <div style={{ fontSize: '12px', color: 'var(--text-muted)' }}>
              Nivel CEFR objetivo: <strong style={{ color: '#fff' }}>{user.level}</strong>
            </div>
          </div>
        </div>

        {/* Modal Actions */}
        <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '12px', borderTop: '1px solid var(--border-glass)', paddingTop: '20px' }}>
          <button className="btn-secondary" onClick={onClose}>Cerrar</button>
          <button className="btn-primary" onClick={() => onUpgradeOffer && onUpgradeOffer(user)}>
            <Sparkles style={{ width: '16px', height: '16px' }} />
            <span>Ofrecer Upgrade de Membresía</span>
          </button>
        </div>
      </GlassCard>
    </div>
  );
}
