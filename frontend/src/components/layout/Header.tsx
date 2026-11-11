import React from 'react';
import { useLocation } from 'react-router-dom';
import { useQueryClient, useQuery } from '@tanstack/react-query';
import {
  Menu,
  Sun,
  Moon,
  RotateCw,
  KeyRound,
  ShieldCheck,
  CheckCircle2,
  AlertCircle,
  Clock,
  Radio,
} from 'lucide-react';
import { useTheme } from '../../contexts/ThemeContext';
import { useAdminAuth } from '../../contexts/AdminAuthContext';
import { ApiService } from '../../services/api';
import { formatDate } from '../../utils/format';

interface HeaderProps {
  onOpenMobileSidebar: () => void;
}

const moduleMetadata: Record<string, { title: string; description: string }> = {
  '/': {
    title: 'Dashboard General',
    description: 'Métricas consolidadas, estado de agentes y prospectos BUYER.',
  },
  '/facebook': {
    title: 'Facebook Page & Publicaciones',
    description: 'Monitoreo de publicaciones, métricas y sincronización de Facebook Graph API.',
  },
  '/instagram': {
    title: 'Instagram Business',
    description: 'Seguimiento de publicaciones, media y comentarios en Instagram.',
  },
  '/comments': {
    title: 'Comentarios & Clasificación de Intención',
    description: 'Análisis inteligente de consultas por producto, precio, reserva y promoción.',
  },
  '/buyers': {
    title: 'BUYERS — Prospectos Identificados',
    description: 'Captación multicanal, interacciones y trazabilidad de clientes potenciales.',
  },
  '/agents': {
    title: 'Agentes Autónomos & Planificador',
    description: 'Centro de control de agentes inteligentes, scheduler y sincronización manual.',
  },
  '/audit': {
    title: 'Auditoría & Bitácora de Acciones',
    description: 'Registro transaccional de operaciones ejecutadas por los agentes en SQL Server.',
  },
  '/settings': {
    title: 'Configuración del Sistema',
    description: 'Estado de integraciones Meta, SQL Server, automatización y preferencias.',
  },
};

