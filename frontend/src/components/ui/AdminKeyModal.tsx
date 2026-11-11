import React, { useState } from 'react';
import { KeyRound, ShieldCheck, ShieldAlert, Trash2 } from 'lucide-react';
import { Modal } from './Modal';
import { Button } from './Button';
import { useAdminAuth } from '../../contexts/AdminAuthContext';

export const AdminKeyModal: React.FC = () => {
  const { adminKey, setAdminKey, clearAdminKey, isAuthenticated, isModalOpen, closeModal } =
    useAdminAuth();
  const [inputValue, setInputValue] = useState('');
  const [savedSuccess, setSavedSuccess] = useState(false);

  const handleOpen = () => {
    setInputValue(adminKey);
    setSavedSuccess(false);
  };

  const handleSave = (e: React.FormEvent) => {
    e.preventDefault();
    if (inputValue.trim()) {
      setAdminKey(inputValue.trim());
      setSavedSuccess(true);
      setTimeout(() => {
        closeModal();
      }, 700);
    } else {
      clearAdminKey();
    }
  };

  const handleClear = () => {
    clearAdminKey();
    setInputValue('');
  };

  return (
    <Modal
      isOpen={isModalOpen}
      onClose={closeModal}
      title={
        <span className="flex items-center gap-2 text-slate-900 dark:text-slate-100">
          <KeyRound className="w-5 h-5 text-brand-amber" />
          Autenticación de Administración
        </span>
      }
      description="Token local para sincronización manual de agentes hacia SQL Server."
    >
      <form onSubmit={handleSave} className="space-y-4">
        <div className="p-3.5 rounded-xl bg-amber-50 dark:bg-amber-950/30 border border-amber-200 dark:border-amber-900/50 flex gap-3 text-xs text-amber-800 dark:text-amber-200">
          <ShieldAlert className="w-5 h-5 flex-shrink-0 text-brand-amber mt-0.5" />
          <div>
            <p className="font-semibold mb-0.5">Seguridad y Privacidad</p>
            <p className="opacity-90 leading-relaxed">
              La clave <code className="bg-amber-100 dark:bg-amber-900/60 px-1 py-0.5 rounded font-mono">ADMIN_API_KEY</code> no se incrusta en el código fuente de la aplicación ni se envía a servidores externos. Se guarda exclusivamente en la sesión local de su navegador para autorizar peticiones protegidas.
            </p>
          </div>
        </div>

        <div>
          <label className="block text-xs font-semibold text-slate-700 dark:text-slate-300 mb-1.5">
            Clave ADMIN_API_KEY:
          </label>
          <input
            type="password"
            value={inputValue}
            onChange={(e) => setInputValue(e.target.value)}
            placeholder="Ingrese el token administrativo..."
            className="w-full px-3.5 py-2.5 text-sm rounded-xl border border-slate-300 dark:border-slate-600 bg-white dark:bg-slate-800 text-slate-900 dark:text-slate-100 focus:outline-none focus:ring-2 focus:ring-brand-red font-mono"
            autoFocus
          />
        </div>

        {isAuthenticated && (
          <div className="flex items-center justify-between p-3 rounded-lg bg-emerald-50 dark:bg-emerald-950/30 border border-emerald-200 dark:border-emerald-800 text-xs text-emerald-800 dark:text-emerald-200">
            <span className="flex items-center gap-2">
              <ShieldCheck className="w-4 h-4 text-emerald-600 dark:text-emerald-400" />
              Sesión administrativa activa
            </span>
            <button
              type="button"
              onClick={handleClear}
              className="text-rose-600 dark:text-rose-400 hover:underline flex items-center gap-1 font-medium cursor-pointer"
            >
              <Trash2 className="w-3.5 h-3.5" />
              Remover clave
            </button>
          </div>
        )}

        <div className="flex justify-end gap-2 pt-2">
          <Button type="button" variant="outline" size="sm" onClick={closeModal}>
            Cancelar
          </Button>
          <Button
            type="submit"
            variant="primary"
            size="sm"
            leftIcon={<KeyRound className="w-4 h-4" />}
          >
            {savedSuccess ? '¡Guardado!' : 'Guardar en Sesión'}
          </Button>
        </div>
      </form>
    </Modal>
  );
};
