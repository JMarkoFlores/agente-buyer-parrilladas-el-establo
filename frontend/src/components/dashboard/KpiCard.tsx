import React from 'react';
import { LucideIcon } from 'lucide-react';
import { Card } from '../ui/Card';
import { formatNumber } from '../../utils/format';

interface KpiCardProps {
  title: string;
  value: number | string;
  icon: LucideIcon;
  description?: string;
  reales?: number;
  demo?: number;
  color?: 'red' | 'blue' | 'amber' | 'emerald' | 'purple' | 'slate';
  iconColor?: string;
  suffix?: string;
}

export const KpiCard: React.FC<KpiCardProps> = ({
  title,
  value,
  icon: Icon,
  description,
  reales,
  demo,
  color = 'red',
  iconColor,
  suffix = '',
}) => {
  const borderColors = {
    red: 'border-l-brand-red',
    blue: 'border-l-blue-500',
    amber: 'border-l-brand-amber',
    emerald: 'border-l-brand-success',
    purple: 'border-l-purple-500',
    slate: 'border-l-slate-400',
  };

  const bgIconColors = {
    red: 'bg-rose-50 text-brand-red dark:bg-rose-950/40 dark:text-rose-400',
    blue: 'bg-blue-50 text-blue-600 dark:bg-blue-950/40 dark:text-blue-400',
    amber: 'bg-amber-50 text-brand-amber dark:bg-amber-950/40 dark:text-amber-400',
    emerald: 'bg-emerald-50 text-brand-success dark:bg-emerald-950/40 dark:text-emerald-400',
    purple: 'bg-purple-50 text-purple-600 dark:bg-purple-950/40 dark:text-purple-400',
    slate: 'bg-slate-100 text-slate-600 dark:bg-slate-800 dark:text-slate-400',
  };

  return (
    <Card
      hover
      className={`border-l-4 ${borderColors[color]} flex flex-col justify-between`}
    >
      <div className="p-5">
        <div className="flex items-center justify-between gap-2 mb-2">
          <span className="text-xs font-bold uppercase tracking-wider text-slate-500 dark:text-slate-400 truncate">
            {title}
          </span>
          <div
            className={`w-9 h-9 rounded-xl flex items-center justify-center flex-shrink-0 ${
              iconColor || bgIconColors[color]
            }`}
          >
            <Icon className="w-5 h-5" />
          </div>
        </div>

        <div className="flex items-baseline gap-1 mt-1">
          <span className="text-2xl sm:text-3xl font-extrabold text-slate-900 dark:text-slate-100 font-mono tracking-tight">
            {typeof value === 'number' ? formatNumber(value) : value}
          </span>
          {suffix && (
            <span className="text-xs text-slate-500 dark:text-slate-400 font-medium">
              {suffix}
            </span>
          )}
        </div>

        {description && (
          <p className="text-xs text-slate-500 dark:text-slate-400 mt-1">
            {description}
          </p>
        )}

        {/* Indicador de procedencia real comprobada */}
        {reales !== undefined && (
          <div className="flex items-center gap-2 mt-3 pt-3 border-t border-slate-100 dark:border-brand-charcoal-border">
            <span className="inline-flex items-center px-2 py-0.5 rounded text-[10px] font-semibold bg-emerald-50 text-emerald-700 dark:bg-emerald-950/50 dark:text-emerald-300 border border-emerald-200 dark:border-emerald-800">
              <span className="w-1.5 h-1.5 rounded-full bg-emerald-500 mr-1.5" />
              Meta Real Verificado
            </span>
          </div>
        )}
      </div>
    </Card>
  );
};
