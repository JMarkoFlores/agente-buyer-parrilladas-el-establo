import React from 'react';
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  Legend,
} from 'recharts';
import { Card, CardHeader, CardTitle, CardContent } from '../ui/Card';
import { Users } from 'lucide-react';
import { useTheme } from '../../contexts/ThemeContext';

interface BuyersByPlatformChartProps {
  facebookBuyers: number;
  instagramBuyers: number;
  demoBuyers?: number;
}

export const BuyersByPlatformChart: React.FC<BuyersByPlatformChartProps> = ({
  facebookBuyers,
  instagramBuyers,
}) => {
  const { theme } = useTheme();
  const isDark = theme === 'dark';

  const data = [
    {
      categoria: 'Facebook',
      Prospectos: facebookBuyers,
    },
    {
      categoria: 'Instagram',
      Prospectos: instagramBuyers,
    },
  ];

  return (
    <Card className="h-full">
      <CardHeader>
        <CardTitle>
          <Users className="w-5 h-5 text-brand-success" />
          BUYERS Reales por Canal de Captación
        </CardTitle>
      </CardHeader>
      <CardContent>
        <div className="h-64 w-full">
          <ResponsiveContainer width="100%" height="100%">
            <BarChart
              data={data}
              margin={{ top: 20, right: 20, left: -10, bottom: 5 }}
            >
              <CartesianGrid
                strokeDasharray="3 3"
                stroke={isDark ? '#2A3B4C' : '#E2E8F0'}
              />
              <XAxis
                dataKey="categoria"
                stroke={isDark ? '#94A3B8' : '#64748B'}
                fontSize={12}
                tickLine={false}
              />
              <YAxis
                stroke={isDark ? '#94A3B8' : '#64748B'}
                fontSize={12}
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
              <Legend wrapperStyle={{ fontSize: '12px', paddingTop: '10px' }} />
              <Bar
                dataKey="Prospectos"
                fill="#B42332"
                radius={[4, 4, 0, 0]}
                name="BUYERS Confirmados"
              />
            </BarChart>
          </ResponsiveContainer>
        </div>
      </CardContent>
    </Card>
  );
};
