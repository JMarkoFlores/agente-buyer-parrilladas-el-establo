import React from 'react';
import {
  AreaChart,
  Area,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
} from 'recharts';
import { Card, CardHeader, CardTitle, CardContent } from '../ui/Card';
import { TrendingUp } from 'lucide-react';
import { useTheme } from '../../contexts/ThemeContext';

export interface InteractionDatePoint {
  date: string;
  interacciones: number;
}

interface InteractionsEvolutionChartProps {
  data: InteractionDatePoint[];
}

export const InteractionsEvolutionChart: React.FC<InteractionsEvolutionChartProps> = ({
  data,
}) => {
  const { theme } = useTheme();
  const isDark = theme === 'dark';

  const hasData = data && data.length > 0;

  return (
    <Card className="h-full">
      <CardHeader>
        <CardTitle>
          <TrendingUp className="w-5 h-5 text-brand-amber" />
          Evolución Temporal de Interacciones
        </CardTitle>
      </CardHeader>
      <CardContent>
        <div className="h-64 w-full">
          {hasData ? (
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart
                data={data}
                margin={{ top: 10, right: 20, left: -10, bottom: 5 }}
              >
                <defs>
                  <linearGradient id="colorInteracciones" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#B42332" stopOpacity={0.4} />
                    <stop offset="95%" stopColor="#B42332" stopOpacity={0.0} />
                  </linearGradient>
                </defs>
                <CartesianGrid
                  strokeDasharray="3 3"
                  stroke={isDark ? '#2A3B4C' : '#E2E8F0'}
                />
                <XAxis
                  dataKey="date"
                  stroke={isDark ? '#94A3B8' : '#64748B'}
                  fontSize={11}
                  tickLine={false}
                />
                <YAxis
                  stroke={isDark ? '#94A3B8' : '#64748B'}
                  fontSize={11}
                  tickLine={false}
                  allowDecimals={false}
                />
                <Tooltip
                  contentStyle={{
                    backgroundColor: isDark ? '#1E2B37' : '#FFFFFF',
                    borderColor: isDark ? '#2A3B4C' : '#E2E8F0',
                    borderRadius: '0.75rem',
                    fontSize: '12px',
                    boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.1)',
                    color: isDark ? '#F8FAFC' : '#0F172A',
                  }}
                />
                <Area
                  type="monotone"
                  dataKey="interacciones"
                  stroke="#B42332"
                  strokeWidth={2}
                  fillOpacity={1}
                  fill="url(#colorInteracciones)"
                  name="Interacciones"
                />
              </AreaChart>
            </ResponsiveContainer>
          ) : (
            <div className="h-full flex flex-col items-center justify-center text-center text-slate-400 dark:text-slate-500 text-xs">
              <TrendingUp className="w-8 h-8 stroke-1 mb-2 opacity-50" />
              <span>Sin registros temporales suficientes para trazar evolución.</span>
            </div>
          )}
        </div>
      </CardContent>
    </Card>
  );
};
