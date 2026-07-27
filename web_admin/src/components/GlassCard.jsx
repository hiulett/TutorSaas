import React from 'react';

export default function GlassCard({ children, className = '', interactive = false, style = {} }) {
  return (
    <div
      className={`glass-panel ${interactive ? 'glass-panel-interactive' : ''} ${className}`}
      style={style}
    >
      {children}
    </div>
  );
}
