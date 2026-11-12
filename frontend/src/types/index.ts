export type PlatformCode = 'FACEBOOK' | 'INSTAGRAM' | 'DESCONOCIDA';
export type OriginType = 'META_REAL' | 'DEMO';
export type IntentCategory =
  | 'CONSULTA_PRECIO'
  | 'INTERES_PRODUCTO'
  | 'CONSULTA_PROMOCION'
  | 'CONSULTA_UBICACION'
  | 'CONSULTA_HORARIO'
  | 'CONSULTA_RESERVA'
  | 'OTRO';

export type BuyerStatus = 'BUYER' | 'CONVERTIDO_LEAD' | 'DESCARTADO';
export type ActionResult = 'EXITOSO' | 'FALLIDO' | 'PENDIENTE';

export interface SchedulerStatus {
  activo?: boolean;
  en_ejecucion?: boolean;
  intervalo_segundos?: number;
  intervalo_minutos?: number;
  origen_intervalo?: string;
  job_id?: string;
  proxima_ejecucion?: string | null;
  coordinador_ocupado?: boolean;
  error?: string | null;
}

export interface CoordinatorStatus {
  nombre?: string;
  estado?: 'IDLE' | 'OCUPADO' | string;
  ultima_sincronizacion?: string | null;
  ultimo_resultado?: string | null;
}

export interface AgentStatus {
  nombre?: string;
  conectado?: boolean;
  page_id?: string;
  page_name?: string;
  account_id?: string;
  username?: string;
  permisos?: string[];
  detalles?: Record<string, unknown>;
  error?: string | null;
}

export interface AgentsStatusResponse {
  scheduler: SchedulerStatus;
  coordinador: CoordinatorStatus;
  agente_facebook: AgentStatus;
  agente_instagram: AgentStatus;
}

export interface DashboardResumen {
  publicaciones: {
    facebook: { total: number; reales: number; demo: number };
    instagram: { total: number; reales: number; demo: number };
    total_reales: number;
    total_demo: number;
  };
  comentarios: {
    total: number;
    reales: number;
    demo: number;
    facebook?: number;
    instagram?: number;
  };
  comentarios_capturados?: {
    facebook: number;
    instagram: number;
    total: number;
  };
  comentarios_reportados_meta?: {
    facebook: number;
    instagram: number;
    total: number;
  };
  reacciones_likes: {
    facebook: number;
    instagram: number;
    total: number;
  };
  buyers: {
    total: number;
    reales: number;
    demo: number;
    reales_facebook: number;
    reales_instagram: number;
  };
  ultima_sincronizacion: {
    fecha: string | null;
    agente: string | null;
    resultado: string | null;
  };
  estado_agentes: {
    scheduler: SchedulerStatus;
    coordinador: CoordinatorStatus;
    facebook: AgentStatus;
    instagram: AgentStatus;
  };
}

export interface CommentItem {
  id_interaccion: number;
  id_interaccion_externa: string;
  plataforma: PlatformCode | string;
  id_publicacion: number;
  meta_post_id: string | null;
  url_publicacion: string | null;
  nombre_usuario: string;
  id_usuario_externo: string | null;
  texto: string;
  fecha_interaccion: string | null;
  tipo: string;
  id_buyer: number | null;
  clasificacion_intencion: IntentCategory | string;
  origen: OriginType;
}

export interface CommentsResponse {
  success: boolean;
  total: number;
  limit: number;
  offset: number;
  items: CommentItem[];
}

export interface BuyerItem {
  id_buyer: number;
  id_plataforma_origen: number;
  plataforma_codigo: PlatformCode | string;
  id_publicacion_origen: number | null;
  meta_post_id_origen: string | null;
  url_publicacion_origen: string | null;
  referencia_externa_enmascarada: string | null;
  fecha_primer_contacto: string | null;
  estado: BuyerStatus | string;
  total_interacciones: number;
  origen: OriginType;
}

export interface BuyersResponse {
  success: boolean;
  total: number;
  limit: number;
  offset: number;
  items: BuyerItem[];
}

export interface BuyerDetail {
  id_buyer: number;
  id_persona: number | null;
  persona?: {
    id_persona: number;
    nombres: string;
    apellidos: string;
    nombre_completo: string;
    telefono: string | null;
    email: string | null;
    fase_actual: string;
  } | null;
  id_plataforma_origen: number;
  plataforma_codigo: string;
  id_publicacion_origen: number | null;
  id_anuncio_origen: number | null;
  referencia_externa: string | null;
  fecha_primer_contacto: string | null;
  estado: string;
  fecha_conversion: string | null;
}

