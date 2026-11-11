import React, { useState, useMemo } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import {
  MessageSquareReply,
  Facebook,
  Instagram,
  Search,
  Filter,
  CheckCircle2,
  XCircle,
  Clock,
  Sparkles,
  Send,
  RotateCw,
  Eye,
  Edit3,
  AlertTriangle,
  ExternalLink,
  ShieldAlert,
  Flame,
  Users,
} from 'lucide-react';
import { ApiService } from '../services/api';
import { Card, CardHeader, CardTitle, CardContent } from '../components/ui/Card';
import { Badge } from '../components/ui/Badge';
import { Button } from '../components/ui/Button';
import { Modal } from '../components/ui/Modal';
import { TableSkeleton } from '../components/ui/Skeleton';
import { EmptyState } from '../components/ui/EmptyState';
import { ErrorState } from '../components/ui/ErrorState';
import { useAdminAuth } from '../contexts/AdminAuthContext';
import { formatDate } from '../utils/format';
import type { AutoReplyItem, AutoReplyStatusType, CommentTraceabilityItem } from '../types';

export const AutoReplyPage: React.FC = () => {
  const queryClient = useQueryClient();
  const { adminKey, isAuthenticated, openModal } = useAdminAuth();

  const [platformFilter, setPlatformFilter] = useState<string>('');
  const [statusFilter, setStatusFilter] = useState<string>('');
  const [searchTerm, setSearchTerm] = useState('');
  const [activeTab, setActiveTab] = useState<'respuestas' | 'trazabilidad'>('respuestas');
  const [traceStatusFilter, setTraceStatusFilter] = useState<string>('');
  const [tracePlatformFilter, setTracePlatformFilter] = useState<string>('');
  const [selectedReply, setSelectedReply] = useState<AutoReplyItem | null>(null);
  const [isEditModalOpen, setIsEditModalOpen] = useState(false);
  const [editedText, setEditedText] = useState('');
  const [feedbackMessage, setFeedbackMessage] = useState<{ type: 'success' | 'error'; text: string } | null>(null);

  // Consulta de estado y métricas de respuestas automáticas
  const {
    data: statusData,
    isLoading: isStatusLoading,
    refetch: refetchStatus,
  } = useQuery({
    queryKey: ['autoReplyStatus'],
    queryFn: ApiService.getAutoReplyStatus,
    refetchInterval: 10000,
  });

  // Consulta de historial de respuestas
  const {
    data: historyData,
    isLoading: isHistoryLoading,
    isError,
    refetch: refetchHistory,
    isFetching,
  } = useQuery({
    queryKey: ['autoReplyHistory', statusFilter, platformFilter],
    queryFn: () =>
      ApiService.getAutoReplyHistory({
        limit: 100,
        estado: statusFilter || undefined,
        plataforma: platformFilter || undefined,
      }),
    refetchInterval: 10000,
  });

  // Consulta de trazabilidad detallada de comentarios
  const {
    data: traceData,
    isLoading: isTraceLoading,
    refetch: refetchTrace,
    isFetching: isTraceFetching,
  } = useQuery({
    queryKey: ['commentTraceability', traceStatusFilter, tracePlatformFilter],
    queryFn: () =>
      ApiService.getCommentTraceability({
        limit: 100,
        estado: traceStatusFilter || undefined,
        plataforma: tracePlatformFilter || undefined,
      }),
    refetchInterval: 10000,
  });

  const items = historyData?.data || [];
  const traceItems = traceData?.data?.items || [];

  // Filtrado en memoria por búsqueda para respuestas
  const filteredItems = useMemo(() => {
    if (!searchTerm) return items;
    const term = searchTerm.toLowerCase();
    return items.filter((r) => {
      const matchComment = r.comentario_original?.texto?.toLowerCase().includes(term);
      const matchUser = r.comentario_original?.nombre_usuario?.toLowerCase().includes(term);
      const matchReply = r.texto_respuesta.toLowerCase().includes(term);
      const matchIntent = r.intencion_detectada.toLowerCase().includes(term);
      return matchComment || matchUser || matchReply || matchIntent;
    });
  }, [items, searchTerm]);

  // Filtrado en memoria por búsqueda para trazabilidad
  const filteredTraceItems = useMemo(() => {
    if (!searchTerm) return traceItems;
    const term = searchTerm.toLowerCase();
    return traceItems.filter((t) => {
      const matchComment = t.texto_comentario?.toLowerCase().includes(term);
      const matchUser = t.usuario_nombre?.toLowerCase().includes(term);
      const matchReply = t.texto_respuesta?.toLowerCase().includes(term);
      const matchReason = t.motivo_trazabilidad?.toLowerCase().includes(term);
      const matchIntent = t.intencion_detectada?.toLowerCase().includes(term);
      return matchComment || matchUser || matchReply || matchReason || matchIntent;
    });
  }, [traceItems, searchTerm]);

  // Mutación: Generar propuestas
  const generateMutation = useMutation({
    mutationFn: () => ApiService.generateAutoReplies(10),
    onSuccess: (data) => {
      setFeedbackMessage({
        type: 'success',
        text: `Evaluación finalizada: ${data.propuestas_generadas} propuestas generadas (${data.omitidos} comentarios omitidos).`,
      });
      queryClient.invalidateQueries({ queryKey: ['autoReplyStatus'] });
      queryClient.invalidateQueries({ queryKey: ['autoReplyHistory'] });
      queryClient.invalidateQueries({ queryKey: ['commentTraceability'] });
    },
    onError: (err: any) => {
      if (err?.response?.status === 401) openModal();
      setFeedbackMessage({
        type: 'error',
        text: err?.response?.data?.error || 'Error al generar propuestas de respuestas.',
      });
    },
  });

  // Mutación: Aprobar
  const approveMutation = useMutation({
    mutationFn: ({ id, text }: { id: number; text?: string }) => ApiService.approveAutoReply(id, text),
    onSuccess: () => {
      setFeedbackMessage({ type: 'success', text: 'Respuesta aprobada exitosamente.' });
      setIsEditModalOpen(false);
      setSelectedReply(null);
      queryClient.invalidateQueries({ queryKey: ['autoReplyStatus'] });
      queryClient.invalidateQueries({ queryKey: ['autoReplyHistory'] });
      queryClient.invalidateQueries({ queryKey: ['commentTraceability'] });
    },
    onError: (err: any) => {
      if (err?.response?.status === 401) openModal();
      setFeedbackMessage({
        type: 'error',
        text: err?.response?.data?.error || 'Error al aprobar la respuesta.',
      });
    },
  });

  // Mutación: Rechazar
  const rejectMutation = useMutation({
    mutationFn: (id: number) => ApiService.rejectAutoReply(id, 'Rechazado desde panel React'),
    onSuccess: () => {
      setFeedbackMessage({ type: 'success', text: 'Respuesta omitida / rechazada.' });
      queryClient.invalidateQueries({ queryKey: ['autoReplyStatus'] });
      queryClient.invalidateQueries({ queryKey: ['autoReplyHistory'] });
      queryClient.invalidateQueries({ queryKey: ['commentTraceability'] });
    },
    onError: (err: any) => {
      if (err?.response?.status === 401) openModal();
      setFeedbackMessage({
        type: 'error',
        text: err?.response?.data?.error || 'Error al rechazar la respuesta.',
      });
    },
  });

  // Mutación: Enviar / Simular
  const sendMutation = useMutation({
    mutationFn: (id: number) => ApiService.sendAutoReply(id),
    onSuccess: (res) => {
      const mode = res.simulada ? 'SIMULADA (Dry Run)' : 'ENVIADA exitosamente a Meta';
      setFeedbackMessage({
        type: 'success',
        text: `Respuesta procesada en modo ${mode}.`,
      });
      queryClient.invalidateQueries({ queryKey: ['autoReplyStatus'] });
      queryClient.invalidateQueries({ queryKey: ['autoReplyHistory'] });
      queryClient.invalidateQueries({ queryKey: ['commentTraceability'] });
    },
    onError: (err: any) => {
      if (err?.response?.status === 401) openModal();
      setFeedbackMessage({
        type: 'error',
        text: err?.response?.data?.error || 'Error al despachar la respuesta.',
      });
    },
  });

  // Mutación: Parada de Emergencia
  const emergencyStopMutation = useMutation({
    mutationFn: () => ApiService.emergencyStopAutoReply('Parada manual desde panel administrativo'),
    onSuccess: () => {
      setFeedbackMessage({
        type: 'error',
        text: 'PARADA DE EMERGENCIA ACTIVA: El envío automático ha sido desactivado.',
      });
      queryClient.invalidateQueries({ queryKey: ['autoReplyStatus'] });
    },
    onError: (err: any) => {
      if (err?.response?.status === 401) openModal();
      setFeedbackMessage({
        type: 'error',
        text: err?.response?.data?.error || 'Error al ejecutar parada de emergencia.',
      });
    },
  });

  // Mutación: Reactivación automática
  const activateAutoMutation = useMutation({
    mutationFn: () => ApiService.activateAutoReply(),
    onSuccess: () => {
      setFeedbackMessage({
        type: 'success',
        text: 'Envío automático reactivado con éxito (PRODUCCIÓN EN VIVO).',
      });
      queryClient.invalidateQueries({ queryKey: ['autoReplyStatus'] });
    },
    onError: (err: any) => {
      if (err?.response?.status === 401) openModal();
      setFeedbackMessage({
        type: 'error',
        text: err?.response?.data?.error || 'Error al activar envío automático.',
      });
    },
  });

  const handleOpenEdit = (reply: AutoReplyItem) => {
    setSelectedReply(reply);
    setEditedText(reply.texto_respuesta);
    setIsEditModalOpen(true);
  };

  const renderStatusBadge = (status: AutoReplyStatusType) => {
    switch (status) {
      case 'ENVIADA':
        return (
          <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded text-[11px] font-bold bg-emerald-50 text-emerald-700 border border-emerald-200 dark:bg-emerald-950/40 dark:text-emerald-300 dark:border-emerald-800">
            <CheckCircle2 className="w-3 h-3 text-emerald-600" />
            ENVIADA
          </span>
        );
      case 'SIMULADA':
        return (
          <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded text-[11px] font-bold bg-blue-50 text-blue-700 border border-blue-200 dark:bg-blue-950/40 dark:text-blue-300 dark:border-blue-800">
            <Sparkles className="w-3 h-3 text-blue-600" />
            SIMULADA
          </span>
        );
      case 'APROBADA':
        return (
          <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded text-[11px] font-bold bg-cyan-50 text-cyan-700 border border-cyan-200 dark:bg-cyan-950/40 dark:text-cyan-300 dark:border-cyan-800">
            <CheckCircle2 className="w-3 h-3 text-cyan-600" />
            APROBADA
          </span>
        );
      case 'PENDIENTE':
      case 'REQUIERE_REVISION':
        return (
          <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded text-[11px] font-bold bg-amber-50 text-amber-700 border border-amber-200 dark:bg-amber-950/40 dark:text-amber-300 dark:border-amber-800">
            <Clock className="w-3 h-3 text-amber-600" />
            PENDIENTE
          </span>
        );
      case 'FALLIDA':
        return (
          <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded text-[11px] font-bold bg-rose-50 text-rose-700 border border-rose-200 dark:bg-rose-950/40 dark:text-rose-300 dark:border-rose-800">
            <XCircle className="w-3 h-3 text-rose-600" />
            FALLIDA
          </span>
        );
      case 'OMITIDA':
      default:
        return (
          <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded text-[11px] font-bold bg-slate-100 text-slate-600 border border-slate-200 dark:bg-slate-800 dark:text-slate-400 dark:border-slate-700">
            OMITIDA
          </span>
        );
    }
  };

  const renderTraceBadge = (status: string) => {
    switch (status) {
      case 'RESPONDIDO_META':
        return (
          <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded text-[11px] font-bold bg-emerald-50 text-emerald-700 border border-emerald-200 dark:bg-emerald-950/40 dark:text-emerald-300 dark:border-emerald-800">
            <CheckCircle2 className="w-3 h-3 text-emerald-600" />
            RESPONDIDO EN META
          </span>
        );
      case 'SIMULADO_DRY_RUN':
        return (
          <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded text-[11px] font-bold bg-blue-50 text-blue-700 border border-blue-200 dark:bg-blue-950/40 dark:text-blue-300 dark:border-blue-800">
            <Sparkles className="w-3 h-3 text-blue-600" />
            SIMULADO (DRY RUN)
          </span>
        );
      case 'APROBADO_EN_COLA':
        return (
          <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded text-[11px] font-bold bg-cyan-50 text-cyan-700 border border-cyan-200 dark:bg-cyan-950/40 dark:text-cyan-300 dark:border-cyan-800">
            <CheckCircle2 className="w-3 h-3 text-cyan-600" />
            APROBADO EN COLA
          </span>
        );
      case 'PENDIENTE_REVISION':
        return (
          <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded text-[11px] font-bold bg-amber-50 text-amber-700 border border-amber-200 dark:bg-amber-950/40 dark:text-amber-300 dark:border-amber-800">
            <Clock className="w-3 h-3 text-amber-600" />
            PENDIENTE REVISIÓN
          </span>
        );
      case 'BLOQUEADO_COOLDOWN':
        return (
          <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded text-[11px] font-bold bg-purple-50 text-purple-700 border border-purple-200 dark:bg-purple-950/40 dark:text-purple-300 dark:border-purple-800">
            <Clock className="w-3 h-3 text-purple-600" />
            LÍMITE FRECUENCIA (ANTI-FLOOD)
          </span>
        );
      case 'OMITIDO_INAPROPIADO':
        return (
          <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded text-[11px] font-bold bg-red-50 text-red-700 border border-red-200 dark:bg-red-950/40 dark:text-red-300 dark:border-red-800">
            <ShieldAlert className="w-3 h-3 text-red-600" />
            MODERACIÓN / INAPROPIADO
          </span>
        );
      case 'OMITIDO_SPAM':
        return (
          <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded text-[11px] font-bold bg-zinc-100 text-zinc-700 border border-zinc-200 dark:bg-zinc-800 dark:text-zinc-300 dark:border-zinc-700">
            <XCircle className="w-3 h-3 text-zinc-500" />
            OMITIDO POR SPAM
          </span>
        );
      case 'OMITIDO_DATOS_SENSIBLES':
        return (
          <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded text-[11px] font-bold bg-amber-50 text-amber-700 border border-amber-200 dark:bg-amber-950/40 dark:text-amber-300 dark:border-amber-800">
            <AlertTriangle className="w-3 h-3 text-amber-600" />
            DATOS SENSIBLES
          </span>
        );
      case 'OMITIDO_ANTIGUEDAD':
        return (
          <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded text-[11px] font-bold bg-slate-100 text-slate-600 border border-slate-200 dark:bg-slate-800 dark:text-slate-400 dark:border-slate-700">
            <Clock className="w-3 h-3 text-slate-500" />
            OMITIDO POR ANTIGÜEDAD
          </span>
        );
      case 'OMITIDO_SIN_INTENCION_COMERCIAL':
        return (
          <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded text-[11px] font-bold bg-slate-100 text-slate-600 border border-slate-200 dark:bg-slate-800 dark:text-slate-400 dark:border-slate-700">
            <XCircle className="w-3 h-3 text-slate-500" />
            SIN CONTENIDO ACCIONABLE
          </span>
        );
      case 'OMITIDO_PROPIO':
        return (
          <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded text-[11px] font-bold bg-slate-100 text-slate-600 border border-slate-200 dark:bg-slate-800 dark:text-slate-400 dark:border-slate-700">
            PROPIO RESTAURANTE
          </span>
        );
      case 'FALLIDO_META':
        return (
          <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded text-[11px] font-bold bg-rose-50 text-rose-700 border border-rose-200 dark:bg-rose-950/40 dark:text-rose-300 dark:border-rose-800">
            <AlertTriangle className="w-3 h-3 text-rose-600" />
            FALLO EN META
          </span>
        );
      case 'PENDIENTE_EVALUACION':
        return (
          <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded text-[11px] font-bold bg-yellow-50 text-yellow-700 border border-yellow-200 dark:bg-yellow-950/40 dark:text-yellow-300 dark:border-yellow-800">
            <Sparkles className="w-3 h-3 text-yellow-600" />
            PENDIENTE EVALUACIÓN
          </span>
        );
      default:
        return (
          <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded text-[11px] font-bold bg-slate-100 text-slate-600 border border-slate-200 dark:bg-slate-800 dark:text-slate-400 dark:border-slate-700">
            {status}
          </span>
        );
    }
  };

  const config = statusData?.config;
  const metricas = statusData?.metricas;

  return (
    <div className="space-y-6 animate-in fade-in duration-200">
      {/* Banner de Estado de Configuración y Seguridad */}
      <Card className="border-l-4 border-l-brand-red">
        <CardHeader
          action={
            <div className="flex items-center gap-2">
              <Button
                variant="outline"
                size="sm"
                onClick={() => {
                  refetchStatus();
                  refetchHistory();
                }}
                isLoading={isFetching}
                leftIcon={<RotateCw className="w-3.5 h-3.5" />}
              >
                Actualizar
              </Button>
              <Button
                variant="primary"
                size="sm"
                onClick={() => generateMutation.mutate()}
                isLoading={generateMutation.isPending}
                leftIcon={<Sparkles className="w-3.5 h-3.5" />}
              >
                Evaluar Comentarios
              </Button>
              {config?.enabled ? (
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => emergencyStopMutation.mutate()}
                  isLoading={emergencyStopMutation.isPending}
                  className="border-rose-300 text-rose-600 hover:bg-rose-50 dark:border-rose-800 dark:text-rose-400 dark:hover:bg-rose-950/40"
                  leftIcon={<ShieldAlert className="w-3.5 h-3.5" />}
                  title="Detener inmediatamente el envío automático a Meta"
                >
                  Parada de Emergencia
                </Button>
              ) : (
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => activateAutoMutation.mutate()}
                  isLoading={activateAutoMutation.isPending}
                  className="border-emerald-300 text-emerald-600 hover:bg-emerald-50 dark:border-emerald-800 dark:text-emerald-400 dark:hover:bg-emerald-950/40"
                  leftIcon={<Send className="w-3.5 h-3.5" />}
                  title="Reactivar el envío automático continuo"
                >
                  Activar Auto-Reply
                </Button>
              )}
            </div>
          }
        >
          <CardTitle>
            <MessageSquareReply className="w-5 h-5 text-brand-red" />
            Agente de Respuestas Automáticas Contextuales
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-3 pt-1 text-xs">
            <div className="p-3 rounded-xl bg-slate-50 dark:bg-brand-charcoal border border-slate-200 dark:border-brand-charcoal-border">
              <span className="text-slate-400 block font-semibold mb-1">Modo de Operación:</span>
              <span className="font-bold flex items-center gap-1.5 text-blue-600 dark:text-blue-400">
                <Sparkles className="w-4 h-4" />
                {config?.dry_run ? 'SIMULACIÓN (DRY RUN ACTIVO)' : 'PRODUCCIÓN EN VIVO'}
              </span>
              <p className="text-[11px] text-slate-500 mt-1">
                {config?.dry_run
                  ? 'Las respuestas se generan y validan sin publicar externamente en Meta.'
                  : 'Publicación real autorizada en Facebook e Instagram.'}
              </p>
            </div>

            <div className="p-3 rounded-xl bg-slate-50 dark:bg-brand-charcoal border border-slate-200 dark:border-brand-charcoal-border">
              <span className="text-slate-400 block font-semibold mb-1">Política de Conversión:</span>
              <span className="font-bold flex items-center gap-1.5 text-emerald-600 dark:text-emerald-400">
                <ShieldAlert className="w-4 h-4" />
                Regla Estricta Anti-Falso LEAD
              </span>
              <p className="text-[11px] text-slate-500 mt-1">
                Responder a un comentario jamás altera el estado del BUYER a LEAD. Solo el registro completo en el formulario convierte.
              </p>
            </div>

            <div className="p-3 rounded-xl bg-slate-50 dark:bg-brand-charcoal border border-slate-200 dark:border-brand-charcoal-border">
              <span className="text-slate-400 block font-semibold mb-1">Enlace Oficial Configurado:</span>
              <a
                href={config?.form_url || 'https://elestablo.giansmd.dev/registro/'}
                target="_blank"
                rel="noreferrer"
                className="font-mono text-brand-red dark:text-rose-400 hover:underline flex items-center gap-1 font-semibold truncate"
              >
                <ExternalLink className="w-3.5 h-3.5 flex-shrink-0" />
                {config?.form_url || 'https://elestablo.giansmd.dev/registro/'}
              </a>
              <p className="text-[11px] text-amber-600 dark:text-amber-400 mt-1">
                Instagram invita al enlace de la biografía por restricción de clics en comentarios.
              </p>
            </div>
          </div>

          {/* Feedback Alert */}
          {feedbackMessage && (
            <div
              className={`mt-4 p-3 rounded-xl border text-xs flex items-center justify-between ${
                feedbackMessage.type === 'success'
                  ? 'bg-emerald-50 border-emerald-200 text-emerald-900 dark:bg-emerald-950/40 dark:border-emerald-800 dark:text-emerald-200'
                  : 'bg-rose-50 border-rose-200 text-rose-900 dark:bg-rose-950/40 dark:border-rose-800 dark:text-rose-200'
              }`}
            >
              <span>{feedbackMessage.text}</span>
              <button
                onClick={() => setFeedbackMessage(null)}
                className="font-bold hover:underline ml-3"
              >
                Cerrar
              </button>
            </div>
          )}
        </CardContent>
      </Card>

      {/* Tarjetas de Métricas */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-5 gap-4">
        <Card className="border-l-4 border-l-blue-600">
          <CardContent className="p-4">
            <span className="text-xs text-slate-500 font-semibold uppercase">Comentarios Elegibles</span>
            <p className="text-2xl font-black text-slate-900 dark:text-slate-100 font-mono mt-0.5">
              {metricas?.total_comentarios_reales ?? 0}
            </p>
            <span className="text-[11px] text-slate-400">En base de datos real</span>
          </CardContent>
        </Card>

        <Card className="border-l-4 border-l-brand-red">
          <CardContent className="p-4">
            <span className="text-xs text-slate-500 font-semibold uppercase">Respuestas Generadas</span>
            <p className="text-2xl font-black text-slate-900 dark:text-slate-100 font-mono mt-0.5">
              {metricas?.total_respuestas ?? 0}
            </p>
            <span className="text-[11px] text-slate-400">Total en histórico</span>
          </CardContent>
        </Card>

        <Card className="border-l-4 border-l-amber-500">
          <CardContent className="p-4">
            <span className="text-xs text-slate-500 font-semibold uppercase">Pendientes Revisión</span>
            <p className="text-2xl font-black text-slate-900 dark:text-slate-100 font-mono mt-0.5">
              {metricas?.pendientes ?? 0}
            </p>
            <span className="text-[11px] text-amber-600 font-medium">Requieren aprobación</span>
          </CardContent>
        </Card>

        <Card className="border-l-4 border-l-emerald-600">
          <CardContent className="p-4">
            <span className="text-xs text-slate-500 font-semibold uppercase">Enviadas / Simuladas</span>
            <p className="text-2xl font-black text-slate-900 dark:text-slate-100 font-mono mt-0.5">
              {(metricas?.enviadas ?? 0) + (metricas?.simuladas ?? 0)}
            </p>
            <span className="text-[11px] text-emerald-600 font-medium">
              {metricas?.enviadas ?? 0} reales, {metricas?.simuladas ?? 0} simuladas
            </span>
          </CardContent>
        </Card>

        <Card className="border-l-4 border-l-rose-500">
          <CardContent className="p-4">
            <span className="text-xs text-slate-500 font-semibold uppercase">Respuestas Fallidas</span>
            <p className="text-2xl font-black text-slate-900 dark:text-slate-100 font-mono mt-0.5">
              {metricas?.fallidas ?? 0}
            </p>
            <span className="text-[11px] text-slate-400">Con error en Meta</span>
          </CardContent>
        </Card>
      </div>

      {/* Selector de Pestañas: Bandeja de Respuestas vs Trazabilidad */}
      <div className="flex border-b border-slate-200 dark:border-brand-charcoal-border px-1 gap-2">
        <button
          onClick={() => setActiveTab('respuestas')}
          className={`px-4 py-2.5 text-xs font-bold border-b-2 transition-colors flex items-center gap-2 ${
            activeTab === 'respuestas'
              ? 'border-brand-red text-brand-red dark:text-rose-400'
              : 'border-transparent text-slate-500 hover:text-slate-800 dark:hover:text-slate-200'
          }`}
        >
          <MessageSquareReply className="w-4 h-4" />
          Bandeja de Respuestas ({filteredItems.length})
        </button>
        <button
          onClick={() => setActiveTab('trazabilidad')}
          className={`px-4 py-2.5 text-xs font-bold border-b-2 transition-colors flex items-center gap-2 ${
            activeTab === 'trazabilidad'
              ? 'border-brand-red text-brand-red dark:text-rose-400'
              : 'border-transparent text-slate-500 hover:text-slate-800 dark:hover:text-slate-200'
          }`}
        >
          <Search className="w-4 h-4" />
          Trazabilidad de Comentarios ({filteredTraceItems.length})
        </button>
      </div>

      {activeTab === 'respuestas' ? (
        /* Card Principal con Tabla de Respuestas */
        <Card>
          <CardHeader
            action={
              <span className="text-xs font-semibold px-2.5 py-1 rounded-full bg-slate-100 dark:bg-slate-800 text-slate-700 dark:text-slate-300">
                {filteredItems.length} registros listados
              </span>
            }
          >
            <CardTitle>
              <MessageSquareReply className="w-5 h-5 text-brand-red" />
              Bandeja de Respuestas Automáticas y Propuestas
            </CardTitle>
          </CardHeader>

          {/* Barra de Filtros */}
          <div className="p-4 border-b border-slate-100 dark:border-brand-charcoal-border bg-slate-50/50 dark:bg-brand-charcoal/30 flex flex-wrap gap-3 items-center justify-between">
            <div className="relative w-full sm:w-64">
              <Search className="w-4 h-4 text-slate-400 absolute left-3 top-1/2 -translate-y-1/2" />
              <input
                type="text"
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                placeholder="Buscar en comentario o respuesta..."
                className="w-full pl-9 pr-3 py-1.5 text-xs rounded-lg border border-slate-300 dark:border-slate-600 bg-white dark:bg-slate-800 text-slate-900 dark:text-slate-100 focus:outline-none focus:ring-1 focus:ring-brand-red"
              />
            </div>

            <div className="flex flex-wrap items-center gap-2">
              {/* Plataforma */}
              <select
                value={platformFilter}
                onChange={(e) => setPlatformFilter(e.target.value)}
                className="px-2.5 py-1 text-xs rounded-lg border border-slate-300 dark:border-slate-600 bg-white dark:bg-slate-800 text-slate-700 dark:text-slate-200"
              >
                <option value="">Todas las plataformas</option>
                <option value="facebook">Facebook</option>
                <option value="instagram">Instagram</option>
              </select>

              {/* Estado */}
              <select
                value={statusFilter}
                onChange={(e) => setStatusFilter(e.target.value)}
                className="px-2.5 py-1 text-xs rounded-lg border border-slate-300 dark:border-slate-600 bg-white dark:bg-slate-800 text-slate-700 dark:text-slate-200"
              >
                <option value="">Todos los estados</option>
                <option value="PENDIENTE">PENDIENTE</option>
                <option value="APROBADA">APROBADA</option>
                <option value="SIMULADA">SIMULADA</option>
                <option value="ENVIADA">ENVIADA</option>
                <option value="FALLIDA">FALLIDA</option>
                <option value="OMITIDA">OMITIDA</option>
              </select>
            </div>
          </div>

          {/* Tabla */}
          <CardContent className="p-0">
            {isHistoryLoading ? (
              <TableSkeleton rows={6} />
            ) : isError ? (
              <ErrorState
                title="Error al consultar respuestas automáticas"
                onRetry={() => refetchHistory()}
              />
            ) : filteredItems.length === 0 ? (
              <EmptyState
                icon={MessageSquareReply}
                title="No hay respuestas automáticas registradas"
                description="Haga clic en 'Evaluar Comentarios' para que el agente examine los comentarios recientes y formule propuestas."
              />
            ) : (
              <div className="overflow-x-auto">
                <table className="w-full text-left text-xs">
                  <thead className="bg-slate-50 dark:bg-slate-800/60 text-slate-600 dark:text-slate-400 uppercase font-bold text-[10px] tracking-wider border-b border-slate-200 dark:border-slate-700">
                    <tr>
                      <th className="py-3 px-4">Plataforma</th>
                      <th className="py-3 px-4">Publicación</th>
                      <th className="py-3 px-4">Comentario Original</th>
                      <th className="py-3 px-4">Intención</th>
                      <th className="py-3 px-4">Respuesta Propuesta</th>
                      <th className="py-3 px-4">Estado</th>
                      <th className="py-3 px-4">Fecha</th>
                      <th className="py-3 px-4 text-right">Acciones</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-slate-100 dark:divide-brand-charcoal-border">
                    {filteredItems.map((r) => {
                      const isFb = r.plataforma_codigo === 'FACEBOOK';
                      return (
                        <tr
                          key={r.id_respuesta}
                          className="hover:bg-slate-50/80 dark:hover:bg-slate-800/40 transition-colors"
                        >
                          <td className="py-3 px-4 whitespace-nowrap">
                            <span className="inline-flex items-center gap-1.5 font-semibold">
                              {isFb ? (
                                <>
                                  <Facebook className="w-4 h-4 text-blue-600" />
                                  <span>Facebook</span>
                                </>
                              ) : (
                                <>
                                  <Instagram className="w-4 h-4 text-rose-600" />
                                  <span>Instagram</span>
                                </>
                              )}
                            </span>
                          </td>
                          <td className="py-3 px-4 whitespace-nowrap font-mono text-[11px] text-slate-500">
                            {r.id_publicacion ? (
                              <span className="text-brand-red font-medium">Post #{r.id_publicacion}</span>
                            ) : (
                              '—'
                            )}
                          </td>
                          <td className="py-3 px-4 max-w-xs truncate">
                            <p className="font-semibold text-slate-800 dark:text-slate-200">
                              {r.comentario_original?.nombre_usuario || 'Usuario'}
                            </p>
                            <p className="text-slate-600 dark:text-slate-400 text-[11px] truncate">
                              "{r.comentario_original?.texto || 'Sin texto'}"
                            </p>
                          </td>
                          <td className="py-3 px-4 whitespace-nowrap">
                            <Badge variant="intent" intent={r.intencion_detectada as any}>
                              {r.intencion_detectada}
                            </Badge>
                          </td>
                          <td className="py-3 px-4 max-w-sm sm:max-w-md truncate text-slate-700 dark:text-slate-300 font-sans">
                            {r.texto_respuesta}
                          </td>
                          <td className="py-3 px-4 whitespace-nowrap">{renderStatusBadge(r.estado)}</td>
                          <td className="py-3 px-4 whitespace-nowrap text-slate-500 font-mono text-[11px]">
                            {formatDate(r.fecha_generacion)}
                          </td>
                          <td className="py-3 px-4 text-right whitespace-nowrap">
                            <div className="flex items-center justify-end gap-1.5">
                              <Button
                                size="sm"
                                variant="ghost"
                                onClick={() => handleOpenEdit(r)}
                                title="Ver y editar respuesta"
                                className="px-2 py-1"
                              >
                                <Edit3 className="w-3.5 h-3.5 text-slate-600 dark:text-slate-300" />
                              </Button>

                              {r.estado === 'PENDIENTE' && (
                                <>
                                  <Button
                                    size="sm"
                                    variant="outline"
                                    onClick={() => approveMutation.mutate({ id: r.id_respuesta })}
                                    isLoading={
                                      approveMutation.isPending &&
                                      approveMutation.variables?.id === r.id_respuesta
                                    }
                                    className="text-emerald-600 hover:text-emerald-700 px-2 py-1"
                                    title="Aprobar propuesta"
                                  >
                                    Aprobar
                                  </Button>
                                  <Button
                                    size="sm"
                                    variant="ghost"
                                    onClick={() => rejectMutation.mutate(r.id_respuesta)}
                                    isLoading={
                                      rejectMutation.isPending &&
                                      rejectMutation.variables === r.id_respuesta
                                    }
                                    className="text-rose-600 hover:text-rose-700 px-2 py-1"
                                    title="Rechazar / Omitir"
                                  >
                                    Rechazar
                                  </Button>
                                </>
                              )}

                              {(r.estado === 'APROBADA' || r.estado === 'PENDIENTE' || r.estado === 'SIMULADA') && (
                                <Button
                                  size="sm"
                                  variant="primary"
                                  onClick={() => sendMutation.mutate(r.id_respuesta)}
                                  isLoading={
                                    sendMutation.isPending &&
                                    sendMutation.variables === r.id_respuesta
                                  }
                                  leftIcon={<Send className="w-3 h-3" />}
                                  className="px-2.5 py-1 text-xs"
                                  title="Despachar a Meta o Simular"
                                >
                                  Enviar
                                </Button>
                              )}
                            </div>
                          </td>
                        </tr>
                      );
                    })}
                  </tbody>
                </table>
              </div>
            )}
          </CardContent>
        </Card>
      ) : (
        /* Card de Trazabilidad Detallada de Comentarios */
        <Card>
          <CardHeader
            action={
              <span className="text-xs font-semibold px-2.5 py-1 rounded-full bg-slate-100 dark:bg-slate-800 text-slate-700 dark:text-slate-300">
                {filteredTraceItems.length} comentarios evaluados
              </span>
            }
          >
            <CardTitle>
              <Search className="w-5 h-5 text-brand-red" />
              Trazabilidad Integral de Comentarios y Respuestas
            </CardTitle>
          </CardHeader>

          {/* Barra de Filtros de Trazabilidad */}
          <div className="p-4 border-b border-slate-100 dark:border-brand-charcoal-border bg-slate-50/50 dark:bg-brand-charcoal/30 flex flex-wrap gap-3 items-center justify-between">
            <div className="relative w-full sm:w-64">
              <Search className="w-4 h-4 text-slate-400 absolute left-3 top-1/2 -translate-y-1/2" />
              <input
                type="text"
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                placeholder="Buscar por usuario, texto o motivo..."
                className="w-full pl-9 pr-3 py-1.5 text-xs rounded-lg border border-slate-300 dark:border-slate-600 bg-white dark:bg-slate-800 text-slate-900 dark:text-slate-100 focus:outline-none focus:ring-1 focus:ring-brand-red"
              />
            </div>

            <div className="flex flex-wrap items-center gap-2">
              {/* Plataforma */}
              <select
                value={tracePlatformFilter}
                onChange={(e) => setTracePlatformFilter(e.target.value)}
                className="px-2.5 py-1 text-xs rounded-lg border border-slate-300 dark:border-slate-600 bg-white dark:bg-slate-800 text-slate-700 dark:text-slate-200"
              >
                <option value="">Todas las plataformas</option>
                <option value="facebook">Facebook</option>
                <option value="instagram">Instagram</option>
              </select>

              {/* Estado de Trazabilidad */}
              <select
                value={traceStatusFilter}
                onChange={(e) => setTraceStatusFilter(e.target.value)}
                className="px-2.5 py-1 text-xs rounded-lg border border-slate-300 dark:border-slate-600 bg-white dark:bg-slate-800 text-slate-700 dark:text-slate-200"
              >
                <option value="">Todos los estados</option>
                <option value="RESPONDIDO_META">RESPONDIDO EN META</option>
                <option value="SIMULADO_DRY_RUN">SIMULADO (DRY RUN)</option>
                <option value="PENDIENTE_REVISION">PENDIENTE REVISIÓN</option>
                <option value="APROBADO_EN_COLA">APROBADO EN COLA</option>
                <option value="BLOQUEADO_COOLDOWN">LÍMITE FRECUENCIA (ANTI-FLOOD)</option>
                <option value="OMITIDO_INAPROPIADO">MODERACIÓN / INAPROPIADO</option>
                <option value="OMITIDO_SPAM">OMITIDO POR SPAM</option>
                <option value="OMITIDO_DATOS_SENSIBLES">DATOS SENSIBLES</option>
                <option value="OMITIDO_ANTIGUEDAD">OMITIDO POR ANTIGÜEDAD</option>
                <option value="OMITIDO_SIN_INTENCION_COMERCIAL">SIN CONTENIDO ACCIONABLE</option>
                <option value="OMITIDO_PROPIO">PROPIO RESTAURANTE</option>
                <option value="FALLIDO_META">FALLO EN META</option>
                <option value="PENDIENTE_EVALUACION">PENDIENTE EVALUACIÓN</option>
              </select>
            </div>
          </div>

          {/* Tabla de Trazabilidad */}
          <CardContent className="p-0">
            {isTraceLoading ? (
              <TableSkeleton rows={6} />
            ) : filteredTraceItems.length === 0 ? (
              <EmptyState
                icon={Search}
                title="No se encontraron registros de trazabilidad"
                description="No hay comentarios que coincidan con los filtros seleccionados."
              />
            ) : (
              <div className="overflow-x-auto">
                <table className="w-full text-left text-xs">
                  <thead className="bg-slate-50 dark:bg-slate-800/60 text-slate-600 dark:text-slate-400 uppercase font-bold text-[10px] tracking-wider border-b border-slate-200 dark:border-slate-700">
                    <tr>
                      <th className="py-3 px-4">Plataforma / ID</th>
                      <th className="py-3 px-4">Usuario</th>
                      <th className="py-3 px-4">Comentario Original</th>
                      <th className="py-3 px-4">Intención</th>
                      <th className="py-3 px-4">Estado de Trazabilidad</th>
                      <th className="py-3 px-4">Motivo / Detalle</th>
                      <th className="py-3 px-4">Respuesta Publicada</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-slate-100 dark:divide-brand-charcoal-border">
                    {filteredTraceItems.map((item: CommentTraceabilityItem) => {
                      const isFb = item.plataforma === 'FACEBOOK';
                      return (
                        <tr
                          key={item.id_interaccion}
                          className="hover:bg-slate-50/80 dark:hover:bg-slate-800/40 transition-colors"
                        >
                          <td className="py-3 px-4 whitespace-nowrap">
                            <div className="flex items-center gap-1.5 font-semibold">
                              {isFb ? (
                                <Facebook className="w-4 h-4 text-blue-600 flex-shrink-0" />
                              ) : (
                                <Instagram className="w-4 h-4 text-rose-600 flex-shrink-0" />
                              )}
                              <span>#{item.id_interaccion}</span>
                            </div>
                            <span className="text-[10px] font-mono text-slate-400 block truncate max-w-[120px]" title={item.id_interaccion_externa}>
                              {item.id_interaccion_externa}
                            </span>
                          </td>
                          <td className="py-3 px-4 whitespace-nowrap">
                            <p className="font-semibold text-slate-800 dark:text-slate-200">
                              {item.usuario_nombre}
                            </p>
                            {item.usuario_id && (
                              <span className="text-[10px] font-mono text-slate-400 block">
                                ID: {item.usuario_id}
                              </span>
                            )}
                          </td>
                          <td className="py-3 px-4 max-w-xs">
                            <p className="text-slate-700 dark:text-slate-300 font-medium">
                              "{item.texto_comentario}"
                            </p>
                            <span className="text-[10px] text-slate-400 font-mono">
                              {item.fecha_interaccion ? formatDate(item.fecha_interaccion) : '—'}
                            </span>
                          </td>
                          <td className="py-3 px-4 whitespace-nowrap">
                            <Badge variant="intent" intent={item.intencion_detectada as any}>
                              {item.intencion_detectada}
                            </Badge>
                          </td>
                          <td className="py-3 px-4 whitespace-nowrap">
                            {renderTraceBadge(item.estado_trazabilidad)}
                          </td>
                          <td className="py-3 px-4 max-w-sm">
                            <p className="text-slate-600 dark:text-slate-300 text-[11px]">
                              {item.motivo_trazabilidad}
                            </p>
                            {item.error_detalle && (
                              <p className="text-rose-600 dark:text-rose-400 text-[10px] font-mono mt-0.5 truncate" title={item.error_detalle}>
                                Error: {item.error_detalle}
                              </p>
                            )}
                          </td>
                          <td className="py-3 px-4 max-w-xs">
                            {item.tiene_respuesta && item.texto_respuesta ? (
                              <div>
                                <p className="text-slate-700 dark:text-slate-200 text-[11px] truncate" title={item.texto_respuesta}>
                                  "{item.texto_respuesta}"
                                </p>
                                {item.id_respuesta_meta && (
                                  <span className="text-[10px] font-mono text-emerald-700 dark:text-emerald-400 block truncate" title={item.id_respuesta_meta}>
                                    Meta ID: {item.id_respuesta_meta}
                                  </span>
                                )}
                              </div>
                            ) : (
                              <span className="text-slate-400 text-[11px] italic">Sin respuesta</span>
                            )}
                          </td>
                        </tr>
                      );
                    })}
                  </tbody>
                </table>
              </div>
            )}
          </CardContent>
        </Card>
      )}

      {/* Modal de Detalle y Edición de Respuesta */}
      {selectedReply && (
        <Modal
          isOpen={isEditModalOpen}
          onClose={() => {
            setIsEditModalOpen(false);
            setSelectedReply(null);
          }}
          title={
            <span className="flex items-center gap-2">
              <MessageSquareReply className="w-5 h-5 text-brand-red" />
              Revisión y Aprobación de Respuesta #{selectedReply.id_respuesta}
            </span>
          }
          description="Valide o modifique el mensaje contextual antes de su envío hacia Meta Graph API."
          size="lg"
        >
          <div className="space-y-4">
            <div className="p-4 rounded-xl bg-slate-50 dark:bg-brand-charcoal border border-slate-200 dark:border-brand-charcoal-border space-y-3">
              <div className="flex items-center justify-between">
                <span className="font-bold text-sm text-slate-900 dark:text-slate-100">
                  Comentario de: {selectedReply.comentario_original?.nombre_usuario || 'Usuario anónimo'}
                </span>
                <Badge variant="intent" intent={selectedReply.intencion_detectada as any}>
                  {selectedReply.intencion_detectada}
                </Badge>
              </div>

              <div className="p-3 rounded-lg bg-white dark:bg-brand-charcoal-card border border-slate-200 dark:border-brand-charcoal-border text-xs">
                <p className="text-slate-400 font-semibold uppercase mb-1">Comentario original:</p>
                <p className="text-slate-800 dark:text-slate-200 font-medium whitespace-pre-wrap">
                  "{selectedReply.comentario_original?.texto}"
                </p>
              </div>

              <div>
                <label className="text-xs font-semibold text-slate-700 dark:text-slate-300 block mb-1.5">
                  Texto de Respuesta Comercial:
                </label>
                <textarea
                  rows={4}
                  value={editedText}
                  onChange={(e) => setEditedText(e.target.value)}
                  className="w-full p-3 text-xs rounded-xl border border-slate-300 dark:border-slate-600 bg-white dark:bg-slate-800 text-slate-900 dark:text-slate-100 focus:outline-none focus:ring-1 focus:ring-brand-red"
                  placeholder="Redacte la respuesta contextual..."
                />
                <span className="text-[11px] text-slate-400 block text-right">
                  {editedText.length} / 2000 caracteres
                </span>
              </div>

              {selectedReply.id_respuesta_meta && (
                <div className="p-2.5 rounded-lg bg-emerald-50 dark:bg-emerald-950/30 border border-emerald-200 dark:border-emerald-800 text-xs">
                  <span className="text-emerald-800 dark:text-emerald-200 font-semibold block">
                    ID Asignado por Meta:
                  </span>
                  <span className="font-mono text-emerald-900 dark:text-emerald-100">
                    {selectedReply.id_respuesta_meta}
                  </span>
                </div>
              )}

              {selectedReply.error_detalle && (
                <div className="p-2.5 rounded-lg bg-rose-50 dark:bg-rose-950/30 border border-rose-200 dark:border-rose-800 text-xs">
                  <span className="text-rose-800 dark:text-rose-200 font-semibold block">
                    Detalle del Error:
                  </span>
                  <span className="text-rose-900 dark:text-rose-100">
                    {selectedReply.error_detalle}
                  </span>
                </div>
              )}
            </div>

            <div className="flex justify-end gap-2 pt-2">
              <Button
                variant="outline"
                size="sm"
                onClick={() => {
                  setIsEditModalOpen(false);
                  setSelectedReply(null);
                }}
              >
                Cerrar
              </Button>
              <Button
                variant="primary"
                size="sm"
                onClick={() =>
                  approveMutation.mutate({
                    id: selectedReply.id_respuesta,
                    text: editedText,
                  })
                }
                isLoading={approveMutation.isPending}
                leftIcon={<CheckCircle2 className="w-3.5 h-3.5" />}
              >
                Guardar y Aprobar
              </Button>
            </div>
          </div>
        </Modal>
      )}
    </div>
  );
};
