import React from 'react';
import { cn } from '../../utils/cn';

interface CardProps extends React.HTMLAttributes<HTMLDivElement> {
  children: React.ReactNode;
  className?: string;
  hover?: boolean;
}

export const Card: React.FC<CardProps> = ({ children, className, hover = false, ...props }) => {
  return (
    <div
      className={cn(
        'bg-white dark:bg-brand-charcoal-card border border-slate-200 dark:border-brand-charcoal-border rounded-xl shadow-card transition-all duration-200',
        hover && 'hover:shadow-card-hover hover:border-slate-300 dark:hover:border-slate-600',
        className
      )}
      {...props}
    >
      {children}
    </div>
  );
};

export const CardHeader: React.FC<{
  children: React.ReactNode;
  className?: string;
  action?: React.ReactNode;
}> = ({ children, className, action }) => {
  return (
    <div
      className={cn(
        'px-5 py-4 border-b border-slate-100 dark:border-brand-charcoal-border flex items-center justify-between',
        className
      )}
    >
      <div className="flex-1">{children}</div>
      {action && <div className="ml-4 flex-shrink-0">{action}</div>}
    </div>
  );
};

export const CardTitle: React.FC<{ children: React.ReactNode; className?: string }> = ({
  children,
  className,
}) => {
  return (
    <h3
      className={cn(
        'text-base font-semibold text-slate-900 dark:text-slate-100 flex items-center gap-2',
        className
      )}
    >
      {children}
    </h3>
  );
};

export const CardDescription: React.FC<{ children: React.ReactNode; className?: string }> = ({
  children,
  className,
}) => {
  return (
    <p className={cn('text-xs text-slate-500 dark:text-slate-400 mt-0.5', className)}>
      {children}
    </p>
  );
};

export const CardContent: React.FC<{ children: React.ReactNode; className?: string }> = ({
  children,
  className,
}) => {
  return <div className={cn('p-5', className)}>{children}</div>;
};

export const CardFooter: React.FC<{ children: React.ReactNode; className?: string }> = ({
  children,
  className,
}) => {
  return (
    <div
      className={cn(
        'px-5 py-3.5 border-t border-slate-100 dark:border-brand-charcoal-border bg-slate-50/50 dark:bg-brand-charcoal/50 rounded-b-xl flex items-center justify-between',
        className
      )}
    >
      {children}
    </div>
  );
};
