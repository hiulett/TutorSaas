import React, { useState } from 'react';
import GlassCard from '../components/GlassCard';
import { Sliders, Cpu, Mic, Shield, Save, Check } from 'lucide-react';

export default function AiSettings({ settings, onSave }) {
  const [sttModel, setSttModel] = useState(settings?.sttModel || 'whisper-large-v3-turbo');
  const [llmModel, setLlmModel] = useState(settings?.llmModel || 'deepseek-chat');
  const [temperature, setTemperature] = useState(settings?.temperature || 0.7);
  const [correctionLevel, setCorrectionLevel] = useState(settings?.correctionLevel || 'moderate');
  const [saved, setSaved] = useState(false);

  const handleSave = (e) => {
    e.preventDefault();
    if (onSave) {
      onSave({ sttModel, llmModel, temperature, correctionLevel });
    }
    setSaved(true);
    setTimeout(() => setSaved(false), 3000);
  };

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '24px', maxWidth: '900px' }}>
      {/* Header */}
      <div>
        <h1 style={{ fontSize: '26px', fontWeight: '800', color: '#fff' }}>Ajustes de IA y Motores Conversacionales</h1>
        <p style={{ color: 'var(--text-muted)', fontSize: '14px', marginTop: '4px' }}>
          Configura los parámetros de inferencia de voz STT en Groq Cloud, el modelo LLM en DeepSeek y los niveles globales de corrección gramatical.
        </p>
      </div>

      <div style={{ padding: '12px 16px', borderRadius: '10px', background: 'rgba(245, 158, 11, 0.1)', border: '1px solid rgba(245, 158, 11, 0.3)', color: '#fbbf24', fontSize: '13px' }}>
        ⚠️ Estos valores se guardan en <code style={{ color: '#fff' }}>system_ai_settings</code>, pero el runtime
        (<code style={{ color: '#fff' }}>llm-proxy</code>) usa variables de entorno (<code style={{ color: '#fff' }}>DEEPSEEK_API_KEY</code>/<code style={{ color: '#fff' }}>GROQ_API_KEY</code>).
        Cambiarlos aquí todavía <strong>no afecta a la app</strong>.
      </div>

      <form onSubmit={handleSave} style={{ display: 'flex', flexDirection: 'column', gap: '24px' }}>
        {/* STT Config */}
        <GlassCard padding="24px">
          <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '16px' }}>
            <Mic style={{ color: 'var(--secondary-teal)', width: '22px', height: '22px' }} />
            <h3 style={{ fontSize: '18px', fontWeight: '700', color: '#fff' }}>Reconocimiento del Habla (STT - Groq Cloud)</h3>
          </div>

          <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
            <div>
              <label style={{ fontSize: '12px', color: 'var(--text-muted)', display: 'block', marginBottom: '6px' }}>Modelo STT Activo</label>
              <select value={sttModel} onChange={(e) => setSttModel(e.target.value)} className="cyber-select">
                <option value="whisper-large-v3-turbo">Groq Whisper Large V3 Turbo (Latencia ~350ms - Recomendado)</option>
                <option value="whisper-large-v3">Groq Whisper Large V3 (Máxima precisión fonética)</option>
              </select>
            </div>
            <p style={{ fontSize: '12px', color: 'var(--text-muted)' }}>
              El idioma está fijado automáticamente en <code style={{ color: 'var(--secondary-teal)', fontFamily: 'var(--font-mono)' }}>language: 'en'</code> para evitar traducciones indeseadas y optimizar latencia.
            </p>
          </div>
        </GlassCard>

        {/* LLM Config */}
        <GlassCard padding="24px">
          <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '16px' }}>
            <Cpu style={{ color: 'var(--primary-purple)', width: '22px', height: '22px' }} />
            <h3 style={{ fontSize: '18px', fontWeight: '700', color: '#fff' }}>Modelo de Tutor IA (LLM - DeepSeek)</h3>
          </div>

          <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
            <div>
              <label style={{ fontSize: '12px', color: 'var(--text-muted)', display: 'block', marginBottom: '6px' }}>Modelo LLM Activo</label>
              <select value={llmModel} onChange={(e) => setLlmModel(e.target.value)} className="cyber-select">
                <option value="deepseek-chat">DeepSeek Chat Completions (SSE Stream - TTFT ~250ms)</option>
                <option value="deepseek-reasoner">DeepSeek Reasoner (Pensamiento profundo y análisis gramatical)</option>
              </select>
            </div>

            <div>
              <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '6px' }}>
                <label style={{ fontSize: '12px', color: 'var(--text-muted)' }}>Creatividad & Temperatura</label>
                <span style={{ fontSize: '12px', color: 'var(--primary-purple)', fontFamily: 'var(--font-mono)', fontWeight: '700' }}>{temperature}</span>
              </div>
              <input
                type="range"
                min="0.1"
                max="1.2"
                step="0.1"
                value={temperature}
                onChange={(e) => setTemperature(parseFloat(e.target.value))}
                style={{ width: '100%', accentColor: 'var(--primary-purple)', cursor: 'pointer' }}
              />
            </div>
          </div>
        </GlassCard>

        {/* Pedagogical Correction Level */}
        <GlassCard padding="24px">
          <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '16px' }}>
            <Shield style={{ color: '#10b981', width: '22px', height: '22px' }} />
            <h3 style={{ fontSize: '18px', fontWeight: '700', color: '#fff' }}>Estilo de Corrección Pedagógica Predeterminado</h3>
          </div>

          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', gap: '16px' }}>
            {[
              { id: 'gentle', title: 'Empático y Suave', desc: 'Corrige solo errores graves sin romper el flujo del diálogo.' },
              { id: 'moderate', title: 'Equilibrado (Default)', desc: 'Corrige gramática y sugiere vocabulario más natural.' },
              { id: 'strict', title: 'Estricto y Riguroso', desc: 'Corrige cada detalle gramatical y pronunciación exacta.' },
            ].map((st) => (
              <div
                key={st.id}
                onClick={() => setCorrectionLevel(st.id)}
                style={{
                  padding: '16px',
                  borderRadius: '12px',
                  background: correctionLevel === st.id ? 'rgba(168, 85, 247, 0.15)' : 'rgba(6, 13, 32, 0.4)',
                  border: correctionLevel === st.id ? '1px solid var(--primary-purple)' : '1px solid var(--border-glass)',
                  cursor: 'pointer',
                  transition: 'all 0.2s ease',
                }}
              >
                <div style={{ fontSize: '14px', fontWeight: '700', color: '#fff' }}>{st.title}</div>
                <div style={{ fontSize: '11px', color: 'var(--text-muted)', marginTop: '4px' }}>{st.desc}</div>
              </div>
            ))}
          </div>
        </GlassCard>

        {/* Submit */}
        <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
          <button type="submit" className="btn-primary" style={{ padding: '12px 28px', fontSize: '15px' }}>
            {saved ? <Check style={{ width: '18px', height: '18px' }} /> : <Save style={{ width: '18px', height: '18px' }} />}
            <span>{saved ? 'Ajustes Guardados' : 'Guardar Configuración de IA'}</span>
          </button>
        </div>
      </form>
    </div>
  );
}
