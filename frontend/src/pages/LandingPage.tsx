import React, { useState, useMemo } from 'react';
import { useQuery } from '@tanstack/react-query';
import {
  Globe,
  Users,
  Eye,
  FileText,
  UserCheck,
  TrendingUp,
  Calendar,
  RefreshCw,
  ExternalLink,
  MessageCircle,
  UtensilsCrossed,
  CheckCircle2,
  XCircle,
  Layers,
  BookOpen,
  ChevronLeft,
  ChevronRight,
  Info,
  ShieldCheck,
  Smartphone,
  Laptop,
} from 'lucide-react';
import { ApiService } from '../services/api';
import { Card, CardHeader, CardTitle, CardContent } from '../components/ui/Card';
import { Badge } from '../components/ui/Badge';
import { Button } from '../components/ui/Button';
import { Modal } from '../components/ui/Modal';
import { TableSkeleton } from '../components/ui/Skeleton';
import { EmptyState } from '../components/ui/EmptyState';
import { ErrorState } from '../components/ui/ErrorState';
import type {
  LandingDetailType,
  VisitaDetailItem,
  VisitanteDetailItem,
  VisualizacionCartaDetailItem,
  VisitanteCartaDetailItem,
  FormularioDetailItem,
  LeadDetailItem,
} from '../types';

