import {
  ORIGEN_VACIO,
  fusionarOrigen,
  leerParametrosOrigen,
  nuevoToken,
  tieneOrigen,
  tokenValido,
  type ParametrosOrigen,
  type TokensSesion,
} from '../app/domain/models/captacion-origen.model';

const COOKIE_VISITANTE = 'establo_vid';
const DIAS_COOKIE = 365;
const CLAVE_VISITA = 'establo_vsid';
const CLAVE_ORIGEN = 'establo_origen';
const CLAVE_ID_VISITA = 'establo_id_visita';

export const API_BASE = (import.meta.env.PUBLIC_API_URL ?? 'http://localhost:5000').replace(/\/$/, '');

function leerCookie(nombre: string): string {
  const prefijo = `${nombre}=`;
  const encontrada = document.cookie
    .split(';')
    .map((parte) => parte.trim())
    .find((parte) => parte.startsWith(prefijo));

  if (!encontrada) {
    return '';
  }

  try {
    return decodeURIComponent(encontrada.slice(prefijo.length));
  } catch {
    return '';
  }
}

function escribirCookie(nombre: string, valor: string, dias: number): void {
  const seguro = window.location.protocol === 'https:' ? '; Secure' : '';
  document.cookie = `${nombre}=${encodeURIComponent(valor)}; path=/; max-age=${dias * 86400}; SameSite=Lax${seguro}`;
}

function leerClave(clave: string): string {
  try {
    return window.sessionStorage.getItem(clave) ?? '';
  } catch {
    return '';
  }
}

function escribirClave(clave: string, valor: string): void {
  try {
    window.sessionStorage.setItem(clave, valor);
  } catch {
    /* modo privado: seguimos sin persistencia */
  }
}

function borrarClave(clave: string): void {
  try {
    window.sessionStorage.removeItem(clave);
  } catch {
    /* ignora */
  }
}

function tokenVigente(valor: string): string {
  return tokenValido(valor) ? valor : nuevoToken();
}

/** Tokens que acompañan el POST de captación. */
export function obtenerTokens(): TokensSesion {
  const cookie = tokenVigente(leerCookie(COOKIE_VISITANTE));
  escribirCookie(COOKIE_VISITANTE, cookie, DIAS_COOKIE);

  const visita = tokenVigente(leerClave(CLAVE_VISITA));
  escribirClave(CLAVE_VISITA, visita);

  return { tokenVisitante: cookie, tokenVisita: visita };
}

/** Origen (utm/fbclid) guardado al entrar al sitio. */
export function leerOrigen(): ParametrosOrigen {
  const crudo = leerClave(CLAVE_ORIGEN);

  if (crudo) {
    try {
      return JSON.parse(crudo) as ParametrosOrigen;
    } catch {
      borrarClave(CLAVE_ORIGEN);
    }
  }

  return ORIGEN_VACIO;
}

/** Guarda el origen de la URL actual sin perder el anterior. */
export function capturarOrigen(busqueda: string = window.location.search): ParametrosOrigen {
  const nuevo = leerParametrosOrigen(busqueda);
  const actual = leerOrigen();
  const fusionado = fusionarOrigen(actual, nuevo);

  if (tieneOrigen(fusionado)) {
    escribirClave(CLAVE_ORIGEN, JSON.stringify(fusionado));
  }

  return fusionado;
}

/** Detecta tipo de dispositivo según userAgent */
function detectarDispositivo(): string {
  if (typeof navigator === 'undefined') return 'DESCONOCIDO';
  const ua = navigator.userAgent || '';
  if (/(tablet|ipad|playbook|silk)|(android(?!.*mobi))/i.test(ua)) return 'TABLETA';
  if (/Mobile|Android|iP(hone|od)|IEMobile|BlackBerry|Kindle|Silk-Accelerated|(hpw|web)OS|Opera M(obi|ini)/i.test(ua)) {
    return 'MOVIL';
  }
  return 'ESCRITORIO';
}

/** Envía un evento interactivo al backend */
export async function registrarEvento(
  tipo: string,
  idProducto?: number | null,
  detalle?: string,
): Promise<void> {
  try {
    const tokens = obtenerTokens();
    const idVisitaStr = leerClave(CLAVE_ID_VISITA);
    const idVisita = idVisitaStr ? Number.parseInt(idVisitaStr, 10) : null;

    await fetch(`${API_BASE}/api/landing/eventos`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        id_visita: idVisita,
        token_visitante: tokens.tokenVisitante,
        tipo,
        id_producto: idProducto || null,
        detalle: detalle || null,
      }),
    });
  } catch (error) {
    console.debug('No se pudo registrar evento web:', error);
  }
}

/** Registra la visita en SQL Server mediante el backend Flask */
async function registrarVisitaEnServidor(tokens: TokensSesion, origen: ParametrosOrigen): Promise<void> {
  try {
    const respuesta = await fetch(`${API_BASE}/api/landing/visitas`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        token_visitante: tokens.tokenVisitante,
        token_visita: tokens.tokenVisita,
        utm_source: origen.utmSource || null,
        utm_campaign: origen.utmCampaign || null,
        id_publicacion: origen.idPublicacion || null,
        dispositivo_tipo: detectarDispositivo(),
      }),
    });

    if (respuesta.ok) {
      const datos = await respuesta.json();
      if (datos?.id_visita) {
        escribirClave(CLAVE_ID_VISITA, String(datos.id_visita));
      }
    }
  } catch (error) {
    console.debug('No se pudo sincronizar la visita con el backend:', error);
  }
}

/** Configura escuchadores de clics globales para métricas de interacción */
function configurarSeguimientoInteracciones(): void {
  if (typeof document === 'undefined') return;

  document.addEventListener('click', (evento) => {
    const target = (evento.target as HTMLElement | null)?.closest('a, button');
    if (!target) return;

    const href = target.getAttribute('href') || '';

    // Clic en carta
    if (href.includes('/carta') || target.hasAttribute('data-track-carta')) {
      registrarEvento('CLIC_CARTA', null, 'Clic hacia la carta');
    }
    // Clic en WhatsApp
    else if (href.includes('wa.me') || href.includes('whatsapp.com')) {
      registrarEvento('CLIC_WHATSAPP', null, 'Clic en botón WhatsApp');
    }
    // Clic en formulario o reserva
    else if (href.includes('/registro') || href.includes('#reservas')) {
      registrarEvento('CLIC_FORMULARIO', null, 'Clic hacia el formulario de reserva');
    }
  });

  // Si estamos en la página de la carta completa, registrar VISTA_CARTA
  if (typeof window !== 'undefined' && window.location.pathname.startsWith('/carta')) {
    registrarEvento('VISTA_CARTA', null, 'Página de carta visualizada');
  }
}

/** Se llama en cada página: crea tokens, captura la atribución y registra la sesión */
export function iniciarSeguimiento(): void {
  const tokens = obtenerTokens();
  const origen = capturarOrigen();

  // Registrar visita en backend asíncronamente
  registrarVisitaEnServidor(tokens, origen).then(() => {
    configurarSeguimientoInteracciones();
  });
}
