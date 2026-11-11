import React, { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import {
  Bot,
  Facebook,
  Instagram,
  Clock,
  Sparkles,
  RotateCw,
  CheckCircle2,
  AlertTriangle,
  Play,
  Layers,
  Activity,
  Shield,
  KeyRound,
  FileCheck,
} from 'lucide-react';
import { ApiService } from '../services/api';
import { Card, CardHeader, CardTitle, CardContent } from '../components/ui/Card';
import { Button } from '../components/ui/Button';
import { Badge } from '../components/ui/Badge';
import { ErrorState } from '../components/ui/ErrorState';
import { useAdminAuth } from '../contexts/AdminAuthContext';
import { formatDate } from '../utils/format';
import type { SyncResult } from '../types';

export const AgentsPage: React.FC = () => {
  const queryClient = useQueryClient();
  const { adminKey, isAuthenticated, openModal } = useAdminAuth();
  const [syncFeedback, setSyncFeedback] = useState<SyncResult | null>(null);

  // Consulta de estado de agentes
  const {
    data: agentsStatus,
    isLoading,
    isError,
    refetch,
  } = useQuery({
    queryKey: ['agentsStatus'],
    queryFn: ApiService.getAgentsStatus,
    refetchInterval: 10000,
  });

  // Mutación para sincronización coordinada
  const syncMutation = useMutation({
    mutationFn: (plataforma: 'todas' | 'facebook' | 'instagram') =>
      ApiService.syncCoordinated(plataforma, adminKey),
    onSuccess: (data) => {
      setSyncFeedback(data);
      queryClient.invalidateQueries({ queryKey: ['agentsStatus'] });
      queryClient.invalidateQueries({ queryKey: ['dashboardResumen'] });
      queryClient.invalidateQueries({ queryKey: ['facebookPosts'] });
      queryClient.invalidateQueries({ queryKey: ['instagramPosts'] });
      queryClient.invalidateQueries({ queryKey: ['comments'] });
      queryClient.invalidateQueries({ queryKey: ['buyers'] });
      queryClient.invalidateQueries({ queryKey: ['audit'] });
    },
    onError: (error: any) => {
      if (error?.response?.status === 401) {
        openModal();
      }
      setSyncFeedback({
        success: false,
        error:
          error?.response?.data?.error ||
          'Error al ejecutar la sincronización coordinada. Verifique las credenciales.',
      });
    },
  });

  const fb = agentsStatus?.agente_facebook;
  const ig = agentsStatus?.agente_instagram;
  const coord = agentsStatus?.coordinador;
  const scheduler = agentsStatus?.scheduler;

  const handleSync = (plataforma: 'todas' | 'facebook' | 'instagram') => {
    if (!isAuthenticated) {
      openModal();
      return;
    }
    syncMutation.mutate(plataforma);
  };

  return (
    <div className="space-y-6 animate-in fade-in duration-200">
      {/* Banner de Acciones Administrativas */}
      <Card className="border-l-4 border-l-brand-amber">
        <CardHeader
          action={
            <div className="flex items-center gap-2">
              {!isAuthenticated && (
                <Button
                  size="sm"
                  variant="outline"
                  onClick={openModal}
                  leftIcon={<KeyRound className="w-3.5 h-3.5 text-brand-amber" />}
                >
                  Configurar ADMIN_API_KEY
                </Button>
              )}
            </div>
          }
        >
          <CardTitle>
            <Shield className="w-5 h-5 text-brand-amber" />
            Control de Sincronización Manual de Agentes
          </CardTitle>
        </CardHeader>
        <CardContent>
          <p className="text-xs text-slate-600 dark:text-slate-300 mb-4 max-w-2xl leading-relaxed">
            Ejecuta la sincronización coordinada de publicaciones, comentarios, reacciones y prospectos BUYER desde Meta Graph API hacia Microsoft SQL Server de forma segura e idempotente.
          </p>

          <div className="flex flex-wrap gap-3">
            <Button
              variant="primary"
              size="sm"
              onClick={() => handleSync('todas')}
              isLoading={syncMutation.isPending && syncMutation.variables === 'todas'}
              disabled={syncMutation.isPending}
              leftIcon={<RotateCw className="w-4 h-4" />}
            >
              Sincronizar Ambas Plataformas
            </Button>

            <Button
              variant="outline"
              size="sm"
              onClick={() => handleSync('facebook')}
              isLoading={syncMutation.isPending && syncMutation.variables === 'facebook'}
              disabled={syncMutation.isPending}
              leftIcon={<Facebook className="w-4 h-4 text-blue-600" />}
            >
              Sincronizar Facebook
            </Button>

            <Button
              variant="outline"
              size="sm"
              onClick={() => handleSync('instagram')}
              isLoading={syncMutation.isPending && syncMutation.variables === 'instagram'}
              disabled={syncMutation.isPending}
              leftIcon={<Instagram className="w-4 h-4 text-rose-600" />}
            >
              Sincronizar Instagram
            </Button>
          </div>

          {/* Feedback de resultado */}
          {syncFeedback && (
            <div
              className={`mt-4 p-4 rounded-xl border text-xs flex items-start justify-between gap-3 ${
                syncFeedback.success
                  ? 'bg-emerald-50 border-emerald-200 text-emerald-900 dark:bg-emerald-950/40 dark:border-emerald-800 dark:text-emerald-200'
                  : 'bg-rose-50 border-rose-200 text-rose-900 dark:bg-rose-950/40 dark:border-rose-800 dark:text-rose-200'
              }`}
            >
              <div className="space-y-1">
                <div className="flex items-center gap-2 font-bold text-sm">
                  {syncFeedback.success ? (
                    <>
                      <CheckCircle2 className="w-4 h-4 text-emerald-600" />
                      Sincronización finalizada exitosamente
                    </>
                  ) : (
                    <>
                      <AlertTriangle className="w-4 h-4 text-rose-600" />
                      Error en la sincronización
                    </>
                  )}
                  {syncFeedback.duracion_segundos && (
                    <span className="text-xs font-mono font-normal opacity-75">
                      ({syncFeedback.duracion_segundos}s)
                    </span>
                  )}
                </div>

                {syncFeedback.resumen_total && (
                  <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 pt-2 text-[11px]">
                    <div className="p-2 rounded bg-white/70 dark:bg-black/30 border border-slate-200/50 dark:border-slate-700/50">
                      <span className="font-semibold block">Publicaciones:</span>
                      <span>
                        +{syncFeedback.resumen_total.publicaciones?.nuevos ?? 0} nuevas,{' '}
                        {syncFeedback.resumen_total.publicaciones?.actualizados ?? 0} act.
                      </span>
                    </div>
                    <div className="p-2 rounded bg-white/70 dark:bg-black/30 border border-slate-200/50 dark:border-slate-700/50">
                      <span className="font-semibold block">Comentarios:</span>
                      <span>
                        +{syncFeedback.resumen_total.comentarios?.nuevos ?? 0} nuevos,{' '}
                        {syncFeedback.resumen_total.comentarios?.actualizados ?? 0} act.
                      </span>
                    </div>
                    <div className="p-2 rounded bg-white/70 dark:bg-black/30 border border-slate-200/50 dark:border-slate-700/50">
                      <span className="font-semibold block">Métricas Diarias:</span>
                      <span>
                        +{syncFeedback.resumen_total.metricas?.nuevos ?? 0} registradas
                      </span>
                    </div>
                    <div className="p-2 rounded bg-white/70 dark:bg-black/30 border border-slate-200/50 dark:border-slate-700/50">
                      <span className="font-semibold block">BUYERS:</span>
                      <span>
                        +{syncFeedback.resumen_total.buyers?.nuevos ?? 0} identificados
                      </span>
                    </div>
                  </div>
                )}

                {syncFeedback.error && (
                  <p className="text-rose-700 dark:text-rose-300 font-medium pt-1">
                    {syncFeedback.error}
                  </p>
                )}
              </div>

              <button
                onClick={() => setSyncFeedback(null)}
                className="font-bold hover:underline"
              >
                Cerrar
              </button>
            </div>
          )}
        </CardContent>
      </Card>

      {/* Grid de Tarjetas de Monitoreo de Agentes */}
      {isError ? (
        <ErrorState
          title="Error al consultar estado de agentes"
          onRetry={() => refetch()}
        />
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {/* 1. BuyerCoordinator */}
          <Card className="flex flex-col justify-between">
            <CardHeader>
              <CardTitle>
                <Bot className="w-5 h-5 text-brand-red" />
                BuyerCoordinator
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-3">
              <div className="flex items-center justify-between text-xs">
                <span className="text-slate-500">Estado de Ejecución:</span>
                <span
                  className={`px-2 py-0.5 rounded text-[10px] font-bold ${
                    coord?.estado === 'OCUPADO'
                      ? 'bg-amber-100 text-amber-800'
                      : 'bg-emerald-100 text-emerald-800 dark:bg-emerald-950 dark:text-emerald-300'
                  }`}
                >
                  {coord?.estado || 'IDLE (Listo)'}
                </span>
              </div>

              <div className="flex items-center justify-between text-xs">
                <span className="text-slate-500">Última Ejecución:</span>
                <span className="font-mono text-slate-700 dark:text-slate-300">
                  {formatDate(coord?.ultima_sincronizacion)}
                </span>
              </div>

              <div className="flex items-center justify-between text-xs">
                <span className="text-slate-500">Último Resultado:</span>
                <span className="font-semibold text-emerald-600 dark:text-emerald-400">
                  {coord?.ultimo_resultado || 'EXITOSO'}
                </span>
              </div>

              <div className="p-3 rounded-xl bg-slate-50 dark:bg-brand-charcoal border border-slate-200 dark:border-brand-charcoal-border text-[11px] text-slate-500">
                Orquesta las tareas de AgenteFacebook y AgenteInstagram, control de concurrencia y transacciones SQL Server.
              </div>
            </CardContent>
          </Card>

          {/* 2. Agente Facebook */}
          <Card className="flex flex-col justify-between">
            <CardHeader>
              <CardTitle>
                <Facebook className="w-5 h-5 text-blue-600" />
                Agente Facebook
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-3">
              <div className="flex items-center justify-between text-xs">
                <span className="text-slate-500">Conexión Meta Graph:</span>
                <span
                  className={`px-2 py-0.5 rounded text-[10px] font-bold ${
                    fb?.conectado
                      ? 'bg-emerald-100 text-emerald-800 dark:bg-emerald-950 dark:text-emerald-300'
                      : 'bg-rose-100 text-rose-800 dark:bg-rose-950 dark:text-rose-300'
                  }`}
                >
                  {fb?.conectado ? 'Conectado v27.0' : 'Desconectado'}
                </span>
              </div>

              <div className="flex items-center justify-between text-xs">
                <span className="text-slate-500">Página Asignada:</span>
                <span className="font-semibold text-slate-700 dark:text-slate-300 truncate max-w-[160px]">
                  {fb?.page_name || 'Parrilladas El Establo'}
                </span>
              </div>

              <div className="flex items-center justify-between text-xs">
                <span className="text-slate-500">Page ID:</span>
                <span className="font-mono text-slate-700 dark:text-slate-300">
                  {fb?.page_id || '1341560062384618'}
                </span>
              </div>

              <div className="p-3 rounded-xl bg-slate-50 dark:bg-brand-charcoal border border-slate-200 dark:border-brand-charcoal-border text-[11px] text-slate-500">
                Extracción incremental de publicaciones, comentarios e interacciones de la FanPage oficial.
              </div>
            </CardContent>
          </Card>

          {/* 3. Agente Instagram */}
          <Card className="flex flex-col justify-between">
            <CardHeader>
              <CardTitle>
                <Instagram className="w-5 h-5 text-rose-600" />
                Agente Instagram
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-3">
              <div className="flex items-center justify-between text-xs">
                <span className="text-slate-500">Conexión Meta Graph:</span>
                <span
                  className={`px-2 py-0.5 rounded text-[10px] font-bold ${
                    ig?.conectado
                      ? 'bg-emerald-100 text-emerald-800 dark:bg-emerald-950 dark:text-emerald-300'
                      : 'bg-rose-100 text-rose-800 dark:bg-rose-950 dark:text-rose-300'
                  }`}
                >
                  {ig?.conectado ? 'Conectado v27.0' : 'Desconectado'}
                </span>
              </div>

              <div className="flex items-center justify-between text-xs">
                <span className="text-slate-500">Cuenta Instagram:</span>
                <span className="font-semibold text-slate-700 dark:text-slate-300">
                  {ig?.username ? `@${ig.username}` : '@elestabloparrilladas'}
                </span>
              </div>

              <div className="flex items-center justify-between text-xs">
                <span className="text-slate-500">IG Account ID:</span>
                <span className="font-mono text-slate-700 dark:text-slate-300">
                  {ig?.account_id ? `${String(ig.account_id).slice(0, 8)}...` : '1784...'}
                </span>
              </div>

              <div className="p-3 rounded-xl bg-slate-50 dark:bg-brand-charcoal border border-slate-200 dark:border-brand-charcoal-border text-[11px] text-slate-500">
                Extracción de media, reels, comentarios y captación de prospectos en Instagram Business.
              </div>
            </CardContent>
          </Card>

          {/* 4. Clasificador de Intención */}
          <Card className="flex flex-col justify-between">
            <CardHeader>
              <CardTitle>
                <Sparkles className="w-5 h-5 text-brand-amber" />
                Clasificador de Intención
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-3">
              <div className="flex items-center justify-between text-xs">
                <span className="text-slate-500">Estado:</span>
                <span className="px-2 py-0.5 rounded text-[10px] font-bold bg-emerald-100 text-emerald-800 dark:bg-emerald-950 dark:text-emerald-300">
                  Activo (En memoria)
                </span>
              </div>

              <div className="flex items-center justify-between text-xs">
                <span className="text-slate-500">Motor de Reglas:</span>
                <span className="font-semibold text-slate-700 dark:text-slate-300">
                  Semántica & Expresiones
                </span>
              </div>

              <div className="flex items-center justify-between text-xs">
                <span className="text-slate-500">Categorías Soportadas:</span>
                <span className="font-mono text-slate-700 dark:text-slate-300">
                  7 Categorías
                </span>
              </div>

              <div className="p-3 rounded-xl bg-slate-50 dark:bg-brand-charcoal border border-slate-200 dark:border-brand-charcoal-border text-[11px] text-slate-500">
                Categoriza consultas en precio, producto, promoción, ubicación, horario, reserva y general.
              </div>
            </CardContent>
          </Card>

          {/* 5. APScheduler */}
          <Card className="flex flex-col justify-between md:col-span-2">
            <CardHeader>
              <CardTitle>
                <Clock className="w-5 h-5 text-emerald-600" />
                Planificador de Automatización (APScheduler)
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-3">
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 text-xs">
                <div className="p-3 rounded-xl bg-slate-50 dark:bg-brand-charcoal border border-slate-200 dark:border-brand-charcoal-border">
                  <span className="text-slate-400 block mb-0.5">Estado del Servicio:</span>
                  <span className="font-bold text-emerald-600 dark:text-emerald-400 flex items-center gap-1.5">
                    <Activity className="w-4 h-4 animate-pulse" />
                    {scheduler?.activo ? 'En Ejecución Periódica' : 'Inactivo'}
                  </span>
                </div>

                <div className="p-3 rounded-xl bg-slate-50 dark:bg-brand-charcoal border border-slate-200 dark:border-brand-charcoal-border">
                  <span className="text-slate-400 block mb-0.5">Intervalo Configurado:</span>
                  <span className="font-mono font-bold text-slate-800 dark:text-slate-200">
                    {scheduler?.intervalo_minutos ? `${scheduler.intervalo_minutos} min` : '60 seg'}
                  </span>
                </div>

                <div className="p-3 rounded-xl bg-slate-50 dark:bg-brand-charcoal border border-slate-200 dark:border-brand-charcoal-border">
                  <span className="text-slate-400 block mb-0.5">Job ID Programado:</span>
                  <span className="font-mono text-slate-700 dark:text-slate-300 text-[11px]">
                    {scheduler?.job_id || 'meta_periodic_sync'}
                  </span>
                </div>

                <div className="p-3 rounded-xl bg-slate-50 dark:bg-brand-charcoal border border-slate-200 dark:border-brand-charcoal-border">
                  <span className="text-slate-400 block mb-0.5">Próxima Ejecución:</span>
                  <span className="font-mono text-slate-700 dark:text-slate-300 text-[11px]">
                    {formatDate(scheduler?.proxima_ejecucion)}
                  </span>
                </div>
              </div>
            </CardContent>
          </Card>
        </div>
      )}
    </div>
  );
};
