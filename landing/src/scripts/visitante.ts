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

/** Se llama en cada página: crea tokens y captura la atribución. */
export function iniciarSeguimiento(): void {
  obtenerTokens();
  capturarOrigen();
}
