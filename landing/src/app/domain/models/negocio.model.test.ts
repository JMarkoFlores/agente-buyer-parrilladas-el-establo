import { describe, expect, it } from 'vitest';
import { NEGOCIO, enlaceWhatsApp } from './negocio.model';

describe('negocio', () => {
  it('genera un enlace de WhatsApp con el mensaje codificado', () => {
    const enlace = enlaceWhatsApp('Hola, quiero reservar');
    expect(enlace).toBe('https://wa.me/51999999999?text=Hola%2C%20quiero%20reservar');
  });

  it('usa solo dígitos en el número de WhatsApp', () => {
    expect(NEGOCIO.whatsapp).toMatch(/^\d{9,15}$/);
  });

  it('define la ruta interna del formulario de captación', () => {
    expect(NEGOCIO.formularioUrl).toBe('/registro');
  });
});
