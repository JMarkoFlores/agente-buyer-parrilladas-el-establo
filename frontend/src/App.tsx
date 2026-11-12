import React from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { ThemeProvider } from './contexts/ThemeContext';
import { AdminAuthProvider } from './contexts/AdminAuthContext';
import { AppLayout } from './components/layout/AppLayout';

import { DashboardPage } from './pages/DashboardPage';
import { FacebookPage } from './pages/FacebookPage';
import { InstagramPage } from './pages/InstagramPage';
import { CommentsPage } from './pages/CommentsPage';
import { BuyersPage } from './pages/BuyersPage';
import { AgentsPage } from './pages/AgentsPage';
import { AuditPage } from './pages/AuditPage';
import { SettingsPage } from './pages/SettingsPage';
import { AutoReplyPage } from './pages/AutoReplyPage';
import { LandingPage } from './pages/LandingPage';

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 5000,
      refetchOnWindowFocus: false,
      retry: 1,
    },
  },
});

export const App: React.FC = () => {
  return (
    <QueryClientProvider client={queryClient}>
      <ThemeProvider>
        <AdminAuthProvider>
          <BrowserRouter>
            <Routes>
              <Route path="/" element={<AppLayout />}>
                <Route index element={<DashboardPage />} />
                <Route path="facebook" element={<FacebookPage />} />
                <Route path="instagram" element={<InstagramPage />} />
                <Route path="comments" element={<CommentsPage />} />
                <Route path="buyers" element={<BuyersPage />} />
                <Route path="agents" element={<AgentsPage />} />
                <Route path="audit" element={<AuditPage />} />
                <Route path="settings" element={<SettingsPage />} />
                <Route path="auto-replies" element={<AutoReplyPage />} />
                <Route path="landing" element={<LandingPage />} />
                <Route path="*" element={<Navigate to="/" replace />} />
              </Route>
            </Routes>
          </BrowserRouter>
        </AdminAuthProvider>
      </ThemeProvider>
    </QueryClientProvider>
  );
};

export default App;
