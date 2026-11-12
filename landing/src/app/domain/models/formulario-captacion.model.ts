import {
  aPayloadOrigen,
  type ParametrosOrigen,
  type PayloadOrigen,
  type TokensSesion,
} from './captacion-origen.model';

/**
 * Formulario de captación del sitio (BUYER -> LEAD).
 *
 * Recolecta los datos de `persona` y `formulario_captacion`:
 * nombres, apellidos, telefono, email, fecha de nacimiento, plato favorito y
 * los consentimientos. Los ids de tracking viajan como tokens opacos.
 */
export interface FormularioCaptacion {
  nombres: string;
  apellidos: string;
  telefono: string;
  email: string;
  /** Formato `YYYY-MM-DD`; vacío si no lo declara. */
  fechaNacimiento: string;
  /** Nombre del plato favorito; el backend lo resuelve a `producto_carta`. */
  idProductoFavorito: string;
  aceptaPoliticaDatos: boolean;
  aceptaMarketing: boolean;
}

export type CampoFormulario = keyof FormularioCaptacion;
export type ErroresFormulario = Partial<Record<CampoFormulario, string>>;

export interface ValidacionFormulario {
  readonly valido: boolean;
  readonly errores: ErroresFormulario;
}

export const FORMULARIO_VACIO: FormularioCaptacion = {
  nombres: '',
  apellidos: '',
  telefono: '',
  email: '',
  fechaNacimiento: '',
  idProductoFavorito: '',
  aceptaPoliticaDatos: false,
  aceptaMarketing: false,
};

const EMAIL = /^[^\s@]+@[^\s@]+\.[a-z]{2,}$/i;
const FECHA = /^\d{4}-\d{2}-\d{2}$/;

/** Deja el celular peruano en 9 dígitos: "+51 912 345 678" -> "912345678". */
export function telefonoNormalizado(valor: string): string {
  const digitos = valor.replace(/\D/g, '');
  const nacional = digitos.startsWith('51') && digitos.length > 9 ? digitos.slice(2) : digitos;

  return /^9\d{8}$/.test(nacional) ? nacional : '';
}

export function emailValido(valor: string): boolean {
  return EMAIL.test(valor.trim());
}

function fechaValida(valor: string, hoy: Date): boolean {
  if (!FECHA.test(valor)) {
    return false;
  }

  const fecha = new Date(`${valor}T00:00:00`);
  if (Number.isNaN(fecha.getTime())) {
    return false;
  }

  return fecha.getTime() <= hoy.getTime();
}

/** Valida el formulario completo. `hoy` se inyecta para poder testear. */
export function validarFormularioCaptacion(
  datos: FormularioCaptacion,
  hoy: Date = new Date(),
): ValidacionFormulario {
  const errores: ErroresFormulario = {};
  const nombres = datos.nombres.trim();
  const apellidos = datos.apellidos.trim();
  const email = datos.email.trim();

  if (nombres.length < 2) {
    errores.nombres = 'Ingresa tus nombres.';
  } else if (nombres.length > 100) {
    errores.nombres = 'Máximo 100 caracteres.';
  }

  if (apellidos.length < 2) {
    errores.apellidos = 'Ingresa tus apellidos.';
  } else if (apellidos.length > 100) {
    errores.apellidos = 'Máximo 100 caracteres.';
  }

  if (!telefonoNormalizado(datos.telefono)) {
    errores.telefono = 'Ingresa un celular peruano de 9 dígitos.';
  }

  if (email && !emailValido(email)) {
    errores.email = 'Ingresa un correo válido.';
  }

  if (datos.fechaNacimiento && !fechaValida(datos.fechaNacimiento, hoy)) {
    errores.fechaNacimiento = 'Ingresa una fecha válida que no sea futura.';
  }

  if (datos.idProductoFavorito.length > 120) {
    errores.idProductoFavorito = 'Selecciona un plato de la lista.';
  }

  if (!datos.aceptaPoliticaDatos) {
    errores.aceptaPoliticaDatos = 'Necesitamos tu autorización para tratar tus datos.';
  }

  return { valido: Object.keys(errores).length === 0, errores };
}

export interface PayloadCaptacion {
  readonly persona: {
    readonly nombres: string;
    readonly apellidos: string;
    readonly telefono: string;
    readonly email: string | null;
    readonly fecha_nacimiento: string | null;
    readonly consentimiento_datos: true;
    readonly consentimiento_marketing: boolean;
  };
  readonly formulario: {
    readonly id_plataforma_origen: 'LANDING_PAGE';
    readonly id_publicacion_origen: number | null;
    readonly producto_favorito: string | null;
    readonly fecha_envio: string;
    readonly acepta_politica_datos: true;
    readonly acepta_marketing: boolean;
  };
  readonly origen: PayloadOrigen;
}

/** Normaliza el formulario al JSON que consume el endpoint de captación. */
export function aPayloadCaptacion(
  datos: FormularioCaptacion,
  tokens: TokensSesion,
  parametros: ParametrosOrigen,
  fecha: Date = new Date(),
): PayloadCaptacion {
  const email = datos.email.trim();

  return {
    persona: {
      nombres: datos.nombres.trim(),
      apellidos: datos.apellidos.trim(),
      telefono: telefonoNormalizado(datos.telefono),
      email: email || null,
      fecha_nacimiento: datos.fechaNacimiento || null,
      consentimiento_datos: true,
      consentimiento_marketing: datos.aceptaMarketing,
    },
    formulario: {
      id_plataforma_origen: 'LANDING_PAGE',
      id_publicacion_origen: parametros.idPublicacion,
      producto_favorito: datos.idProductoFavorito || null,
      fecha_envio: fecha.toISOString(),
      acepta_politica_datos: true,
      acepta_marketing: datos.aceptaMarketing,
    },
    origen: aPayloadOrigen(tokens, parametros),
  };
}