export interface FacebookPost {
  id_publicacion: number;
  meta_post_id: string;
  texto: string | null;
  fecha_publicacion: string | null;
  url_publicacion: string | null;
  url_formulario?: string | null;
  tipo?: string | null;
  estado: string;
  origen?: OriginType;
  total_reacciones?: number | null;
  total_likes?: number | null;
  total_comentarios?: number | null;
  comentarios_reportados_meta?: number | null;
  comentarios_capturados?: number;
  total_compartidos?: number | null;
  alcance?: number | null;
  impresiones?: number | null;
  fecha_corte_metrica?: string | null;
  ultima_sincronizacion?: string | null;
}

export interface InstagramPost {
  id_publicacion: number;
  meta_post_id: string;
  texto: string | null;
  fecha_publicacion: string | null;
  url_publicacion: string | null;
  url_formulario?: string | null;
  url_multimedia?: string | null;
  tipo_multimedia?: string | null;
  estado: string;
  origen?: OriginType;
  total_likes?: number | null;
  total_reacciones?: number | null;
  total_comentarios?: number | null;
  comentarios_reportados_meta?: number | null;
  comentarios_capturados?: number;
  total_compartidos?: number | null;
  alcance?: number | null;
  impresiones?: number | null;
  fecha_corte_metrica?: string | null;
  ultima_sincronizacion?: string | null;
}

export interface AuditItem {
  id_accion: number;
  nombre_agente: string;
  accion: string;
  resultado: ActionResult | string;
  detalles: string | null;
  fecha_ejecucion: string;
  id_buyer_asociado: number | null;
}

export interface AuditResponse {
  success: boolean;
  total: number;
  limit: number;
  offset: number;
  items: AuditItem[];
}

export interface SyncResult {
  success: boolean;
  estado?: string;
  coordinador?: string;
  plataformas_exitosas?: string[];
  plataformas_fallidas?: string[];
  resumen_total?: {
    publicaciones?: { nuevos: number; actualizados: number; fallidos: number };
    comentarios?: { nuevos: number; actualizados: number; fallidos: number };
    metricas?: { nuevos: number; actualizados: number; fallidos: number };
    buyers?: { nuevos: number; reutilizados: number };
  };
  duracion_segundos?: number;
  error?: string;
  codigo?: string;
  message?: string;
}

export interface DbStatusResponse {
  status: 'connected' | 'error';
  database: string;
  server?: string;
  driver?: string;
  auth_mode?: string;
  server_edition?: string;
  server_utc_time?: string;
  dbo_tables_count?: number;
  schema_valid?: boolean;
  message?: string;
  detail?: string;
}

export interface HealthResponse {
  status: string;
  service: string;
  version: string;
  timestamp_utc: string;
  stage: string;
}

export type AutoReplyStatusType =
  | 'PENDIENTE'
  | 'APROBADA'
  | 'SIMULADA'
  | 'ENVIANDO'
  | 'ENVIADA'
  | 'FALLIDA'
  | 'OMITIDA'
  | 'REQUIERE_REVISION';

export interface AutoReplyItem {
  id_respuesta: number;
  id_interaccion: number;
  id_buyer: number | null;
  id_plataforma: number;
  plataforma_codigo: 'FACEBOOK' | 'INSTAGRAM' | string;
  intencion_detectada: string;
  texto_respuesta: string;
  id_respuesta_meta: string | null;
  estado: AutoReplyStatusType;
  tipo_envio: 'AUTOMATICO' | 'MANUAL_APROBADO' | 'SIMULADO' | string;
  fecha_generacion: string;
  fecha_envio: string | null;
  error_detalle: string | null;
  comentario_original?: {
    id_interaccion: number;
    id_interaccion_externa: string;
    nombre_usuario: string | null;
    texto: string | null;
    fecha_interaccion: string;
    tipo: string;
  } | null;
  id_publicacion?: number | null;
  url_publicacion?: string | null;
}

export interface AutoReplyStatus {
  config: {
    enabled: boolean;
    dry_run: boolean;
    require_review: boolean;
    facebook_enabled: boolean;
    instagram_enabled: boolean;
    form_url: string;
    landing_url: string;
    max_per_cycle: number;
    cooldown_hours: number;
  };
  metricas: {
    total_comentarios_reales: number;
    total_respuestas: number;
    pendientes: number;
    aprobadas: number;
    simuladas: number;
    enviadas: number;
    fallidas: number;
    omitidas: number;
  };
}

export interface AutoReplyResponse {
  success: boolean;
  total: number;
  limit: number;
  offset: number;
  data: AutoReplyItem[];
}

