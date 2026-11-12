import React, { useState, useMemo } from 'react';
import { useQuery } from '@tanstack/react-query';
import {
  Users,
  Facebook,
  Instagram,
  Globe,
  Search,
  Filter,
  Eye,
  Calendar,
  ExternalLink,
  MessageCircle,
  Shield,
  UserCheck,
  UserX,
} from 'lucide-react';
import { ApiService } from '../services/api';
import { Card, CardHeader, CardTitle, CardContent } from '../components/ui/Card';
import { Badge } from '../components/ui/Badge';
import { Button } from '../components/ui/Button';
import { Modal } from '../components/ui/Modal';
import { TableSkeleton } from '../components/ui/Skeleton';
import { EmptyState } from '../components/ui/EmptyState';
import { ErrorState } from '../components/ui/ErrorState';
import { formatDate, maskExternalRef } from '../utils/format';
import type { BuyerItem, BuyerDetail } from '../types';

export const BuyersPage: React.FC = () => {
  const [platformFilter, setPlatformFilter] = useState<string>('');
  const [statusFilter, setStatusFilter] = useState<string>('');
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedBuyer, setSelectedBuyer] = useState<BuyerItem | null>(null);

  // Consulta de BUYERS con TanStack Query
  const {
    data: buyersData,
    isLoading,
    isError,
    refetch,
  } = useQuery({
    queryKey: ['buyers', platformFilter],
    queryFn: () =>
      ApiService.getBuyers({
        limit: 250,
        plataforma: platformFilter || undefined,
      }),
    refetchInterval: 15000,
  });

  // Consulta de detalle del BUYER seleccionado
  const {
    data: buyerDetail,
    isLoading: isDetailLoading,
  } = useQuery({
    queryKey: ['buyerDetail', selectedBuyer?.id_buyer],
    queryFn: () => (selectedBuyer ? ApiService.getBuyerDetail(selectedBuyer.id_buyer) : null),
    enabled: Boolean(selectedBuyer),
  });

  const buyers = buyersData?.items || [];

  // Filtrado compuesto
  const filteredBuyers = useMemo(() => {
    return buyers.filter((b) => {
      // Estado
      if (statusFilter && b.estado !== statusFilter) return false;

      // Búsqueda
      if (!searchTerm) return true;
      const term = searchTerm.toLowerCase();
      const refMatch = b.referencia_externa_enmascarada?.toLowerCase().includes(term);
      const idMatch = String(b.id_buyer).includes(term);
      const platMatch = b.plataforma_codigo?.toLowerCase().includes(term);
      return refMatch || idMatch || platMatch;
    });
  }, [buyers, statusFilter, searchTerm]);

  // Métricas
  const metrics = useMemo(() => {
    const total = buyers.length;
    const convertidos = buyers.filter((b) => b.estado === 'CONVERTIDO_LEAD').length;
    const fb = buyers.filter((b) => b.plataforma_codigo === 'FACEBOOK').length;
    const ig = buyers.filter((b) => b.plataforma_codigo === 'INSTAGRAM').length;
    const landing = buyers.filter((b) => b.plataforma_codigo === 'LANDING_PAGE').length;
    return { total, convertidos, fb, ig, landing };
  }, [buyers]);

  const renderStatusBadge = (status: string) => {
    switch (status) {
      case 'CONVERTIDO_LEAD':
        return (
          <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded text-[11px] font-semibold bg-emerald-50 text-emerald-700 border border-emerald-200 dark:bg-emerald-950/40 dark:text-emerald-300 dark:border-emerald-800">
            <UserCheck className="w-3 h-3" />
            CONVERTIDO A LEAD
          </span>
        );
      case 'DESCARTADO':
        return (
          <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded text-[11px] font-semibold bg-rose-50 text-rose-700 border border-rose-200 dark:bg-rose-950/40 dark:text-rose-300 dark:border-rose-800">
            <UserX className="w-3 h-3" />
            DESCARTADO
          </span>
        );
      default:
        return (
          <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded text-[11px] font-semibold bg-blue-50 text-blue-700 border border-blue-200 dark:bg-blue-950/40 dark:text-blue-300 dark:border-blue-800">
            <Users className="w-3 h-3" />
            BUYER ACTIVO
          </span>
        );
    }
  };

  return (
    <div className="space-y-6 animate-in fade-in duration-200">
      {/* Tarjetas de Métricas de BUYERS */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-6 gap-4">
        <Card className="border-l-4 border-l-brand-red">
          <CardContent className="p-4">
            <span className="text-xs text-slate-500 font-semibold uppercase">BUYERS Totales</span>
            <p className="text-2xl font-black text-slate-900 dark:text-slate-100 font-mono mt-0.5">
              {metrics.total}
            </p>
            <span className="text-[11px] text-emerald-600 dark:text-emerald-400 font-medium">
              Multicanal Integrado
            </span>
          </CardContent>
        </Card>

        <Card className="border-l-4 border-l-emerald-600">
          <CardContent className="p-4">
            <span className="text-xs text-slate-500 font-semibold uppercase">Convertidos a LEAD</span>
            <p className="text-2xl font-black text-slate-900 dark:text-slate-100 font-mono mt-0.5">
              {metrics.convertidos}
            </p>
            <span className="text-[11px] text-slate-400">Prospectos calificados</span>
          </CardContent>
        </Card>

        <Card className="border-l-4 border-l-blue-600">
          <CardContent className="p-4">
            <span className="text-xs text-slate-500 font-semibold uppercase">Desde Facebook</span>
            <p className="text-2xl font-black text-slate-900 dark:text-slate-100 font-mono mt-0.5">
              {metrics.fb}
            </p>
            <span className="text-[11px] text-slate-400">Comentarios en posts</span>
          </CardContent>
        </Card>

        <Card className="border-l-4 border-l-rose-500">
          <CardContent className="p-4">
            <span className="text-xs text-slate-500 font-semibold uppercase">Desde Instagram</span>
            <p className="text-2xl font-black text-slate-900 dark:text-slate-100 font-mono mt-0.5">
              {metrics.ig}
            </p>
            <span className="text-[11px] text-slate-400">Comentarios en media</span>
          </CardContent>
        </Card>

        <Card className="border-l-4 border-l-teal-600">
          <CardContent className="p-4">
            <span className="text-xs text-slate-500 font-semibold uppercase">Desde Landing Page</span>
            <p className="text-2xl font-black text-slate-900 dark:text-slate-100 font-mono mt-0.5">
              {metrics.landing}
            </p>
            <span className="text-[11px] text-slate-400">Formularios calificados</span>
          </CardContent>
        </Card>

        <Card className="border-l-4 border-l-slate-400">
          <CardContent className="p-4">
            <span className="text-xs text-slate-500 font-semibold uppercase">Privacidad</span>
            <p className="text-sm font-bold text-slate-900 dark:text-slate-100 mt-1">
              Enmascarado
            </p>
            <span className="text-[11px] text-slate-400">Sin exponer PII sensible</span>
          </CardContent>
        </Card>
      </div>

      {/* Card Principal con Tabla de BUYERS */}
      <Card>
        <CardHeader
          action={
            <span className="text-xs font-semibold px-2.5 py-1 rounded-full bg-slate-100 dark:bg-slate-800 text-slate-700 dark:text-slate-300">
              {filteredBuyers.length} prospectos listados
            </span>
          }
        >
          <CardTitle>
            <Users className="w-5 h-5 text-brand-success" />
            Prospectos Identificados (BUYERS)
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
              placeholder="Buscar por ID o referencia..."
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
              <option value="landing">Landing Page</option>
            </select>

            {/* Estado */}
            <select
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value)}
              className="px-2.5 py-1 text-xs rounded-lg border border-slate-300 dark:border-slate-600 bg-white dark:bg-slate-800 text-slate-700 dark:text-slate-200"
            >
              <option value="">Todos los estados</option>
              <option value="BUYER">BUYER</option>
              <option value="CONVERTIDO_LEAD">CONVERTIDO_LEAD</option>
              <option value="DESCARTADO">DESCARTADO</option>
            </select>
          </div>
        </div>

        {/* Tabla */}
        <CardContent className="p-0">
          {isLoading ? (
            <TableSkeleton rows={8} />
          ) : isError ? (
            <ErrorState
              title="Error al consultar prospectos BUYER"
              onRetry={() => refetch()}
            />
          ) : filteredBuyers.length === 0 ? (
            <EmptyState
              icon={Users}
              title="No hay BUYERS encontrados"
              description="No se hallaron prospectos con los filtros actuales o la búsqueda aplicada."
            />
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full text-left text-xs">
                <thead className="bg-slate-50 dark:bg-slate-800/60 text-slate-600 dark:text-slate-400 uppercase font-bold text-[10px] tracking-wider border-b border-slate-200 dark:border-slate-700">
                  <tr>
                    <th className="py-3 px-4">ID BUYER</th>
                    <th className="py-3 px-4">Plataforma</th>
                    <th className="py-3 px-4">Referencia Externa</th>
                    <th className="py-3 px-4">Publicación Origen</th>
                    <th className="py-3 px-4">Primer Contacto</th>
                    <th className="py-3 px-4">Interacciones</th>
                    <th className="py-3 px-4">Estado</th>
                    <th className="py-3 px-4 text-right">Acción</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-100 dark:divide-brand-charcoal-border">
                  {filteredBuyers.map((b) => {
                    return (
                      <tr
                        key={b.id_buyer}
                        className="hover:bg-slate-50/80 dark:hover:bg-slate-800/40 transition-colors"
                      >
                        <td className="py-3 px-4 font-mono font-bold text-slate-900 dark:text-slate-100 whitespace-nowrap">
                          #{b.id_buyer}
                        </td>
                        <td className="py-3 px-4 whitespace-nowrap">
                          <span className="inline-flex items-center gap-1.5 font-semibold">
                            {b.plataforma_codigo === 'FACEBOOK' ? (
                              <>
                                <Facebook className="w-4 h-4 text-blue-600" />
                                <span>Facebook</span>
                              </>
                            ) : b.plataforma_codigo === 'LANDING_PAGE' ? (
                              <>
                                <Globe className="w-4 h-4 text-emerald-600" />
                                <span>Landing Page</span>
                              </>
                            ) : (
                              <>
                                <Instagram className="w-4 h-4 text-rose-600" />
                                <span>Instagram</span>
                              </>
                            )}
                          </span>
                        </td>
                        <td className="py-3 px-4 font-mono text-[11px] text-slate-600 dark:text-slate-300 whitespace-nowrap">
                          <span className="inline-flex items-center gap-1">
                            <Shield className="w-3 h-3 text-slate-400" />
                            {maskExternalRef(b.referencia_externa_enmascarada)}
                          </span>
                        </td>
                        <td className="py-3 px-4 whitespace-nowrap text-slate-500 font-mono text-[11px]">
                          {b.id_publicacion_origen ? (
                            <span className="text-brand-red dark:text-rose-400 font-medium">
                              Post #{b.id_publicacion_origen}
                            </span>
                          ) : (
                            '—'
                          )}
                        </td>
                        <td className="py-3 px-4 whitespace-nowrap text-slate-500 dark:text-slate-400">
                          {formatDate(b.fecha_primer_contacto)}
                        </td>
                        <td className="py-3 px-4 font-mono font-semibold text-slate-700 dark:text-slate-300">
                          <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded bg-slate-100 dark:bg-slate-800 text-[11px]">
                            <MessageCircle className="w-3 h-3 text-brand-amber" />
                            {b.total_interacciones ?? 0}
                          </span>
                        </td>
                        <td className="py-3 px-4 whitespace-nowrap">
                          {renderStatusBadge(b.estado)}
                        </td>
                        <td className="py-3 px-4 text-right whitespace-nowrap">
                          <Button
                            size="sm"
                            variant="ghost"
                            onClick={() => setSelectedBuyer(b)}
                            leftIcon={<Eye className="w-3.5 h-3.5" />}
                            className="text-xs py-1"
                          >
                            Detalle
                          </Button>
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

      {/* Modal de Detalle de BUYER */}
      {selectedBuyer && (
        <Modal
          isOpen={Boolean(selectedBuyer)}
          onClose={() => setSelectedBuyer(null)}
          title={
            <span className="flex items-center gap-2">
              <Users className="w-5 h-5 text-brand-success" />
              Detalle del Prospecto BUYER #{selectedBuyer.id_buyer}
            </span>
          }
          description="Información de procedencia comercial y trazabilidad de interacciones."
          size="md"
        >
          <div className="space-y-4">
            {isDetailLoading ? (
              <TableSkeleton rows={3} />
            ) : (
              <div className="p-4 rounded-xl bg-slate-50 dark:bg-brand-charcoal border border-slate-200 dark:border-brand-charcoal-border space-y-3">
                <div className="flex items-center justify-between">
                  <span className="font-bold text-base text-slate-900 dark:text-slate-100">
                    BUYER #{selectedBuyer.id_buyer}
                  </span>
                  {renderStatusBadge(selectedBuyer.estado)}
                </div>

                <div className="grid grid-cols-2 gap-3 text-xs pt-2 border-t border-slate-200 dark:border-slate-700">
                  <div>
                    <span className="text-slate-400 block">Canal de Captación:</span>
                    <span className="font-semibold text-slate-700 dark:text-slate-300">
                      {selectedBuyer.plataforma_codigo}
                    </span>
                  </div>
                  <div>
                    <span className="text-slate-400 block">Primer Contacto:</span>
                    <span className="font-mono text-slate-700 dark:text-slate-300">
                      {formatDate(selectedBuyer.fecha_primer_contacto)}
                    </span>
                  </div>
                  <div>
                    <span className="text-slate-400 block">Referencia Enmascarada:</span>
                    <span className="font-mono font-medium text-slate-700 dark:text-slate-300">
                      {maskExternalRef(selectedBuyer.referencia_externa_enmascarada)}
                    </span>
                  </div>
                  <div>
                    <span className="text-slate-400 block">Interacciones:</span>
                    <span className="font-mono font-semibold text-brand-amber">
                      {selectedBuyer.total_interacciones} registradas
                    </span>
                  </div>
                </div>

                {buyerDetail?.persona && (
                  <div className="mt-3 p-3 rounded-lg bg-emerald-50 dark:bg-emerald-950/30 border border-emerald-200 dark:border-emerald-800 text-xs">
                    <p className="font-bold text-emerald-800 dark:text-emerald-200 mb-1">
                      Persona Vinculada en dbo.persona (LEAD):
                    </p>
                    <p className="text-emerald-900 dark:text-emerald-100">
                      {buyerDetail.persona.nombre_completo || 'Datos de lead disponibles'}
                    </p>
                    <p className="text-[11px] text-emerald-700 dark:text-emerald-300 mt-0.5">
                      Fase actual: {buyerDetail.persona.fase_actual}
                    </p>
                  </div>
                )}

                <div className="p-3 rounded-lg bg-slate-100 dark:bg-slate-800/60 text-[11px] text-slate-500 space-y-1">
                  <p className="font-semibold text-slate-700 dark:text-slate-300">
                    Políticas de Conversión:
                  </p>
                  <p>
                    La conversión de BUYER a LEAD respeta la lógica transaccional de backend y el consentimiento informado de datos del restaurante.
                  </p>
                </div>
              </div>
            )}
          </div>
        </Modal>
      )}
    </div>
  );
};
