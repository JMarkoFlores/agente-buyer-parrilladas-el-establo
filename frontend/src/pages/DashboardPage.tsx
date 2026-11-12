import React, { useMemo } from 'react';
import { useQuery } from '@tanstack/react-query';
import {
  Facebook,
  Instagram,
  MessageSquare,
  Users,
  ThumbsUp,
  Heart,
  Calendar,
  Sparkles,
  Globe,
  UtensilsCrossed,
  FileText,
  UserCheck,
  TrendingUp,
  Eye,
  Target,
  DollarSign,
  Award,
} from 'lucide-react';
import { ApiService } from '../services/api';
import { KpiCard } from '../components/dashboard/KpiCard';
import { StrategicKpiCard } from '../components/dashboard/StrategicKpiCard';
import { AgentStatusCards } from '../components/dashboard/AgentStatusCards';
import { CommentsByPlatformChart } from '../components/charts/CommentsByPlatformChart';
import { IntentDistributionChart } from '../components/charts/IntentDistributionChart';
import { BuyersByPlatformChart } from '../components/charts/BuyersByPlatformChart';
import { InteractionsEvolutionChart } from '../components/charts/InteractionsEvolutionChart';
import { CardSkeleton } from '../components/ui/Skeleton';
import { ErrorState } from '../components/ui/ErrorState';
import { formatShortDate } from '../utils/format';

