import React from 'react';
import { BrowserRouter, Routes, Route, Link, useLocation } from 'react-router-dom';
import { Activity, ShieldCheck } from 'lucide-react';
import Dashboard from './pages/Dashboard';
import Permissions from './pages/Permissions';

function Header() {
  const location = useLocation();

  return (
    <header style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '2.5rem' }}>
      <div>
        <h1>Events AI Dashboard</h1>
        <p>Monitoramento em tempo real (YOLO + LLaVA)</p>
      </div>
      <div style={{ display: 'flex', gap: '1rem', alignItems: 'center' }}>
        <nav className="glass" style={{ display: 'flex', padding: '0.25rem', borderRadius: '2rem' }}>
          <Link 
            to="/" 
            className={`btn ${location.pathname === '/' ? 'btn-primary' : 'btn-ghost'}`}
            style={{ borderRadius: '1.5rem', padding: '0.5rem 1.25rem' }}
          >
            <Activity size={18} /> Feed
          </Link>
          <Link 
            to="/permissions" 
            className={`btn ${location.pathname === '/permissions' ? 'btn-primary' : 'btn-ghost'}`}
            style={{ borderRadius: '1.5rem', padding: '0.5rem 1.25rem' }}
          >
            <ShieldCheck size={18} /> Permissões
          </Link>
        </nav>
        <div className="glass" style={{ display: 'flex', alignItems: 'center', gap: '0.75rem', padding: '0.75rem 1.25rem', borderRadius: '2rem' }}>
          <div className="pulse-indicator"></div>
          <span style={{ fontSize: '0.875rem', fontWeight: 600 }}>Sistema Online</span>
        </div>
      </div>
    </header>
  );
}

function App() {
  return (
    <BrowserRouter>
      <div className="app-container">
        <Header />
        <Routes>
          <Route path="/" element={<Dashboard />} />
          <Route path="/permissions" element={<Permissions />} />
        </Routes>
      </div>
    </BrowserRouter>
  );
}

export default App;
