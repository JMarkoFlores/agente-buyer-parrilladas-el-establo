import { describe, expect, it } from 'vitest';
import {
  ORIGEN_VACIO,
  aPayloadOrigen,
  fusionarOrigen,
  leerParametrosOrigen,
  tieneOrigen,
  tokenValido,
} from './captacion-origen.model';

describe('captacion-origen', () => {
  it('lee utm, fbclid e id de publicación de la URL', () => {
    const origen = leerParametrosOrigen(
      '?utm_source=facebook&utm_campaign=parrilla&utm_content=video&fbclid=abc123&id_publicacion=42',
    );

    expect(origen).toEqual({
      utmSource: 'facebook',
      utmCampaign: 'parrilla',
      utmContent: 'video',
      fbclid: 'abc123',
      idPublicacion: 42,
    });
  });

  it('ignora parámetros ausentes o inválidos', () => {
    expect(leerParametrosOrigen('')).toEqual(ORIGEN_VACIO);
    expect(leerParametrosOrigen('?id_publicacion=abc').idPublicacion).toBeNull();
    expect(leerParametrosOrigen('?id_publicacion=-3').idPublicacion).toBeNull();
    expect(tieneOrigen(ORIGEN_VACIO)).toBe(false);
  });

  it('fusiona orígenes conservando lo previo cuando lo nuevo viene vacío', () => {
    const previo = leerParametrosOrigen('?utm_source=instagram&utm_campaign=menos');
    const nuevo = leerParametrosOrigen('?utm_campaign=carta&id_publicacion=7');
    const fusionado = fusionarOrigen(previo, nuevo);

    expect(fusionado.utmSource).toBe('instagram');
    expect(fusionado.utmCampaign).toBe('carta');
    expect(fusionado.idPublicacion).toBe(7);
  });

  it('valida tokens UUID', () => {
    expect(tokenValido('2a4b6c8e-1f3a-4b5c-9d0e-1a2b3c4d5e6f')).toBe(true);
    expect(tokenValido('sin-formato')).toBe(false);
  });

  it('normaliza el payload de origen', () => {
    const payload = aPayloadOrigen(
      { tokenVisitante: 'aaa', tokenVisita: 'bbb' },
      leerParametrosOrigen('?utm_source=facebook&id_publicacion=9'),
    );

    expect(payload).toEqual({
      token_visitante: 'aaa',
      token_visita: 'bbb',
      utm_source: 'facebook',
      utm_campaign: null,
      utm_content: null,
      fbclid: null,
      id_publicacion: 9,
    });
  });
});
