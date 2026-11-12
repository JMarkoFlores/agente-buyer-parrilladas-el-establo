/**
 * Utilidades de formateo para fechas, números y cadenas.
 */

// La BD guarda UTC sin offset ("2026-11-12T05:00:00"); sin "Z" el navegador lo
// interpretaría como hora local. Se muestra siempre en hora de Lima (UTC-5).
const TIME_ZONE = 'America/Lima';

function parseDbDate(dateStr: string): Date {
  const hasOffset = /[zZ]$|[+-]\d{2}:?\d{2}$/.test(dateStr);
  const needsUtcMark = dateStr.includes('T') && !hasOffset;
  return new Date(needsUtcMark ? `${dateStr}Z` : dateStr);
}

export function formatDate(dateStr: string | null | undefined): string {
  if (!dateStr) return '—';
  try {
    const d = parseDbDate(dateStr);
    if (isNaN(d.getTime())) return dateStr;
    return new Intl.DateTimeFormat('es-PE', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
      timeZone: TIME_ZONE,
    }).format(d);
  } catch {
    return dateStr;
  }
}

export function formatShortDate(dateStr: string | null | undefined): string {
  if (!dateStr) return '—';
  try {
    const d = parseDbDate(dateStr);
    if (isNaN(d.getTime())) return dateStr;
    return new Intl.DateTimeFormat('es-PE', {
      month: 'short',
      day: 'numeric',
      timeZone: TIME_ZONE,
    }).format(d);
  } catch {
    return dateStr;
  }
}

export function formatNumber(num: number | null | undefined): string {
  if (num === null || num === undefined) return '0';
  return new Intl.NumberFormat('es-PE').format(num);
}

export function maskExternalRef(ref: string | null | undefined): string {
  if (!ref) return '—';
  if (ref.includes('***')) return ref;
  if (ref.length <= 8) return ref;
  return `${ref.slice(0, 4)}***${ref.slice(-4)}`;
}

/**
 * Nombre visible del autor de un comentario/interacción.
 * Meta no expone el nombre de todos los autores: cuando falta, se indica el canal.
 */
export function formatNombreUsuario(
  nombre: string | null | undefined,
  plataforma: string | null | undefined
): string {
  const limpio = (nombre || '').trim();
  if (limpio) return limpio;

  const codigo = (plataforma || '').toUpperCase();
  if (codigo === 'FACEBOOK') return 'Usuario de Facebook (sin nombre público)';
  if (codigo === 'INSTAGRAM') return 'Usuario de Instagram (sin nombre público)';
  return 'Usuario anónimo (sin nombre público)';
}

export function getIntentColor(intent: string): {
  bg: string;
  text: string;
  border: string;
  dot: string;
} {
  switch (intent?.toUpperCase()) {
    case 'CONSULTA_PRECIO':
      return {
        bg: 'bg-emerald-50 dark:bg-emerald-950/40',
        text: 'text-emerald-700 dark:text-emerald-300',
        border: 'border-emerald-200 dark:border-emerald-800',
        dot: 'bg-emerald-500',
      };
    case 'INTERES_PRODUCTO':
      return {
        bg: 'bg-blue-50 dark:bg-blue-950/40',
        text: 'text-blue-700 dark:text-blue-300',
        border: 'border-blue-200 dark:border-blue-800',
        dot: 'bg-blue-500',
      };
    case 'CONSULTA_PROMOCION':
      return {
        bg: 'bg-amber-50 dark:bg-amber-950/40',
        text: 'text-amber-700 dark:text-amber-300',
        border: 'border-amber-200 dark:border-amber-800',
        dot: 'bg-amber-500',
      };
    case 'CONSULTA_UBICACION':
      return {
        bg: 'bg-purple-50 dark:bg-purple-950/40',
        text: 'text-purple-700 dark:text-purple-300',
        border: 'border-purple-200 dark:border-purple-800',
        dot: 'bg-purple-500',
      };
    case 'CONSULTA_HORARIO':
      return {
        bg: 'bg-cyan-50 dark:bg-cyan-950/40',
        text: 'text-cyan-700 dark:text-cyan-300',
        border: 'border-cyan-200 dark:border-cyan-800',
        dot: 'bg-cyan-500',
      };
    case 'CONSULTA_RESERVA':
      return {
        bg: 'bg-rose-50 dark:bg-rose-950/40',
        text: 'text-rose-700 dark:text-rose-300',
        border: 'border-rose-200 dark:border-rose-800',
        dot: 'bg-rose-500',
      };
    case 'ELOGIO':
      return {
        bg: 'bg-orange-50 dark:bg-orange-950/40',
        text: 'text-orange-700 dark:text-orange-300',
        border: 'border-orange-200 dark:border-orange-800',
        dot: 'bg-orange-500',
      };
    case 'AGRADECIMIENTO':
      return {
        bg: 'bg-teal-50 dark:bg-teal-950/40',
        text: 'text-teal-700 dark:text-teal-300',
        border: 'border-teal-200 dark:border-teal-800',
        dot: 'bg-teal-500',
      };
    case 'EMOJI_POSITIVO':
      return {
        bg: 'bg-amber-50 dark:bg-amber-950/40',
        text: 'text-amber-800 dark:text-amber-200',
        border: 'border-amber-200 dark:border-amber-700',
        dot: 'bg-amber-500',
      };
    case 'SALUDO':
      return {
        bg: 'bg-indigo-50 dark:bg-indigo-950/40',
        text: 'text-indigo-700 dark:text-indigo-300',
        border: 'border-indigo-200 dark:border-indigo-800',
        dot: 'bg-indigo-500',
      };
    case 'INAPROPIADO':
      return {
        bg: 'bg-red-50 dark:bg-red-950/40',
        text: 'text-red-700 dark:text-red-300',
        border: 'border-red-200 dark:border-red-800',
        dot: 'bg-red-500',
      };
    case 'SPAM':
      return {
        bg: 'bg-zinc-100 dark:bg-zinc-800',
        text: 'text-zinc-700 dark:text-zinc-300',
        border: 'border-zinc-200 dark:border-zinc-700',
        dot: 'bg-zinc-500',
      };
    default:
      return {
        bg: 'bg-slate-100 dark:bg-slate-800',
        text: 'text-slate-700 dark:text-slate-300',
        border: 'border-slate-200 dark:border-slate-700',
        dot: 'bg-slate-400',
      };
  }
}
