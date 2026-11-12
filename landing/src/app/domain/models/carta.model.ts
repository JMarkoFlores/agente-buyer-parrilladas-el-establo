export type CategoriaId =
  | 'res'
  | 'cerdo'
  | 'pollo'
  | 'entradas'
  | 'combos'
  | 'ensaladas'
  | 'acompanamientos'
  | 'bebidas'
  | 'vinos';

export interface ItemCarta {
  readonly nombre: string;
  /** Composición o ingredientes del plato. */
  readonly descripcion?: string;
  /** Medida o porción, p. ej. "500 g" o "1 Litro". */
  readonly detalle?: string;
  /** Subgrupo dentro de la categoría, p. ej. "Argentina" o "Cervezas". */
  readonly grupo?: string;
  /** Precio en soles, IGV incluido. */
  readonly precio: number;
  readonly destacado?: boolean;
  /** Imagen opcional (ruta en /public) para las tarjetas de destacados. */
  readonly imagen?: string;
}

export interface Categoria {
  readonly id: CategoriaId;
  readonly titulo: string;
  /** Aclaración general de la categoría (guarniciones, IGV, etc.). */
  readonly nota?: string;
  readonly items: ReadonlyArray<ItemCarta>;
}

const SOLO_PAPAS = 'Dos espadas, acompañadas solo de papas fritas.';

