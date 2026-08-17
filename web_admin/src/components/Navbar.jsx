import React from 'react';
import { RefreshCw } from 'lucide-react';

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
      <span style={{ fontSize: '13px', color: 'var(--text-muted)', fontFamily: 'var(--font-mono)' }}>
        TUTORSAAS · COMMAND DECK
      </span>

      <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
        <div style={{
          display: 'flex',
          alignItems: 'center',
          gap: '8px',
          padding: '6px 14px',
          borderRadius: '20px',
          background: 'rgba(16, 185, 129, 0.1)',
          border: '1px solid rgba(16, 185, 129, 0.3)',
          fontFamily: 'var(--font-mono)',
          fontSize: '12px',
          color: '#34d399',
        }}>
          <span style={{ width: '8px', height: '8px', borderRadius: '50%', background: '#10b981' }} />
          Conectado a Supabase
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
