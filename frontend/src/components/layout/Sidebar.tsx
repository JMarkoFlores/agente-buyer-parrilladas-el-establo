import React from 'react';
import { NavLink } from 'react-router-dom';
import {
  LayoutDashboard,
  Facebook,
  Instagram,
  MessageCircle,
  Users,
  Bot,
  ClipboardList,
  Settings,
  MessageSquareReply,
  X,
  Flame,
  Activity,
  Globe,
} from 'lucide-react';
import { cn } from '../../utils/cn';

interface SidebarProps {
  isOpen: boolean;
  onClose: () => void;
}

interface NavItem {
  number: string;
  name: string;
  to: string;
  icon: React.ComponentType<{ className?: string }>;
}

const navItems: NavItem[] = [
  { number: '1', name: 'Dashboard', to: '/', icon: LayoutDashboard },
  { number: '2', name: 'Facebook', to: '/facebook', icon: Facebook },
  { number: '3', name: 'Instagram', to: '/instagram', icon: Instagram },
  { number: '4', name: 'Comentarios & Intención', to: '/comments', icon: MessageCircle },
  { number: '5', name: 'Landing Page', to: '/landing', icon: Globe },
  { number: '6', name: 'BUYERS', to: '/buyers', icon: Users },
  { number: '7', name: 'Agentes Inteligentes', to: '/agents', icon: Bot },
  { number: '8', name: 'Auditoría', to: '/audit', icon: ClipboardList },
  { number: '9', name: 'Configuración', to: '/settings', icon: Settings },
  { number: '10', name: 'Respuestas automáticas', to: '/auto-replies', icon: MessageSquareReply },
];

export const Sidebar: React.FC<SidebarProps> = ({ isOpen, onClose }) => {
  return (
    <>
      {/* Mobile Backdrop */}
      {isOpen && (
        <div
          className="fixed inset-0 z-40 bg-black/60 backdrop-blur-sm lg:hidden transition-opacity"
          onClick={onClose}
          aria-hidden="true"
        />
      )}

      {/* Sidebar Container */}
      <aside
        className={cn(
          'fixed top-0 bottom-0 left-0 z-50 w-64 bg-white dark:bg-brand-charcoal border-r border-slate-200 dark:border-brand-charcoal-border flex flex-col transition-transform duration-300 ease-in-out lg:translate-x-0',
          isOpen ? 'translate-x-0' : '-translate-x-full'
        )}
      >
        {/* Brand Header */}
        <div className="h-16 px-5 border-b border-slate-200 dark:border-brand-charcoal-border flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl bg-brand-red flex items-center justify-center text-white shadow-md shadow-brand-red/20">
              <Flame className="w-5 h-5 fill-white/90" />
            </div>
            <div className="flex flex-col">
              <span className="text-sm font-bold text-slate-900 dark:text-slate-100 tracking-tight leading-tight">
                El Establo
              </span>
              <span className="text-[11px] font-medium text-brand-red dark:text-rose-400">
                Agente BUYER
              </span>
            </div>
          </div>
          <button
            onClick={onClose}
            className="p-1.5 text-slate-400 hover:text-slate-600 dark:hover:text-slate-200 rounded-lg lg:hidden"
            aria-label="Cerrar navegación"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Navigation List */}
        <div className="flex-1 px-3 py-4 overflow-y-auto space-y-1">
          <div className="px-3 pb-2 text-[10px] font-bold uppercase tracking-wider text-slate-400 dark:text-slate-500">
            Módulos del Sistema
          </div>
          {navItems.map((item) => {
            const Icon = item.icon;
            return (
              <NavLink
                key={item.to}
                to={item.to}
                end={item.to === '/'}
                onClick={onClose}
                className={({ isActive }) =>
                  cn(
                    'group flex items-center gap-3 px-3 py-2.5 rounded-xl text-xs font-semibold transition-all duration-150',
                    isActive
                      ? 'bg-brand-red text-white shadow-sm shadow-brand-red/20 font-bold'
                      : 'text-slate-600 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-slate-800/70 hover:text-slate-900 dark:hover:text-white'
                  )
                }
              >
                {({ isActive }) => (
                  <>
                    <span
                      className={cn(
                        'w-5 h-5 flex items-center justify-center text-[11px] font-bold rounded-md',
                        isActive
                          ? 'bg-white/20 text-white'
                          : 'bg-slate-100 dark:bg-slate-800 text-slate-400 dark:text-slate-500 group-hover:text-slate-600 dark:group-hover:text-slate-300'
                      )}
                    >
                      {item.number}
                    </span>
                    <Icon
                      className={cn(
                        'w-4 h-4 transition-transform group-hover:scale-105',
                        isActive ? 'text-white' : 'text-slate-400 dark:text-slate-400 group-hover:text-slate-700 dark:group-hover:text-slate-200'
                      )}
                    />
                    <span className="flex-1 truncate">{item.name}</span>
                  </>
                )}
              </NavLink>
            );
          })}
        </div>

        {/* Sidebar Footer */}
        <div className="p-4 border-t border-slate-200 dark:border-brand-charcoal-border bg-slate-50/50 dark:bg-brand-charcoal/50">
          <div className="flex items-center justify-between text-xs mb-1.5">
            <span className="text-slate-500 dark:text-slate-400 font-medium flex items-center gap-1.5">
              <Activity className="w-3.5 h-3.5 text-emerald-500 animate-pulse" />
              Estado Conexión
            </span>
            <span className="inline-flex items-center px-1.5 py-0.5 rounded text-[10px] font-semibold bg-emerald-50 dark:bg-emerald-950/50 text-emerald-600 dark:text-emerald-400 border border-emerald-200 dark:border-emerald-800/60">
              Online
            </span>
          </div>
          <div className="flex items-center justify-between text-[11px] text-slate-400 dark:text-slate-500">
            <span>Versión</span>
            <span className="font-mono">v1.0.0 (SPA)</span>
          </div>
        </div>
      </aside>
    </>
  );
};
