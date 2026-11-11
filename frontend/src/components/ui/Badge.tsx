import React from 'react';
import { cn } from '../../utils/cn';
import { getIntentColor } from '../../utils/format';

interface BadgeProps {
  children: React.ReactNode;
  variant?: 'default' | 'success' | 'warning' | 'danger' | 'info' | 'purple' | 'outline' | 'origin' | 'intent';
  size?: 'sm' | 'md';
  className?: string;
  isDemo?: boolean;
  intent?: string;
}

export const Badge: React.FC<BadgeProps> = ({
  children,
  variant = 'default',
  size = 'sm',
  className,
  isDemo,
  intent,
}) => {
  // Manejo especial de origen REAL vs DEMO
  if (variant === 'origin' || isDemo !== undefined) {
    const demo = isDemo ?? String(children).toUpperCase().includes('DEMO');
    return (
      <span
        className={cn(
          'inline-flex items-center font-medium rounded-full transition-colors',
          size === 'sm' ? 'px-2 py-0.5 text-[11px]' : 'px-2.5 py-1 text-xs',
          demo
            ? 'bg-amber-50 text-amber-700 border border-amber-200 dark:bg-amber-950/40 dark:text-amber-300 dark:border-amber-800/60'
            : 'bg-emerald-50 text-emerald-700 border border-emerald-200 dark:bg-emerald-950/40 dark:text-emerald-300 dark:border-emerald-800/60',
          className
        )}
      >
        <span
          className={cn(
            'w-1.5 h-1.5 rounded-full mr-1.5',
            demo ? 'bg-amber-500' : 'bg-emerald-500'
          )}
        />
        {demo ? 'DEMO' : 'REAL'}
      </span>
    );
  }

  // Manejo especial de intenciones de comentarios
  if (variant === 'intent' && intent) {
    const colors = getIntentColor(intent);
    return (
      <span
        className={cn(
          'inline-flex items-center font-medium rounded-md border transition-colors',
          size === 'sm' ? 'px-2 py-0.5 text-[11px]' : 'px-2.5 py-1 text-xs',
          colors.bg,
          colors.text,
          colors.border,
          className
        )}
      >
        <span className={cn('w-1.5 h-1.5 rounded-full mr-1.5', colors.dot)} />
        {children}
      </span>
    );
  }

  const variants = {
    default:
      'bg-slate-100 text-slate-700 border border-slate-200 dark:bg-slate-800 dark:text-slate-300 dark:border-slate-700',
    success:
      'bg-emerald-50 text-emerald-700 border border-emerald-200 dark:bg-emerald-950/40 dark:text-emerald-300 dark:border-emerald-800/60',
    warning:
      'bg-amber-50 text-amber-700 border border-amber-200 dark:bg-amber-950/40 dark:text-amber-300 dark:border-amber-800/60',
    danger:
      'bg-rose-50 text-rose-700 border border-rose-200 dark:bg-rose-950/40 dark:text-rose-300 dark:border-rose-800/60',
    info:
      'bg-blue-50 text-blue-700 border border-blue-200 dark:bg-blue-950/40 dark:text-blue-300 dark:border-blue-800/60',
    purple:
      'bg-purple-50 text-purple-700 border border-purple-200 dark:bg-purple-950/40 dark:text-purple-300 dark:border-purple-800/60',
    outline:
      'border border-slate-300 text-slate-700 dark:border-slate-600 dark:text-slate-300',
    origin: '',
    intent: '',
  };

  return (
    <span
      className={cn(
        'inline-flex items-center font-medium rounded-full transition-colors',
        size === 'sm' ? 'px-2 py-0.5 text-[11px]' : 'px-2.5 py-1 text-xs',
        variants[variant],
        className
      )}
    >
      {children}
    </span>
  );
};
