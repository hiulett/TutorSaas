import React from 'react';
import { Search, Bell, Activity, RefreshCw } from 'lucide-react';

export default function Navbar({ onRefresh, session }) {
  return (
    <header style={{
      height: '70px',
      padding: '0 32px',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'space-between',
      borderBottom: '1px solid var(--border-glass)',
      background: 'rgba(11, 19, 38, 0.4)',
      backdropFilter: 'blur(10px)',
    }}>
      {/* Search Input */}
      <div style={{ position: 'relative', width: '360px' }}>
        <Search style={{
          position: 'absolute',
          left: '14px',
          top: '50%',
          transform: 'translateY(-50%)',
          width: '18px',
          height: '18px',
          color: 'var(--text-muted)',
        }} />
        <input
          type="text"
          placeholder="Buscar lecciones, usuarios, niveles CEFR..."
          className="cyber-input"
          style={{ paddingLeft: '42px' }}
        />
      </div>

      {/* Right Controls */}
      <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
        {/* Latency & Status Indicator */}
        <div style={{
          display: 'flex',
          alignItems: 'center',
          gap: '8px',
          padding: '6px 14px',
          borderRadius: '20px',
          background: 'rgba(6, 182, 212, 0.1)',
          border: '1px solid rgba(6, 182, 212, 0.3)',
          fontFamily: 'var(--font-mono)',
          fontSize: '12px',
          color: 'var(--secondary-teal)',
        }}>
          <Activity style={{ width: '14px', height: '14px' }} />
          <span>IA Latency: <strong>1.1s</strong> (Groq + DeepSeek)</span>
        </div>

        <button
          onClick={onRefresh}
          className="btn-secondary"
          title="Sincronizar datos"
          style={{ padding: '8px 12px' }}
        >
          <RefreshCw style={{ width: '16px', height: '16px' }} />
        </button>

        <div style={{
          width: '36px',
          height: '36px',
          borderRadius: '50%',
          background: 'linear-gradient(135deg, var(--primary-purple), var(--secondary-teal))',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          fontWeight: '700',
          fontSize: '14px',
          color: '#fff',
          boxShadow: '0 0 12px rgba(168, 85, 247, 0.3)',
        }}>
          {(session?.user?.email?.[0] || 'A').toUpperCase()}
        </div>
      </div>
    </header>
  );
}
