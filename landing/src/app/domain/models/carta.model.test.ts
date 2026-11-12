import { describe, expect, it } from 'vitest';
import { CARTA, agrupar, destacados, etiquetaItem, soles } from './carta.model';

describe('carta', () => {
  it('formatea precios en soles con dos decimales', () => {
    expect(soles(32)).toBe('S/ 32.00');
    expect(soles(6.5)).toBe('S/ 6.50');
    expect(soles(200)).toBe('S/ 200.00');
  });

  it('tiene las nueve categorías de la carta con items y precios válidos', () => {
    expect(CARTA.map((categoria) => categoria.id)).toEqual([
      'res',
      'cerdo',
      'pollo',
      'entradas',
      'combos',
      'ensaladas',
      'acompanamientos',
      'bebidas',
      'vinos',
    ]);

    for (const categoria of CARTA) {
      expect(categoria.items.length).toBeGreaterThan(0);
      for (const item of categoria.items) {
        expect(item.precio).toBeGreaterThan(0);
        expect(item.nombre.trim()).not.toBe('');
      }
    }
  });

  it('incluye los combos para compartir', () => {
    const combos = CARTA.find((categoria) => categoria.id === 'combos');

    expect(combos).toBeDefined();
    expect(combos?.items.map((item) => item.nombre)).toEqual(
      expect.arrayContaining([
        'Mixta Grande',
        'Mixta Junior',
        'Señor Cuatrero',
        'Trilogía Cuatrero',
        'Cuatrero',
        'Cuatrero mix',
      ]),
    );
    expect(combos?.items.find((item) => item.nombre === 'Mixta Grande')?.precio).toBe(200);
  });

  it('registra cada tamaño como un item independiente', () => {
    const res = CARTA.find((categoria) => categoria.id === 'res');
    const lomos = res?.items.filter((item) => item.nombre === 'Lomo fino') ?? [];

    expect(lomos.map((item) => item.detalle)).toEqual(['400 g', '300 g']);
    expect(lomos.map((item) => item.precio)).toEqual([64, 54]);
  });

  it('no repite nombre y detalle dentro de un mismo subgrupo', () => {
    for (const categoria of CARTA) {
      const claves = categoria.items.map(
        (item) => `${item.grupo ?? ''}|${item.nombre}|${item.detalle ?? ''}`,
      );
      expect(new Set(claves).size).toBe(claves.length);
    }
  });

  it('agrupa por subgrupo conservando el orden', () => {
    const grupos = agrupar([
      { nombre: 'A', precio: 10, grupo: 'Uno' },
      { nombre: 'B', precio: 10, grupo: 'Uno' },
      { nombre: 'C', precio: 10, grupo: 'Dos' },
    ]);

    expect(grupos.map((grupo) => grupo.titulo)).toEqual(['Uno', 'Dos']);
    expect(grupos[0].items.map((item) => item.nombre)).toEqual(['A', 'B']);
  });

  it('etiqueta el item con su medida cuando existe', () => {
    expect(etiquetaItem({ nombre: 'Picanha', detalle: '400 g', precio: 65 })).toBe('Picanha · 400 g');
    expect(etiquetaItem({ nombre: 'Salsa BBQ', precio: 10 })).toBe('Salsa BBQ');
  });

  it('expone al menos tres destacados y todos tienen imagen', () => {
    const favoritos = destacados();

    expect(favoritos.length).toBeGreaterThanOrEqual(3);
    for (const item of favoritos) {
      expect(item.imagen).toBeTruthy();
    }
  });
});
