import React, { useState } from 'react';
import { supabase } from '../lib/supabaseClient';
import { LogIn, Mail, Lock, Eye, EyeOff, Sparkles, AlertCircle } from 'lucide-react';

export default function Login({ onLogin }) {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPwd, setShowPwd] = useState(false);
  const [error, setError] = useState('');
  const [mode, setMode] = useState('login');
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    try {
      if (mode === 'login') {
        const { data, error: authError } = await supabase.auth.signInWithPassword({ email, password });
        if (authError) throw authError;
        if (data?.session) onLogin(data.session);
      } else {
        const { data, error: authError } = await supabase.auth.signUp({ email, password });
        if (authError) throw authError;
        setMode('login');
        setError('Cuenta creada. Revisa tu email para verificar.');
      }
    } catch (err) {
      setError(err.message || 'Error de autenticación');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={{ minHeight: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center', position: 'relative' }}>
      <div className="space-bg">
        <div className="orb orb-purple" style={{ top: '10%', left: '20%' }} />
        <div className="orb orb-teal" style={{ bottom: '20%', right: '15%' }} />
        <div className="orb orb-blue" style={{ top: '50%', left: '60%' }} />
      </div>

      <div className="glass-panel" style={{ width: '420px', padding: '40px' }}>
        <div style={{ textAlign: 'center', marginBottom: '32px' }}>
          <div style={{ width: '56px', height: '56px', borderRadius: '16px', background: 'linear-gradient(135deg, var(--primary-purple), var(--secondary-teal))', display: 'flex', alignItems: 'center', justifyContent: 'center', margin: '0 auto 16px', boxShadow: '0 0 24px rgba(168, 85, 247, 0.4)' }}>
            <Sparkles style={{ width: '28px', height: '28px', color: '#fff' }} />
          </div>
          <h1 style={{ fontSize: '24px', fontWeight: '800', color: '#fff', margin: '0 0 4px' }}>TutorSaas</h1>
          <p style={{ fontSize: '14px', color: 'var(--text-muted)', margin: 0 }}>COMMAND DECK — Acceso Administrativo</p>
        </div>

        <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
          {error && (
            <div style={{ padding: '12px 16px', borderRadius: '10px', background: 'rgba(239, 68, 68, 0.1)', border: '1px solid rgba(239, 68, 68, 0.3)', color: '#fca5a5', fontSize: '13px', display: 'flex', alignItems: 'center', gap: '8px' }}>
              <AlertCircle style={{ width: '16px', height: '16px', flexShrink: 0 }} />
              <span>{error}</span>
            </div>
          )}

          <div>
            <label style={{ display: 'block', fontSize: '12px', fontWeight: '600', color: 'var(--text-muted)', marginBottom: '6px', textTransform: 'uppercase', letterSpacing: '0.05em' }}>Email</label>
            <div style={{ position: 'relative' }}>
              <Mail style={{ position: 'absolute', left: '14px', top: '50%', transform: 'translateY(-50%)', width: '18px', height: '18px', color: 'var(--text-muted)' }} />
              <input type="email" value={email} onChange={e => setEmail(e.target.value)} placeholder="admin@tutorsaas.com" required className="cyber-input" style={{ paddingLeft: '42px' }} />
            </div>
          </div>

          <div>
            <label style={{ display: 'block', fontSize: '12px', fontWeight: '600', color: 'var(--text-muted)', marginBottom: '6px', textTransform: 'uppercase', letterSpacing: '0.05em' }}>Contraseña</label>
            <div style={{ position: 'relative' }}>
              <Lock style={{ position: 'absolute', left: '14px', top: '50%', transform: 'translateY(-50%)', width: '18px', height: '18px', color: 'var(--text-muted)' }} />
              <input type={showPwd ? 'text' : 'password'} value={password} onChange={e => setPassword(e.target.value)} placeholder="••••••••" required className="cyber-input" style={{ paddingLeft: '42px', paddingRight: '42px' }} />
              <button type="button" onClick={() => setShowPwd(!showPwd)} style={{ position: 'absolute', right: '14px', top: '50%', transform: 'translateY(-50%)', background: 'none', border: 'none', cursor: 'pointer', color: 'var(--text-muted)', padding: '4px' }}>
                {showPwd ? <EyeOff style={{ width: '18px', height: '18px' }} /> : <Eye style={{ width: '18px', height: '18px' }} />}
              </button>
            </div>
          </div>

          <button type="submit" disabled={loading} className="btn-primary" style={{ marginTop: '8px', padding: '14px', fontSize: '15px', fontWeight: '700', opacity: loading ? '0.7' : '1', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '8px' }}>
            <LogIn style={{ width: '18px', height: '18px' }} />
            {loading ? 'Autenticando...' : mode === 'login' ? 'Iniciar Sesión' : 'Crear Cuenta'}
          </button>

          <p style={{ textAlign: 'center', fontSize: '13px', color: 'var(--text-muted)', margin: '4px 0 0' }}>
            {mode === 'login' ? (
              <>¿No tienes cuenta?{' '}<button type="button" onClick={() => { setMode('register'); setError(''); }} style={{ background: 'none', border: 'none', color: 'var(--primary-purple)', cursor: 'pointer', fontWeight: '600', padding: 0, fontSize: '13px' }}>Registrarse</button></>
            ) : (
              <>¿Ya tienes cuenta?{' '}<button type="button" onClick={() => { setMode('login'); setError(''); }} style={{ background: 'none', border: 'none', color: 'var(--primary-purple)', cursor: 'pointer', fontWeight: '600', padding: 0, fontSize: '13px' }}>Iniciar Sesión</button></>
            )}
          </p>
        </form>
      </div>
    </div>
  );
}
