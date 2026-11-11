import React, { createContext, useContext, useState, useEffect } from 'react';

interface AdminAuthContextType {
  adminKey: string;
  setAdminKey: (key: string) => void;
  clearAdminKey: () => void;
  isAuthenticated: boolean;
  isModalOpen: boolean;
  openModal: () => void;
  closeModal: () => void;
}

const STORAGE_KEY = 'buyer_admin_key';

const AdminAuthContext = createContext<AdminAuthContextType | undefined>(undefined);

export const AdminAuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [adminKey, setAdminKeyState] = useState<string>(() => {
    return sessionStorage.getItem(STORAGE_KEY) || '';
  });
  const [isModalOpen, setIsModalOpen] = useState<boolean>(false);

  useEffect(() => {
    if (adminKey) {
      sessionStorage.setItem(STORAGE_KEY, adminKey);
    } else {
      sessionStorage.removeItem(STORAGE_KEY);
    }
  }, [adminKey]);

  const setAdminKey = (key: string) => {
    setAdminKeyState(key.trim());
  };

  const clearAdminKey = () => {
    setAdminKeyState('');
    sessionStorage.removeItem(STORAGE_KEY);
  };

  return (
    <AdminAuthContext.Provider
      value={{
        adminKey,
        setAdminKey,
        clearAdminKey,
        isAuthenticated: Boolean(adminKey && adminKey.length > 0),
        isModalOpen,
        openModal: () => setIsModalOpen(true),
        closeModal: () => setIsModalOpen(false),
      }}
    >
      {children}
    </AdminAuthContext.Provider>
  );
};

export const useAdminAuth = () => {
  const context = useContext(AdminAuthContext);
  if (!context) {
    throw new Error('useAdminAuth must be used within an AdminAuthProvider');
  }
  return context;
};
