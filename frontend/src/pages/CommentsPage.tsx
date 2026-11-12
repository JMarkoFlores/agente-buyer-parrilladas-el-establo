import React, { useState, useMemo } from 'react';
import { useQuery } from '@tanstack/react-query';
import {
  MessageSquare,
  Facebook,
  Instagram,
  Filter,
  Search,
  Users,
  Eye,
  Sparkles,
  ExternalLink,
  Target,
} from 'lucide-react';
import { ApiService } from '../services/api';
import { Card, CardHeader, CardTitle, CardContent } from '../components/ui/Card';
import { Badge } from '../components/ui/Badge';
import { Button } from '../components/ui/Button';
import { Modal } from '../components/ui/Modal';
import { TableSkeleton } from '../components/ui/Skeleton';
import { EmptyState } from '../components/ui/EmptyState';
import { ErrorState } from '../components/ui/ErrorState';
import { IntentDistributionChart } from '../components/charts/IntentDistributionChart';
import { formatDate, formatNombreUsuario } from '../utils/format';
import type { CommentItem } from '../types';

export const CommentsPage: React.FC = () => {
  const [platformFilter, setPlatformFilter] = useState<string>('');
  const [intentFilter, setIntentFilter] = useState<string>('');
  const [buyerFilter, setBuyerFilter] = useState<'ALL' | 'WITH_BUYER' | 'WITHOUT_BUYER'>('ALL');
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedComment, setSelectedComment] = useState<CommentItem | null>(null);

  // Consulta de comentarios con TanStack Query
  const {
    data: commentsData,
    isLoading,
    isError,
    refetch,
  } = useQuery({
    queryKey: ['comments', platformFilter, intentFilter],
    queryFn: () =>
      ApiService.getComments({
        limit: 250,
        plataforma: platformFilter || undefined,
        intencion: intentFilter || undefined,
      }),
    refetchInterval: 10000,
  });

  const comments = commentsData?.items || [];

  // Filtrado compuesto
  const filteredComments = useMemo(() => {
    return comments.filter((c) => {
      // Buyer asociado
      if (buyerFilter === 'WITH_BUYER' && !c.id_buyer) return false;
      if (buyerFilter === 'WITHOUT_BUYER' && c.id_buyer) return false;

      // Búsqueda
      if (!searchTerm) return true;
      const term = searchTerm.toLowerCase();
      const textMatch = c.texto?.toLowerCase().includes(term);
      const userMatch = c.nombre_usuario?.toLowerCase().includes(term);
      return textMatch || userMatch;
    });
  }, [comments, buyerFilter, searchTerm]);

  // Conteo de intenciones para el gráfico
  const intentCounts = useMemo(() => {
    const counts: Record<string, number> = {
      CONSULTA_PRECIO: 0,
      INTERES_PRODUCTO: 0,
      CONSULTA_PROMOCION: 0,
      CONSULTA_UBICACION: 0,
      CONSULTA_HORARIO: 0,
      CONSULTA_RESERVA: 0,
      OTRO: 0,
    };
    filteredComments.forEach((c) => {
      const intent = c.clasificacion_intencion || 'OTRO';
      counts[intent] = (counts[intent] || 0) + 1;
    });
    return counts;
  }, [filteredComments]);

  // Métricas
  const metrics = useMemo(() => {
    const total = comments.length;
    const fb = comments.filter((c) => c.plataforma === 'FACEBOOK').length;
    const ig = comments.filter((c) => c.plataforma === 'INSTAGRAM').length;
    const clasificados = comments.filter(
      (c) => c.clasificacion_intencion && c.clasificacion_intencion !== 'OTRO'
    ).length;
    const conBuyer = comments.filter((c) => Boolean(c.id_buyer)).length;
    return { total, fb, ig, clasificados, conBuyer };
  }, [comments]);

  return (
    <div className="space-y-6 animate-in fade-in duration-200">
      {/* Tarjetas de Métricas de Comentarios */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-5 gap-4">
        <Card className="border-l-4 border-l-amber-500">
          <CardContent className="p-4">
            <span className="text-xs text-slate-500 font-semibold uppercase">Total Comentarios</span>
            <p className="text-2xl font-black text-slate-900 dark:text-slate-100 font-mono mt-0.5">
              {metrics.total}
            </p>
            <span className="text-[11px] text-slate-400">Captados en BD</span>
          </CardContent>
        </Card>

        <Card className="border-l-4 border-l-blue-600">
          <CardContent className="p-4">
            <span className="text-xs text-slate-500 font-semibold uppercase">Facebook</span>
            <p className="text-2xl font-black text-slate-900 dark:text-slate-100 font-mono mt-0.5">
              {metrics.fb}
            </p>
            <span className="text-[11px] text-slate-400">Página oficial</span>
          </CardContent>
        </Card>

        <Card className="border-l-4 border-l-rose-500">
          <CardContent className="p-4">
            <span className="text-xs text-slate-500 font-semibold uppercase">Instagram</span>
            <p className="text-2xl font-black text-slate-900 dark:text-slate-100 font-mono mt-0.5">
              {metrics.ig}
            </p>
            <span className="text-[11px] text-slate-400">Media & Reels</span>
          </CardContent>
        </Card>

        <Card className="border-l-4 border-l-emerald-600">
          <CardContent className="p-4">
            <span className="text-xs text-slate-500 font-semibold uppercase">Clasificados</span>
            <p className="text-2xl font-black text-slate-900 dark:text-slate-100 font-mono mt-0.5">
              {metrics.clasificados}
            </p>
            <span className="text-[11px] text-slate-400">Con intención clave</span>
          </CardContent>
        </Card>

        <Card className="border-l-4 border-l-purple-600">
          <CardContent className="p-4">
            <span className="text-xs text-slate-500 font-semibold uppercase">Con BUYER</span>
            <p className="text-2xl font-black text-slate-900 dark:text-slate-100 font-mono mt-0.5">
              {metrics.conBuyer}
            </p>
            <span className="text-[11px] text-slate-400">Vinculados a prospectos</span>
          </CardContent>
        </Card>
      </div>

      {/* Gráfico de Distribución de Intenciones */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div className="lg:col-span-1">
          <IntentDistributionChart intentCounts={intentCounts} />
        </div>

        {/* Panel Explicativo de Intenciones */}
        <div className="lg:col-span-2">
          <Card className="h-full flex flex-col justify-between">
            <CardHeader>
              <CardTitle>
                <Sparkles className="w-5 h-5 text-brand-amber" />
                Categorías de Intención Detectadas
              </CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-xs text-slate-600 dark:text-slate-300 mb-4 leading-relaxed">
                El clasificador inteligente analiza cada comentario mediante reglas semánticas y patrones de intención comercial de Parrilladas El Establo:
              </p>
              <div className="grid grid-cols-2 sm:grid-cols-3 gap-3">
                <div className="p-3 rounded-xl border border-emerald-200 dark:border-emerald-800/60 bg-emerald-50/50 dark:bg-emerald-950/20">
                  <Badge variant="intent" intent="CONSULTA_PRECIO">Precio</Badge>
                  <p className="text-[11px] text-slate-600 dark:text-slate-300 mt-1.5">
                    Consultas de costo, carta, cuánto cuesta.
                  </p>
                </div>
                <div className="p-3 rounded-xl border border-blue-200 dark:border-blue-800/60 bg-blue-50/50 dark:bg-blue-950/20">
                  <Badge variant="intent" intent="INTERES_PRODUCTO">Producto</Badge>
                  <p className="text-[11px] text-slate-600 dark:text-slate-300 mt-1.5">
                    Cortes, carnes, parrillas, guarniciones.
                  </p>
                </div>
                <div className="p-3 rounded-xl border border-amber-200 dark:border-amber-800/60 bg-amber-50/50 dark:bg-amber-950/20">
                  <Badge variant="intent" intent="CONSULTA_PROMOCION">Promoción</Badge>
                  <p className="text-[11px] text-slate-600 dark:text-slate-300 mt-1.5">
                    Ofertas, combos, descuentos especiales.
                  </p>
                </div>
                <div className="p-3 rounded-xl border border-purple-200 dark:border-purple-800/60 bg-purple-50/50 dark:bg-purple-950/20">
                  <Badge variant="intent" intent="CONSULTA_UBICACION">Ubicación</Badge>
                  <p className="text-[11px] text-slate-600 dark:text-slate-300 mt-1.5">
                    Dirección, sedes, locales, cómo llegar.
                  </p>
                </div>
                <div className="p-3 rounded-xl border border-cyan-200 dark:border-cyan-800/60 bg-cyan-50/50 dark:bg-cyan-950/20">
                  <Badge variant="intent" intent="CONSULTA_HORARIO">Horario</Badge>
                  <p className="text-[11px] text-slate-600 dark:text-slate-300 mt-1.5">
                    Horas de atención, apertura y cierre.
                  </p>
                </div>
                <div className="p-3 rounded-xl border border-rose-200 dark:border-rose-800/60 bg-rose-50/50 dark:bg-rose-950/20">
                  <Badge variant="intent" intent="CONSULTA_RESERVA">Reserva</Badge>
                  <p className="text-[11px] text-slate-600 dark:text-slate-300 mt-1.5">
                    Mesas, eventos, cumpleaños, reservas.
                  </p>
                </div>
              </div>
            </CardContent>
          </Card>
        </div>
      </div>

      {/* Card Principal con Tabla de Comentarios */}
      <Card>
        <CardHeader
          action={
            <span className="text-xs font-semibold px-2.5 py-1 rounded-full bg-slate-100 dark:bg-slate-800 text-slate-700 dark:text-slate-300">
              {filteredComments.length} comentarios listados
            </span>
          }
        >
          <CardTitle>
            <MessageSquare className="w-5 h-5 text-brand-amber" />
            Comentarios Captados y Clasificación de Intención
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
              placeholder="Buscar en comentario o usuario..."
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

            {/* Intención */}
            <select
              value={intentFilter}
              onChange={(e) => setIntentFilter(e.target.value)}
              className="px-2.5 py-1 text-xs rounded-lg border border-slate-300 dark:border-slate-600 bg-white dark:bg-slate-800 text-slate-700 dark:text-slate-200"
            >
              <option value="">Todas las intenciones</option>
              <option value="CONSULTA_PRECIO">CONSULTA_PRECIO</option>
              <option value="INTERES_PRODUCTO">INTERES_PRODUCTO</option>
              <option value="CONSULTA_PROMOCION">CONSULTA_PROMOCION</option>
              <option value="CONSULTA_UBICACION">CONSULTA_UBICACION</option>
              <option value="CONSULTA_HORARIO">CONSULTA_HORARIO</option>
              <option value="CONSULTA_RESERVA">CONSULTA_RESERVA</option>
              <option value="OTRO">OTRO</option>
            </select>

            {/* Buyer vinculado */}
            <select
              value={buyerFilter}
              onChange={(e) => setBuyerFilter(e.target.value as any)}
              className="px-2.5 py-1 text-xs rounded-lg border border-slate-300 dark:border-slate-600 bg-white dark:bg-slate-800 text-slate-700 dark:text-slate-200"
            >
              <option value="ALL">BUYER: Todos</option>
              <option value="WITH_BUYER">Con BUYER asociado</option>
              <option value="WITHOUT_BUYER">Sin BUYER asociado</option>
            </select>
          </div>
        </div>

        {/* Tabla */}
        <CardContent className="p-0">
          {isLoading ? (
            <TableSkeleton rows={8} />
          ) : isError ? (
            <ErrorState
              title="Error al consultar comentarios"
              onRetry={() => refetch()}
            />
          ) : filteredComments.length === 0 ? (
            <EmptyState
              icon={MessageSquare}
              title="No hay comentarios con los filtros seleccionados"
              description="Ajuste los filtros de plataforma, intención o el término de búsqueda."
            />
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full text-left text-xs">
                <thead className="bg-slate-50 dark:bg-slate-800/60 text-slate-600 dark:text-slate-400 uppercase font-bold text-[10px] tracking-wider border-b border-slate-200 dark:border-slate-700">
                  <tr>
                    <th className="py-3 px-4">Plataforma</th>
                    <th className="py-3 px-4">Usuario</th>
                    <th className="py-3 px-4">Texto del Comentario</th>
                    <th className="py-3 px-4">Fecha & Hora</th>
                    <th className="py-3 px-4">Intención Detectada</th>
                    <th className="py-3 px-4">BUYER Vinculado</th>
                    <th className="py-3 px-4 text-right">Acción</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-100 dark:divide-brand-charcoal-border">
                  {filteredComments.map((c) => {
                    return (
                      <tr
                        key={c.id_interaccion}
                        className="hover:bg-slate-50/80 dark:hover:bg-slate-800/40 transition-colors"
                      >
                        <td className="py-3 px-4 whitespace-nowrap">
                          <span className="inline-flex items-center gap-1.5 font-semibold">
                            {c.plataforma === 'FACEBOOK' ? (
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
                        <td className="py-3 px-4 font-medium text-slate-900 dark:text-slate-100 whitespace-nowrap">
                          {formatNombreUsuario(c.nombre_usuario, c.plataforma)}
                        </td>
                        <td className="py-3 px-4 max-w-xs sm:max-w-md truncate text-slate-700 dark:text-slate-300">
                          {c.texto}
                        </td>
                        <td className="py-3 px-4 whitespace-nowrap text-slate-500 dark:text-slate-400">
                          {formatDate(c.fecha_interaccion)}
                        </td>
                        <td className="py-3 px-4 whitespace-nowrap">
                          <Badge variant="intent" intent={c.clasificacion_intencion}>
                            {c.clasificacion_intencion || 'OTRO'}
                          </Badge>
                        </td>
                        <td className="py-3 px-4 whitespace-nowrap">
                          {c.id_buyer ? (
                            <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded text-[11px] font-mono font-semibold bg-emerald-50 text-emerald-700 border border-emerald-200 dark:bg-emerald-950/40 dark:text-emerald-300 dark:border-emerald-800">
                              <Users className="w-3 h-3" />
                              BUYER #{c.id_buyer}
                            </span>
                          ) : (
                            <span className="text-slate-400 text-[11px]">—</span>
                          )}
                        </td>
                        <td className="py-3 px-4 text-right whitespace-nowrap">
                          <Button
                            size="sm"
                            variant="ghost"
                            onClick={() => setSelectedComment(c)}
                            leftIcon={<Eye className="w-3.5 h-3.5" />}
                            className="text-xs py-1"
                          >
                            Ver
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

      {/* Modal de Detalle de Comentario */}
      {selectedComment && (
        <Modal
          isOpen={Boolean(selectedComment)}
          onClose={() => setSelectedComment(null)}
          title={
            <span className="flex items-center gap-2">
              <MessageSquare className="w-5 h-5 text-brand-amber" />
              Detalle de Comentario & Intención
            </span>
          }
          description={`Interacción #${selectedComment.id_interaccion} — ID Externo: ${selectedComment.id_interaccion_externa}`}
          size="md"
        >
          <div className="space-y-4">
            <div className="p-4 rounded-xl bg-slate-50 dark:bg-brand-charcoal border border-slate-200 dark:border-brand-charcoal-border space-y-3">
              <div className="flex items-center justify-between">
                <span className="font-bold text-sm text-slate-900 dark:text-slate-100">
                  {formatNombreUsuario(selectedComment.nombre_usuario, selectedComment.plataforma)}
                </span>
                <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded text-[11px] font-semibold bg-emerald-50 text-emerald-700 border border-emerald-200 dark:bg-emerald-950/40 dark:text-emerald-300 dark:border-emerald-800">
                  Meta Real Verificado
                </span>
              </div>

              <div className="p-3 rounded-lg bg-white dark:bg-brand-charcoal-card border border-slate-200 dark:border-brand-charcoal-border">
                <p className="text-xs text-slate-500 mb-1 font-semibold uppercase tracking-wider">
                  Texto del Comentario:
                </p>
                <p className="text-sm text-slate-800 dark:text-slate-100 whitespace-pre-wrap leading-relaxed">
                  "{selectedComment.texto}"
                </p>
              </div>

              <div className="grid grid-cols-2 gap-3 text-xs pt-1">
                <div>
                  <span className="text-slate-400 block">Plataforma:</span>
                  <span className="font-semibold text-slate-700 dark:text-slate-300">
                    {selectedComment.plataforma}
                  </span>
                </div>
                <div>
                  <span className="text-slate-400 block">Fecha y Hora:</span>
                  <span className="font-mono text-slate-700 dark:text-slate-300">
                    {formatDate(selectedComment.fecha_interaccion)}
                  </span>
                </div>
                <div>
                  <span className="text-slate-400 block">Clasificación:</span>
                  <div className="mt-1">
                    <Badge variant="intent" intent={selectedComment.clasificacion_intencion}>
                      {selectedComment.clasificacion_intencion}
                    </Badge>
                  </div>
                </div>
                <div>
                  <span className="text-slate-400 block">BUYER Asociado:</span>
                  <span className="font-mono font-semibold text-brand-red dark:text-rose-400">
                    {selectedComment.id_buyer ? `#${selectedComment.id_buyer}` : 'No vinculado'}
                  </span>
                </div>
              </div>

              {selectedComment.url_publicacion && (
                <div className="pt-2 border-t border-slate-200 dark:border-slate-700">
                  <a
                    href={selectedComment.url_publicacion}
                    target="_blank"
                    rel="noreferrer"
                    className="text-xs text-brand-red dark:text-rose-400 hover:underline inline-flex items-center gap-1 font-medium"
                  >
                    <ExternalLink className="w-3.5 h-3.5" />
                    Ir a la publicación de origen
                  </a>
                </div>
              )}
            </div>
          </div>
        </Modal>
      )}
    </div>
  );
};
