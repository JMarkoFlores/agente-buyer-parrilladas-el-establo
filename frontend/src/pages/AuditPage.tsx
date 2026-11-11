import React, { useState, useMemo } from 'react';
import { useQuery } from '@tanstack/react-query';
import {
  ClipboardList,
  Search,
  Filter,
  RotateCw,
  CheckCircle2,
  XCircle,
  Clock,
  Bot,
  Users,
} from 'lucide-react';
import { ApiService } from '../services/api';
import { Card, CardHeader, CardTitle, CardContent } from '../components/ui/Card';
import { Button } from '../components/ui/Button';
import { Badge } from '../components/ui/Badge';
import { TableSkeleton } from '../components/ui/Skeleton';
import { EmptyState } from '../components/ui/EmptyState';
import { ErrorState } from '../components/ui/ErrorState';
import { formatDate } from '../utils/format';
import type { AuditItem } from '../types';

export const AuditPage: React.FC = () => {
  const [agentFilter, setAgentFilter] = useState('');
  const [resultFilter, setResultFilter] = useState('');
  const [actionFilter, setActionFilter] = useState('');
  const [searchTerm, setSearchTerm] = useState('');

  // Consulta de actividad de auditoría
  const {
    data: auditData,
    isLoading,
    isError,
    refetch,
    isFetching,
  } = useQuery({
    queryKey: ['auditActivity', agentFilter, resultFilter, actionFilter],
    queryFn: () =>
      ApiService.getAgentsActivity({
        limit: 150,
        agente: agentFilter || undefined,
        resultado: resultFilter || undefined,
        accion: actionFilter || undefined,
      }),
    refetchInterval: 15000,
  });

  const items = auditData?.items || [];

  // Filtrado local por término de búsqueda
  const filteredItems = useMemo(() => {
    if (!searchTerm) return items;
    const term = searchTerm.toLowerCase();
    return items.filter((item) => {
      const matchAgente = item.nombre_agente?.toLowerCase().includes(term);
      const matchAccion = item.accion?.toLowerCase().includes(term);
      const matchDetalle = item.detalles?.toLowerCase().includes(term);
      const matchBuyer = item.id_buyer_asociado && String(item.id_buyer_asociado).includes(term);
      return matchAgente || matchAccion || matchDetalle || matchBuyer;
    });
  }, [items, searchTerm]);

  const renderResultBadge = (result: string) => {
    switch (result?.toUpperCase()) {
      case 'EXITOSO':
        return (
          <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded text-[11px] font-bold bg-emerald-50 text-emerald-700 border border-emerald-200 dark:bg-emerald-950/40 dark:text-emerald-300 dark:border-emerald-800">
            <CheckCircle2 className="w-3 h-3 text-emerald-600" />
            EXITOSO
          </span>
        );
      case 'FALLIDO':
        return (
          <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded text-[11px] font-bold bg-rose-50 text-rose-700 border border-rose-200 dark:bg-rose-950/40 dark:text-rose-300 dark:border-rose-800">
            <XCircle className="w-3 h-3 text-rose-600" />
            FALLIDO
          </span>
        );
      default:
        return (
          <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded text-[11px] font-bold bg-amber-50 text-amber-700 border border-amber-200 dark:bg-amber-950/40 dark:text-amber-300 dark:border-amber-800">
            <Clock className="w-3 h-3 text-amber-600" />
            PENDIENTE
          </span>
        );
    }
  };

  return (
    <div className="space-y-6 animate-in fade-in duration-200">
      <Card>
        <CardHeader
          action={
            <Button
              size="sm"
              variant="outline"
              onClick={() => refetch()}
              isLoading={isFetching}
              leftIcon={<RotateCw className="w-3.5 h-3.5" />}
            >
              Recargar Bitácora
            </Button>
          }
        >
          <CardTitle>
            <ClipboardList className="w-5 h-5 text-slate-700 dark:text-slate-300" />
            Auditoría de Acciones de Agentes (dbo.accion_agente)
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
              placeholder="Buscar en acción, detalle o agente..."
              className="w-full pl-9 pr-3 py-1.5 text-xs rounded-lg border border-slate-300 dark:border-slate-600 bg-white dark:bg-slate-800 text-slate-900 dark:text-slate-100 focus:outline-none focus:ring-1 focus:ring-brand-red"
            />
          </div>

          <div className="flex flex-wrap items-center gap-2">
            {/* Agente */}
            <select
              value={agentFilter}
              onChange={(e) => setAgentFilter(e.target.value)}
              className="px-2.5 py-1 text-xs rounded-lg border border-slate-300 dark:border-slate-600 bg-white dark:bg-slate-800 text-slate-700 dark:text-slate-200"
            >
              <option value="">Todos los agentes</option>
              <option value="AgenteFacebook">AgenteFacebook</option>
              <option value="AgenteInstagram">AgenteInstagram</option>
              <option value="AgenteCoordinador">AgenteCoordinador</option>
              <option value="BuyerCoordinator">BuyerCoordinator</option>
            </select>

            {/* Resultado */}
            <select
              value={resultFilter}
              onChange={(e) => setResultFilter(e.target.value)}
              className="px-2.5 py-1 text-xs rounded-lg border border-slate-300 dark:border-slate-600 bg-white dark:bg-slate-800 text-slate-700 dark:text-slate-200"
            >
              <option value="">Todos los resultados</option>
              <option value="EXITOSO">EXITOSO</option>
              <option value="FALLIDO">FALLIDO</option>
              <option value="PENDIENTE">PENDIENTE</option>
            </select>
          </div>
        </div>

        {/* Tabla */}
        <CardContent className="p-0">
          {isLoading ? (
            <TableSkeleton rows={8} />
          ) : isError ? (
            <ErrorState
              title="Error al consultar historial de auditoría"
              onRetry={() => refetch()}
            />
          ) : filteredItems.length === 0 ? (
            <EmptyState
              icon={ClipboardList}
              title="No hay registros de auditoría"
              description="No se encontraron acciones registradas con los filtros seleccionados."
            />
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full text-left text-xs font-mono">
                <thead className="bg-slate-50 dark:bg-slate-800/60 text-slate-600 dark:text-slate-400 uppercase font-bold text-[10px] tracking-wider border-b border-slate-200 dark:border-slate-700 font-sans">
                  <tr>
                    <th className="py-3 px-4">Fecha y Hora</th>
                    <th className="py-3 px-4">Agente</th>
                    <th className="py-3 px-4">Acción</th>
                    <th className="py-3 px-4">Resultado</th>
                    <th className="py-3 px-4">Detalle de Operación</th>
                    <th className="py-3 px-4">BUYER Asociado</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-100 dark:divide-brand-charcoal-border">
                  {filteredItems.map((item) => (
                    <tr
                      key={item.id_accion}
                      className="hover:bg-slate-50/80 dark:hover:bg-slate-800/40 transition-colors"
                    >
                      <td className="py-3 px-4 whitespace-nowrap text-slate-500 dark:text-slate-400 text-[11px]">
                        {formatDate(item.fecha_ejecucion)}
                      </td>
                      <td className="py-3 px-4 whitespace-nowrap font-bold text-slate-800 dark:text-slate-200 font-sans">
                        <span className="inline-flex items-center gap-1.5">
                          <Bot className="w-3.5 h-3.5 text-slate-500" />
                          {item.nombre_agente}
                        </span>
                      </td>
                      <td className="py-3 px-4 whitespace-nowrap text-slate-700 dark:text-slate-300 font-semibold text-[11px]">
                        {item.accion}
                      </td>
                      <td className="py-3 px-4 whitespace-nowrap font-sans">
                        {renderResultBadge(item.resultado)}
                      </td>
                      <td className="py-3 px-4 text-slate-600 dark:text-slate-400 max-w-sm sm:max-w-md truncate text-[11px]">
                        {item.detalles || '—'}
                      </td>
                      <td className="py-3 px-4 whitespace-nowrap text-slate-500 text-[11px]">
                        {item.id_buyer_asociado ? (
                          <span className="inline-flex items-center gap-1 px-1.5 py-0.5 rounded bg-slate-100 dark:bg-slate-800 text-slate-700 dark:text-slate-300">
                            <Users className="w-3 h-3" />
                            #{item.id_buyer_asociado}
                          </span>
                        ) : (
                          '—'
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
  );
};
