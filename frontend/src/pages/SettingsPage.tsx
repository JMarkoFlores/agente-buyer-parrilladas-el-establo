import React from 'react';
import { useQuery } from '@tanstack/react-query';
import {
  Settings,
  Database,
  Server,
  Facebook,
  Instagram,
  Clock,
  Sun,
  Moon,
  KeyRound,
  ShieldCheck,
  CheckCircle2,
  AlertTriangle,
  Info,
  Radio,
  Lock,
} from 'lucide-react';
import { ApiService } from '../services/api';
import { Card, CardHeader, CardTitle, CardContent } from '../components/ui/Card';
import { Button } from '../components/ui/Button';
import { Badge } from '../components/ui/Badge';
import { useTheme } from '../contexts/ThemeContext';
import { useAdminAuth } from '../contexts/AdminAuthContext';
import { formatDate } from '../utils/format';

export const SettingsPage: React.FC = () => {
  const { theme, toggleTheme, setTheme } = useTheme();
  const { isAuthenticated, openModal, clearAdminKey } = useAdminAuth();

  // Diagnóstico de SQL Server
  const { data: dbStatus, isLoading: isDbLoading } = useQuery({
    queryKey: ['dbStatus'],
    queryFn: ApiService.getDbStatus,
    refetchInterval: 30000,
  });

  // Salud del backend Flask
  const { data: health, isLoading: isHealthLoading } = useQuery({
    queryKey: ['health'],
    queryFn: ApiService.getHealth,
    refetchInterval: 30000,
  });

  // Estado de los agentes y scheduler
  const { data: agentsStatus } = useQuery({
    queryKey: ['agentsStatus'],
    queryFn: ApiService.getAgentsStatus,
    refetchInterval: 15000,
  });

  const scheduler = agentsStatus?.scheduler;
  const fb = agentsStatus?.agente_facebook;
  const ig = agentsStatus?.agente_instagram;

  return (
    <div className="space-y-6 animate-in fade-in duration-200">
      {/* 1. SECCIÓN: CONEXIONES DEL SISTEMA */}
      <Card>
        <CardHeader>
          <CardTitle>
            <Server className="w-5 h-5 text-brand-red" />
            1. Estado de Conexiones del Ecosistema
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
            {/* Backend Flask */}
            <div className="p-4 rounded-xl border border-slate-200 dark:border-brand-charcoal-border bg-slate-50/50 dark:bg-brand-charcoal/40 flex flex-col justify-between">
              <div>
                <div className="flex items-center justify-between mb-2">
                  <span className="text-xs font-bold text-slate-800 dark:text-slate-200 flex items-center gap-1.5">
                    <Server className="w-4 h-4 text-emerald-600" />
                    Backend Flask
                  </span>
                  <span
                    className={`px-2 py-0.5 rounded text-[10px] font-bold ${
                      health?.status === 'healthy'
                        ? 'bg-emerald-100 text-emerald-800 dark:bg-emerald-950 dark:text-emerald-300'
                        : 'bg-rose-100 text-rose-800'
                    }`}
                  >
                    {health?.status === 'healthy' ? 'Online' : 'Offline'}
                  </span>
                </div>
                <p className="text-xs text-slate-500 dark:text-slate-400">
                  Puerto local: <code className="font-mono text-slate-700 dark:text-slate-300">5000</code>
                </p>
              </div>
              <div className="mt-3 pt-2 border-t border-slate-200 dark:border-slate-700 text-[11px] text-slate-500">
                Versión API: {health?.version || '1.0.0'}
              </div>
            </div>

            {/* Microsoft SQL Server */}
            <div className="p-4 rounded-xl border border-slate-200 dark:border-brand-charcoal-border bg-slate-50/50 dark:bg-brand-charcoal/40 flex flex-col justify-between">
              <div>
                <div className="flex items-center justify-between mb-2">
                  <span className="text-xs font-bold text-slate-800 dark:text-slate-200 flex items-center gap-1.5">
                    <Database className="w-4 h-4 text-blue-600" />
                    SQL Server
                  </span>
                  <span
                    className={`px-2 py-0.5 rounded text-[10px] font-bold ${
                      dbStatus?.status === 'connected'
                        ? 'bg-emerald-100 text-emerald-800 dark:bg-emerald-950 dark:text-emerald-300'
                        : 'bg-amber-100 text-amber-800 dark:bg-amber-950 dark:text-amber-300'
                    }`}
                  >
                    {dbStatus?.status === 'connected' ? 'Conectado' : 'Sin conexión'}
                  </span>
                </div>
                <p className="text-xs text-slate-500 dark:text-slate-400">
                  Base: <code className="font-mono text-slate-700 dark:text-slate-300">{dbStatus?.database || 'buyer'}</code>
                </p>
              </div>
              <div className="mt-3 pt-2 border-t border-slate-200 dark:border-slate-700 text-[11px] text-slate-500 flex justify-between">
                <span>Tablas dbo:</span>
                <span className="font-mono font-bold text-slate-700 dark:text-slate-300">
                  {dbStatus?.dbo_tables_count ?? 22} / 22
                </span>
              </div>
            </div>

            {/* Facebook Graph API */}
            <div className="p-4 rounded-xl border border-slate-200 dark:border-brand-charcoal-border bg-slate-50/50 dark:bg-brand-charcoal/40 flex flex-col justify-between">
              <div>
                <div className="flex items-center justify-between mb-2">
                  <span className="text-xs font-bold text-slate-800 dark:text-slate-200 flex items-center gap-1.5">
                    <Facebook className="w-4 h-4 text-blue-600" />
                    Facebook Graph
                  </span>
                  <span
                    className={`px-2 py-0.5 rounded text-[10px] font-bold ${
                      fb?.conectado
                        ? 'bg-emerald-100 text-emerald-800 dark:bg-emerald-950 dark:text-emerald-300'
                        : 'bg-rose-100 text-rose-800'
                    }`}
                  >
                    {fb?.conectado ? 'v27.0 OK' : 'Pendiente'}
                  </span>
                </div>
                <p className="text-xs text-slate-500 dark:text-slate-400 truncate">
                  Página: {fb?.page_name || 'Parrilladas El Establo'}
                </p>
              </div>
              <div className="mt-3 pt-2 border-t border-slate-200 dark:border-slate-700 text-[11px] text-slate-500 flex justify-between">
                <span>Page ID:</span>
                <span className="font-mono">{fb?.page_id || '1341560062384618'}</span>
              </div>
            </div>

            {/* Instagram Graph API */}
            <div className="p-4 rounded-xl border border-slate-200 dark:border-brand-charcoal-border bg-slate-50/50 dark:bg-brand-charcoal/40 flex flex-col justify-between">
              <div>
                <div className="flex items-center justify-between mb-2">
                  <span className="text-xs font-bold text-slate-800 dark:text-slate-200 flex items-center gap-1.5">
                    <Instagram className="w-4 h-4 text-rose-600" />
                    Instagram Graph
                  </span>
                  <span
                    className={`px-2 py-0.5 rounded text-[10px] font-bold ${
                      ig?.conectado
                        ? 'bg-emerald-100 text-emerald-800 dark:bg-emerald-950 dark:text-emerald-300'
                        : 'bg-rose-100 text-rose-800'
                    }`}
                  >
                    {ig?.conectado ? 'v27.0 OK' : 'Pendiente'}
                  </span>
                </div>
                <p className="text-xs text-slate-500 dark:text-slate-400 truncate">
                  Usuario: {ig?.username ? `@${ig.username}` : '@elestabloparrilladas'}
                </p>
              </div>
              <div className="mt-3 pt-2 border-t border-slate-200 dark:border-slate-700 text-[11px] text-slate-500 flex justify-between">
                <span>Account ID:</span>
                <span className="font-mono">{ig?.account_id ? `${String(ig.account_id).slice(0, 6)}...` : '1784...'}</span>
              </div>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* 2. SECCIÓN: AUTOMATIZACIÓN & SCHEDULER */}
      <Card>
        <CardHeader>
          <CardTitle>
            <Clock className="w-5 h-5 text-brand-amber" />
            2. Automatización y Programación (APScheduler)
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4 text-xs">
            <div className="p-4 rounded-xl bg-slate-50 dark:bg-brand-charcoal border border-slate-200 dark:border-brand-charcoal-border">
              <span className="text-slate-400 block mb-1">Estado de Sincronización Automática:</span>
              <span className="font-bold text-sm text-emerald-600 dark:text-emerald-400 flex items-center gap-2">
                <Radio className="w-4 h-4 animate-pulse" />
                {scheduler?.activo ? 'Activo (En segundo plano)' : 'Inactivo'}
              </span>
            </div>

            <div className="p-4 rounded-xl bg-slate-50 dark:bg-brand-charcoal border border-slate-200 dark:border-brand-charcoal-border">
              <span className="text-slate-400 block mb-1">Intervalo Configurado:</span>
              <span className="font-bold text-sm text-slate-900 dark:text-slate-100 font-mono">
                {scheduler?.intervalo_minutos ? `${scheduler.intervalo_minutos} minutos` : '60 segundos'}
              </span>
              <span className="text-[10px] text-slate-400 block mt-0.5">
                Origen: {scheduler?.origen_intervalo || 'Configuración Backend'}
              </span>
            </div>

            <div className="p-4 rounded-xl bg-slate-50 dark:bg-brand-charcoal border border-slate-200 dark:border-brand-charcoal-border">
              <span className="text-slate-400 block mb-1">Próxima Ejecución:</span>
              <span className="font-bold text-sm text-slate-900 dark:text-slate-100 font-mono">
                {formatDate(scheduler?.proxima_ejecucion)}
              </span>
            </div>
          </div>
          <p className="text-[11px] text-slate-400 mt-3 italic">
            * El frontend visualiza el planificador en tiempo real. Por seguridad, las modificaciones al intervalo del backend se administran mediante variables de entorno en el servidor Flask.
          </p>
        </CardContent>
      </Card>

      {/* 3. SECCIÓN: PREFERENCIAS & TEMA */}
      <Card>
        <CardHeader>
          <CardTitle>
            <Sun className="w-5 h-5 text-brand-amber" />
            3. Preferencias de la Interfaz Visual
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            {/* Modo Claro / Oscuro */}
            <div>
              <label className="block text-xs font-bold text-slate-700 dark:text-slate-300 uppercase mb-2">
                Tema de Color
              </label>
              <div className="flex gap-3">
                <button
                  onClick={() => setTheme('light')}
                  className={`flex-1 p-3 rounded-xl border flex items-center justify-center gap-2 text-xs font-semibold cursor-pointer transition-all ${
                    theme === 'light'
                      ? 'border-brand-red bg-rose-50 text-brand-red shadow-sm'
                      : 'border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800 text-slate-600 dark:text-slate-300'
                  }`}
                >
                  <Sun className="w-4 h-4 text-amber-500" />
                  Modo Claro
                </button>
                <button
                  onClick={() => setTheme('dark')}
                  className={`flex-1 p-3 rounded-xl border flex items-center justify-center gap-2 text-xs font-semibold cursor-pointer transition-all ${
                    theme === 'dark'
                      ? 'border-brand-red bg-brand-charcoal text-white shadow-sm'
                      : 'border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-800 text-slate-600 dark:text-slate-300'
                  }`}
                >
                  <Moon className="w-4 h-4 text-amber-400" />
                  Modo Oscuro
                </button>
              </div>
            </div>

            {/* Actualización Automática */}
            <div>
              <label className="block text-xs font-bold text-slate-700 dark:text-slate-300 uppercase mb-2">
                Actualización Automática (TanStack Query)
              </label>
              <div className="p-3 rounded-xl bg-slate-50 dark:bg-brand-charcoal border border-slate-200 dark:border-brand-charcoal-border text-xs text-slate-600 dark:text-slate-300">
                <div className="flex items-center justify-between mb-1">
                  <span className="font-semibold">Caché & Refresco React:</span>
                  <span className="font-bold text-emerald-600 dark:text-emerald-400">Activo</span>
                </div>
                <p className="text-[11px] text-slate-400">
                  Agentes: 10s | Resumen: 15s | Comentarios: 10s | Publicaciones: 30s
                </p>
              </div>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* 4. SECCIÓN: SEGURIDAD ADMINISTRATIVA */}
      <Card>
        <CardHeader
          action={
            <Button
              size="sm"
              variant="outline"
              onClick={openModal}
              leftIcon={<KeyRound className="w-3.5 h-3.5 text-brand-amber" />}
            >
              {isAuthenticated ? 'Cambiar Clave' : 'Configurar Clave'}
            </Button>
          }
        >
          <CardTitle>
            <Lock className="w-5 h-5 text-brand-red" />
            4. Seguridad & Token de Administración
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-3">
          <div className="flex items-center justify-between p-3.5 rounded-xl bg-slate-50 dark:bg-brand-charcoal border border-slate-200 dark:border-brand-charcoal-border text-xs">
            <div>
              <span className="font-bold text-slate-800 dark:text-slate-200 block mb-0.5">
                Estado de Autorización Administrativa:
              </span>
              <p className="text-[11px] text-slate-500">
                {isAuthenticated
                  ? 'Clave cargada en la sesión actual. Habilita los botones de sincronización manual.'
                  : 'Sin clave configurada en sesión. Las sincronizaciones requerirán confirmación.'}
              </p>
            </div>
            {isAuthenticated ? (
              <span className="inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-xs font-bold bg-emerald-100 text-emerald-800 dark:bg-emerald-950 dark:text-emerald-300">
                <ShieldCheck className="w-3.5 h-3.5 text-emerald-600" />
                Activo
              </span>
            ) : (
              <span className="inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-xs font-bold bg-amber-100 text-amber-800 dark:bg-amber-950 dark:text-amber-300">
                <AlertTriangle className="w-3.5 h-3.5 text-amber-600" />
                No configurado
              </span>
            )}
          </div>

          <div className="p-3.5 rounded-xl bg-amber-50/60 dark:bg-amber-950/20 border border-amber-200 dark:border-amber-900/40 text-xs text-amber-900 dark:text-amber-200 flex gap-2.5">
            <Info className="w-4 h-4 text-brand-amber flex-shrink-0 mt-0.5" />
            <p className="leading-relaxed">
              <strong>Protección de Credenciales:</strong> Los secretos de la aplicación (<code>META_APP_SECRET</code>, <code>META_PAGE_ACCESS_TOKEN</code>, credenciales de SQL Server) permanecen protegidos exclusivamente en el backend Flask y nunca son expuestos ni transmitidos al navegador.
            </p>
          </div>
        </CardContent>
      </Card>

      {/* 5. INFORMACIÓN DEL PROYECTO */}
      <Card>
        <CardHeader>
          <CardTitle>
            <Info className="w-5 h-5 text-slate-600" />
            5. Información del Proyecto Académico
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-2 text-xs">
            <div className="flex flex-col sm:flex-row sm:items-center justify-between py-1.5 border-b border-slate-100 dark:border-brand-charcoal-border">
              <span className="text-slate-400">Proyecto:</span>
              <span className="font-semibold text-slate-800 dark:text-slate-200">
                Agente Inteligente Multicanal para la Captación y Conversión de BUYERS
              </span>
            </div>
            <div className="flex flex-col sm:flex-row sm:items-center justify-between py-1.5 border-b border-slate-100 dark:border-brand-charcoal-border">
              <span className="text-slate-400">Empresa / Caso de Estudio:</span>
              <span className="font-semibold text-slate-800 dark:text-slate-200">
                Parrilladas El Establo
              </span>
            </div>
            <div className="flex items-center justify-between py-1.5 border-b border-slate-100 dark:border-brand-charcoal-border">
              <span className="text-slate-400">Frontend Stack:</span>
              <span className="font-mono text-slate-700 dark:text-slate-300">
                React 18 + TypeScript + Vite + Tailwind CSS + TanStack Query
              </span>
            </div>
            <div className="flex items-center justify-between py-1.5">
              <span className="text-slate-400">Backend Stack:</span>
              <span className="font-mono text-slate-700 dark:text-slate-300">
                Python Flask + SQLAlchemy + Microsoft SQL Server (22 tablas)
              </span>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  );
};