export interface CommentTraceabilityItem {
  id_interaccion: number;
  id_interaccion_externa: string;
  id_publicacion: number;
  plataforma: 'FACEBOOK' | 'INSTAGRAM' | string;
  fecha_interaccion: string | null;
  usuario_nombre: string;
  usuario_id: string | null;
  texto_comentario: string;
  intencion_detectada: string;
  estado_trazabilidad: string;
  motivo_trazabilidad: string;
  tiene_respuesta: boolean;
  id_respuesta: number | null;
  texto_respuesta: string | null;
  id_respuesta_meta: string | null;
  fecha_envio: string | null;
  error_detalle: string | null;
}

export interface CommentTraceabilitySummary {
  total_evaluados: number;
  respondidos_meta: number;
  simulados: number;
  pendientes_revision: number;
  aprobados_cola: number;
  bloqueados_cooldown: number;
  omitidos_sin_intencion: number;
  omitidos_propios: number;
  fallidos: number;
  descartados_manual: number;
  pendientes_evaluacion: number;
}

export interface CommentTraceabilityResponse {
  success: boolean;
  data: {
    total: number;
    limit: number;
    offset: number;
    resumen: CommentTraceabilitySummary;
    items: CommentTraceabilityItem[];
  };
}

export interface LandingResumen {
  visitas_landing: number;
  visitantes_landing: number;
  visualizaciones_carta: number;
  visitantes_carta: number;
  formularios: number;
  leads: number;
  conversion: number;
  // Compatibilidad con versiones previas
  total_visitas?: number;
  visitantes_unicos?: number;
  clics_carta?: number;
  visitas_carta?: number;
  formularios_exitosos?: number;
  leads_nuevos?: number;
  tasa_conversion?: number;
  conversion_detalle?: {
    numerador_leads: number;
    denominador_visitantes: number;
    resultado_tasa: number;
    periodo: string;
  };
}

export type LandingDetailType =
  | 'visitas'
  | 'visitantes'
  | 'visualizaciones_carta'
  | 'visitantes_carta'
  | 'formularios'
  | 'leads'
  | 'conversion';

export interface LandingDetailResponse<T> {
  success: boolean;
  total: number;
  page: number;
  page_size: number;
  total_pages: number;
  items: T[];
  error?: string;
}

export interface VisitaDetailItem {
  id_visita: number;
  id_visitante: number;
  token_visitante: string;
  token_visitante_abreviado: string;
  fecha: string;
  ruta: string;
  canal_origen: string;
  utm_campaign: string | null;
  dispositivo_tipo: string;
}

export interface VisitanteDetailItem {
  id_visitante: number;
  token_visitante: string;
  token_visitante_abreviado: string;
  primera_visita: string;
  ultima_visita: string;
  total_accesos: number;
  dispositivo_tipo: string;
}

export interface VisualizacionCartaDetailItem {
  id_evento: number;
  id_visita: number;
  id_visitante: number | null;
  token_visitante: string;
  token_visitante_abreviado: string;
  fecha: string;
  ruta: string;
  detalle: string;
  canal_origen: string;
}

export interface VisitanteCartaDetailItem {
  id_visitante: number;
  token_visitante: string;
  token_visitante_abreviado: string;
  primera_apertura: string;
  ultima_apertura: string;
  total_visualizaciones: number;
  dispositivo_tipo: string;
}

export interface FormularioDetailItem {
  id_formulario: number;
  id_persona: number;
  persona_nombre: string;
  telefono: string;
  email: string;
  fecha_envio: string;
  plato_favorito: string;
  estado: string;
  origen: string;
  utm_campaign: string | null;
  acepta_marketing: boolean;
  es_admin?: boolean;
}

export interface LeadDetailItem {
  id_conversion: number;
  id_lead: number | null;
  id_persona: number;
  persona_nombre: string;
  telefono: string;
  email: string;
  plato_favorito: string;
  fecha_conversion: string;
  plataforma_origen: string;
  estado_buyer: string;
  es_admin?: boolean;
}

export interface VisitaDiaItem {
  fecha: string;
  visitas: number;
  visitantes: number;
}

export interface FormularioRecienteItem {
  id_formulario: number;
  persona_nombre: string;
  telefono: string;
  email: string | null;
  plato_favorito: string;
  utm_source: string;
  utm_campaign: string | null;
  fecha_envio: string;
  acepta_marketing: boolean;
}

export interface LandingStatsResponse {
  success: boolean;
  periodo?: string;
  resumen: LandingResumen;
  visitas_por_dia: VisitaDiaItem[];
  formularios_recientes: FormularioRecienteItem[];
  error?: string;
}


