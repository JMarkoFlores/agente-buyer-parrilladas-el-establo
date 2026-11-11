import React from 'react';
import { Facebook, Instagram, Bot, Clock, CheckCircle2, AlertTriangle } from 'lucide-react';
import { Card, CardHeader, CardTitle, CardContent } from '../ui/Card';
import { formatDate } from '../../utils/format';
import type { DashboardResumen } from '../../types';

interface AgentStatusCardsProps {
  data?: DashboardResumen;
}

export const AgentStatusCards: React.FC<AgentStatusCardsProps> = ({ data }) => {
  const fb = data?.estado_agentes?.facebook;
  const ig = data?.estado_agentes?.instagram;
  const coord = data?.estado_agentes?.coordinador;
  const scheduler = data?.estado_agentes?.scheduler;
  const ultima = data?.ultima_sincronizacion;

  return (
    <Card className="h-full">
      <CardHeader
        action={
          ultima?.fecha ? (
            <span className="text-xs text-slate-500 dark:text-slate-400 flex items-center gap-1.5 font-mono">
              <Clock className="w-3.5 h-3.5 text-slate-400" />
              Última sinc: {formatDate(ultima.fecha)}
            </span>
          ) : null
        }
      >
        <CardTitle>
          <Bot className="w-5 h-5 text-brand-red" />
          Estado de los Agentes Autónomos
        </CardTitle>
      </CardHeader>
      <CardContent>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
          {/* Agente Facebook */}
          <div className="p-4 rounded-xl border border-slate-200 dark:border-brand-charcoal-border bg-slate-50/60 dark:bg-brand-charcoal/50 flex flex-col justify-between">
            <div>
              <div className="flex items-center justify-between mb-2">
                <span className="text-xs font-bold text-slate-700 dark:text-slate-200 flex items-center gap-1.5">
                  <Facebook className="w-4 h-4 text-blue-600" />
                  Agente Facebook
                </span>
                <span
                  className={`inline-flex items-center px-2 py-0.5 rounded text-[10px] font-semibold border ${
                    fb?.conectado
                      ? 'bg-emerald-50 text-emerald-700 border-emerald-200 dark:bg-emerald-950/40 dark:text-emerald-300 dark:border-emerald-800'
                      : 'bg-rose-50 text-rose-700 border-rose-200 dark:bg-rose-950/40 dark:text-rose-300 dark:border-rose-800'
                  }`}
                >
                  {fb?.conectado ? 'Conectado' : 'Sin conexión'}
                </span>
              </div>
              <p className="text-xs text-slate-500 dark:text-slate-400 truncate">
                {fb?.page_name || 'Parrilladas El Establo'}
              </p>
            </div>
            <div className="mt-3 pt-2.5 border-t border-slate-200/60 dark:border-slate-700/60 flex items-center justify-between text-[11px] text-slate-500 dark:text-slate-400">
              <span>Graph API:</span>
              <span className="font-mono font-medium">v27.0</span>
            </div>
          </div>

          {/* Agente Instagram */}
          <div className="p-4 rounded-xl border border-slate-200 dark:border-brand-charcoal-border bg-slate-50/60 dark:bg-brand-charcoal/50 flex flex-col justify-between">
            <div>
              <div className="flex items-center justify-between mb-2">
                <span className="text-xs font-bold text-slate-700 dark:text-slate-200 flex items-center gap-1.5">
                  <Instagram className="w-4 h-4 text-rose-600" />
                  Agente Instagram
                </span>
                <span
                  className={`inline-flex items-center px-2 py-0.5 rounded text-[10px] font-semibold border ${
                    ig?.conectado
                      ? 'bg-emerald-50 text-emerald-700 border-emerald-200 dark:bg-emerald-950/40 dark:text-emerald-300 dark:border-emerald-800'
                      : 'bg-rose-50 text-rose-700 border-rose-200 dark:bg-rose-950/40 dark:text-rose-300 dark:border-rose-800'
                  }`}
                >
                  {ig?.conectado ? 'Conectado' : 'Sin conexión'}
                </span>
              </div>
              <p className="text-xs text-slate-500 dark:text-slate-400 truncate">
                {ig?.username ? `@${ig.username}` : '@elestabloparrilladas'}
              </p>
            </div>
            <div className="mt-3 pt-2.5 border-t border-slate-200/60 dark:border-slate-700/60 flex items-center justify-between text-[11px] text-slate-500 dark:text-slate-400">
              <span>Cuenta IG:</span>
              <span className="font-mono font-medium">{ig?.account_id ? `${String(ig.account_id).slice(0, 6)}...` : '1784...'}</span>
            </div>
          </div>

          {/* BuyerCoordinator */}
          <div className="p-4 rounded-xl border border-slate-200 dark:border-brand-charcoal-border bg-slate-50/60 dark:bg-brand-charcoal/50 flex flex-col justify-between">
            <div>
              <div className="flex items-center justify-between mb-2">
                <span className="text-xs font-bold text-slate-700 dark:text-slate-200 flex items-center gap-1.5">
                  <Bot className="w-4 h-4 text-slate-700 dark:text-slate-300" />
                  Coordinador
                </span>
                <span
                  className={`inline-flex items-center px-2 py-0.5 rounded text-[10px] font-semibold border ${
                    coord?.estado === 'OCUPADO'
                      ? 'bg-amber-50 text-amber-700 border-amber-200 dark:bg-amber-950/40 dark:text-amber-300'
                      : 'bg-slate-100 text-slate-700 border-slate-200 dark:bg-slate-800 dark:text-slate-300'
                  }`}
                >
                  {coord?.estado || 'IDLE'}
                </span>
              </div>
              <p className="text-xs text-slate-500 dark:text-slate-400">
                Orquestador de captación & clasificación
              </p>
            </div>
            <div className="mt-3 pt-2.5 border-t border-slate-200/60 dark:border-slate-700/60 flex items-center justify-between text-[11px] text-slate-500 dark:text-slate-400">
              <span>Resultado:</span>
              <span className="font-semibold text-emerald-600 dark:text-emerald-400 flex items-center gap-1">
                {coord?.ultimo_resultado === 'EXITOSO' || ultima?.resultado === 'EXITOSO' ? (
                  <>
                    <CheckCircle2 className="w-3 h-3" />
                    EXITOSO
                  </>
                ) : (
                  coord?.ultimo_resultado || 'OK'
                )}
              </span>
            </div>
          </div>

          {/* APScheduler */}
          <div className="p-4 rounded-xl border border-slate-200 dark:border-brand-charcoal-border bg-slate-50/60 dark:bg-brand-charcoal/50 flex flex-col justify-between">
            <div>
              <div className="flex items-center justify-between mb-2">
                <span className="text-xs font-bold text-slate-700 dark:text-slate-200 flex items-center gap-1.5">
                  <Clock className="w-4 h-4 text-brand-amber" />
                  APScheduler
                </span>
                <span
                  className={`inline-flex items-center px-2 py-0.5 rounded text-[10px] font-semibold border ${
                    scheduler?.activo
                      ? 'bg-emerald-50 text-emerald-700 border-emerald-200 dark:bg-emerald-950/40 dark:text-emerald-300'
                      : 'bg-slate-100 text-slate-600 border-slate-200 dark:bg-slate-800 dark:text-slate-400'
                  }`}
                >
                  {scheduler?.activo ? 'En Ejecución' : 'Inactivo'}
                </span>
              </div>
              <p className="text-xs text-slate-500 dark:text-slate-400">
                Intervalo: {scheduler?.intervalo_minutos ? `${scheduler.intervalo_minutos} min` : '60 seg'}
              </p>
            </div>
            <div className="mt-3 pt-2.5 border-t border-slate-200/60 dark:border-slate-700/60 flex items-center justify-between text-[11px] text-slate-500 dark:text-slate-400">
              <span>Automatización:</span>
              <span className="font-medium text-slate-700 dark:text-slate-300">
                {scheduler?.activo ? 'Auto-sync' : 'Manual'}
              </span>
            </div>
          </div>
        </div>
      </CardContent>
    </Card>
  );
};
