/**
 * Origen de la captación en un sitio estático.
 *
 * El navegador no conoce los ids reales de la base (id_visita, id_buyer), por eso
 * envía tokens opacos que el endpoint del POST resuelve y registra.
 */
export interface ParametrosOrigen {
  readonly utmSource: string;
  readonly utmCampaign: string;
  readonly utmContent: string;
  readonly fbclid: string;
  readonly idPublicacion: number | null;
}

export const ORIGEN_VACIO: ParametrosOrigen = {
  utmSource: '',
  utmCampaign: '',
  utmContent: '',
  fbclid: '',
  idPublicacion: null,
};

export interface TokensSesion {
  /** `visitante_web.token_visitante`: cookie de 365 días. */
  readonly tokenVisitante: string;
  /** Identificador de la sesión de navegación actual. */
  readonly tokenVisita: string;
}

const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

/** Lee utm/fbclid/id de publicación desde un query string. */
export function leerParametrosOrigen(search: string): ParametrosOrigen {
  const params = new URLSearchParams(search.startsWith('?') ? search.slice(1) : search);
  const publicacion = Number.parseInt(params.get('id_publicacion') ?? params.get('publicacion') ?? '', 10);

  return {
    utmSource: params.get('utm_source')?.trim() ?? '',
    utmCampaign: params.get('utm_campaign')?.trim() ?? '',
    utmContent: params.get('utm_content')?.trim() ?? '',
    fbclid: params.get('fbclid')?.trim() ?? '',
    idPublicacion: Number.isInteger(publicacion) && publicacion > 0 ? publicacion : null,
  };
}

/** Verdadero si el origen aporta algún dato útil para atribución. */
export function tieneOrigen(parametros: ParametrosOrigen): boolean {
  return Boolean(
    parametros.utmSource ||
      parametros.utmCampaign ||
      parametros.utmContent ||
      parametros.fbclid ||
      parametros.idPublicacion,
  );
}

/** Combina orígenes: los valores nuevos no vacíos pisan a los previos. */
export function fusionarOrigen(
  previo: ParametrosOrigen,
  nuevo: ParametrosOrigen,
): ParametrosOrigen {
  return {
    utmSource: nuevo.utmSource || previo.utmSource,
    utmCampaign: nuevo.utmCampaign || previo.utmCampaign,
    utmContent: nuevo.utmContent || previo.utmContent,
    fbclid: nuevo.fbclid || previo.fbclid,
    idPublicacion: nuevo.idPublicacion ?? previo.idPublicacion,
  };
}

/** Valida un token UUID (formato de `crypto.randomUUID()`). */
export function tokenValido(valor: string): boolean {
  return UUID.test(valor.trim());
}

/** Genera un token nuevo. Requiere `crypto.randomUUID` (navegadores modernos y Node 19+). */
export function nuevoToken(): string {
  return crypto.randomUUID();
}

export interface PayloadOrigen {
  readonly token_visitante: string;
  readonly token_visita: string;
  readonly utm_source: string | null;
  readonly utm_campaign: string | null;
  readonly utm_content: string | null;
  readonly fbclid: string | null;
  readonly id_publicacion: number | null;
}

/** Normaliza tokens y parámetros para el endpoint de captación. */
export function aPayloadOrigen(
  tokens: TokensSesion,
  parametros: ParametrosOrigen,
): PayloadOrigen {
  return {
    token_visitante: tokens.tokenVisitante,
    token_visita: tokens.tokenVisita,
    utm_source: parametros.utmSource || null,
    utm_campaign: parametros.utmCampaign || null,
    utm_content: parametros.utmContent || null,
    fbclid: parametros.fbclid || null,
    id_publicacion: parametros.idPublicacion,
  };
}