export const CARTA: ReadonlyArray<Categoria> = [
  {
    id: 'res',
    titulo: 'Carnes de res',
    nota: 'Cortes a la parrilla. Las guarniciones vienen incluidas salvo indicación del plato.',
    items: [
      // Angus · americana y uruguaya
      {
        nombre: 'Asado de tira de res',
        grupo: 'Angus · Americana y uruguaya',
        detalle: '500 g',
        precio: 115,
      },
      {
        nombre: 'Entraña fina',
        grupo: 'Angus · Americana y uruguaya',
        detalle: '400 g',
        precio: 125,
      },
      {
        nombre: 'Beefe angosto',
        grupo: 'Angus · Americana y uruguaya',
        detalle: '400 g',
        precio: 100,
      },
      {
        nombre: 'Picanha',
        grupo: 'Angus · Americana y uruguaya',
        detalle: '400 g',
        precio: 115,
        destacado: true,
        imagen: '/img/picanha.jpg',
      },
      {
        nombre: 'Beefe ancho',
        grupo: 'Angus · Americana y uruguaya',
        detalle: '400 g',
        precio: 105,
      },
      // Argentina
      {
        nombre: 'Beefe ancho',
        grupo: 'Argentina',
        detalle: '300 g',
        precio: 72,
      },
      {
        nombre: 'Picanha',
        grupo: 'Argentina',
        detalle: '400 g',
        precio: 80,
      },
      // Nacional
      {
        nombre: 'Lomo fino',
        grupo: 'Nacional',
        detalle: '400 g',
        precio: 64,
      },
      {
        nombre: 'Lomo fino',
        grupo: 'Nacional',
        detalle: '300 g',
        precio: 54,
      },
      {
        nombre: 'Beefe ancho',
        grupo: 'Nacional',
        detalle: '300 g',
        precio: 49,
      },
      {
        nombre: 'Beefe angosto',
        grupo: 'Nacional',
        detalle: '400 g',
        precio: 51,
      },
      {
        nombre: 'Beefe angosto',
        grupo: 'Nacional',
        detalle: '300 g',
        precio: 47,
      },
      {
        nombre: 'Beefe de chorizo',
        grupo: 'Nacional',
        detalle: '400 g',
        precio: 52,
      },
      {
        nombre: 'Picanha',
        grupo: 'Nacional',
        detalle: '400 g',
        precio: 65,
      },
      {
        nombre: 'Cuadril',
        grupo: 'Nacional',
        detalle: '400 g',
        precio: 50,
      },
      {
        nombre: 'Cuadril',
        grupo: 'Nacional',
        detalle: '300 g',
        precio: 45,
      },
      {
        nombre: 'Churrasco',
        grupo: 'Nacional',
        detalle: '300 g',
        precio: 41,
        destacado: true,
        imagen: '/img/churrasco.jpg',
      },
      {
        nombre: 'Entraña fina',
        grupo: 'Nacional',
        detalle: '400 g',
        precio: 62,
      },
      {
        nombre: 'Asado de tira de res',
        grupo: 'Nacional',
        detalle: '700 g',
        precio: 62,
      },
      {
        nombre: 'T. Bone',
        grupo: 'Nacional',
        detalle: '400 g',
        precio: 75,
      },
      {
        nombre: 'Tomahawk',
        grupo: 'Nacional',
        detalle: '1.00 kg',
        precio: 145,
      },
      {
        nombre: 'Anticuchos de lomo fino en espadas',
        grupo: 'Nacional',
        descripcion: SOLO_PAPAS,
        precio: 45,
      },
    ],
  },
  {
    id: 'cerdo',
    titulo: 'Cerdo',
    nota: 'Cortes a la parrilla. Las guarniciones vienen incluidas salvo indicación del plato.',
    items: [
      {
        nombre: 'Asado de tira de cerdo',
        grupo: 'Cortes',
        detalle: '700 g',
        descripcion: 'Dos cortes de tira de cerdo.',
        precio: 58,
      },
      {
        nombre: 'Chuleta de cerdo',
        grupo: 'Cortes',
        detalle: '500 g',
        descripcion: 'Dos cortes de chuleta.',
        precio: 51,
      },
      {
        nombre: 'Chuleta de cerdo',
        grupo: 'Cortes',
        detalle: '300 g',
        precio: 39,
      },
      {
        nombre: 'Lomo de cerdo (salomillo)',
        grupo: 'Cortes',
        detalle: '400 g',
        precio: 53,
      },
      {
        nombre: 'Anticuchos de lomo fino de cerdo en espadas',
        grupo: 'Cortes',
        descripcion: SOLO_PAPAS,
        precio: 42,
      },
      {
        nombre: 'Costilla de cerdo St. Louis',
        grupo: 'Costillas',
        precio: 52,
      },
      {
        nombre: 'Costilla de cerdo St. Louis en salsa BBQ',
        grupo: 'Costillas',
        precio: 58,
      },
      {
        nombre: 'Baby Ribs',
        grupo: 'Costillas',
        detalle: '700 a 800 g',
        descripcion: 'Costilla de cerdo para dos personas.',
        precio: 76,
      },
      {
        nombre: 'Baby Ribs en salsa BBQ',
        grupo: 'Costillas',
        detalle: '700 a 800 g',
        descripcion: 'Costilla de cerdo para dos personas.',
        precio: 81,
      },
    ],
  },
  {
    id: 'pollo',
    titulo: 'Pollo',
    nota: 'Cortes a la parrilla. Las guarniciones vienen incluidas.',
    items: [
      {
        nombre: '1/4 de pollo a la parrilla',
        precio: 30,
      },
      {
        nombre: 'Filete de pechuga',
        detalle: '400 g',
        precio: 38,
      },
    ],
  },
  {
    id: 'entradas',
    titulo: 'Entradas',
    nota: 'Salvo el anticucho y el chorizo por unidad, las entradas vienen con papas fritas, papas sancochadas o nuestra clásica ensalada mixta.',
    items: [
      {
        nombre: 'Alitas en salsa BBQ',
        detalle: '6 unidades',
        descripcion: 'Alitas bañadas en salsa BBQ.',
        precio: 30,
      },
      {
        nombre: 'Mollejitas a la parrilla',
        detalle: '300 g',
        precio: 30,
      },
      {
        nombre: 'Champiñones a la parrilla',
        detalle: '200 g',
        precio: 25,
      },
      {
        nombre: 'Anticuchos de corazón de res',
        detalle: '2 palitos',
        precio: 28,
      },
      {
        nombre: 'Anticuchos de champiñones',
        detalle: '2 palitos',
        precio: 28,
      },
      {
        nombre: 'Chorizo parrillero porción',
        detalle: '3 unidades',
        precio: 30,
      },
      {
        nombre: 'Anticucho por unidad',
        precio: 14,
      },
      {
        nombre: 'Chorizo parrillero por unidad',
        precio: 13,
      },
      {
        nombre: 'Piqueo Cuatrero',
        descripcion: '3 alitas + 2 anticuchos + 4 mollejitas + 2 chorizos.',
        precio: 44,
      },
    ],
  },
  {
    id: 'combos',
    titulo: 'Combos para compartir',
    nota: 'Parrillas surtidas pensadas para compartir. Las guarniciones vienen incluidas.',
    items: [
      {
        nombre: 'Mixta Grande',
        grupo: 'Parrillas para compartir',
        detalle: 'Ideal para 7 personas',
        descripcion:
          '1/4 de pollo + 3 chuletas de cerdo + 2 churrascos + 1 asado de tira + 3 anticuchos de corazón + 8 mollejitas + 3 chorizos + 2 porciones de papas fritas + 2 ensaladas mixtas.',
        precio: 200,
        destacado: true,
        imagen: '/img/parrilla-mixta.jpg',
      },
      {
        nombre: 'Mixta Junior',
        grupo: 'Parrillas para compartir',
        detalle: 'Ideal para 5 personas',
        descripcion:
          '1/4 de pollo + 2 chuletas de cerdo + 1 churrasco + 2 anticuchos de corazón + 4 mollejitas + 2 chorizos + 1 porción de papas fritas + 1 ensalada mixta.',
        precio: 160,
      },
      {
        nombre: 'Señor Cuatrero',
        grupo: 'Combos personales',
        detalle: '900 g',
        descripcion:
          '300 g de lomo fino + 300 g de cuadril + 300 g de beefe, con papas y ensalada mixta.',
        precio: 130,
      },
      {
        nombre: 'Trilogía Cuatrero',
        grupo: 'Combos personales',
        detalle: '600 g',
        descripcion:
          '200 g de beefe + 200 g de filete de pierna + 200 g de lomo de cerdo, con papas y ensalada mixta.',
        precio: 72,
      },
      {
        nombre: 'Cuatrero',
        grupo: 'Combos personales',
        detalle: '500 g',
        descripcion: 'Dos cortes de churrasco.',
        precio: 54,
      },
      {
        nombre: 'Cuatrero mix',
        grupo: 'Combos personales',
        detalle: '500 g',
        descripcion: 'Un corte de churrasco y un corte de cerdo.',
        precio: 54,
      },
    ],
  },
  {
    id: 'ensaladas',
    titulo: 'Ensaladas',
    items: [
      {
        nombre: 'Ensalada mixta clásica',
        descripcion:
          'Lechuga, tomate, pepinillo, zanahoria, beterraga, palta y aliño de la casa.',
        precio: 15,
      },
      {
        nombre: 'Ensalada mixta personal',
        descripcion:
          'Lechuga, tomate, pepinillo, zanahoria, beterraga, palta y aliño de la casa.',
        precio: 10,
      },
      {
        nombre: 'Ensalada César al estilo Cuatrero',
        descripcion:
          'Lechuga romana, tocino en cuadraditos, queso parmesano rallado y fajitas de pollo con aliño de la casa.',
        precio: 26,
      },
      {
        nombre: 'Ensalada de palta',
        descripcion: 'Palta entera y zanahoria con aliño de la casa.',
        precio: 15,
      },
    ],
  },
  {
    id: 'acompanamientos',
    titulo: 'Acompañamientos',
    items: [
      { nombre: 'Porción de papas fritas', precio: 14 },
      { nombre: 'Plato compartido de papas fritas', precio: 8 },
      { nombre: 'Porción de papa sancochada', precio: 14 },
      { nombre: 'Salsa BBQ', precio: 10 },
    ],
  },
  {
    id: 'bebidas',
    titulo: 'Bebidas',
    nota: 'La limonada frozen tiene un costo adicional de S/ 5.',
    items: [
      { nombre: 'Gaseosa Coca Cola', grupo: 'Gaseosas', detalle: '1 Litro', precio: 8 },
      { nombre: 'Gaseosa Inca Kola', grupo: 'Gaseosas', detalle: '1 Litro', precio: 8 },
      { nombre: 'Gaseosa personal', grupo: 'Gaseosas', detalle: '296 ml', precio: 3 },
      { nombre: 'Coca Cola Zero', grupo: 'Gaseosas', detalle: '500 ml', precio: 4 },
      { nombre: 'Inca Kola Zero', grupo: 'Gaseosas', detalle: '500 ml', precio: 4 },
      { nombre: 'Agua con gas o sin gas', grupo: 'Gaseosas', detalle: '625 ml', precio: 3 },

      { nombre: 'Jarra de limonada clásica', grupo: 'Limonadas', precio: 13 },
      { nombre: 'Jarra de limonada cherry', grupo: 'Limonadas', precio: 15 },
      { nombre: 'Jarra de limonada menta', grupo: 'Limonadas', precio: 15 },
      { nombre: 'Jarra de limonada africana', grupo: 'Limonadas', precio: 15 },
      { nombre: 'Jarra de limonada tropical', grupo: 'Limonadas', precio: 15 },
      { nombre: 'Jarra de limonada eléctrica', grupo: 'Limonadas', precio: 17 },

      { nombre: 'Jarra de chicha morada', grupo: 'Jarras', precio: 15 },
      { nombre: 'Jarra de maracuyá', grupo: 'Jarras', precio: 18 },
      { nombre: 'Jarra de naranjada', grupo: 'Jarras', precio: 18 },
      { nombre: 'Jarra de jugo de piña', grupo: 'Jarras', precio: 18 },
      { nombre: 'Jarra de jugo de durazno', grupo: 'Jarras', precio: 18 },
      { nombre: 'Copa de sangría', grupo: 'Jarras', precio: 20 },
      { nombre: 'Jarra de sangría de vino', grupo: 'Jarras', detalle: 'Chile Santa Helena', precio: 55 },

      { nombre: 'Jugo de naranja', grupo: 'Jugos 16 oz', precio: 8 },
      { nombre: 'Jugo de chicha morada', grupo: 'Jugos 16 oz', precio: 8 },
      { nombre: 'Jugo de limonada', grupo: 'Jugos 16 oz', precio: 6 },
      { nombre: 'Jugo de piña', grupo: 'Jugos 16 oz', precio: 8 },
      { nombre: 'Jugo de durazno', grupo: 'Jugos 16 oz', precio: 8 },
      { nombre: 'Jugo de fresa', grupo: 'Jugos 16 oz', precio: 9 },
      { nombre: 'Jugo de mango', grupo: 'Jugos 16 oz', precio: 9 },

      { nombre: 'Té, anís o manzanilla', grupo: 'Infusiones', precio: 4 },
      { nombre: 'Café pasado', grupo: 'Infusiones', precio: 6 },

      { nombre: 'Malta Cuzqueña', grupo: 'Cervezas', detalle: '330 ml', precio: 10 },
      { nombre: 'Cuzqueña Premium', grupo: 'Cervezas', detalle: '330 ml', precio: 10 },
      { nombre: 'Cuzqueña Trigo', grupo: 'Cervezas', detalle: '330 ml', precio: 10 },
      { nombre: 'Pilsen Callao', grupo: 'Cervezas', detalle: '310 ml', precio: 8 },
      { nombre: 'Cerveza Corona', grupo: 'Cervezas', detalle: '350 ml', precio: 12 },
      { nombre: 'Cerveza Budweiser', grupo: 'Cervezas', detalle: '343 ml', precio: 12 },
      { nombre: 'Cerveza Stella Artois', grupo: 'Cervezas', detalle: '343 ml', precio: 12 },
      { nombre: 'Costera Río Rojo', grupo: 'Cervezas', detalle: '330 ml', precio: 16 },
      { nombre: 'Costera IPA', grupo: 'Cervezas', detalle: '330 ml', precio: 16 },
    ],
  },
  {
    id: 'vinos',
    titulo: 'Vinos',
    nota: 'Botellas de 750 ml salvo indicación. Se restringe el consumo de bebidas alcohólicas (Ordenanza 024-2014 MPT).',
    items: [
      { nombre: 'Tacama Selección Especial', grupo: 'Perú', detalle: '750 ml', precio: 65 },
      { nombre: 'Tacama Selección Especial', grupo: 'Perú', detalle: '375 ml', precio: 38 },
      { nombre: 'Tacama Gran Tinto', grupo: 'Perú', detalle: '750 ml', precio: 50 },
      { nombre: 'Tacama Gran Tinto', grupo: 'Perú', detalle: '375 ml', precio: 25 },
      { nombre: 'Tacama Blanco de Blancos', grupo: 'Perú', detalle: '750 ml', precio: 65 },
      { nombre: 'Rubini Ocucaje', grupo: 'Perú', detalle: 'Cabernet Sauvignon · 750 ml', precio: 110 },
      { nombre: 'Fond de Cave', grupo: 'Perú', detalle: 'Cabernet · 750 ml', precio: 45 },
      { nombre: 'Fond de Cave', grupo: 'Perú', detalle: 'Cabernet · 375 ml', precio: 24 },
      { nombre: 'Intipalka Valle del Sol', grupo: 'Perú', detalle: 'Malbec · 750 ml', precio: 65 },
      { nombre: 'Intipalka Valle del Sol', grupo: 'Perú', detalle: 'Cabernet Sauvignon · 750 ml', precio: 65 },
      { nombre: 'Tabernero', grupo: 'Perú', detalle: 'Cabernet Sauvignon · 750 ml', precio: 48 },
      { nombre: 'Tabernero', grupo: 'Perú', detalle: 'Cabernet Sauvignon · 375 ml', precio: 24 },
      { nombre: 'Tabernero Gran Tinto Fina Reserva', grupo: 'Perú', detalle: '750 ml', precio: 40 },
      { nombre: 'Tabernero Gran Tinto Fina Reserva', grupo: 'Perú', detalle: '375 ml', precio: 22 },
      { nombre: 'Tabernero Blanco de Blancos', grupo: 'Perú', detalle: '750 ml', precio: 40 },

      { nombre: 'Escorihuela Gascón', grupo: 'Argentina', detalle: 'Malbec · 750 ml', precio: 80 },
      { nombre: 'Escorihuela Gascón', grupo: 'Argentina', detalle: 'Cabernet Sauvignon · 750 ml', precio: 80 },
      { nombre: 'Nieto Senetiner', grupo: 'Argentina', detalle: 'Malbec · 750 ml', precio: 75 },
      { nombre: 'Nieto Senetiner', grupo: 'Argentina', detalle: 'Cabernet Sauvignon · 750 ml', precio: 75 },
      { nombre: 'Alegoría Gran Reserva', grupo: 'Argentina', detalle: 'Malbec · 750 ml', precio: 130 },
      { nombre: 'Alegoría Gran Reserva', grupo: 'Argentina', detalle: 'Cabernet Sauvignon · 750 ml', precio: 130 },
      { nombre: 'Selección de Parcelas Reserva', grupo: 'Argentina', detalle: 'Malbec · 750 ml', precio: 100 },
      { nombre: 'Selección de Parcelas Reserva', grupo: 'Argentina', detalle: 'Cabernet Sauvignon · 750 ml', precio: 100 },
      { nombre: 'Navarro Correas', grupo: 'Argentina', detalle: 'Cabernet Sauvignon · 750 ml', precio: 80 },
      { nombre: 'Navarro Correas', grupo: 'Argentina', detalle: 'Malbec · 750 ml', precio: 80 },
      { nombre: 'Navarro Correas', grupo: 'Argentina', detalle: 'Merlot · 750 ml', precio: 80 },
      { nombre: 'Navarro Correas Blend', grupo: 'Argentina', detalle: 'Cabernet, Malbec y Merlot · 750 ml', precio: 80 },
      { nombre: 'Los Árboles', grupo: 'Argentina', detalle: 'Cabernet Sauvignon · 750 ml', precio: 55 },
      { nombre: 'Los Árboles', grupo: 'Argentina', detalle: 'Malbec · 750 ml', precio: 55 },
      { nombre: 'Los Árboles', grupo: 'Argentina', detalle: 'Sauvignon, Malbec y Merlot · 750 ml', precio: 55 },
      { nombre: 'La Celia', grupo: 'Argentina', detalle: 'Malbec · 750 ml', precio: 80 },
      { nombre: 'La Celia', grupo: 'Argentina', detalle: 'Cabernet Sauvignon · 750 ml', precio: 80 },
      { nombre: 'Séptima', grupo: 'Argentina', detalle: 'Malbec · 750 ml', precio: 65 },
      { nombre: 'Séptima', grupo: 'Argentina', detalle: 'Cabernet Sauvignon · 750 ml', precio: 65 },

      { nombre: 'Errazuris Reserva', grupo: 'Chile', detalle: 'Carmenere · 750 ml', precio: 65 },
      { nombre: 'Errazuris Reserva', grupo: 'Chile', detalle: 'Cabernet Sauvignon · 750 ml', precio: 65 },
      { nombre: 'Cousiño Macul Antiguas Reservas', grupo: 'Chile', detalle: 'Cabernet Sauvignon · 750 ml', precio: 80 },
      { nombre: 'Cousiño Macul Don Matías Reserva', grupo: 'Chile', detalle: 'Cabernet Sauvignon · 750 ml', precio: 70 },
      { nombre: 'Cousiño Macul Don Luis', grupo: 'Chile', detalle: 'Cabernet Sauvignon · 750 ml', precio: 55 },
      { nombre: 'Marqués de Casa Concha', grupo: 'Chile', detalle: 'Cabernet Sauvignon · 750 ml', precio: 110 },
      { nombre: 'Casillero del Diablo Reserva Privada', grupo: 'Chile', detalle: 'Cabernet Sauvignon · 750 ml', precio: 90 },
      { nombre: 'Casillero del Diablo Reserva', grupo: 'Chile', detalle: 'Cabernet Sauvignon · 750 ml', precio: 50 },
      { nombre: 'Casillero del Diablo Reserva', grupo: 'Chile', detalle: 'Carmenere · 750 ml', precio: 50 },
      { nombre: 'Casillero del Diablo Reserva', grupo: 'Chile', detalle: 'Malbec · 750 ml', precio: 50 },
      { nombre: 'Casillero del Diablo Reserva', grupo: 'Chile', detalle: 'Merlot · 750 ml', precio: 50 },
      { nombre: 'Casillero del Diablo Reserva', grupo: 'Chile', detalle: 'Cabernet Sauvignon · 375 ml', precio: 30 },
      { nombre: 'Concha y Toro Frontera', grupo: 'Chile', detalle: 'Cabernet Sauvignon · 750 ml', precio: 40 },

      { nombre: 'Herederos del Marqués de Riscal', grupo: 'España', detalle: 'Tempranillo · 750 ml', precio: 130 },
      { nombre: 'Herederos del Marqués de Riscal', grupo: 'España', detalle: 'Tinto Reserva · 750 ml', precio: 75 },
      { nombre: 'Protos Roble', grupo: 'España', detalle: '750 ml', precio: 75 },

      { nombre: 'Tacama Blanco de Blancos', grupo: 'Blancos', detalle: '750 ml', precio: 65 },
      { nombre: 'Tabernero Blanco de Blancos', grupo: 'Blancos', detalle: '750 ml', precio: 40 },
      { nombre: 'Selección de Parcelas Reserva', grupo: 'Blancos', detalle: 'Chardonnay · 750 ml', precio: 95 },
    ],
  },
];

/** Formatea un monto en soles: 32 -> "S/ 32.00". */
export function soles(monto: number): string {
  return `S/ ${monto.toFixed(2)}`;
}

export function destacados(): ReadonlyArray<ItemCarta> {
  return CARTA.flatMap((categoria) => categoria.items.filter((item) => item.destacado));
}

export interface GrupoCarta {
  readonly titulo: string | null;
  readonly items: ReadonlyArray<ItemCarta>;
}

/** Agrupa los items por `grupo` conservando el orden de aparición. */
export function agrupar(items: ReadonlyArray<ItemCarta>): ReadonlyArray<GrupoCarta> {
  const grupos: Array<{ titulo: string | null; items: ItemCarta[] }> = [];

  for (const item of items) {
    const titulo = item.grupo ?? null;
    const actual = grupos[grupos.length - 1];

    if (actual && actual.titulo === titulo) {
      actual.items.push(item);
    } else {
      grupos.push({ titulo, items: [item] });
    }
  }

  return grupos;
}

/** Etiqueta legible de un item: "Picanha · 400 g". */
export function etiquetaItem(item: ItemCarta): string {
  return item.detalle ? `${item.nombre} · ${item.detalle}` : item.nombre;
}