export const Header: React.FC<HeaderProps> = ({ onOpenMobileSidebar }) => {
  const location = useLocation();
  const queryClient = useQueryClient();
  const { theme, toggleTheme } = useTheme();
  const { isAuthenticated, openModal } = useAdminAuth();

  // Comprobar salud del backend
  const { data: healthData, isError: isHealthError } = useQuery({
    queryKey: ['health'],
    queryFn: ApiService.getHealth,
    refetchInterval: 30000,
  });

  // Resumen del dashboard para última sincronización y agentes
  const { data: resumenData, isFetching } = useQuery({
    queryKey: ['dashboardResumen'],
    queryFn: ApiService.getDashboardResumen,
    refetchInterval: 15000,
  });

  const currentMeta = moduleMetadata[location.pathname] || {
    title: 'Agente BUYER',
    description: 'Parrilladas El Establo',
  };

  const handleRefreshAll = () => {
    queryClient.invalidateQueries();
  };

  const lastSyncDate = resumenData?.ultima_sincronizacion?.fecha;
  const schedulerActive = resumenData?.estado_agentes?.scheduler?.activo;

  return (
    <header className="sticky top-0 z-30 h-16 bg-white/95 dark:bg-brand-charcoal/95 backdrop-blur-md border-b border-slate-200 dark:border-brand-charcoal-border px-4 lg:px-8 flex items-center justify-between transition-colors">
      {/* Left: Mobile Toggle & Module Info */}
      <div className="flex items-center gap-3">
        <button
          onClick={onOpenMobileSidebar}
          className="p-2 -ml-2 text-slate-500 hover:text-slate-800 dark:text-slate-400 dark:hover:text-slate-100 rounded-lg lg:hidden"
          aria-label="Abrir menú"
        >
          <Menu className="w-5 h-5" />
        </button>
        <div>
          <h1 className="text-sm sm:text-base font-bold text-slate-900 dark:text-slate-100 leading-tight">
            {currentMeta.title}
          </h1>
          <p className="text-[11px] text-slate-500 dark:text-slate-400 hidden sm:block">
            {currentMeta.description}
          </p>
        </div>
      </div>

      {/* Right: Status Indicators & Actions */}
      <div className="flex items-center gap-2 sm:gap-3">
        {/* Backend & Scheduler Pills */}
        <div className="hidden xl:flex items-center gap-2">
          {/* Backend Status */}
          <div
            className={`flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-medium border ${
              isHealthError
                ? 'bg-rose-50 text-rose-700 border-rose-200 dark:bg-rose-950/40 dark:text-rose-300 dark:border-rose-900'
                : 'bg-emerald-50 text-emerald-700 border-emerald-200 dark:bg-emerald-950/40 dark:text-emerald-300 dark:border-emerald-800'
            }`}
          >
            {isHealthError ? (
              <>
                <AlertCircle className="w-3.5 h-3.5" />
                <span>Backend Offline</span>
              </>
            ) : (
              <>
                <CheckCircle2 className="w-3.5 h-3.5" />
                <span>Flask 5000</span>
              </>
            )}
          </div>

          {/* Scheduler Status */}
          <div className="flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-medium bg-slate-100 dark:bg-slate-800 text-slate-700 dark:text-slate-300 border border-slate-200 dark:border-slate-700">
            <Radio
              className={`w-3.5 h-3.5 ${
                schedulerActive ? 'text-emerald-500 animate-pulse' : 'text-slate-400'
              }`}
            />
            <span>Scheduler: {schedulerActive ? 'Activo' : 'Pausado'}</span>
          </div>

          {/* Last Sync */}
          {lastSyncDate && (
            <div className="flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs text-slate-600 dark:text-slate-400 bg-slate-50 dark:bg-brand-charcoal-card border border-slate-200 dark:border-slate-700">
              <Clock className="w-3.5 h-3.5 text-slate-400" />
              <span>Sinc: {formatDate(lastSyncDate)}</span>
            </div>
          )}
        </div>

        {/* Admin Key Button */}
        <button
          onClick={openModal}
          className={`flex items-center gap-1.5 px-2.5 py-1.5 rounded-lg text-xs font-semibold border transition-all cursor-pointer ${
            isAuthenticated
              ? 'bg-emerald-50 text-emerald-700 border-emerald-300 dark:bg-emerald-950/40 dark:text-emerald-300 dark:border-emerald-700 hover:bg-emerald-100'
              : 'bg-amber-50 text-amber-800 border-amber-300 dark:bg-amber-950/40 dark:text-amber-200 dark:border-amber-700 hover:bg-amber-100'
          }`}
          title={isAuthenticated ? 'Clave de administración activa' : 'Configurar ADMIN_API_KEY'}
        >
          {isAuthenticated ? (
            <>
              <ShieldCheck className="w-3.5 h-3.5 text-emerald-600 dark:text-emerald-400" />
              <span className="hidden sm:inline">Admin Activo</span>
            </>
          ) : (
            <>
              <KeyRound className="w-3.5 h-3.5 text-amber-600 dark:text-amber-400" />
              <span className="hidden sm:inline">Clave Admin</span>
            </>
          )}
        </button>

        {/* Refresh Button */}
        <button
          onClick={handleRefreshAll}
          disabled={isFetching}
          className="p-2 text-slate-600 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-slate-800 rounded-lg transition-colors border border-slate-200 dark:border-slate-700 cursor-pointer disabled:opacity-50"
          title="Actualizar datos ahora"
        >
          <RotateCw className={`w-4 h-4 ${isFetching ? 'animate-spin text-brand-red' : ''}`} />
        </button>

        {/* Theme Toggle (Light / Dark) */}
        <button
          onClick={toggleTheme}
          className="p-2 text-slate-600 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-slate-800 rounded-lg transition-colors border border-slate-200 dark:border-slate-700 cursor-pointer"
          title={theme === 'dark' ? 'Cambiar a modo claro' : 'Cambiar a modo oscuro'}
        >
          {theme === 'dark' ? (
            <Sun className="w-4 h-4 text-amber-400" />
          ) : (
            <Moon className="w-4 h-4 text-slate-600" />
          )}
        </button>
      </div>
    </header>
  );
};