export const LandingPage: React.FC = () => {
  const [dateFilter, setDateFilter] = useState<'todo' | 'hoy' | '7dias' | '30dias'>('todo');
  const [selectedIndicator, setSelectedIndicator] = useState<LandingDetailType | null>(null);
  const [detailPage, setDetailPage] = useState<number>(1);
  const pageSize = 10;

  // Parámetros de fecha según filtro
  const queryDates = useMemo(() => {
    if (dateFilter === 'todo') return { periodo: 'todo' };
    return { periodo: dateFilter };
  }, [dateFilter]);

  // Consulta de estadísticas principales
  const {
    data: statsData,
    isLoading,
    isError,
    error,
    refetch,
    isFetching,
  } = useQuery({
    queryKey: ['landingStats', queryDates],
    queryFn: () => ApiService.getLandingStats(queryDates),
    refetchInterval: 15000,
  });

  const resumen = statsData?.resumen || {
    visitas_landing: 0,
    visitantes_landing: 0,
    visualizaciones_carta: 0,
    visitantes_carta: 0,
    formularios: 0,
    leads: 0,
    conversion: 0,
  };

  const visitasPorDia = statsData?.visitas_por_dia || [];

  // Al abrir un indicador o cambiar de filtro, reiniciar a la página 1
  const handleOpenDetail = (type: LandingDetailType) => {
    setSelectedIndicator(type);
    setDetailPage(1);
  };

  const handleCloseDetail = () => {
    setSelectedIndicator(null);
  };

  // Consulta de registros detallados bajo demanda
  const detailEndpoint = useMemo(() => {
    if (!selectedIndicator || selectedIndicator === 'conversion') return null;
    switch (selectedIndicator) {
      case 'visitas':
        return 'visitas';
      case 'visitantes':
        return 'visitantes';
      case 'visualizaciones_carta':
        return 'visualizaciones-carta';
      case 'visitantes_carta':
        return 'visitantes-carta';
      case 'formularios':
        return 'formularios';
      case 'leads':
        return 'leads';
      default:
        return null;
    }
  }, [selectedIndicator]);

  const {
    data: detailData,
    isLoading: isDetailLoading,
    isError: isDetailError,
    error: detailErrorObj,
  } = useQuery({
    queryKey: ['landingDetails', detailEndpoint, queryDates, detailPage],
    queryFn: () =>
      detailEndpoint
        ? ApiService.getLandingDetails<unknown>(detailEndpoint, {
            ...queryDates,
            page: detailPage,
            page_size: pageSize,
          })
        : null,
    enabled: Boolean(detailEndpoint),
  });

  // Metadatos de paginación del detalle
  const totalDetailItems = detailData?.total ?? 0;
  const totalPages = detailData?.total_pages ?? 1;

  // Configuración de títulos para el modal de detalle
  const modalInfo = useMemo(() => {
    switch (selectedIndicator) {
      case 'visitas':
        return {
          title: 'Visitas Landing',
          description: 'Sesiones de navegación iniciadas en el sitio web dentro del período evaluado.',
          badgeColor: 'blue',
        };
      case 'visitantes':
        return {
          title: 'Visitantes Landing',
          description: 'Navegadores únicos aproximados identificados mediante token persistente (no personas físicas).',
          badgeColor: 'indigo',
        };
      case 'visualizaciones_carta':
        return {
          title: 'Visualizaciones Carta',
          description: 'Accesos y aperturas efectivas de la ruta /carta/ registradas mediante eventos VISTA_CARTA.',
          badgeColor: 'amber',
        };
      case 'visitantes_carta':
        return {
          title: 'Visitantes Carta',
          description: 'Navegadores únicos que abrieron efectivamente la ruta /carta/ al menos una vez en el período.',
          badgeColor: 'purple',
        };
      case 'formularios':
        return {
          title: 'Formularios Recibidos',
          description: 'Registros válidos recibidos desde el formulario de captación de la landing page.',
          badgeColor: 'emerald',
        };
      case 'leads':
        return {
          title: 'LEADS Calificados',
          description: 'Prospectos únicos convertidos a LEAD vinculados a formularios de la landing page.',
          badgeColor: 'rose',
        };
      case 'conversion':
        return {
          title: 'Tasa de Conversión BUYER → LEAD',
          description: 'Desglose y fórmula matemática del cálculo de conversión en la landing page.',
          badgeColor: 'red',
        };
      default:
        return { title: '', description: '', badgeColor: 'slate' };
    }
  }, [selectedIndicator]);

  return (
    <div className="space-y-6">
      {/* Encabezado y Filtros */}
      <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <div className="flex items-center gap-2">
            <Globe className="w-7 h-7 text-brand-red" />
            <h1 className="text-2xl font-bold tracking-tight text-slate-900 dark:text-slate-100">
              Landing Page & Carta Digital
            </h1>
          </div>
          <p className="text-sm text-slate-500 dark:text-slate-400 mt-1">
            Métricas de tráfico, visualizaciones únicas de la carta y conversión BUYER → LEAD en Parrilladas El Establo.
          </p>
        </div>

        <div className="flex flex-wrap items-center gap-3">
          {/* Selector de Rango de Fecha */}
          <div className="flex items-center bg-white dark:bg-brand-charcoal border border-slate-200 dark:border-brand-charcoal-border rounded-xl p-1 shadow-sm">
            <button
              onClick={() => setDateFilter('todo')}
              className={`px-3 py-1.5 text-xs font-semibold rounded-lg transition-colors ${
                dateFilter === 'todo'
                  ? 'bg-brand-red text-white'
                  : 'text-slate-600 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-slate-800'
              }`}
            >
              Todo
            </button>
            <button
              onClick={() => setDateFilter('hoy')}
              className={`px-3 py-1.5 text-xs font-semibold rounded-lg transition-colors ${
                dateFilter === 'hoy'
                  ? 'bg-brand-red text-white'
                  : 'text-slate-600 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-slate-800'
              }`}
            >
              Hoy
            </button>
            <button
              onClick={() => setDateFilter('7dias')}
              className={`px-3 py-1.5 text-xs font-semibold rounded-lg transition-colors ${
                dateFilter === '7dias'
                  ? 'bg-brand-red text-white'
                  : 'text-slate-600 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-slate-800'
              }`}
            >
              7 Días
            </button>
            <button
              onClick={() => setDateFilter('30dias')}
              className={`px-3 py-1.5 text-xs font-semibold rounded-lg transition-colors ${
                dateFilter === '30dias'
                  ? 'bg-brand-red text-white'
                  : 'text-slate-600 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-slate-800'
              }`}
            >
              30 Días
            </button>
          </div>

          {/* Botón Refrescar */}
          <Button
            variant="outline"
            size="sm"
            onClick={() => refetch()}
            disabled={isFetching}
            className="flex items-center gap-2"
          >
            <RefreshCw className={`w-4 h-4 ${isFetching ? 'animate-spin' : ''}`} />
            <span>Actualizar</span>
          </Button>

          {/* Enlace directo a la Landing */}
          <a
            href="https://elestablo2.giansmd.dev/"
            target="_blank"
            rel="noopener noreferrer"
            className="inline-flex items-center gap-1.5 px-3 py-1.5 text-xs font-semibold text-slate-700 dark:text-slate-200 bg-slate-100 dark:bg-slate-800 hover:bg-slate-200 dark:hover:bg-slate-700 rounded-lg transition-colors"
          >
            <span>Ver Landing</span>
            <ExternalLink className="w-3.5 h-3.5" />
          </a>
        </div>
      </div>

      {/* Manejo de Error Principal */}
      {isError && (
        <ErrorState
          title="Error al cargar métricas de la landing page"
          message={(error as Error)?.message || 'No se pudo conectar con el endpoint de analítica.'}
          onRetry={() => refetch()}
        />
      )}

      {/* Grid de 7 Tarjetas Interactivas Clicables */}
      <div className="grid grid-cols-2 gap-4 sm:grid-cols-3 lg:grid-cols-4 xl:grid-cols-7">
        {/* 1. Visitas Landing */}
        <Card
          onClick={() => handleOpenDetail('visitas')}
          className="p-4 border-l-4 border-l-blue-500 cursor-pointer hover:shadow-lg hover:border-slate-400 dark:hover:border-slate-500 transition-all duration-150 active:scale-[0.98] group"
        >
          <div className="flex items-center justify-between text-slate-500 dark:text-slate-400">
            <span className="text-xs font-semibold uppercase tracking-wider group-hover:text-blue-500 transition-colors">
              Visitas Landing
            </span>
            <Eye className="w-4 h-4 text-blue-500" />
          </div>
          <p className="mt-2 text-2xl font-bold tracking-tight text-slate-900 dark:text-slate-100">
            {isLoading ? '...' : resumen.visitas_landing.toLocaleString()}
          </p>
          <span className="text-[11px] text-slate-400 dark:text-slate-500 flex items-center justify-between mt-1">
            <span>Sesiones web</span>
            <span className="text-[10px] text-blue-500 opacity-0 group-hover:opacity-100 transition-opacity font-semibold">
              Ver detalle →
            </span>
          </span>
        </Card>

        {/* 2. Visitantes Landing */}
        <Card
          onClick={() => handleOpenDetail('visitantes')}
          className="p-4 border-l-4 border-l-indigo-500 cursor-pointer hover:shadow-lg hover:border-slate-400 dark:hover:border-slate-500 transition-all duration-150 active:scale-[0.98] group"
        >
          <div className="flex items-center justify-between text-slate-500 dark:text-slate-400">
            <span className="text-xs font-semibold uppercase tracking-wider group-hover:text-indigo-500 transition-colors">
              Visitantes Landing
            </span>
            <Users className="w-4 h-4 text-indigo-500" />
          </div>
          <p className="mt-2 text-2xl font-bold tracking-tight text-slate-900 dark:text-slate-100">
            {isLoading ? '...' : resumen.visitantes_landing.toLocaleString()}
          </p>
          <span className="text-[11px] text-slate-400 dark:text-slate-500 flex items-center justify-between mt-1">
            <span>Navegadores únicos</span>
            <span className="text-[10px] text-indigo-500 opacity-0 group-hover:opacity-100 transition-opacity font-semibold">
              Ver detalle →
            </span>
          </span>
        </Card>

        {/* 3. Visualizaciones Carta */}
        <Card
          onClick={() => handleOpenDetail('visualizaciones_carta')}
          className="p-4 border-l-4 border-l-amber-500 cursor-pointer hover:shadow-lg hover:border-slate-400 dark:hover:border-slate-500 transition-all duration-150 active:scale-[0.98] group"
        >
          <div className="flex items-center justify-between text-slate-500 dark:text-slate-400">
            <span className="text-xs font-semibold uppercase tracking-wider group-hover:text-amber-500 transition-colors">
              Visualizaciones Carta
            </span>
            <BookOpen className="w-4 h-4 text-amber-500" />
          </div>
          <p className="mt-2 text-2xl font-bold tracking-tight text-slate-900 dark:text-slate-100">
            {isLoading ? '...' : resumen.visualizaciones_carta.toLocaleString()}
          </p>
          <span className="text-[11px] text-slate-400 dark:text-slate-500 flex items-center justify-between mt-1">
            <span>Aperturas /carta/</span>
            <span className="text-[10px] text-amber-500 opacity-0 group-hover:opacity-100 transition-opacity font-semibold">
              Ver detalle →
            </span>
          </span>
        </Card>

        {/* 4. Visitantes Carta */}
        <Card
          onClick={() => handleOpenDetail('visitantes_carta')}
          className="p-4 border-l-4 border-l-purple-500 cursor-pointer hover:shadow-lg hover:border-slate-400 dark:hover:border-slate-500 transition-all duration-150 active:scale-[0.98] group"
        >
          <div className="flex items-center justify-between text-slate-500 dark:text-slate-400">
            <span className="text-xs font-semibold uppercase tracking-wider group-hover:text-purple-500 transition-colors">
              Visitantes Carta
            </span>
            <UtensilsCrossed className="w-4 h-4 text-purple-500" />
          </div>
          <p className="mt-2 text-2xl font-bold tracking-tight text-slate-900 dark:text-slate-100">
            {isLoading ? '...' : resumen.visitantes_carta.toLocaleString()}
          </p>
          <span className="text-[11px] text-slate-400 dark:text-slate-500 flex items-center justify-between mt-1">
            <span>Navegadores en carta</span>
            <span className="text-[10px] text-purple-500 opacity-0 group-hover:opacity-100 transition-opacity font-semibold">
              Ver detalle →
            </span>
          </span>
        </Card>

        {/* 5. Formularios */}
        <Card
          onClick={() => handleOpenDetail('formularios')}
          className="p-4 border-l-4 border-l-emerald-500 cursor-pointer hover:shadow-lg hover:border-slate-400 dark:hover:border-slate-500 transition-all duration-150 active:scale-[0.98] group"
        >
          <div className="flex items-center justify-between text-slate-500 dark:text-slate-400">
            <span className="text-xs font-semibold uppercase tracking-wider group-hover:text-emerald-500 transition-colors">
              Formularios
            </span>
            <FileText className="w-4 h-4 text-emerald-500" />
          </div>
          <p className="mt-2 text-2xl font-bold tracking-tight text-slate-900 dark:text-slate-100">
            {isLoading ? '...' : resumen.formularios.toLocaleString()}
          </p>
          <span className="text-[11px] text-slate-400 dark:text-slate-500 flex items-center justify-between mt-1">
            <span>Captaciones web</span>
            <span className="text-[10px] text-emerald-500 opacity-0 group-hover:opacity-100 transition-opacity font-semibold">
              Ver detalle →
            </span>
          </span>
        </Card>

        {/* 6. LEADS */}
        <Card
          onClick={() => handleOpenDetail('leads')}
          className="p-4 border-l-4 border-l-rose-500 cursor-pointer hover:shadow-lg hover:border-slate-400 dark:hover:border-slate-500 transition-all duration-150 active:scale-[0.98] group"
        >
          <div className="flex items-center justify-between text-slate-500 dark:text-slate-400">
            <span className="text-xs font-semibold uppercase tracking-wider group-hover:text-rose-500 transition-colors">
              LEADS
            </span>
            <UserCheck className="w-4 h-4 text-rose-500" />
          </div>
          <p className="mt-2 text-2xl font-bold tracking-tight text-slate-900 dark:text-slate-100">
            {isLoading ? '...' : resumen.leads.toLocaleString()}
          </p>
          <span className="text-[11px] text-slate-400 dark:text-slate-500 flex items-center justify-between mt-1">
            <span>Convertidos</span>
            <span className="text-[10px] text-rose-500 opacity-0 group-hover:opacity-100 transition-opacity font-semibold">
              Ver detalle →
            </span>
          </span>
        </Card>

        {/* 7. Conversión */}
        <Card
          onClick={() => handleOpenDetail('conversion')}
          className="p-4 border-l-4 border-l-brand-red bg-gradient-to-br from-white to-red-50/30 dark:from-brand-charcoal dark:to-red-950/20 cursor-pointer hover:shadow-lg hover:border-brand-red transition-all duration-150 active:scale-[0.98] group"
        >
          <div className="flex items-center justify-between text-slate-500 dark:text-slate-400">
            <span className="text-xs font-bold uppercase tracking-wider text-brand-red dark:text-rose-400">
              Conversión
            </span>
            <TrendingUp className="w-4 h-4 text-brand-red dark:text-rose-400" />
          </div>
          <p className="mt-2 text-2xl font-extrabold tracking-tight text-brand-red dark:text-rose-400">
            {isLoading ? '...' : `${resumen.conversion}%`}
          </p>
          <span className="text-[11px] text-slate-400 dark:text-slate-500 flex items-center justify-between mt-1">
            <span>LEADS / Visitantes</span>
            <span className="text-[10px] text-brand-red font-semibold opacity-0 group-hover:opacity-100 transition-opacity">
              Fórmula →
            </span>
          </span>
        </Card>
      </div>

      {/* Aclaración Metodológica y Privacidad */}
      <div className="flex items-center gap-2 p-3 bg-slate-50 dark:bg-slate-800/40 border border-slate-200 dark:border-brand-charcoal-border rounded-xl text-xs text-slate-500 dark:text-slate-400">
        <Info className="w-4 h-4 text-slate-400 shrink-0" />
        <span>
          <strong>Nota de Privacidad:</strong> Los &quot;Visitantes Únicos&quot; corresponden a navegadores identificados aproximadamente mediante identificador persistente local (<code className="font-mono text-brand-red dark:text-rose-400">token_visitante</code>), garantizando la no invasión a la privacidad del cliente y evitando el rastreo de personas físicas no autorizadas.
        </span>
      </div>

      {/* Sección Principal Limpia: Serie Temporal de Visitas por Día */}
      <Card>
        <CardHeader>
          <div className="flex items-center justify-between">
            <CardTitle className="text-base flex items-center gap-2">
              <Calendar className="w-4 h-4 text-slate-500" />
              <span>Visitas por Día</span>
            </CardTitle>
            <Badge variant="outline" className="text-xs font-mono">
              {statsData?.periodo || 'Período actual'}
            </Badge>
          </div>
        </CardHeader>
        <CardContent>
          {isLoading ? (
            <TableSkeleton rows={4} />
          ) : visitasPorDia.length === 0 ? (
            <EmptyState
              icon={Calendar}
              title="Sin visitas registradas"
              description="No hay visitas registradas para el período seleccionado."
            />
          ) : (
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-3">
              {visitasPorDia.map((item) => (
                <div
                  key={item.fecha}
                  className="flex items-center justify-between p-3 rounded-xl bg-slate-50 dark:bg-slate-800/60 border border-slate-100 dark:border-slate-800"
                >
                  <div>
                    <p className="text-xs font-bold text-slate-800 dark:text-slate-200">{item.fecha}</p>
                    <p className="text-[11px] text-slate-400">{item.visitantes} navegadores únicos</p>
                  </div>
                  <Badge variant="outline" className="font-mono text-xs font-bold text-blue-600 dark:text-blue-400">
                    {item.visitas} visitas
                  </Badge>
                </div>
              ))}
            </div>
          )}
        </CardContent>
      </Card>

      {/* MODAL DE DETALLE INTERACTIVO BAJO DEMANDA */}
      <Modal
        isOpen={selectedIndicator !== null}
        onClose={handleCloseDetail}
        title={
          <div className="flex items-center gap-2">
            <span>{modalInfo.title}</span>
            {selectedIndicator !== 'conversion' && (
              <Badge variant="outline" className="text-xs font-mono">
                {totalDetailItems} registros
              </Badge>
            )}
          </div>
        }
        description={modalInfo.description}
        size="2xl"
        footer={
          <div className="flex items-center justify-between w-full">
            <span className="text-xs text-slate-400">
              Período: <strong>{statsData?.periodo || 'Histórico'}</strong>
            </span>
            <Button variant="outline" size="sm" onClick={handleCloseDetail}>
              Cerrar
            </Button>
          </div>
        }
      >
        {/* Caso Especial: Desglose de Conversión */}
        {selectedIndicator === 'conversion' && (
          <div className="space-y-6">
            {/* Tarjeta de Fórmula Matemática */}
            <div className="p-5 rounded-2xl bg-gradient-to-r from-red-50 to-orange-50 dark:from-red-950/30 dark:to-orange-950/20 border border-red-200 dark:border-red-900/50">
              <h3 className="text-sm font-bold text-slate-900 dark:text-slate-100 flex items-center gap-2 mb-3">
                <TrendingUp className="w-4 h-4 text-brand-red" />
                <span>Fórmula Matemática de Conversión</span>
              </h3>
              <div className="flex flex-col sm:flex-row items-center justify-center gap-4 py-4 text-center font-mono">
                <div className="p-3 bg-white dark:bg-brand-charcoal rounded-xl border border-slate-200 dark:border-brand-charcoal-border shadow-sm min-w-[160px]">
                  <p className="text-[11px] uppercase text-slate-400 font-sans">Numerador (LEADS)</p>
                  <p className="text-2xl font-extrabold text-rose-500 mt-1">{resumen.leads}</p>
                </div>
                <span className="text-xl font-bold text-slate-400">÷</span>
                <div className="p-3 bg-white dark:bg-brand-charcoal rounded-xl border border-slate-200 dark:border-brand-charcoal-border shadow-sm min-w-[160px]">
                  <p className="text-[11px] uppercase text-slate-400 font-sans">Denominador (Visitantes)</p>
                  <p className="text-2xl font-extrabold text-indigo-500 mt-1">{resumen.visitantes_landing}</p>
                </div>
                <span className="text-xl font-bold text-slate-400">× 100 =</span>
                <div className="p-3 bg-brand-red text-white rounded-xl shadow-md min-w-[160px]">
                  <p className="text-[11px] uppercase text-white/80 font-sans">Tasa de Conversión</p>
                  <p className="text-2xl font-black mt-1">{resumen.conversion}%</p>
                </div>
              </div>
            </div>

            {/* Embudo de Conversión de la Landing */}
            <div className="border border-slate-200 dark:border-brand-charcoal-border rounded-xl overflow-hidden">
              <div className="px-4 py-3 bg-slate-50 dark:bg-slate-800/60 border-b border-slate-200 dark:border-brand-charcoal-border">
                <h4 className="text-xs font-bold uppercase tracking-wider text-slate-600 dark:text-slate-300">
                  Embudo de Interacción (Funnel Web)
                </h4>
              </div>
              <div className="divide-y divide-slate-100 dark:divide-brand-charcoal-border text-xs">
                <div className="flex items-center justify-between p-3">
                  <span className="text-slate-600 dark:text-slate-400">1. Total de Visitas (Sesiones)</span>
                  <span className="font-mono font-bold text-slate-900 dark:text-slate-100">{resumen.visitas_landing}</span>
                </div>
                <div className="flex items-center justify-between p-3">
                  <span className="text-slate-600 dark:text-slate-400">2. Visitantes Únicos (Navegadores)</span>
                  <span className="font-mono font-bold text-slate-900 dark:text-slate-100">{resumen.visitantes_landing}</span>
                </div>
                <div className="flex items-center justify-between p-3">
                  <span className="text-slate-600 dark:text-slate-400">3. Visitantes que Consultaron la Carta (/carta/)</span>
                  <span className="font-mono font-bold text-slate-900 dark:text-slate-100">{resumen.visitantes_carta}</span>
                </div>
                <div className="flex items-center justify-between p-3">
                  <span className="text-slate-600 dark:text-slate-400">4. Formularios de Captación Recibidos</span>
                  <span className="font-mono font-bold text-slate-900 dark:text-slate-100">{resumen.formularios}</span>
                </div>
                <div className="flex items-center justify-between p-3 bg-red-50/50 dark:bg-red-950/20 font-bold">
                  <span className="text-brand-red dark:text-rose-400">5. LEADS Únicos Calificados</span>
                  <span className="font-mono text-brand-red dark:text-rose-400">{resumen.leads}</span>
                </div>
              </div>
            </div>

            {/* Aviso Ético de Privacidad */}
            <div className="p-4 rounded-xl bg-slate-50 dark:bg-slate-800/40 border border-slate-200 dark:border-brand-charcoal-border text-xs text-slate-500 dark:text-slate-400 flex items-start gap-2.5">
              <ShieldCheck className="w-4 h-4 text-emerald-500 shrink-0 mt-0.5" />
              <p>
                El cálculo no utiliza técnicas invasivas ni datos DEMO ficticios. En caso de no existir visitantes dentro del período consultado, se evita la división entre cero mostrando 0.00%.
              </p>
            </div>
          </div>
        )}

        {/* Carga y Errores de Detalle */}
        {selectedIndicator !== 'conversion' && isDetailLoading && <TableSkeleton rows={5} />}

        {selectedIndicator !== 'conversion' && isDetailError && (
          <ErrorState
            title="Error al cargar el detalle del indicador"
            message={(detailErrorObj as Error)?.message || 'No se pudo obtener el desglose de registros.'}
          />
        )}

        {/* Tablas Específicas por Indicador */}
        {selectedIndicator !== 'conversion' && !isDetailLoading && !isDetailError && (
          <div>
            {totalDetailItems === 0 ? (
              <EmptyState
                icon={FileText}
                title="Sin registros en el período"
                description="No se encontraron registros que sustenten este indicador para el rango de fechas seleccionado."
              />
            ) : (
              <div className="space-y-4">
                <div className="overflow-x-auto rounded-xl border border-slate-200 dark:border-brand-charcoal-border">
                  <table className="w-full text-left border-collapse text-xs">
                    {/* ENCABEZADOS SEGÚN INDICADOR */}
                    <thead>
                      <tr className="border-b border-slate-200 dark:border-brand-charcoal-border bg-slate-50 dark:bg-slate-800/60 text-[11px] font-bold uppercase tracking-wider text-slate-500 dark:text-slate-400">
                        {selectedIndicator === 'visitas' && (
                          <>
                            <th className="py-2.5 px-3">ID Visita</th>
                            <th className="py-2.5 px-3">Navegador (Token)</th>
                            <th className="py-2.5 px-3">Fecha y Hora</th>
                            <th className="py-2.5 px-3">Canal Origen</th>
                            <th className="py-2.5 px-3">Campaña</th>
                            <th className="py-2.5 px-3">Dispositivo</th>
                          </>
                        )}
                        {selectedIndicator === 'visitantes' && (
                          <>
                            <th className="py-2.5 px-3">ID Visitante</th>
                            <th className="py-2.5 px-3">Identificador Anónimo</th>
                            <th className="py-2.5 px-3">Dispositivo</th>
                            <th className="py-2.5 px-3">Primera Visita</th>
                            <th className="py-2.5 px-3">Última Visita</th>
                            <th className="py-2.5 px-3 text-center">Accesos Período</th>
                          </>
                        )}
                        {selectedIndicator === 'visualizaciones_carta' && (
                          <>
                            <th className="py-2.5 px-3">ID Evento</th>
                            <th className="py-2.5 px-3">Navegador (Token)</th>
                            <th className="py-2.5 px-3">Fecha y Hora</th>
                            <th className="py-2.5 px-3">Ruta</th>
                            <th className="py-2.5 px-3">ID Visita</th>
                            <th className="py-2.5 px-3">Origen</th>
                          </>
                        )}
                        {selectedIndicator === 'visitantes_carta' && (
                          <>
                            <th className="py-2.5 px-3">ID Visitante</th>
                            <th className="py-2.5 px-3">Identificador Anónimo</th>
                            <th className="py-2.5 px-3">Dispositivo</th>
                            <th className="py-2.5 px-3">Primera Apertura Carta</th>
                            <th className="py-2.5 px-3">Última Apertura</th>
                            <th className="py-2.5 px-3 text-center">Vistas Carta</th>
                          </>
                        )}
                        {selectedIndicator === 'formularios' && (
                          <>
                            <th className="py-2.5 px-3">ID Form</th>
                            <th className="py-2.5 px-3">Persona / Contacto</th>
                            <th className="py-2.5 px-3">Plato Favorito</th>
                            <th className="py-2.5 px-3">Fecha Envío</th>
                            <th className="py-2.5 px-3">Origen</th>
                            <th className="py-2.5 px-3 text-center">Marketing</th>
                          </>
                        )}
                        {selectedIndicator === 'leads' && (
                          <>
                            <th className="py-2.5 px-3">ID Lead / Buyer</th>
                            <th className="py-2.5 px-3">Persona / Contacto</th>
                            <th className="py-2.5 px-3">Plato Favorito</th>
                            <th className="py-2.5 px-3">Fecha Conversión</th>
                            <th className="py-2.5 px-3">Plataforma</th>
                            <th className="py-2.5 px-3">Estado</th>
                          </>
                        )}
                      </tr>
                    </thead>

                    {/* CUERPO DE TABLA SEGÚN INDICADOR */}
                    <tbody className="divide-y divide-slate-100 dark:divide-brand-charcoal-border">
                      {/* Visitas Landing */}
                      {selectedIndicator === 'visitas' &&
                        (detailData?.items as VisitaDetailItem[] | undefined)?.map((row) => (
                          <tr key={row.id_visita} className="hover:bg-slate-50/70 dark:hover:bg-slate-800/40">
                            <td className="py-2.5 px-3 font-mono font-bold">#{row.id_visita}</td>
                            <td className="py-2.5 px-3 font-mono text-[11px] text-slate-500" title={row.token_visitante}>
                              {row.token_visitante_abreviado}
                            </td>
                            <td className="py-2.5 px-3 whitespace-nowrap">{row.fecha}</td>
                            <td className="py-2.5 px-3">
                              <Badge variant="outline" className="text-[11px]">
                                {row.canal_origen}
                              </Badge>
                            </td>
                            <td className="py-2.5 px-3 text-slate-400">{row.utm_campaign || '-'}</td>
                            <td className="py-2.5 px-3">
                              <span className="inline-flex items-center gap-1 text-[11px] text-slate-500">
                                {row.dispositivo_tipo === 'MOVIL' ? (
                                  <Smartphone className="w-3.5 h-3.5 text-blue-500" />
                                ) : (
                                  <Laptop className="w-3.5 h-3.5 text-slate-400" />
                                )}
                                {row.dispositivo_tipo}
                              </span>
                            </td>
                          </tr>
                        ))}

                      {/* Visitantes Landing */}
                      {selectedIndicator === 'visitantes' &&
                        (detailData?.items as VisitanteDetailItem[] | undefined)?.map((row) => (
                          <tr key={row.id_visitante} className="hover:bg-slate-50/70 dark:hover:bg-slate-800/40">
                            <td className="py-2.5 px-3 font-mono font-bold">#{row.id_visitante}</td>
                            <td className="py-2.5 px-3 font-mono text-[11px] text-slate-500" title={row.token_visitante}>
                              {row.token_visitante_abreviado}
                            </td>
                            <td className="py-2.5 px-3">
                              <span className="inline-flex items-center gap-1 text-[11px] text-slate-500">
                                {row.dispositivo_tipo === 'MOVIL' ? (
                                  <Smartphone className="w-3.5 h-3.5 text-indigo-500" />
                                ) : (
                                  <Laptop className="w-3.5 h-3.5 text-slate-400" />
                                )}
                                {row.dispositivo_tipo}
                              </span>
                            </td>
                            <td className="py-2.5 px-3 whitespace-nowrap">{row.primera_visita}</td>
                            <td className="py-2.5 px-3 whitespace-nowrap">{row.ultima_visita}</td>
                            <td className="py-2.5 px-3 text-center font-mono font-bold">
                              {row.total_accesos}
                            </td>
                          </tr>
                        ))}

                      {/* Visualizaciones Carta */}
                      {selectedIndicator === 'visualizaciones_carta' &&
                        (detailData?.items as VisualizacionCartaDetailItem[] | undefined)?.map((row) => (
                          <tr key={row.id_evento} className="hover:bg-slate-50/70 dark:hover:bg-slate-800/40">
                            <td className="py-2.5 px-3 font-mono font-bold">#{row.id_evento}</td>
                            <td className="py-2.5 px-3 font-mono text-[11px] text-slate-500" title={row.token_visitante}>
                              {row.token_visitante_abreviado}
                            </td>
                            <td className="py-2.5 px-3 whitespace-nowrap">{row.fecha}</td>
                            <td className="py-2.5 px-3">
                              <span className="font-mono text-amber-600 dark:text-amber-400 font-semibold">
                                {row.ruta}
                              </span>
                            </td>
                            <td className="py-2.5 px-3 font-mono">#{row.id_visita}</td>
                            <td className="py-2.5 px-3">
                              <Badge variant="outline" className="text-[11px]">
                                {row.canal_origen}
                              </Badge>
                            </td>
                          </tr>
                        ))}

                      {/* Visitantes Carta */}
                      {selectedIndicator === 'visitantes_carta' &&
                        (detailData?.items as VisitanteCartaDetailItem[] | undefined)?.map((row) => (
                          <tr key={row.id_visitante} className="hover:bg-slate-50/70 dark:hover:bg-slate-800/40">
                            <td className="py-2.5 px-3 font-mono font-bold">#{row.id_visitante}</td>
                            <td className="py-2.5 px-3 font-mono text-[11px] text-slate-500" title={row.token_visitante}>
                              {row.token_visitante_abreviado}
                            </td>
                            <td className="py-2.5 px-3">
                              <span className="inline-flex items-center gap-1 text-[11px] text-slate-500">
                                {row.dispositivo_tipo === 'MOVIL' ? (
                                  <Smartphone className="w-3.5 h-3.5 text-purple-500" />
                                ) : (
                                  <Laptop className="w-3.5 h-3.5 text-slate-400" />
                                )}
                                {row.dispositivo_tipo}
                              </span>
                            </td>
                            <td className="py-2.5 px-3 whitespace-nowrap">{row.primera_apertura}</td>
                            <td className="py-2.5 px-3 whitespace-nowrap">{row.ultima_apertura}</td>
                            <td className="py-2.5 px-3 text-center font-mono font-bold text-purple-600 dark:text-purple-400">
                              {row.total_visualizaciones}
                            </td>
                          </tr>
                        ))}

                      {/* Formularios */}
                      {selectedIndicator === 'formularios' &&
                        (detailData?.items as FormularioDetailItem[] | undefined)?.map((row) => (
                          <tr key={row.id_formulario} className="hover:bg-slate-50/70 dark:hover:bg-slate-800/40">
                            <td className="py-2.5 px-3 font-mono font-bold">#{row.id_formulario}</td>
                            <td className="py-2.5 px-3">
                              <p className="font-bold text-slate-900 dark:text-slate-100">{row.persona_nombre}</p>
                              <div className="flex items-center gap-2 text-[11px] text-slate-400">
                                <span className="font-mono">{row.telefono}</span>
                                {row.email && <span>· {row.email}</span>}
                              </div>
                            </td>
                            <td className="py-2.5 px-3">
                              <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-md bg-amber-50 dark:bg-amber-950/40 text-amber-700 dark:text-amber-300 border border-amber-200 dark:border-amber-800/50 text-[11px]">
                                <UtensilsCrossed className="w-3 h-3 shrink-0" />
                                <span className="truncate max-w-[130px]">{row.plato_favorito}</span>
                              </span>
                            </td>
                            <td className="py-2.5 px-3 whitespace-nowrap">{row.fecha_envio}</td>
                            <td className="py-2.5 px-3">
                              <Badge variant="outline" className="text-[11px]">
                                {row.origen}
                              </Badge>
                            </td>
                            <td className="py-2.5 px-3 text-center">
                              {row.acepta_marketing ? (
                                <CheckCircle2 className="w-4 h-4 text-emerald-500 inline" />
                              ) : (
                                <XCircle className="w-4 h-4 text-slate-400 inline" />
                              )}
                            </td>
                          </tr>
                        ))}

                      {/* LEADS */}
                      {selectedIndicator === 'leads' &&
                        (detailData?.items as LeadDetailItem[] | undefined)?.map((row) => (
                          <tr key={row.id_conversion} className="hover:bg-slate-50/70 dark:hover:bg-slate-800/40">
                            <td className="py-2.5 px-3 font-mono font-bold">
                              #{row.id_lead || row.id_conversion}
                            </td>
                            <td className="py-2.5 px-3">
                              <p className="font-bold text-slate-900 dark:text-slate-100">{row.persona_nombre}</p>
                              <div className="flex items-center gap-1.5 text-[11px] text-slate-400">
                                <span className="font-mono">{row.telefono}</span>
                                {row.telefono && (
                                  <a
                                    href={`https://wa.me/51${row.telefono.replace(/\\D/g, '')}`}
                                    target="_blank"
                                    rel="noopener noreferrer"
                                    className="text-emerald-500 hover:text-emerald-600"
                                    title="WhatsApp"
                                  >
                                    <MessageCircle className="w-3.5 h-3.5" />
                                  </a>
                                )}
                              </div>
                            </td>
                            <td className="py-2.5 px-3">
                              <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-md bg-amber-50 dark:bg-amber-950/40 text-amber-700 dark:text-amber-300 border border-amber-200 dark:border-amber-800/50 text-[11px]">
                                <UtensilsCrossed className="w-3 h-3 shrink-0" />
                                <span className="truncate max-w-[130px]">{row.plato_favorito}</span>
                              </span>
                            </td>
                            <td className="py-2.5 px-3 whitespace-nowrap">{row.fecha_conversion}</td>
                            <td className="py-2.5 px-3 font-mono text-[11px]">{row.plataforma_origen}</td>
                            <td className="py-2.5 px-3">
                              <Badge variant="outline" className="text-[11px] text-rose-600 border-rose-300">
                                {row.estado_buyer}
                              </Badge>
                            </td>
                          </tr>
                        ))}
                    </tbody>
                  </table>
                </div>

                {/* Controles de Paginación */}
                {totalPages > 1 && (
                  <div className="flex items-center justify-between pt-2">
                    <span className="text-xs text-slate-400">
                      Página <strong>{detailPage}</strong> de <strong>{totalPages}</strong> ({totalDetailItems} registros)
                    </span>
                    <div className="flex items-center gap-2">
                      <Button
                        variant="outline"
                        size="sm"
                        disabled={detailPage <= 1}
                        onClick={() => setDetailPage((p) => Math.max(1, p - 1))}
                        className="flex items-center gap-1"
                      >
                        <ChevronLeft className="w-4 h-4" />
                        <span>Anterior</span>
                      </Button>
                      <Button
                        variant="outline"
                        size="sm"
                        disabled={detailPage >= totalPages}
                        onClick={() => setDetailPage((p) => p + 1)}
                        className="flex items-center gap-1"
                      >
                        <span>Siguiente</span>
                        <ChevronRight className="w-4 h-4" />
                      </Button>
                    </div>
                  </div>
                )}
              </div>
            )}
          </div>
        )}
      </Modal>

      {/* Pie Informativo de Integración Multicanal */}
      <Card className="p-4 bg-slate-50/70 dark:bg-brand-charcoal/60 border border-slate-200 dark:border-brand-charcoal-border">
        <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3 text-xs text-slate-500 dark:text-slate-400">
          <div className="flex items-center gap-2">
            <Layers className="w-4 h-4 text-brand-red" />
            <span>
              <strong>Arquitectura Unificada BUYER:</strong> Haz clic en cualquiera de las 7 tarjetas para auditar los registros exactos que sustentan la métrica.
            </span>
          </div>
          <span className="font-mono text-[11px] shrink-0 text-slate-400">
            Plataforma ID: 3 (LANDING_PAGE)
          </span>
        </div>
      </Card>
    </div>
  );
};
