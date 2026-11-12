import React, { useState, useMemo } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import {
  Facebook,
  Search,
  RotateCw,
  ExternalLink,
  Eye,
  ThumbsUp,
  MessageSquare,
  Users,
  CheckCircle2,
  AlertCircle,
  FileText,
} from 'lucide-react';
import { ApiService } from '../services/api';
import { Card, CardHeader, CardTitle, CardContent } from '../components/ui/Card';
import { Button } from '../components/ui/Button';
import { Badge } from '../components/ui/Badge';
import { Modal } from '../components/ui/Modal';
import { TableSkeleton } from '../components/ui/Skeleton';
import { EmptyState } from '../components/ui/EmptyState';
import { ErrorState } from '../components/ui/ErrorState';
import { useAdminAuth } from '../contexts/AdminAuthContext';
import { formatDate, formatNombreUsuario } from '../utils/format';
import type { FacebookPost, SyncResult } from '../types';

export const FacebookPage: React.FC = () => {
  const queryClient = useQueryClient();
  const { adminKey, openModal } = useAdminAuth();

  // Estados locales de búsqueda y selección
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedPost, setSelectedPost] = useState<FacebookPost | null>(null);
  const [syncFeedback, setSyncFeedback] = useState<SyncResult | null>(null);

  // Consulta de publicaciones Facebook reales
  const {
    data: postsData,
    isLoading,
    isError,
    refetch,
  } = useQuery({
    queryKey: ['facebookPosts'],
    queryFn: () => ApiService.getFacebookPosts({ limit: 100 }),
    refetchInterval: 30000,
  });

  // Consulta de estado de Facebook
  const { data: statusData } = useQuery({
    queryKey: ['facebookStatus'],
    queryFn: ApiService.getFacebookStatus,
    refetchInterval: 30000,
  });

  // Consulta de comentarios del post seleccionado (si está abierto el modal)
  const {
    data: postCommentsData,
    isLoading: isCommentsLoading,
  } = useQuery({
    queryKey: ['facebookPostComments', selectedPost?.id_publicacion],
    queryFn: () =>
      selectedPost ? ApiService.getFacebookPostComments(selectedPost.id_publicacion) : null,
    enabled: Boolean(selectedPost),
  });

  // Mutación para sincronización manual
  const syncMutation = useMutation({
    mutationFn: () => ApiService.syncFacebook(adminKey),
    onSuccess: (data) => {
      setSyncFeedback(data);
      queryClient.invalidateQueries({ queryKey: ['facebookPosts'] });
      queryClient.invalidateQueries({ queryKey: ['dashboardResumen'] });
      queryClient.invalidateQueries({ queryKey: ['facebookStatus'] });
      queryClient.invalidateQueries({ queryKey: ['comments'] });
      queryClient.invalidateQueries({ queryKey: ['buyers'] });
    },
    onError: (error: any) => {
      if (error?.response?.status === 401) {
        openModal();
      }
      setSyncFeedback({
        success: false,
        error: error?.response?.data?.error || 'Error al ejecutar sincronización.',
      });
    },
  });

  const posts = postsData?.data || [];

  // Filtrado exclusivo sobre datos reales
  const filteredPosts = useMemo(() => {
    return posts.filter((post) => {
      // Excluir cualquier registro demo residual
      if (post.meta_post_id?.startsWith('DEMO_') || post.origen === 'DEMO') return false;

      if (!searchTerm) return true;
      const term = searchTerm.toLowerCase();
      const textMatch = post.texto?.toLowerCase().includes(term);
      const idMatch = post.meta_post_id?.toLowerCase().includes(term);
      return textMatch || idMatch;
    });
  }, [posts, searchTerm]);

  // Métricas agregadas sobre publicaciones reales confirmadas
  const metrics = useMemo(() => {
    const total = filteredPosts.length;
    const totalReacciones = filteredPosts.reduce(
      (sum, p) => sum + (typeof p.total_reacciones === 'number' ? p.total_reacciones : 0),
      0
    );
    const totalComentariosMeta = filteredPosts.reduce(
      (sum, p) =>
        sum +
        (typeof p.total_comentarios === 'number'
          ? p.total_comentarios
          : typeof p.comentarios_reportados_meta === 'number'
          ? p.comentarios_reportados_meta
          : 0),
      0
    );
    const totalComentariosCapturados = filteredPosts.reduce(
      (sum, p) => sum + (typeof p.comentarios_capturados === 'number' ? p.comentarios_capturados : 0),
      0
    );
    return { total, totalReacciones, totalComentariosMeta, totalComentariosCapturados };
  }, [filteredPosts]);

  return (
    <div className="space-y-6 animate-in fade-in duration-200">
      {/* Feedback de Sincronización */}
      {syncFeedback && (
        <div
          className={`p-4 rounded-xl border flex items-start justify-between gap-3 ${
            syncFeedback.success
              ? 'bg-emerald-50 border-emerald-200 text-emerald-800 dark:bg-emerald-950/40 dark:border-emerald-800 dark:text-emerald-200'
              : 'bg-rose-50 border-rose-200 text-rose-800 dark:bg-rose-950/40 dark:border-rose-800 dark:text-rose-200'
          }`}
        >
          <div className="flex items-start gap-2.5">
            {syncFeedback.success ? (
              <CheckCircle2 className="w-5 h-5 text-emerald-600 flex-shrink-0 mt-0.5" />
            ) : (
              <AlertCircle className="w-5 h-5 text-rose-600 flex-shrink-0 mt-0.5" />
            )}
            <div className="text-xs">
              <p className="font-bold">
                {syncFeedback.success
                  ? 'Sincronización de Facebook exitosa'
                  : 'Fallo al sincronizar Facebook'}
              </p>
              {syncFeedback.resumen_total && (
                <p className="mt-0.5">
                  Nuevos: {syncFeedback.resumen_total.publicaciones?.nuevos ?? 0} posts | Actualizados:{' '}
                  {syncFeedback.resumen_total.publicaciones?.actualizados ?? 0} | Fallidos:{' '}
                  {syncFeedback.resumen_total.publicaciones?.fallidos ?? 0}
                </p>
              )}
              {syncFeedback.error && <p className="mt-0.5">{syncFeedback.error}</p>}
            </div>
          </div>
          <button
            onClick={() => setSyncFeedback(null)}
            className="text-xs font-semibold hover:underline"
          >
            Cerrar
          </button>
        </div>
      )}

      {/* Tarjetas de Métricas de Facebook */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <Card className="border-l-4 border-l-blue-600">
          <CardContent className="p-4 flex items-center justify-between">
            <div>
              <span className="text-xs text-slate-500 font-semibold uppercase">Publicaciones Reales</span>
              <p className="text-2xl font-black text-slate-900 dark:text-slate-100 font-mono mt-0.5">
                {metrics.total}
              </p>
              <span className="text-[11px] text-emerald-600 dark:text-emerald-400 font-medium">
                Página oficial El Establo
              </span>
            </div>
            <div className="w-10 h-10 rounded-xl bg-blue-50 text-blue-600 dark:bg-blue-950/40 dark:text-blue-400 flex items-center justify-center">
              <Facebook className="w-5 h-5" />
            </div>
          </CardContent>
        </Card>

        <Card className="border-l-4 border-l-amber-500">
          <CardContent className="p-4 flex items-center justify-between">
            <div>
              <span className="text-xs text-slate-500 font-semibold uppercase">Comentarios (Meta API)</span>
              <p className="text-2xl font-black text-slate-900 dark:text-slate-100 font-mono mt-0.5">
                {metrics.totalComentariosMeta}
              </p>
              <span className="text-[11px] text-slate-400 font-mono">
                Capturados en BD: {metrics.totalComentariosCapturados}
              </span>
            </div>
            <div className="w-10 h-10 rounded-xl bg-amber-50 text-brand-amber dark:bg-amber-950/40 dark:text-amber-400 flex items-center justify-center">
              <MessageSquare className="w-5 h-5" />
            </div>
          </CardContent>
        </Card>

        <Card className="border-l-4 border-l-emerald-600">
          <CardContent className="p-4 flex items-center justify-between">
            <div>
              <span className="text-xs text-slate-500 font-semibold uppercase">Reacciones Actuales</span>
              <p className="text-2xl font-black text-slate-900 dark:text-slate-100 font-mono mt-0.5">
                {metrics.totalReacciones}
              </p>
              <span className="text-[11px] text-slate-400">Confirmadas Meta Graph API</span>
            </div>
            <div className="w-10 h-10 rounded-xl bg-emerald-50 text-brand-success dark:bg-emerald-950/40 dark:text-emerald-400 flex items-center justify-center">
              <ThumbsUp className="w-5 h-5" />
            </div>
          </CardContent>
        </Card>

        <Card className="border-l-4 border-l-slate-400">
          <CardContent className="p-4 flex items-center justify-between">
            <div>
              <span className="text-xs text-slate-500 font-semibold uppercase">Página Conectada</span>
              <p className="text-sm font-bold text-slate-900 dark:text-slate-100 truncate mt-0.5">
                {String(statusData?.nombre_pagina || 'Parrilladas El Establo')}
              </p>
              <span className="text-[11px] text-slate-400 font-mono">
                ID: {String(statusData?.id_pagina || '1341560062384618')}
              </span>
            </div>
            <div className="w-10 h-10 rounded-xl bg-slate-100 text-slate-600 dark:bg-slate-800 dark:text-slate-300 flex items-center justify-center">
              <Users className="w-5 h-5" />
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Contenedor de Publicaciones */}
      <Card>
        <CardHeader
          action={
            <Button
              size="sm"
              variant="primary"
              onClick={() => syncMutation.mutate()}
              isLoading={syncMutation.isPending}
              leftIcon={<RotateCw className="w-4 h-4" />}
            >
              Sincronizar Facebook
            </Button>
          }
        >
          <CardTitle>
            <Facebook className="w-5 h-5 text-blue-600" />
            Publicaciones Reales de Facebook
          </CardTitle>
        </CardHeader>

        {/* Barra de Filtros */}
        <div className="p-4 border-b border-slate-100 dark:border-brand-charcoal-border bg-slate-50/50 dark:bg-brand-charcoal/30 flex flex-col sm:flex-row gap-3 items-center justify-between">
          <div className="relative w-full sm:w-96">
            <Search className="w-4 h-4 text-slate-400 absolute left-3 top-1/2 -translate-y-1/2" />
            <input
              type="text"
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              placeholder="Buscar por texto o Meta Post ID..."
              className="w-full pl-9 pr-3 py-1.5 text-xs rounded-lg border border-slate-300 dark:border-slate-600 bg-white dark:bg-slate-800 text-slate-900 dark:text-slate-100 focus:outline-none focus:ring-1 focus:ring-brand-red"
            />
          </div>

          <div className="text-xs text-slate-500 font-medium">
            Mostrando {filteredPosts.length} publicación(es) real(es)
          </div>
        </div>

        {/* Tabla de Publicaciones */}
        <CardContent className="p-0">
          {isLoading ? (
            <TableSkeleton rows={5} />
          ) : isError ? (
            <ErrorState
              title="Error al cargar publicaciones de Facebook"
              onRetry={() => refetch()}
            />
          ) : filteredPosts.length === 0 ? (
            <EmptyState
              icon={FileText}
              title="No se encontraron publicaciones reales"
              description="No hay publicaciones reales registradas o la búsqueda indicada no arrojó resultados."
            />
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full text-left text-xs">
                <thead className="bg-slate-50 dark:bg-slate-800/60 text-slate-600 dark:text-slate-400 uppercase font-bold text-[10px] tracking-wider border-b border-slate-200 dark:border-slate-700">
                  <tr>
                    <th className="py-3 px-4">Meta Post ID</th>
                    <th className="py-3 px-4">Descripción / Contenido</th>
                    <th className="py-3 px-4">Fecha</th>
                    <th className="py-3 px-4">Reacciones (Meta)</th>
                    <th className="py-3 px-4">Comentarios (Meta API)</th>
                    <th className="py-3 px-4">Comentarios Capturados</th>
                    <th className="py-3 px-4">Estado</th>
                    <th className="py-3 px-4 text-right">Acciones</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-100 dark:divide-brand-charcoal-border">
                  {filteredPosts.map((post) => {
                    const reaccionesText =
                      post.total_reacciones !== null && post.total_reacciones !== undefined
                        ? post.total_reacciones
                        : 'No disponible';
                    const comentariosMetaText =
                      post.total_comentarios !== null && post.total_comentarios !== undefined
                        ? post.total_comentarios
                        : post.comentarios_reportados_meta !== null && post.comentarios_reportados_meta !== undefined
                        ? post.comentarios_reportados_meta
                        : 'No disponible';
                    const comentariosCapturados = post.comentarios_capturados ?? 0;

                    return (
                      <tr
                        key={post.id_publicacion}
                        className="hover:bg-slate-50/80 dark:hover:bg-slate-800/40 transition-colors"
                      >
                        <td className="py-3 px-4 font-mono text-[11px] text-slate-700 dark:text-slate-300 font-semibold whitespace-nowrap">
                          {post.meta_post_id ? `${post.meta_post_id.slice(0, 20)}...` : '—'}
                        </td>
                        <td className="py-3 px-4 max-w-xs sm:max-w-md truncate text-slate-800 dark:text-slate-200 font-medium">
                          {post.texto || <span className="text-slate-400 italic">Sin texto descriptivo</span>}
                        </td>
                        <td className="py-3 px-4 whitespace-nowrap text-slate-500 dark:text-slate-400">
                          {formatDate(post.fecha_publicacion)}
                        </td>
                        <td className="py-3 px-4 font-mono font-bold text-blue-700 dark:text-blue-400">
                          {reaccionesText}
                        </td>
                        <td className="py-3 px-4 font-mono font-bold text-amber-700 dark:text-amber-400">
                          {comentariosMetaText}
                        </td>
                        <td className="py-3 px-4 font-mono font-semibold text-emerald-700 dark:text-emerald-400">
                          {comentariosCapturados}
                        </td>
                        <td className="py-3 px-4 whitespace-nowrap">
                          <span className="inline-flex px-2 py-0.5 rounded text-[10px] font-semibold bg-emerald-50 text-emerald-700 dark:bg-emerald-950/40 dark:text-emerald-300 border border-emerald-200 dark:border-emerald-800">
                            {post.estado || 'PUBLICADA'}
                          </span>
                        </td>
                        <td className="py-3 px-4 text-right whitespace-nowrap">
                          <div className="flex items-center justify-end gap-1.5">
                            {post.url_publicacion && (
                              <a
                                href={post.url_publicacion}
                                target="_blank"
                                rel="noreferrer"
                                className="p-1.5 text-slate-400 hover:text-blue-600 dark:hover:text-blue-400 rounded-lg hover:bg-slate-100 dark:hover:bg-slate-800 transition-colors"
                                title="Ver publicación en Facebook"
                              >
                                <ExternalLink className="w-4 h-4" />
                              </a>
                            )}
                            <Button
                              size="sm"
                              variant="outline"
                              onClick={() => setSelectedPost(post)}
                              leftIcon={<Eye className="w-3.5 h-3.5" />}
                              className="text-xs py-1"
                            >
                              Detalle
                            </Button>
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

      {/* Modal de Detalle de Publicación */}
      {selectedPost && (
        <Modal
          isOpen={Boolean(selectedPost)}
          onClose={() => setSelectedPost(null)}
          title={
            <span className="flex items-center gap-2">
              <Facebook className="w-5 h-5 text-blue-600" />
              Detalle de Publicación Facebook
            </span>
          }
          description={`ID Interno #${selectedPost.id_publicacion} — Meta Post ID: ${selectedPost.meta_post_id}`}
          size="lg"
        >
          <div className="space-y-5">
            {/* Cabecera del post */}
            <div className="p-4 rounded-xl bg-slate-50 dark:bg-brand-charcoal border border-slate-200 dark:border-brand-charcoal-border space-y-2">
              <div className="flex items-center justify-between">
                <span className="inline-flex items-center px-2 py-0.5 rounded text-[10px] font-semibold bg-emerald-50 text-emerald-700 dark:bg-emerald-950/40 dark:text-emerald-300 border border-emerald-200 dark:border-emerald-800">
                  REAL — Meta Graph API
                </span>
                <span className="text-xs text-slate-500 font-mono">
                  {formatDate(selectedPost.fecha_publicacion)}
                </span>
              </div>
              <p className="text-sm text-slate-800 dark:text-slate-100 whitespace-pre-wrap leading-relaxed">
                {selectedPost.texto || 'Sin texto descriptivo registrado en la API.'}
              </p>
              {selectedPost.url_publicacion && (
                <a
                  href={selectedPost.url_publicacion}
                  target="_blank"
                  rel="noreferrer"
                  className="text-xs text-blue-600 dark:text-blue-400 hover:underline inline-flex items-center gap-1 font-medium pt-1"
                >
                  <ExternalLink className="w-3.5 h-3.5" />
                  Abrir enlace original en Facebook
                </a>
              )}
            </div>

            {/* Comentarios asociados a la publicación */}
            <div>
              <h4 className="text-xs font-bold uppercase tracking-wider text-slate-500 dark:text-slate-400 mb-2 flex items-center justify-between">
                <span>Comentarios de esta Publicación</span>
                <span className="font-mono text-slate-700 dark:text-slate-300">
                  Total Capturados: {postCommentsData?.total_comentarios ?? selectedPost.comentarios_capturados ?? 0}
                </span>
              </h4>

              {postCommentsData?.comentarios &&
                (postCommentsData.comentarios as any[]).some((c) => !c.nombre_visible) && (
                  <p className="text-[10px] text-slate-400 mb-2">
                    {(postCommentsData.comentarios as any[]).filter((c) => !c.nombre_visible).length}{' '}
                    comentario(s) sin nombre: Meta no expone el autor de esos comentarios.
                  </p>
                )}

              {isCommentsLoading ? (
                <TableSkeleton rows={3} />
              ) : !postCommentsData?.comentarios || (postCommentsData.comentarios as any[]).length === 0 ? (
                <div className="p-4 rounded-lg bg-slate-50 dark:bg-brand-charcoal/50 text-center text-xs text-slate-500">
                  No hay comentarios registrados para esta publicación.
                </div>
              ) : (
                <div className="space-y-2 max-h-60 overflow-y-auto pr-1">
                  {(postCommentsData.comentarios as any[]).map((c, idx) => (
                    <div
                      key={c.id_interaccion || idx}
                      className="p-3 rounded-lg border border-slate-200 dark:border-brand-charcoal-border bg-white dark:bg-brand-charcoal-card text-xs"
                    >
                      <div className="flex items-center justify-between mb-1">
                        <span
                          className="font-semibold text-slate-900 dark:text-slate-100"
                          title={
                            c.nombre_visible
                              ? undefined
                              : 'Meta no expone el nombre del autor de este comentario.'
                          }
                        >
                          {formatNombreUsuario(c.nombre_visible, 'FACEBOOK')}
                        </span>
                        <span className="text-[10px] text-slate-400">
                          {formatDate(c.fecha_interaccion)}
                        </span>
                      </div>
                      <p className="text-slate-700 dark:text-slate-300">{c.texto}</p>
                    </div>
                  ))}
                </div>
              )}
            </div>
          </div>
        </Modal>
      )}
    </div>
  );
};
