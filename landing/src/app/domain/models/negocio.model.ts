export interface Negocio {
  readonly nombre: string;
  readonly claim: string;
  readonly direccion: string;
  readonly ciudad: string;
  /** Solo dígitos con código de país, sin "+" ni espacios. */
  readonly whatsapp: string;
  readonly horarios: ReadonlyArray<{ dias: string; horas: string }>;
  /** Ruta interna del formulario de registro de clientes (BUYER -> LEAD). */
  readonly formularioUrl: string;
}

export const NEGOCIO: Negocio = {
  nombre: 'Parrilladas El Establo',
  claim: '¡El auténtico sabor a la parrilla!',
  direccion: 'Av. Francisco Borja 187',
  ciudad: 'Trujillo, Perú',
  whatsapp: '51999999999',
  horarios: [
    { dias: 'Lunes a jueves', horas: '12:00 – 22:30' },
    { dias: 'Viernes a domingo', horas: '12:00 – 23:30' },
  ],
  formularioUrl: '/registro',
};

/** Enlace de WhatsApp con mensaje prellenado. */
export function enlaceWhatsApp(mensaje: string, numero: string = NEGOCIO.whatsapp): string {
  return `https://wa.me/${numero}?text=${encodeURIComponent(mensaje)}`;
}
