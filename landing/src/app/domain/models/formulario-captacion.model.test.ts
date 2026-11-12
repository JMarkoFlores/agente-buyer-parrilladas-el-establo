import { describe, expect, it } from 'vitest';
import { ORIGEN_VACIO, leerParametrosOrigen } from './captacion-origen.model';
import {
  FORMULARIO_VACIO,
  aPayloadCaptacion,
  emailValido,
  telefonoNormalizado,
  validarFormularioCaptacion,
  type FormularioCaptacion,
} from './formulario-captacion.model';

const TOKENS = { tokenVisitante: 'token-visitante', tokenVisita: 'token-visita' };
const HOY = new Date('2026-11-10T15:00:00Z');

function completo(extra: Partial<FormularioCaptacion> = {}): FormularioCaptacion {
  return {
    ...FORMULARIO_VACIO,
    nombres: 'Ana',
    apellidos: 'Pérez',
    telefono: '+51 912 345 678',
    aceptaPoliticaDatos: true,
    ...extra,
  };
}

describe('formulario-captacion', () => {
  it('normaliza celulares peruanos a nueve dígitos', () => {
    expect(telefonoNormalizado('+51 912 345 678')).toBe('912345678');
    expect(telefonoNormalizado('51912345678')).toBe('912345678');
    expect(telefonoNormalizado('912345678')).toBe('912345678');
    expect(telefonoNormalizado('912-345-678')).toBe('912345678');
    expect(telefonoNormalizado('812345678')).toBe('');
    expect(telefonoNormalizado('')).toBe('');
  });

  it('valida correos', () => {
    expect(emailValido('ana@ejemplo.pe')).toBe(true);
    expect(emailValido('ana@ejemplo')).toBe(false);
    expect(emailValido('ana ejemplo@correo.com')).toBe(false);
  });

  it('acepta un formulario completo', () => {
    const { valido, errores } = validarFormularioCaptacion(completo(), HOY);

    expect(valido).toBe(true);
    expect(errores).toEqual({});
  });

  it('exige nombres, apellidos, celular y autorización de datos', () => {
    const { valido, errores } = validarFormularioCaptacion(FORMULARIO_VACIO, HOY);

    expect(valido).toBe(false);
    expect(errores.nombres).toBeDefined();
    expect(errores.apellidos).toBeDefined();
    expect(errores.telefono).toBeDefined();
    expect(errores.aceptaPoliticaDatos).toBeDefined();
  });

  it('rechaza fechas futuras o mal formadas y correos inválidos', () => {
    const futuro = validarFormularioCaptacion(
      completo({ fechaNacimiento: '2027-01-01', email: 'no-es-correo' }),
      HOY,
    );

    expect(futuro.errores.fechaNacimiento).toBeDefined();
    expect(futuro.errores.email).toBeDefined();
  });

  it('el marketing es opcional', () => {
    const sinMarketing = validarFormularioCaptacion(completo({ aceptaMarketing: false }), HOY);
    expect(sinMarketing.valido).toBe(true);

    const conMarketing = aPayloadCaptacion(
      completo({ aceptaMarketing: true }),
      TOKENS,
      ORIGEN_VACIO,
      HOY,
    );
    expect(conMarketing.persona.consentimiento_marketing).toBe(true);
    expect(conMarketing.formulario.acepta_marketing).toBe(true);
  });

  it('arma el payload de persona, formulario y origen', () => {
    const payload = aPayloadCaptacion(
      completo({ email: ' ana@ejemplo.pe ', fechaNacimiento: '1990-05-04', idProductoFavorito: 'Picanha · 400 g' }),
      TOKENS,
      leerParametrosOrigen('?utm_source=facebook&utm_campaign=carta&id_publicacion=12'),
      HOY,
    );

    expect(payload.persona).toEqual({
      nombres: 'Ana',
      apellidos: 'Pérez',
      telefono: '912345678',
      email: 'ana@ejemplo.pe',
      fecha_nacimiento: '1990-05-04',
      consentimiento_datos: true,
      consentimiento_marketing: false,
    });
    expect(payload.formulario).toEqual({
      id_plataforma_origen: 'LANDING_PAGE',
      id_publicacion_origen: 12,
      producto_favorito: 'Picanha · 400 g',
      fecha_envio: '2026-11-10T15:00:00.000Z',
      acepta_politica_datos: true,
      acepta_marketing: false,
    });
    expect(payload.origen).toEqual({
      token_visitante: 'token-visitante',
      token_visita: 'token-visita',
      utm_source: 'facebook',
      utm_campaign: 'carta',
      utm_content: null,
      fbclid: null,
      id_publicacion: 12,
    });
  });

  it('deja en null los campos opcionales vacíos', () => {
    const payload = aPayloadCaptacion(completo(), TOKENS, ORIGEN_VACIO, HOY);

    expect(payload.persona.email).toBeNull();
    expect(payload.persona.fecha_nacimiento).toBeNull();
    expect(payload.formulario.producto_favorito).toBeNull();
  });
});
