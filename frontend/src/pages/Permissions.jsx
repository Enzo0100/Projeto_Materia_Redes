import React, { useEffect, useState } from 'react';
import { Plus, Edit2, Trash2, Shield, Settings, Server } from 'lucide-react';

const API_URL = 'http://localhost:8000';
const AVAILABLE_MODELS = ["Bocejo", "Distração", "Uso de Celular", "Fumar", "EPI", "Capacete", "Acompanhante"];

export default function Permissions() {
  const [permissions, setPermissions] = useState({});
  const [loading, setLoading] = useState(true);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [currentEditingImei, setCurrentEditingImei] = useState(null);
  
  // Form state
  const [formImei, setFormImei] = useState('');
  const [formUseYolo, setFormUseYolo] = useState(true);
  const [formUseVlm, setFormUseVlm] = useState(false);
  const [formModels, setFormModels] = useState([]);

  const fetchPermissions = async () => {
    try {
      const res = await fetch(`${API_URL}/api/permissions`, {
        headers: {
          'Authorization': 'Basic ' + btoa('admin:admin123')
        }
      });
      const data = await res.json();
      setPermissions(data);
    } catch (err) {
      console.error("Failed to fetch permissions", err);
      alert("Erro ao carregar permissões");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchPermissions();
  }, []);

  const openModal = (imei = null) => {
    setCurrentEditingImei(imei);
    if (imei && permissions[imei]) {
      setFormImei(imei);
      setFormUseYolo(permissions[imei].use_yolo);
      setFormUseVlm(permissions[imei].use_vlm);
      setFormModels(permissions[imei].allowed_models || []);
    } else {
      setFormImei('');
      setFormUseYolo(true);
      setFormUseVlm(false);
      setFormModels([]);
    }
    setIsModalOpen(true);
  };

  const closeModal = () => {
    setIsModalOpen(false);
    setCurrentEditingImei(null);
  };

  const handleModelToggle = (model) => {
    setFormModels(prev => 
      prev.includes(model) ? prev.filter(m => m !== model) : [...prev, model]
    );
  };

  const persistData = async (newData) => {
    try {
      const res = await fetch(`${API_URL}/api/permissions`, {
        method: 'POST',
        headers: { 
          'Content-Type': 'application/json',
          'Authorization': 'Basic ' + btoa('admin:admin123')
        },
        body: JSON.stringify(newData)
      });
      if (!res.ok) throw new Error("Server error");
      setPermissions(newData);
    } catch (err) {
      console.error(err);
      alert("Erro ao salvar permissões no servidor");
    }
  };

  const savePermission = async (e) => {
    e.preventDefault();
    if (!formImei.trim()) return alert("IMEI é obrigatório");

    const newData = { ...permissions };

    if (currentEditingImei && currentEditingImei !== formImei && currentEditingImei !== 'GLOBAL_DEFAULT') {
      delete newData[currentEditingImei];
    }

    newData[formImei.trim()] = {
      use_yolo: formUseYolo,
      use_vlm: formUseVlm,
      allowed_models: formModels
    };

    await persistData(newData);
    closeModal();
  };

  const deleteImei = async (imei) => {
    if (imei === 'GLOBAL_DEFAULT') return alert("Não é possível excluir o padrão global.");
    if (!window.confirm(`Tem certeza que deseja excluir as permissões do IMEI ${imei}?`)) return;
    
    const newData = { ...permissions };
    delete newData[imei];
    await persistData(newData);
  };

  return (
    <div style={{ animation: 'fadeIn 0.5s ease-out' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1.5rem' }}>
        <div>
          <h2>Gerenciar Acessos</h2>
          <p>Controle de modelos IA e funcionalidades por IMEI</p>
        </div>
        <button onClick={() => openModal()} className="btn btn-primary">
          <Plus size={18} /> Adicionar IMEI
        </button>
      </div>

      <div className="glass table-container">
        <table>
          <thead>
            <tr>
              <th><div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}><Server size={14}/> IMEI</div></th>
              <th><div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}><Settings size={14}/> YOLO Ativo</div></th>
              <th><div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}><Shield size={14}/> VLM Ativo</div></th>
              <th>Modelos Permitidos</th>
              <th style={{ textAlign: 'right' }}>Ações</th>
            </tr>
          </thead>
          <tbody>
            {loading ? (
              <tr><td colSpan="5" style={{ textAlign: 'center', padding: '2rem' }}>Carregando...</td></tr>
            ) : Object.keys(permissions).length === 0 ? (
              <tr><td colSpan="5" style={{ textAlign: 'center', padding: '2rem' }}>Nenhuma permissão configurada.</td></tr>
            ) : (
              Object.entries(permissions).map(([imei, config]) => (
                <tr key={imei}>
                  <td style={{ fontWeight: 600, color: imei === 'GLOBAL_DEFAULT' ? 'var(--primary-color)' : 'white' }}>
                    {imei}
                  </td>
                  <td>
                    {config.use_yolo ? <span className="tag tag-success">Sim</span> : <span className="tag tag-neutral">Não</span>}
                  </td>
                  <td>
                    {config.use_vlm ? <span className="tag tag-success">Sim</span> : <span className="tag tag-neutral">Não</span>}
                  </td>
                  <td>
                    <div style={{ display: 'flex', gap: '0.5rem', flexWrap: 'wrap' }}>
                      {config.allowed_models?.length > 0 
                        ? config.allowed_models.map(m => <span key={m} className="tag tag-neutral">{m}</span>)
                        : <span style={{ color: 'var(--text-secondary)' }}>Nenhum</span>
                      }
                    </div>
                  </td>
                  <td style={{ textAlign: 'right' }}>
                    <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '0.5rem' }}>
                      <button onClick={() => openModal(imei)} className="btn btn-ghost" style={{ padding: '0.4rem' }}>
                        <Edit2 size={16} />
                      </button>
                      {imei !== 'GLOBAL_DEFAULT' && (
                        <button onClick={() => deleteImei(imei)} className="btn btn-danger" style={{ padding: '0.4rem' }}>
                          <Trash2 size={16} />
                        </button>
                      )}
                    </div>
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>

      {isModalOpen && (
        <div style={{
          position: 'fixed', top: 0, left: 0, right: 0, bottom: 0,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          zIndex: 50
        }} className="glass-modal">
          <div className="glass" style={{ width: '100%', maxWidth: '500px', padding: '2rem', animation: 'scaleIn 0.2s ease-out' }}>
            <h3 style={{ marginBottom: '1.5rem', fontSize: '1.5rem', fontWeight: 700 }}>
              {currentEditingImei ? `Editar: ${currentEditingImei}` : 'Novo Cadastro de IMEI'}
            </h3>

            <form onSubmit={savePermission}>
              <div style={{ marginBottom: '1.5rem' }}>
                <label style={{ display: 'block', marginBottom: '0.5rem', color: 'var(--text-secondary)', fontSize: '0.875rem' }}>IMEI do Equipamento</label>
                <input 
                  type="text" 
                  className="input-field" 
                  value={formImei}
                  onChange={(e) => setFormImei(e.target.value)}
                  disabled={currentEditingImei === 'GLOBAL_DEFAULT'}
                  placeholder="Ex: 14681536"
                  required 
                />
              </div>

              <div style={{ display: 'flex', gap: '2rem', marginBottom: '1.5rem' }}>
                <label className="checkbox-label">
                  <input type="checkbox" className="checkbox-input" checked={formUseYolo} onChange={(e) => setFormUseYolo(e.target.checked)} />
                  Ativar YOLO
                </label>
                <label className="checkbox-label">
                  <input type="checkbox" className="checkbox-input" checked={formUseVlm} onChange={(e) => setFormUseVlm(e.target.checked)} />
                  Ativar VLM
                </label>
              </div>

              <div style={{ marginBottom: '2rem' }}>
                <label style={{ display: 'block', marginBottom: '0.75rem', color: 'var(--text-secondary)', fontSize: '0.875rem' }}>Modelos Permitidos</label>
                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '0.75rem' }}>
                  {AVAILABLE_MODELS.map(model => (
                    <label key={model} className="checkbox-label">
                      <input 
                        type="checkbox" 
                        className="checkbox-input" 
                        checked={formModels.includes(model)} 
                        onChange={() => handleModelToggle(model)} 
                      />
                      {model}
                    </label>
                  ))}
                </div>
              </div>

              <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '1rem' }}>
                <button type="button" onClick={closeModal} className="btn btn-ghost">Cancelar</button>
                <button type="submit" className="btn btn-primary">Salvar Alterações</button>
              </div>
            </form>
          </div>
        </div>
      )}
      <style dangerouslySetInnerHTML={{__html: `
        @keyframes scaleIn {
          from { transform: scale(0.95); opacity: 0; }
          to { transform: scale(1); opacity: 1; }
        }
        @keyframes fadeIn {
          from { opacity: 0; transform: translateY(10px); }
          to { opacity: 1; transform: translateY(0); }
        }
      `}} />
    </div>
  );
}
