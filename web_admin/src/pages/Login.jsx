import React, { useState } from 'react';
import { supabase } from '../lib/supabaseClient';
import { LogIn, Mail, Lock, Eye, EyeOff, Sparkles, AlertCircle, ShieldCheck, ArrowLeft } from 'lucide-react';

export default function Login({ onLogin }) {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPwd, setShowPwd] = useState(false);
  const [error, setError] = useState('');

  // 2FA (TOTP)
  const [factorId, setFactorId] = useState(null);
  const [totpCode, setTotpCode] = useState('');

  const [loading, setLoading] = useState(false);

  const handlePasswordSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    try {
      const { data, error: authError } = await supabase.auth.signInWithPassword({ email, password });
      if (authError) throw authError;

      // Si la cuenta tiene TOTP habilitado, Supabase devuelve factor_id.
      if (data?.factor_id) {
        setFactorId(data.factor_id);
        setTotpCode('');
        return;
      }
      if (data?.session) onLogin(data.session);
    } catch (err) {
      setError(err.message || 'Error de autenticación');
    } finally {
      setLoading(false);
    }
  };

  const handleTotpSubmit = async (e) => {
    e.preventDefault();
    if (!factorId || totpCode.trim().length === 0) return;
    setError('');
    setLoading(true);

    try {
      // 1) Lanzar el reto del factor TOTP.
      const { data: challenge, error: cErr } = await supabase.auth.mfa.challenge({ factorId });
      if (cErr) throw cErr;

      // 2) Verificar el código. Si el reto expiró, se reintenta una vez.
      const { data: verify, error: vErr } = await supabase.auth.mfa.verify({
        factorId,
        challengeId: challenge.id,
        code: totpCode.trim(),
      });
      if (vErr) {
        if (/expired/i.test(vErr.message)) {
          const retry = await supabase.auth.mfa.challenge({ factorId });
          if (retry.error) throw retry.error;
          const verify2 = await supabase.auth.mfa.verify({
            factorId,
            challengeId: retry.data.id,
            code: totpCode.trim(),
          });
          if (verify2.error) throw verify2.error;
          if (verify2.data?.valid && verify2.data?.session) onLogin(verify2.data.session);
          return;
        }
        throw vErr;
      }
      if (verify?.valid && verify?.session) onLogin(verify.session);
      else setError('Código 2FA incorrecto');
    } catch (err) {
      setError(err.message || 'Error verificando el código 2FA');
    } finally {
      setLoading(false);
    }
  };

  const backToPassword = () => {
    setFactorId(null);
    setTotpCode('');
    setError('');
  };

  const inputStyle = { paddingLeft: '42px' };

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
          <p style={{ fontSize: '14px', color: 'var(--text-muted)', margin: 0 }}>
            {factorId ? 'Verificación en dos pasos' : 'COMMAND DECK — Acceso Administrativo'}
          </p>
        </div>

        {factorId ? (
          <form onSubmit={handleTotpSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
            {error && (
              <div style={{ padding: '12px 16px', borderRadius: '10px', background: 'rgba(239, 68, 68, 0.1)', border: '1px solid rgba(239, 68, 68, 0.3)', color: '#fca5a5', fontSize: '13px', display: 'flex', alignItems: 'center', gap: '8px' }}>
                <AlertCircle style={{ width: '16px', height: '16px', flexShrink: 0 }} />
                <span>{error}</span>
              </div>
            )}

            <div style={{ textAlign: 'center', padding: '8px 0' }}>
              <ShieldCheck style={{ width: '36px', height: '36px', color: 'var(--secondary-teal)' }} />
              <p style={{ fontSize: '13px', color: 'var(--text-muted)', margin: '8px 0 0' }}>
                Ingresa el código de 6 dígitos de tu app de autenticación.
              </p>
            </div>

            <div>
              <label style={{ display: 'block', fontSize: '12px', fontWeight: '600', color: 'var(--text-muted)', marginBottom: '6px', textTransform: 'uppercase', letterSpacing: '0.05em' }}>Código 2FA</label>
              <input
                type="text"
                inputMode="numeric"
                maxLength={6}
                autoComplete="one-time-code"
                value={totpCode}
                onChange={(e) => setTotpCode(e.target.value.replace(/\D/g, ''))}
                placeholder="••••••"
                required
                className="cyber-input"
                style={{ textAlign: 'center', fontSize: '20px', letterSpacing: '6px', ...inputStyle }}
              />
            </div>

            <button type="submit" disabled={loading || totpCode.length === 0} className="btn-primary" style={{ marginTop: '8px', padding: '14px', fontSize: '15px', fontWeight: '700', opacity: loading ? '0.7' : '1', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '8px' }}>
              <ShieldCheck style={{ width: '18px', height: '18px' }} />
              {loading ? 'Verificando...' : 'Verificar código'}
            </button>

            <button type="button" onClick={backToPassword} style={{ background: 'none', border: 'none', color: 'var(--text-muted)', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: '6px', justifyContent: 'center', padding: 0, fontSize: '13px' }}>
              <ArrowLeft style={{ width: '14px', height: '14px' }} />
              Volver
            </button>
          </form>
        ) : (
          <form onSubmit={handlePasswordSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
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
                <input type="email" value={email} onChange={(e) => setEmail(e.target.value)} placeholder="admin@tutorsaas.com" required className="cyber-input" style={inputStyle} />
              </div>
            </div>

            <div>
              <label style={{ display: 'block', fontSize: '12px', fontWeight: '600', color: 'var(--text-muted)', marginBottom: '6px', textTransform: 'uppercase', letterSpacing: '0.05em' }}>Contraseña</label>
              <div style={{ position: 'relative' }}>
                <Lock style={{ position: 'absolute', left: '14px', top: '50%', transform: 'translateY(-50%)', width: '18px', height: '18px', color: 'var(--text-muted)' }} />
                <input type={showPwd ? 'text' : 'password'} value={password} onChange={(e) => setPassword(e.target.value)} placeholder="••••••••" required className="cyber-input" style={{ ...inputStyle, paddingRight: '42px' }} />
                <button type="button" onClick={() => setShowPwd(!showPwd)} style={{ position: 'absolute', right: '14px', top: '50%', transform: 'translateY(-50%)', background: 'none', border: 'none', cursor: 'pointer', color: 'var(--text-muted)', padding: '4px' }}>
                  {showPwd ? <EyeOff style={{ width: '18px', height: '18px' }} /> : <Eye style={{ width: '18px', height: '18px' }} />}
                </button>
              </div>
            </div>

            <button type="submit" disabled={loading} className="btn-primary" style={{ marginTop: '8px', padding: '14px', fontSize: '15px', fontWeight: '700', opacity: loading ? '0.7' : '1', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '8px' }}>
              <LogIn style={{ width: '18px', height: '18px' }} />
              {loading ? 'Autenticando...' : 'Iniciar Sesión'}
            </button>
          </form>
        )}
      </div>
    </div>
  );
}