export const DashboardPage: React.FC = () => {
  // Resumen del dashboard
  const {
    data: resumen,
    isLoading: isResumenLoading,
    isError: isResumenError,
    refetch: refetchResumen,
  } = useQuery({
    queryKey: ['dashboardResumen'],
    queryFn: ApiService.getDashboardResumen,
    refetchInterval: 15000,
  });

  // Comentarios para calcular distribución de intenciones y evolución
  const { data: commentsData } = useQuery({
    queryKey: ['dashboardCommentsRecent'],
    queryFn: () => ApiService.getComments({ limit: 100 }),
    refetchInterval: 10000,
  });

  // Calcular distribución de intenciones a partir de los datos reales de comentarios
  const intentCounts = useMemo(() => {
    const counts: Record<string, number> = {
      CONSULTA_PRECIO: 0,
      INTERES_PRODUCTO: 0,
      CONSULTA_PROMOCION: 0,
      CONSULTA_UBICACION: 0,
      CONSULTA_HORARIO: 0,
      CONSULTA_RESERVA: 0,
      OTRO: 0,
    };

    if (commentsData?.items) {
      commentsData.items.forEach((c) => {
        const intent = c.clasificacion_intencion || 'OTRO';
        counts[intent] = (counts[intent] || 0) + 1;
      });
    }

    return counts;
  }, [commentsData]);

  // Calcular evolución de interacciones por fecha
  const evolutionData = useMemo(() => {
    if (!commentsData?.items || commentsData.items.length === 0) return [];

    const map = new Map<string, number>();
    // Ordenar de más antiguo a más reciente
    const sorted = [...commentsData.items].sort((a, b) => {
      const ta = a.fecha_interaccion ? new Date(a.fecha_interaccion).getTime() : 0;
      const tb = b.fecha_interaccion ? new Date(b.fecha_interaccion).getTime() : 0;
      return ta - tb;
    });

    sorted.forEach((item) => {
      if (item.fecha_interaccion) {
        const key = formatShortDate(item.fecha_interaccion);
        map.set(key, (map.get(key) || 0) + 1);
      }
    });

    return Array.from(map.entries()).map(([date, interacciones]) => ({
      date,
      interacciones,
    }));
  }, [commentsData]);

  if (isResumenError) {
    return (
      <div className="space-y-6">
        <ErrorState
          title="Error al consultar el resumen gerencial"
          message="No fue posible conectar con el endpoint /api/dashboard/resumen del backend Flask."
          onRetry={() => refetchResumen()}
        />
      </div>
    );
  }

  const fbPubs = resumen?.publicaciones.facebook;
  const igPubs = resumen?.publicaciones.instagram;
  const coms = resumen?.comentarios;
  const buyers = resumen?.buyers;
  const likes = resumen?.reacciones_likes;
  const landing = resumen?.landing;
  const kpis = resumen?.kpis;

  return (
    <div className="space-y-6 animate-in fade-in duration-200">
      {/* Banner de bienvenida y contexto del agente */}
      <div className="p-5 rounded-2xl bg-gradient-to-r from-brand-charcoal via-slate-900 to-brand-charcoal text-white border border-slate-800 shadow-sm flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
        <div>
          <div className="flex items-center gap-2 mb-1">
            <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded text-[11px] font-semibold bg-brand-red text-white">
              <Sparkles className="w-3 h-3" />
              Agente Inteligente
            </span>
            <span className="text-xs text-slate-400 font-mono">Meta Graph API v27.0</span>
          </div>
          <h2 className="text-lg sm:text-xl font-extrabold text-white tracking-tight">
            Parrilladas El Establo — Dashboard de Captación BUYER
          </h2>
          <p className="text-xs text-slate-300 mt-0.5 max-w-xl">
            Monitoreo multicanal de prospectos, clasificación de intención y sincronización con Microsoft SQL Server.
          </p>
        </div>
        <div className="flex items-center gap-2 self-stretch sm:self-auto justify-end">
          <div className="px-3 py-2 rounded-xl bg-white/10 backdrop-blur-sm border border-white/10 text-right">
            <span className="text-[10px] uppercase font-bold text-slate-300 block">
              Prospectos Reales
            </span>
            <span className="text-lg font-black text-brand-amber font-mono">
              {buyers?.reales ?? 0}
            </span>
          </div>
        </div>
      </div>

      {/* Tarjetas Principales de Redes Sociales Meta */}
      {isResumenLoading ? (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-6 gap-4">
          {Array.from({ length: 6 }).map((_, i) => (
            <CardSkeleton key={i} />
          ))}
        </div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-6 gap-4">
          {/* Publicaciones Facebook */}
          <KpiCard
            title="Posts Facebook"
            value={fbPubs?.reales ?? 0}
            reales={fbPubs?.reales}
            icon={Facebook}
            color="blue"
            description="Página oficial"
          />

          {/* Publicaciones Instagram */}
          <KpiCard
            title="Posts Instagram"
            value={igPubs?.reales ?? 0}
            reales={igPubs?.reales}
            icon={Instagram}
            color="red"
            description="Media comercial"
          />

          {/* Comentarios Totales */}
          <KpiCard
            title="Comentarios"
            value={coms?.reales ?? 0}
            reales={coms?.reales}
            icon={MessageSquare}
            color="amber"
            description="Interacciones reales"
          />

          {/* BUYERS Identificados */}
          <KpiCard
            title="BUYERS Totales"
            value={buyers?.reales ?? 0}
            reales={buyers?.reales}
            icon={Users}
            color="emerald"
            description="Multicanal consolidado"
          />

          {/* Reacciones Facebook */}
          <KpiCard
            title="Reacciones FB"
            value={likes?.facebook ?? 0}
            icon={ThumbsUp}
            color="blue"
            description="Reacciones actuales Meta"
          />

          {/* Likes Instagram */}
          <KpiCard
            title="Likes Instagram"
            value={likes?.instagram ?? 0}
            icon={Heart}
            color="purple"
            description="Me gusta actuales Meta"
          />
        </div>
      )}

      {/* Sección: Indicadores de Landing Page y Carta Digital */}
      <div className="space-y-3">
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-1">
          <div className="flex items-center gap-2">
            <Globe className="w-5 h-5 text-emerald-600 dark:text-emerald-400" />
            <h3 className="text-base font-extrabold text-slate-900 dark:text-slate-100 tracking-tight">
              Indicadores de Landing Page y Carta Digital
            </h3>
          </div>
          <span className="text-[11px] font-semibold text-slate-500 dark:text-slate-400 font-mono">
            Fuente SQL Server · dbo.visita_web & dbo.evento_web
          </span>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-7 gap-3">
          <KpiCard
            title="Visitas Landing"
            value={landing?.visitas_landing ?? 0}
            icon={Globe}
            color="blue"
            description="Sesiones totales"
          />
          <KpiCard
            title="Visitantes Landing"
            value={landing?.visitantes_landing ?? 0}
            icon={Users}
            color="purple"
            description="Navegadores únicos"
          />
          <KpiCard
            title="Visualiz. Carta"
            value={landing?.visualizaciones_carta ?? 0}
            icon={Eye}
            color="amber"
            description="Aperturas /carta/"
          />
          <KpiCard
            title="Visitantes Carta"
            value={landing?.visitantes_carta ?? 0}
            icon={UtensilsCrossed}
            color="red"
            description="Exploraron el menú"
          />
          <KpiCard
            title="Formularios"
            value={landing?.formularios ?? 0}
            icon={FileText}
            color="blue"
            description="Envíos recibidos"
          />
          <KpiCard
            title="LEADS Landing"
            value={landing?.leads ?? 0}
            icon={UserCheck}
            color="emerald"
            description="Personas calificadas"
          />
          <KpiCard
            title="Conversión Landing"
            value={landing?.conversion !== undefined ? `${landing.conversion}%` : '0.00%'}
            icon={TrendingUp}
            color="emerald"
            description="Tasa LEAD / Visitantes"
          />
        </div>
      </div>

      {/* Sección: Indicadores Estratégicos de Captación BUYER — KPI */}
      <div className="space-y-3">
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-1">
          <div className="flex items-center gap-2">
            <Target className="w-5 h-5 text-brand-red" />
            <h3 className="text-base font-extrabold text-slate-900 dark:text-slate-100 tracking-tight">
              Indicadores Estratégicos de Captación BUYER — KPI
            </h3>
          </div>
          <span className="text-[11px] font-semibold text-slate-500 dark:text-slate-400 font-mono">
            Modelos Académicos · Actualizado desde SQL Server
          </span>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-4">
          <StrategicKpiCard
            kpi={kpis?.cpa}
            icon={DollarSign}
            themeColor="amber"
          />
          <StrategicKpiCard
            kpi={kpis?.tmd}
            icon={UtensilsCrossed}
            themeColor="blue"
          />
          <StrategicKpiCard
            kpi={kpis?.b1}
            icon={Award}
            themeColor="emerald"
          />
        </div>
      </div>

      {/* Charts Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Gráfico 1: Comentarios por plataforma */}
        <CommentsByPlatformChart
          facebookReales={coms?.facebook ?? 2}
          instagramReales={coms?.instagram ?? 1}
        />

        {/* Gráfico 2: Evolución de interacciones */}
        <InteractionsEvolutionChart data={evolutionData} />

        {/* Gráfico 3: Distribución de intención */}
        <IntentDistributionChart intentCounts={intentCounts} />

        {/* Gráfico 4: BUYERS por plataforma multicanal */}
        <BuyersByPlatformChart
          facebookBuyers={buyers?.reales_facebook ?? 0}
          instagramBuyers={buyers?.reales_instagram ?? 0}
          landingBuyers={buyers?.reales_landing ?? 0}
        />
      </div>

      {/* Estado de Agentes Autónomos */}
      <AgentStatusCards data={resumen} />
    </div>
  );
};
