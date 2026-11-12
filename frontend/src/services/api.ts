import axios from 'axios';
import type {
  DashboardResumen,
  CommentsResponse,
  BuyersResponse,
  BuyerDetail,
  FacebookPost,
  InstagramPost,
  AuditResponse,
  SyncResult,
  DbStatusResponse,
  HealthResponse,
  AgentsStatusResponse,
  AutoReplyStatus,
  AutoReplyResponse,
  AutoReplyItem,
  CommentTraceabilityResponse,
  LandingStatsResponse,
  LandingDetailResponse,
} from '../types';

const api = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL || '/api',
  headers: {
    'Content-Type': 'application/json',
  },
  timeout: 30000,
});

// Interceptor para inyectar automáticamente la clave de administración si existe
api.interceptors.request.use((config) => {
  const adminKey = sessionStorage.getItem('buyer_admin_key');
  if (adminKey) {
    config.headers['X-Admin-Token'] = adminKey;
    config.headers['X-API-Key'] = adminKey;
  }
  return config;
});

export const ApiService = {
  // Diagnóstico del sistema
  async getHealth(): Promise<HealthResponse> {
    const res = await api.get<HealthResponse>('/health');
    return res.data;
  },

  async getDbStatus(): Promise<DbStatusResponse> {
    const res = await api.get<DbStatusResponse>('/db/status');
    return res.data;
  },

  // Dashboard Resumen
  async getDashboardResumen(): Promise<DashboardResumen> {
    const res = await api.get<{ success: boolean; data: DashboardResumen }>('/dashboard/resumen');
    return res.data.data;
  },

  // Comentarios & Intención
  async getComments(params?: {
    limit?: number;
    offset?: number;
    plataforma?: string;
    intencion?: string;
  }): Promise<CommentsResponse> {
    const res = await api.get<CommentsResponse>('/dashboard/comentarios', { params });
    return res.data;
  },

  // BUYERS
  async getBuyers(params?: {
    limit?: number;
    offset?: number;
    plataforma?: string;
  }): Promise<BuyersResponse> {
    const res = await api.get<BuyersResponse>('/dashboard/buyers', { params });
    return res.data;
  },

  async getBuyerDetail(idBuyer: number): Promise<BuyerDetail> {
    const res = await api.get<{ success: boolean; data: BuyerDetail }>(`/buyers/${idBuyer}`);
    return res.data.data;
  },

  // Facebook
  async getFacebookStatus(): Promise<Record<string, unknown>> {
    const res = await api.get<{ success: boolean; data: Record<string, unknown> }>('/facebook/status');
    return res.data.data;
  },

  async getFacebookPosts(params?: { limit?: number; offset?: number }): Promise<{
    total: number;
    limit: number;
    offset: number;
    data: FacebookPost[];
  }> {
    const res = await api.get<{
      success: boolean;
      total: number;
      limit: number;
      offset: number;
      data: FacebookPost[];
    }>('/facebook/publicaciones', { params });
    return res.data;
  },

  async getFacebookPostComments(idPublicacion: number): Promise<{
    publicacion: FacebookPost;
    total_comentarios: number;
    comentarios: unknown[];
  }> {
    const res = await api.get<{
      success: boolean;
      data: {
        publicacion: FacebookPost;
        total_comentarios: number;
        comentarios: unknown[];
      };
    }>(`/facebook/publicaciones/${idPublicacion}/comentarios`);
    return res.data.data;
  },

  async syncFacebook(customKey?: string): Promise<SyncResult> {
    const headers: Record<string, string> = {};
    if (customKey) {
      headers['X-Admin-Token'] = customKey;
      headers['X-API-Key'] = customKey;
    }
    const res = await api.post<SyncResult>('/facebook/sincronizar', {}, { headers });
    return res.data;
  },

  // Instagram
  async getInstagramStatus(): Promise<Record<string, unknown>> {
    const res = await api.get<{ success: boolean; data: Record<string, unknown> }>('/instagram/status');
    return res.data.data;
  },

  async getInstagramPosts(params?: { limit?: number; offset?: number }): Promise<{
    total: number;
    limit: number;
    offset: number;
    data: InstagramPost[];
  }> {
    const res = await api.get<{
      success: boolean;
      total: number;
      limit: number;
      offset: number;
      data: InstagramPost[];
    }>('/instagram/publicaciones', { params });
    return res.data;
  },

  async getInstagramPostComments(idPublicacion: number): Promise<{
    publicacion: InstagramPost;
    total_comentarios: number;
    comentarios: unknown[];
  }> {
    const res = await api.get<{
      success: boolean;
      data: {
        publicacion: InstagramPost;
        total_comentarios: number;
        comentarios: unknown[];
      };
    }>(`/instagram/publicaciones/${idPublicacion}/comentarios`);
    return res.data.data;
  },

  async syncInstagram(customKey?: string): Promise<SyncResult> {
    const headers: Record<string, string> = {};
    if (customKey) {
      headers['X-Admin-Token'] = customKey;
      headers['X-API-Key'] = customKey;
    }
    const res = await api.post<SyncResult>('/instagram/sincronizar', {}, { headers });
    return res.data;
  },

  // Agentes Autónomos y Coordinador
  async getAgentsStatus(): Promise<AgentsStatusResponse> {
    const res = await api.get<{ success: boolean; data: AgentsStatusResponse }>('/agentes/status');
    return res.data.data;
  },

  async syncCoordinated(
    plataforma: 'todas' | 'facebook' | 'instagram' = 'todas',
    customKey?: string
  ): Promise<SyncResult> {
    const headers: Record<string, string> = {};
    if (customKey) {
      headers['X-Admin-Token'] = customKey;
      headers['X-API-Key'] = customKey;
    }
    const res = await api.post<SyncResult>(
      '/agentes/sincronizar',
      { plataforma },
      { headers, params: { plataforma } }
    );
    return res.data;
  },

  async getAgentsActivity(params?: {
    limit?: number;
    offset?: number;
    agente?: string;
    accion?: string;
    resultado?: string;
  }): Promise<AuditResponse> {
    const res = await api.get<AuditResponse>('/agentes/actividad', { params });
    return res.data;
  },

  // Agente de Respuestas Automáticas
  async getAutoReplyStatus(): Promise<AutoReplyStatus> {
    const res = await api.get<{ success: boolean; data: AutoReplyStatus }>('/respuestas/status');
    return res.data.data;
  },

  async getPendingAutoReplies(params?: {
    limit?: number;
    offset?: number;
    plataforma?: string;
  }): Promise<AutoReplyResponse> {
    const res = await api.get<AutoReplyResponse>('/respuestas/pendientes', { params });
    return res.data;
  },

  async getAutoReplyHistory(params?: {
    limit?: number;
    offset?: number;
    estado?: string;
    plataforma?: string;
  }): Promise<AutoReplyResponse> {
    const res = await api.get<AutoReplyResponse>('/respuestas/historial', { params });
    return res.data;
  },

  async generateAutoReplies(max?: number): Promise<{
    success: boolean;
    total_evaluados: number;
    propuestas_generadas: number;
    omitidos: number;
    items: AutoReplyItem[];
  }> {
    const res = await api.post('/respuestas/generar', { max });
    return res.data;
  },

  async approveAutoReply(
    idRespuesta: number,
    textoRespuesta?: string
  ): Promise<{ success: boolean; data: AutoReplyItem }> {
    const res = await api.post(`/respuestas/${idRespuesta}/aprobar`, {
      texto_respuesta: textoRespuesta,
    });
    return res.data;
  },

  async rejectAutoReply(
    idRespuesta: number,
    motivo?: string
  ): Promise<{ success: boolean; data: AutoReplyItem }> {
    const res = await api.post(`/respuestas/${idRespuesta}/rechazar`, { motivo });
    return res.data;
  },

  async sendAutoReply(idRespuesta: number): Promise<{
    success: boolean;
    simulada?: boolean;
    mensaje?: string;
    data: AutoReplyItem;
    error?: string;
  }> {
    const res = await api.post(`/respuestas/${idRespuesta}/enviar`, {});
    return res.data;
  },

  async getCommentTraceability(params?: {
    limit?: number;
    offset?: number;
    estado?: string;
    plataforma?: string;
  }): Promise<CommentTraceabilityResponse> {
    const res = await api.get<CommentTraceabilityResponse>('/respuestas/trazabilidad', { params });
    return res.data;
  },

  async emergencyStopAutoReply(motivo?: string): Promise<{ success: boolean; mensaje: string; data: AutoReplyStatus }> {
    const res = await api.post('/respuestas/emergency-stop', { motivo });
    return res.data;
  },

  async activateAutoReply(): Promise<{ success: boolean; mensaje: string; data: AutoReplyStatus }> {
    const res = await api.post('/respuestas/activar-auto', {});
    return res.data;
  },

  async reprocessComment(
    idInteraccion: number,
    forzarDespacho?: boolean
  ): Promise<{ success: boolean; mensaje?: string; error?: string; data?: AutoReplyItem }> {
    const res = await api.post(`/respuestas/reprocesar/${idInteraccion}`, {
      forzar_despacho: forzarDespacho,
    });
    return res.data;
  },

  // Landing Page Metrics
  async getLandingStats(params?: {
    fecha_inicio?: string;
    fecha_fin?: string;
    periodo?: string;
  }): Promise<LandingStatsResponse> {
    const res = await api.get<LandingStatsResponse>('/landing/estadisticas', { params });
    return res.data;
  },

  // Landing Page Details (on demand)
  async getLandingDetails<T>(
    tipo: string,
    params?: {
      fecha_inicio?: string;
      fecha_fin?: string;
      periodo?: string;
      page?: number;
      page_size?: number;
    }
  ): Promise<LandingDetailResponse<T>> {
    const res = await api.get<LandingDetailResponse<T>>(`/landing/detalles/${tipo}`, { params });
    return res.data;
  },
};

export default api;
