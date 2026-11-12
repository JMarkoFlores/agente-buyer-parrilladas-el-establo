import React, { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import {
  Globe,
  Users,
  Eye,
  MousePointerClick,
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
} from 'lucide-react';
import { ApiService } from '../services/api';
import { Card, CardHeader, CardTitle, CardContent } from '../components/ui/Card';
import { Badge } from '../components/ui/Badge';
import { Button } from '../components/ui/Button';
import { TableSkeleton } from '../components/ui/Skeleton';
import { EmptyState } from '../components/ui/EmptyState';
import { ErrorState } from '../components/ui/ErrorState';

export const LandingPage: React.FC = () => {
  const [dateFilter, setDateFilter] = useState<'todo' | 'hoy' | '7dias' | '30dias'>('todo');

  // Calcular fechas según filtro
  const queryDates = React.useMemo(() => {
    const hoy = new Date();
    const formato = (d: Date) => d.toISOString().slice(0, 10);

    if (dateFilter === 'hoy') {
      const fechaStr = formato(hoy);
      return { fecha_inicio: fechaStr, fecha_fin: fechaStr };
    }
    if (dateFilter === '7dias') {
      const pasada = new Date();
      pasada.setDate(hoy.getDate() - 7);
      return { fecha_inicio: formato(pasada), fecha_fin: formato(hoy) };
    }
    if (dateFilter === '30dias') {
      const pasada = new Date();
      pasada.setDate(hoy.getDate() - 30);
      return { fecha_inicio: formato(pasada), fecha_fin: formato(hoy) };
    }
    return {};
  }, [dateFilter]);

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
    total_visitas: 0,
    visitantes_unicos: 0,
    clics_carta: 0,
    visitas_carta: 0,
    formularios_exitosos: 0,
    leads_nuevos: 0,
    tasa_conversion: 0,
  };

  const visitasPorDia = statsData?.visitas_por_dia || [];
  const formulariosRecientes = statsData?.formularios_recientes || [];

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
            Métricas reales de tráfico web, interacción con la carta y conversión BUYER → LEAD en Parrilladas El Establo.
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
            href="http://localhost:4321"
            target="_blank"
            rel="noopener noreferrer"
            className="inline-flex items-center gap-1.5 px-3 py-1.5 text-xs font-semibold text-slate-700 dark:text-slate-200 bg-slate-100 dark:bg-slate-800 hover:bg-slate-200 dark:hover:bg-slate-700 rounded-lg transition-colors"
          >
            <span>Ver Landing</span>
            <ExternalLink className="w-3.5 h-3.5" />
          </a>
        </div>
      </div>

      {/* Manejo de Error */}
      {isError && (
        <ErrorState
          title="Error al cargar métricas de la landing page"
          message={(error as Error)?.message || 'No se pudo conectar con el endpoint de analítica.'}
          onRetry={() => refetch()}
        />
      )}

      {/* Grid de 7 Tarjetas de Métricas Principales */}
      <div className="grid grid-cols-2 gap-4 sm:grid-cols-3 lg:grid-cols-4 xl:grid-cols-7">
        {/* 1. Total Visitas */}
        <Card className="p-4 border-l-4 border-l-blue-500">
          <div className="flex items-center justify-between text-slate-500 dark:text-slate-400">
            <span className="text-xs font-semibold uppercase tracking-wider">Visitas</span>
            <Eye className="w-4 h-4 text-blue-500" />
          </div>
          <p className="mt-2 text-2xl font-bold tracking-tight text-slate-900 dark:text-slate-100">
            {isLoading ? '...' : resumen.total_visitas.toLocaleString()}
          </p>
          <span className="text-[11px] text-slate-400 dark:text-slate-500">Sesiones iniciadas</span>
        </Card>

        {/* 2. Visitantes Únicos */}
        <Card className="p-4 border-l-4 border-l-indigo-500">
          <div className="flex items-center justify-between text-slate-500 dark:text-slate-400">
            <span className="text-xs font-semibold uppercase tracking-wider">Visitantes</span>
            <Users className="w-4 h-4 text-indigo-500" />
          </div>
          <p className="mt-2 text-2xl font-bold tracking-tight text-slate-900 dark:text-slate-100">
            {isLoading ? '...' : resumen.visitantes_unicos.toLocaleString()}
          </p>
          <span className="text-[11px] text-slate-400 dark:text-slate-500">Dispositivos únicos</span>
        </Card>

        {/* 3. Clics en Carta */}
        <Card className="p-4 border-l-4 border-l-amber-500">
          <div className="flex items-center justify-between text-slate-500 dark:text-slate-400">
            <span className="text-xs font-semibold uppercase tracking-wider">Clics Carta</span>
            <MousePointerClick className="w-4 h-4 text-amber-500" />
          </div>
          <p className="mt-2 text-2xl font-bold tracking-tight text-slate-900 dark:text-slate-100">
            {isLoading ? '...' : resumen.clics_carta.toLocaleString()}
          </p>
          <span className="text-[11px] text-slate-400 dark:text-slate-500">Interacción &quot;Ver carta&quot;</span>
        </Card>

        {/* 4. Visitas a la Carta */}
        <Card className="p-4 border-l-4 border-l-purple-500">
          <div className="flex items-center justify-between text-slate-500 dark:text-slate-400">
            <span className="text-xs font-semibold uppercase tracking-wider">Vistas Carta</span>
            <UtensilsCrossed className="w-4 h-4 text-purple-500" />
          </div>
          <p className="mt-2 text-2xl font-bold tracking-tight text-slate-900 dark:text-slate-100">
            {isLoading ? '...' : resumen.visitas_carta.toLocaleString()}
          </p>
          <span className="text-[11px] text-slate-400 dark:text-slate-500">Ruta /carta/ vista</span>
        </Card>

        {/* 5. Formularios Recibidos */}
        <Card className="p-4 border-l-4 border-l-emerald-500">
          <div className="flex items-center justify-between text-slate-500 dark:text-slate-400">
            <span className="text-xs font-semibold uppercase tracking-wider">Formularios</span>
            <FileText className="w-4 h-4 text-emerald-500" />
          </div>
          <p className="mt-2 text-2xl font-bold tracking-tight text-slate-900 dark:text-slate-100">
            {isLoading ? '...' : resumen.formularios_exitosos.toLocaleString()}
          </p>
          <span className="text-[11px] text-slate-400 dark:text-slate-500">Captaciones válidas</span>
        </Card>

        {/* 6. LEADS Nuevos */}
        <Card className="p-4 border-l-4 border-l-rose-500">
          <div className="flex items-center justify-between text-slate-500 dark:text-slate-400">
            <span className="text-xs font-semibold uppercase tracking-wider">LEADS</span>
            <UserCheck className="w-4 h-4 text-rose-500" />
          </div>
          <p className="mt-2 text-2xl font-bold tracking-tight text-slate-900 dark:text-slate-100">
            {isLoading ? '...' : resumen.leads_nuevos.toLocaleString()}
          </p>
          <span className="text-[11px] text-slate-400 dark:text-slate-500">Convertidos a LEAD</span>
        </Card>

        {/* 7. Tasa de Conversión */}
        <Card className="p-4 border-l-4 border-l-brand-red bg-gradient-to-br from-white to-red-50/30 dark:from-brand-charcoal dark:to-red-950/20">
          <div className="flex items-center justify-between text-slate-500 dark:text-slate-400">
            <span className="text-xs font-bold uppercase tracking-wider text-brand-red dark:text-rose-400">Conversión</span>
            <TrendingUp className="w-4 h-4 text-brand-red dark:text-rose-400" />
          </div>
          <p className="mt-2 text-2xl font-extrabold tracking-tight text-brand-red dark:text-rose-400">
            {isLoading ? '...' : `${resumen.tasa_conversion}%`}
          </p>
          <span className="text-[11px] text-slate-400 dark:text-slate-500">LEADS / Visitantes</span>
        </Card>
      </div>

      {/* Sección Doble: Gráfico Diario y Resumen */}
      <div className="grid grid-cols-1 gap-6 lg:grid-cols-3">
        {/* Serie Temporal de Visitas por Día */}
        <Card className="lg:col-span-1">
          <CardHeader>
            <CardTitle className="text-base flex items-center gap-2">
              <Calendar className="w-4 h-4 text-slate-500" />
              <span>Visitas por Día</span>
            </CardTitle>
          </CardHeader>
          <CardContent>
            {isLoading ? (
              <TableSkeleton rows={4} />
            ) : visitasPorDia.length === 0 ? (
              <EmptyState
                icon={Calendar}
                title="Sin datos diarios"
                description="No hay visitas registradas para el período seleccionado."
              />
            ) : (
              <div className="space-y-3">
                {visitasPorDia.map((item) => (
                  <div
                    key={item.fecha}
                    className="flex items-center justify-between p-2.5 rounded-lg bg-slate-50 dark:bg-slate-800/60 border border-slate-100 dark:border-slate-800"
                  >
                    <div>
                      <p className="text-xs font-bold text-slate-800 dark:text-slate-200">{item.fecha}</p>
                      <p className="text-[11px] text-slate-400">{item.visitantes} visitantes únicos</p>
                    </div>
                    <Badge variant="outline" className="font-mono text-xs font-semibold">
                      {item.visitas} visitas
                    </Badge>
                  </div>
                ))}
              </div>
            )}
          </CardContent>
        </Card>

        {/* Tabla de Formularios y LEADS Recientes */}
        <Card className="lg:col-span-2">
          <CardHeader>
            <div className="flex items-center justify-between">
              <CardTitle className="text-base flex items-center gap-2">
                <FileText className="w-4 h-4 text-brand-red" />
                <span>LEADS Captados Recientemente</span>
              </CardTitle>
              <Badge variant="outline" className="text-xs">
                {formulariosRecientes.length} registros
              </Badge>
            </div>
          </CardHeader>
          <CardContent>
            {isLoading ? (
              <TableSkeleton rows={5} />
            ) : formulariosRecientes.length === 0 ? (
              <EmptyState
                icon={FileText}
                title="Sin formularios recientes"
                description="Aún no se han recibido registros a través del formulario de captación."
              />
            ) : (
              <div className="overflow-x-auto">
                <table className="w-full text-left border-collapse">
                  <thead>
                    <tr className="border-b border-slate-200 dark:border-brand-charcoal-border text-[11px] font-bold uppercase tracking-wider text-slate-400">
                      <th className="py-2.5 px-3">Lead / Persona</th>
                      <th className="py-2.5 px-3">Contacto</th>
                      <th className="py-2.5 px-3">Plato Favorito</th>
                      <th className="py-2.5 px-3">Origen UTM</th>
                      <th className="py-2.5 px-3">Fecha</th>
                      <th className="py-2.5 px-3 text-center">Marketing</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-slate-100 dark:divide-brand-charcoal-border text-xs">
                    {formulariosRecientes.map((form) => (
                      <tr
                        key={form.id_formulario}
                        className="hover:bg-slate-50/80 dark:hover:bg-slate-800/40 transition-colors"
                      >
                        <td className="py-3 px-3">
                          <p className="font-bold text-slate-900 dark:text-slate-100">{form.persona_nombre}</p>
                          <span className="text-[11px] text-slate-400">ID #{form.id_formulario}</span>
                        </td>
                        <td className="py-3 px-3">
                          <div className="flex items-center gap-1.5">
                            <span className="font-mono text-slate-700 dark:text-slate-300">{form.telefono}</span>
                            {form.telefono && (
                              <a
                                href={`https://wa.me/51${form.telefono}`}
                                target="_blank"
                                rel="noopener noreferrer"
                                className="text-emerald-500 hover:text-emerald-600"
                                title="Abrir en WhatsApp"
                              >
                                <MessageCircle className="w-3.5 h-3.5" />
                              </a>
                            )}
                          </div>
                          {form.email && <p className="text-[11px] text-slate-400 truncate max-w-[150px]">{form.email}</p>}
                        </td>
                        <td className="py-3 px-3">
                          <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-md bg-amber-50 dark:bg-amber-950/40 text-amber-700 dark:text-amber-300 border border-amber-200 dark:border-amber-800/50 text-[11px] font-medium">
                            <UtensilsCrossed className="w-3 h-3 shrink-0" />
                            <span className="truncate max-w-[140px]">{form.plato_favorito}</span>
                          </span>
                        </td>
                        <td className="py-3 px-3">
                          <Badge variant="outline" className="text-[11px]">
                            {form.utm_source}
                          </Badge>
                          {form.utm_campaign && (
                            <p className="text-[10px] text-slate-400 mt-0.5 truncate max-w-[120px]">
                              {form.utm_campaign}
                            </p>
                          )}
                        </td>
                        <td className="py-3 px-3 text-slate-500 dark:text-slate-400 whitespace-nowrap">
                          {form.fecha_envio}
                        </td>
                        <td className="py-3 px-3 text-center">
                          {form.acepta_marketing ? (
                            <span className="inline-flex text-emerald-500" title="Aceptó promociones">
                              <CheckCircle2 className="w-4 h-4" />
                            </span>
                          ) : (
                            <span className="inline-flex text-slate-300 dark:text-slate-600" title="No aceptó">
                              <XCircle className="w-4 h-4" />
                            </span>
                          )}
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
          </CardContent>
        </Card>
      </div>

      {/* Tarjeta Informativa de Integración Multicanal */}
      <Card className="p-4 bg-slate-50/70 dark:bg-brand-charcoal/60 border border-slate-200 dark:border-brand-charcoal-border">
        <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3 text-xs text-slate-500 dark:text-slate-400">
          <div className="flex items-center gap-2">
            <Layers className="w-4 h-4 text-brand-red" />
            <span>
              <strong>Arquitectura Unificada BUYER:</strong> Los LEADS captados en la landing quedan centralizados en la base de datos SQL Server (<code className="font-mono text-brand-red dark:text-rose-400">buyer</code>), reconciliados con los agentes de Facebook e Instagram.
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
