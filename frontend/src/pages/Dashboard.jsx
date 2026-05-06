import React, { useEffect, useState } from 'react';
import { RefreshCw, CheckCircle, XCircle, Clock, Zap } from 'lucide-react';

const API_URL = 'http://localhost:8000'; // Assuming backend is on port 8000

export default function Dashboard() {
  const [data, setData] = useState({ stats: null, recent_events: [] });
  const [loading, setLoading] = useState(true);

  const fetchDashboard = async () => {
    try {
      const res = await fetch(`${API_URL}/api/dashboard`, {
        headers: {
          'Authorization': 'Basic ' + btoa('admin:admin123')
        }
      });
      const json = await res.json();
      setData(json);
    } catch (err) {
      console.error("Failed to fetch dashboard data", err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchDashboard();
    const interval = setInterval(fetchDashboard, 10000);
    return () => clearInterval(interval);
  }, []);

  if (loading && !data.stats) {
    return <div style={{ textAlign: 'center', marginTop: '4rem' }}>Carregando dados...</div>;
  }

  const { stats, recent_events } = data;

  return (
    <div style={{ animation: 'fadeIn 0.5s ease-out' }}>
      {/* Stats Cards */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(240px, 1fr))', gap: '1.5rem', marginBottom: '2.5rem' }}>
        <div className="glass" style={{ padding: '1.5rem', borderTop: '4px solid var(--primary-color)' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', marginBottom: '0.5rem' }}>
            <Zap size={20} color="var(--primary-color)" />
            <p style={{ margin: 0, fontSize: '0.875rem' }}>Total Processado</p>
          </div>
          <p style={{ fontSize: '2.5rem', fontWeight: 700, margin: 0 }}>{stats?.total || 0}</p>
        </div>
        
        <div className="glass" style={{ padding: '1.5rem', borderTop: '4px solid var(--danger-color)' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', marginBottom: '0.5rem' }}>
            <XCircle size={20} color="var(--danger-color)" />
            <p style={{ margin: 0, fontSize: '0.875rem' }}>Ocorrências Válidas (Reais)</p>
          </div>
          <p style={{ fontSize: '2.5rem', fontWeight: 700, margin: 0, color: 'var(--danger-color)' }}>{stats?.valid || 0}</p>
        </div>
        
        <div className="glass" style={{ padding: '1.5rem', borderTop: '4px solid var(--success-color)' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', marginBottom: '0.5rem' }}>
            <CheckCircle size={20} color="var(--success-color)" />
            <p style={{ margin: 0, fontSize: '0.875rem' }}>Falsos Positivos Filtrados</p>
          </div>
          <p style={{ fontSize: '2.5rem', fontWeight: 700, margin: 0, color: 'var(--success-color)' }}>{stats?.invalid || 0}</p>
        </div>
        
        <div className="glass" style={{ padding: '1.5rem', borderTop: '4px solid #8b5cf6' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', marginBottom: '0.5rem' }}>
            <Clock size={20} color="#8b5cf6" />
            <p style={{ margin: 0, fontSize: '0.875rem' }}>Tempo Médio</p>
          </div>
          <p style={{ fontSize: '2.5rem', fontWeight: 700, margin: 0, color: '#a78bfa' }}>
            {stats?.avg_time_ms || 0} <span style={{ fontSize: '1.25rem', color: 'var(--text-secondary)' }}>ms</span>
          </p>
        </div>
      </div>

      {/* Feed Table */}
      <div className="glass table-container">
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '1.25rem 1.5rem', borderBottom: '1px solid var(--card-border)' }}>
          <h2>Feed de Eventos</h2>
          <button onClick={fetchDashboard} className="btn btn-primary" style={{ padding: '0.4rem 0.75rem', fontSize: '0.75rem' }}>
            <RefreshCw size={14} /> Atualizar Agora
          </button>
        </div>
        
        <table style={{ width: '100%', borderCollapse: 'collapse', textAlign: 'left' }}>
          <thead>
            <tr>
              <th>Data/Hora</th>
              <th>Ocorrência</th>
              <th>IMEI</th>
              <th>Tipo de Alarme</th>
              <th>Confiança YOLO</th>
              <th>Decisão VLM</th>
              <th>Status Final</th>
            </tr>
          </thead>
          <tbody>
            {recent_events?.length === 0 ? (
              <tr>
                <td colSpan="7" style={{ textAlign: 'center', padding: '3rem', color: 'var(--text-secondary)' }}>
                  Nenhum evento processado ainda. Aguardando mensagens do RabbitMQ...
                </td>
              </tr>
            ) : (
              recent_events?.map((item, idx) => (
                <tr key={`${item.occurrence_id}-${idx}`}>
                  <td style={{ color: 'var(--text-secondary)' }}>{item.timestamp}</td>
                  <td style={{ fontWeight: 600 }}>#{item.occurrence_id}</td>
                  <td>{item.imei || 'Desconhecido'}</td>
                  <td>{item.alarm_type}</td>
                  <td style={{ color: 'var(--primary-color)', fontWeight: 600 }}>
                    {(item.yolo_conf * 100).toFixed(1)}%
                  </td>
                  <td title={item.vlm_reason} style={{ maxWidth: '200px', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis', cursor: 'help' }}>
                    {item.vlm_reason || '---'}
                  </td>
                  <td>
                    {item.status === 'valid' ? (
                      <span className="tag tag-danger">VÁLIDO</span>
                    ) : (
                      <span className="tag tag-success">FALSO POSITIVO</span>
                    )}
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}
