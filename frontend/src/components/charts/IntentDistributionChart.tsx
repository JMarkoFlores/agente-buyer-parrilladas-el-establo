import React from 'react';
import {
  PieChart,
  Pie,
  Cell,
  Tooltip,
  ResponsiveContainer,
  Legend,
} from 'recharts';
import { Card, CardHeader, CardTitle, CardContent } from '../ui/Card';
import { Target } from 'lucide-react';
import { useTheme } from '../../contexts/ThemeContext';

export interface IntentCount {
  name: string;
  count: number;
  color: string;
}

interface IntentDistributionChartProps {
  intentCounts: Record<string, number>;
}

const INTENT_COLORS: Record<string, { label: string; color: string }> = {
  CONSULTA_PRECIO: { label: 'Precio', color: '#16836B' },
  INTERES_PRODUCTO: { label: 'Producto', color: '#2563EB' },
  CONSULTA_PROMOCION: { label: 'Promoción', color: '#D99A36' },
  CONSULTA_UBICACION: { label: 'Ubicación', color: '#9333EA' },
  CONSULTA_HORARIO: { label: 'Horario', color: '#0891B2' },
  CONSULTA_RESERVA: { label: 'Reserva', color: '#E11D48' },
  OTRO: { label: 'Otros', color: '#64748B' },
};

export const IntentDistributionChart: React.FC<IntentDistributionChartProps> = ({
  intentCounts,
}) => {
  const { theme } = useTheme();
  const isDark = theme === 'dark';

  const chartData = Object.entries(intentCounts)
    .filter(([_, count]) => count > 0)
    .map(([intentKey, count]) => {
      const config = INTENT_COLORS[intentKey] || {
        label: intentKey,
        color: '#94A3B8',
      };
      return {
        name: config.label,
        value: count,
        color: config.color,
      };
    });

  // Si no hay datos, mostrar placeholder visual estructurado
  const hasData = chartData.length > 0;
  const displayData = hasData
    ? chartData
    : [{ name: 'Sin registros', value: 1, color: isDark ? '#334155' : '#E2E8F0' }];

  return (
    <Card className="h-full">
      <CardHeader>
        <CardTitle>
          <Target className="w-5 h-5 text-brand-red" />
          Distribución de Intención
        </CardTitle>
      </CardHeader>
      <CardContent>
        <div className="h-64 w-full flex items-center justify-center">
          <ResponsiveContainer width="100%" height="100%">
            <PieChart>
              <Pie
                data={displayData}
                cx="50%"
                cy="50%"
                innerRadius={55}
                outerRadius={80}
                paddingAngle={hasData ? 3 : 0}
                dataKey="value"
              >
                {displayData.map((entry, index) => (
                  <Cell key={`cell-${index}`} fill={entry.color} />
                ))}
              </Pie>
              {hasData && (
                <Tooltip
                  formatter={(value: number, name: string) => [
                    `${value} comentario${value > 1 ? 's' : ''}`,
                    name,
                  ]}
                  contentStyle={{
                    backgroundColor: isDark ? '#1E2B37' : '#FFFFFF',
                    borderColor: isDark ? '#2A3B4C' : '#E2E8F0',
                    borderRadius: '0.75rem',
                    fontSize: '12px',
                    boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.1)',
                    color: isDark ? '#F8FAFC' : '#0F172A',
                  }}
                />
              )}
              {hasData && (
                <Legend
                  wrapperStyle={{ fontSize: '11px', paddingTop: '8px' }}
                />
              )}
            </PieChart>
          </ResponsiveContainer>
        </div>
      </CardContent>
    </Card>
  );
};
