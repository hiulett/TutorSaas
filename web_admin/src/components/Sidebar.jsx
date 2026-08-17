import React from 'react';
import {
  LayoutDashboard,
  BookOpen,
  Layers,
  Users,
  Sliders,
  Sparkles,
  LogOut,
  ShieldCheck,
  CreditCard,
  Coins,
} from 'lucide-react';
import { supabase } from '../lib/supabaseClient';

export default function Sidebar({ activeTab, setActiveTab, session }) {
  const navItems = [
    { id: 'overview', label: 'Panel Principal', icon: LayoutDashboard },
    { id: 'lessons', label: 'Lecciones y Escenarios', icon: BookOpen },
    { id: 'cefr', label: 'Niveles CEFR', icon: Layers },
    { id: 'users', label: 'Usuarios y Progreso', icon: Users },
    { id: 'plans', label: 'Planes y Membresías', icon: CreditCard },
    { id: 'economy', label: 'Economía y Config', icon: Coins },
    { id: 'ai-settings', label: 'Ajustes de IA', icon: Sliders },
  ];

  const handleLogout = async () => {
    await supabase.auth.signOut();
  };

  return (
    <aside style={{ width: '260px', flexShrink: 0, padding: '24px 16px', display: 'flex', flexDirection: 'column', borderRight: '1px solid var(--border-glass)' }}>
      {/* Brand Header */}
      <div style={{ display: 'flex', alignItems: 'center', gap: '12px', padding: '0 12px 28px 12px' }}>
        <div style={{
          width: '42px',
          height: '42px',
          borderRadius: '12px',
          background: 'linear-gradient(135deg, var(--primary-purple), var(--secondary-teal))',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          boxShadow: '0 0 18px rgba(168, 85, 247, 0.4)',
        }}>
          <Sparkles style={{ width: '24px', height: '24px', color: '#fff' }} />
        </div>
        <div>
          <h2 style={{ fontSize: '18px', fontWeight: '800', color: '#fff', lineHeight: '1.2' }}>TutorSaas</h2>
          <span style={{ fontSize: '11px', color: 'var(--secondary-teal)', fontFamily: 'var(--font-mono)', fontWeight: '600', letterSpacing: '0.05em' }}>
            COMMAND DECK
          </span>
        </div>
      </div>

      {/* Navigation Links */}
      <nav style={{ display: 'flex', flexDirection: 'column', gap: '6px', flex: 1 }}>
        {navItems.map((item) => {
          const Icon = item.icon;
          const isActive = activeTab === item.id;

          return (
            <button
              key={item.id}
              onClick={() => setActiveTab(item.id)}
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: '12px',
                padding: '12px 14px',
                borderRadius: '12px',
                border: 'none',
                background: isActive
                  ? 'linear-gradient(90deg, rgba(168, 85, 247, 0.15), rgba(56, 189, 248, 0.05))'
                  : 'transparent',
                color: isActive ? '#fff' : 'var(--text-muted)',
                fontWeight: isActive ? '700' : '500',
                fontSize: '14px',
                cursor: 'pointer',
                transition: 'all 0.2s ease',
                textAlign: 'left',
                borderLeft: isActive ? '3px solid var(--primary-purple)' : '3px solid transparent',
              }}
            >
              <Icon style={{ width: '18px', height: '18px', color: isActive ? 'var(--primary-purple)' : 'inherit' }} />
              <span>{item.label}</span>
            </button>
          );
        })}
      </nav>

      {/* Session Info + Logout */}
      <div style={{ display: 'flex', flexDirection: 'column', gap: '8px', marginTop: 'auto' }}>
        {session?.user && (
          <div style={{ padding: '12px', borderRadius: '12px', background: 'rgba(255, 255, 255, 0.03)', border: '1px solid var(--border-glass)' }}>
            <div style={{ fontSize: '11px', color: 'var(--text-muted)', fontFamily: 'var(--font-mono)' }}>{session.user.email}</div>
          </div>
        )}
        <button onClick={handleLogout} style={{ display: 'flex', alignItems: 'center', gap: '10px', padding: '12px 14px', borderRadius: '12px', border: '1px solid rgba(239, 68, 68, 0.3)', background: 'rgba(239, 68, 68, 0.08)', color: '#fca5a5', fontWeight: '600', fontSize: '13px', cursor: 'pointer', transition: 'all 0.2s ease', textAlign: 'left' }}>
          <LogOut style={{ width: '16px', height: '16px' }} />
          <span>Cerrar Sesión</span>
        </button>
      </div>
    </aside>
  );
}
