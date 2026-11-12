import React from 'react';
import { LucideIcon, Info, Sparkles, Database, CheckCircle2, AlertCircle } from 'lucide-react';
import { Card, CardContent } from '../ui/Card';
import type { KpiItem } from '../../types';

interface StrategicKpiCardProps {
  kpi?: KpiItem | null;
  icon: LucideIcon;
  themeColor: 'amber' | 'blue' | 'emerald' | 'purple';
}

export const StrategicKpiCard: React.FC<StrategicKpiCardProps> = ({
  kpi,
  icon: Icon,
  themeColor = 'emerald',
}) => {
  if (!kpi) return null;

  const colorStyles = {
    amber: {
      border: 'border-l-brand-amber',
      badgeBg: 'bg-amber-50 text-amber-700 border-amber-200 dark:bg-amber-950/40 dark:text-amber-300 dark:border-amber-800',
      iconBg: 'bg-amber-100 text-amber-700 dark:bg-amber-900/40 dark:text-amber-400',
      valColor: 'text-amber-600 dark:text-amber-400',
    },
    blue: {
      border: 'border-l-blue-600',
      badgeBg: 'bg-blue-50 text-blue-700 border-blue-200 dark:bg-blue-950/40 dark:text-blue-300 dark:border-blue-800',
      iconBg: 'bg-blue-100 text-blue-700 dark:bg-blue-900/40 dark:text-blue-400',
      valColor: 'text-blue-600 dark:text-blue-400',
    },
    emerald: {
      border: 'border-l-emerald-600',
      badgeBg: 'bg-emerald-50 text-emerald-700 border-emerald-200 dark:bg-emerald-950/40 dark:text-emerald-300 dark:border-emerald-800',
      iconBg: 'bg-emerald-100 text-emerald-700 dark:bg-emerald-900/40 dark:text-emerald-400',
      valColor: 'text-emerald-600 dark:text-emerald-400',
    },
    purple: {
      border: 'border-l-purple-600',
      badgeBg: 'bg-purple-50 text-purple-700 border-purple-200 dark:bg-purple-950/40 dark:text-purple-300 dark:border-purple-800',
      iconBg: 'bg-purple-100 text-purple-700 dark:bg-purple-900/40 dark:text-purple-400',
      valColor: 'text-purple-600 dark:text-purple-400',
    },
  }[themeColor];

  const isMixto = kpi.tipo_dato === 'MIXTO';

  return (
    <Card className={`border-l-4 ${colorStyles.border} shadow-sm flex flex-col justify-between`}>
      <CardContent className="p-5 space-y-4">
        {/* Cabecera con Nombre y Badges */}
        <div className="flex items-start justify-between gap-3">
          <div className="space-y-1">
            <div className="flex items-center gap-2">
              <span className="font-mono text-xs font-black px-2 py-0.5 rounded bg-slate-100 dark:bg-slate-800 text-slate-800 dark:text-slate-200">
                {kpi.codigo}
              </span>
              <span
                className={`inline-flex items-center gap-1 px-2 py-0.5 rounded text-[10px] font-bold border uppercase tracking-wider ${
                  isMixto
                    ? 'bg-amber-50 text-amber-800 border-amber-300 dark:bg-amber-950/50 dark:text-amber-200 dark:border-amber-800'
                    : 'bg-emerald-50 text-emerald-800 border-emerald-300 dark:bg-emerald-950/50 dark:text-emerald-200 dark:border-emerald-800'
                }`}
              >
                {isMixto ? (
                  <>
                    <Sparkles className="w-3 h-3" />
                    KPI MIXTO · GASTO SIMULADO
                  </>
                ) : (
                  <>
                    <Database className="w-3 h-3" />
                    KPI REAL · SQL SERVER
                  </>
                )}
              </span>
            </div>
            <h3 className="text-sm font-extrabold text-slate-900 dark:text-slate-100 leading-snug">
              {kpi.nombre}
            </h3>
          </div>

          <div className={`w-10 h-10 rounded-xl flex items-center justify-center flex-shrink-0 ${colorStyles.iconBg}`}>
            <Icon className="w-5 h-5" />
          </div>
        </div>

        {/* Valor Principal del KPI */}
        <div className="py-2 px-3.5 rounded-xl bg-slate-50 dark:bg-slate-800/50 border border-slate-100 dark:border-slate-800">
          <div className="text-[11px] font-semibold text-slate-500 dark:text-slate-400 uppercase tracking-wider mb-1 flex items-center justify-between">
            <span>Resultado Oficial</span>
            <span className="font-mono text-[10px] text-slate-400">{kpi.unidad}</span>
          </div>

          <div className="flex items-baseline gap-2">
            {kpi.calculable && kpi.valor !== null ? (
              <span className={`text-2xl sm:text-3xl font-black font-mono tracking-tight ${colorStyles.valColor}`}>
                {kpi.valor_formateado}
              </span>
            ) : (
              <div className="flex items-center gap-1.5 text-amber-700 dark:text-amber-400 font-semibold text-xs sm:text-sm py-1">
                <AlertCircle className="w-4 h-4 flex-shrink-0" />
                <span>{kpi.valor_formateado}</span>
              </div>
            )}
          </div>
        </div>

        {/* Desglose de Numerador y Denominador */}
        <div className="grid grid-cols-2 gap-2 text-xs">
          <div className="p-2.5 rounded-lg bg-white dark:bg-slate-900/60 border border-slate-200 dark:border-slate-800">
            <span className="text-[10px] font-bold text-slate-500 uppercase block truncate" title={kpi.numerador_label}>
              Numerador
            </span>
            <p className="font-mono font-bold text-slate-900 dark:text-slate-100 text-sm mt-0.5">
              {kpi.numerador !== null && kpi.numerador !== undefined
                ? typeof kpi.numerador === 'number' && kpi.codigo === 'CPA'
                  ? `S/ ${kpi.numerador.toFixed(2)}`
                  : kpi.numerador
                : '—'}
            </p>
            <span className="text-[10px] text-slate-400 line-clamp-1" title={kpi.numerador_label}>
              {kpi.numerador_label}
            </span>
          </div>

          <div className="p-2.5 rounded-lg bg-white dark:bg-slate-900/60 border border-slate-200 dark:border-slate-800">
            <span className="text-[10px] font-bold text-slate-500 uppercase block truncate" title={kpi.denominador_label}>
              Denominador
            </span>
            <p className="font-mono font-bold text-slate-900 dark:text-slate-100 text-sm mt-0.5">
              {kpi.denominador !== null && kpi.denominador !== undefined ? kpi.denominador : '—'}
            </p>
            <span className="text-[10px] text-slate-400 line-clamp-1" title={kpi.denominador_label}>
              {kpi.denominador_label}
            </span>
          </div>
        </div>

        {/* Fórmula & Procedencia */}
        <div className="space-y-1.5 pt-2 border-t border-slate-100 dark:border-slate-800 text-[11px] text-slate-600 dark:text-slate-400">
          <div className="flex items-center gap-1.5 font-mono text-[10px] bg-slate-100 dark:bg-slate-800/80 px-2 py-1 rounded">
            <span className="font-bold text-slate-700 dark:text-slate-300">Fórmula:</span>
            <span className="text-slate-600 dark:text-slate-400 truncate">{kpi.formula}</span>
          </div>

          <div className="flex items-center justify-between text-[10px] text-slate-400 pt-1">
            <span>Período: <strong className="text-slate-600 dark:text-slate-300">{kpi.periodo}</strong></span>
            <span className="truncate max-w-[150px]" title={kpi.procedencia}>{kpi.procedencia.split(',')[0]}</span>
          </div>

          {kpi.observacion && (
            <p className="text-[10px] text-slate-500 dark:text-slate-400 italic pt-1 leading-normal border-t border-slate-100/60 dark:border-slate-800/60">
              {kpi.observacion}
            </p>
          )}
        </div>
      </CardContent>
    </Card>
  );
};
