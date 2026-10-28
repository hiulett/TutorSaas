import React, { useState, useEffect } from 'react';
import Sidebar from './components/Sidebar';
import Navbar from './components/Navbar';
import AdminOverview from './pages/AdminOverview';
import LessonManager from './pages/LessonManager';
import CefrLevelsManager from './pages/CefrLevelsManager';
import UserBiometricsManager from './pages/UserBiometricsManager';
import SubscriptionPlansManager from './pages/SubscriptionPlansManager';
import EconomyConfig from './pages/EconomyConfig';
import AiSettings from './pages/AiSettings';
import RetentionDashboard from './pages/RetentionDashboard';
import Login from './pages/Login';
import { supabase } from './lib/supabaseClient';
import { adminService } from './services/adminService';

export default function App() {
  const [session, setSession] = useState(null);
  const [authLoading, setAuthLoading] = useState(true);
  const [unauthorized, setUnauthorized] = useState(false);
  const [activeTab, setActiveTab] = useState('overview');
  const [lessons, setLessons] = useState([]);
  const [cefrLevels, setCefrLevels] = useState([]);
  const [users, setUsers] = useState([]);
  const [plans, setPlans] = useState([]);
  const [overviewMetrics, setOverviewMetrics] = useState(null);
  const [cefrDistribution, setCefrDistribution] = useState([]);
  const [aiSettings, setAiSettings] = useState(null);
  const [retentionMetrics, setRetentionMetrics] = useState(null);
  const [loading, setLoading] = useState(true);

  const isAdmin = (s) => s?.user?.app_metadata?.role === 'admin';

  useEffect(() => {
    supabase.auth.getSession().then(({ data: { session: s } }) => {
      setSession(s);
      if (s && !isAdmin(s)) {
        supabase.auth.signOut();
        setUnauthorized(true);
      }
      setAuthLoading(false);
    });

    const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, s) => {
      setSession(s);
      if (s && !isAdmin(s)) {
        supabase.auth.signOut();
        setUnauthorized(true);
      } else if (s && isAdmin(s)) {
        setUnauthorized(false);
      }
    });

    return () => subscription?.unsubscribe();
  }, []);

  const loadAllData = async () => {
    setLoading(true);
    try {
      const [fetchedMetrics, fetchedLessons, fetchedLevels, fetchedUsers, fetchedPlans, fetchedAi, fetchedDist, fetchedRetention] = await Promise.all([
        adminService.getOverviewMetrics(),
        adminService.getScenarios(),
        adminService.getCefrLevels(),
        adminService.getUsersWithBiometrics(),
        adminService.getSubscriptionPlans(),
        adminService.getAiSettings(),
        adminService.getCefrDistribution(),
        adminService.getRetentionMetrics(),
      ]);

      setOverviewMetrics(fetchedMetrics);
      setLessons(fetchedLessons);
      setCefrLevels(fetchedLevels);
      setUsers(fetchedUsers);
      setPlans(fetchedPlans);
      setAiSettings(fetchedAi);
      setCefrDistribution(fetchedDist);
      setRetentionMetrics(fetchedRetention);
    } catch (err) {
      console.error('Error loading admin data:', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (session) {
      loadAllData();
    }
  }, [session]);

  const handleSaveLesson = async (newLesson) => {
    setLessons((prev) => {
      const index = prev.findIndex((l) => l.id === newLesson.id);
      if (index >= 0) {
        const updated = [...prev];
        updated[index] = newLesson;
        return updated;
      }
      return [newLesson, ...prev];
    });

    try {
      await adminService.saveScenario(newLesson);
    } catch (err) {
      console.error('Error persisting scenario to Supabase:', err);
    }
  };

  const handleDeleteLesson = async (lessonId) => {
    setLessons((prev) => prev.filter((l) => l.id !== lessonId));
    try {
      await adminService.deleteScenario(lessonId);
    } catch (err) {
      console.error('Error deleting scenario:', err);
    }
  };

  const handleSaveLevel = async (level) => {
    setCefrLevels((prev) => {
      const exists = prev.some((l) => l.code === level.code);
      return exists ? prev.map((l) => (l.code === level.code ? level : l)) : [...prev, level];
    });
    try {
      await adminService.saveCefrLevel(level);
    } catch (err) {
      console.error('Error saving CEFR level:', err);
    }
  };

  const handleDeleteLevel = async (code) => {
    setCefrLevels((prev) => prev.filter((l) => l.code !== code));
    try {
      await adminService.deleteCefrLevel(code);
    } catch (err) {
      console.error('Error deleting CEFR level:', err);
    }
  };

  const handleSavePlan = async (updatedPlan) => {
    setPlans((prev) => {
      const exists = prev.some((p) => p.id === updatedPlan.id);
      return exists ? prev.map((p) => (p.id === updatedPlan.id ? updatedPlan : p)) : [updatedPlan, ...prev];
    });
    try {
      await adminService.saveSubscriptionPlan(updatedPlan);
    } catch (err) {
      console.error('Error saving subscription plan:', err);
    }
  };

  const handleDeletePlan = async (planId) => {
    setPlans((prev) => prev.filter((p) => p.id !== planId));
    try {
      await adminService.deleteSubscriptionPlan(planId);
    } catch (err) {
      console.error('Error deleting subscription plan:', err);
    }
  };

  const handleSaveAiSettings = async (newSettings) => {
    setAiSettings(newSettings);
    try {
      await adminService.updateAiSettings(newSettings);
    } catch (err) {
      console.error('Error saving AI settings:', err);
    }
  };

  const handleSaveUser = async (updatedUser) => {
    setUsers((prev) => prev.map((u) => (u.id === updatedUser.id ? updatedUser : u)));
    try {
      await adminService.saveUserProfile(updatedUser);
    } catch (err) {
      console.error('Error saving user profile to Supabase:', err);
    }
  };

  const handleDeleteUser = async (userId) => {
    setUsers((prev) => prev.filter((u) => u.id !== userId));
    try {
      await adminService.deleteUserProfile(userId);
    } catch (err) {
      console.error('Error deleting user:', err);
    }
  };

  if (authLoading) {
    return (
      <div style={{ minHeight: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center', background: 'var(--bg-deep-space)' }}>
        <div className="space-bg">
          <div className="orb orb-purple" />
          <div className="orb orb-teal" />
        </div>
        <div style={{ width: '48px', height: '48px', borderRadius: '50%', border: '3px solid rgba(168, 85, 247, 0.2)', borderTopColor: 'var(--primary-purple)', animation: 'spin 1s linear infinite' }} />
      </div>
    );
  }

  if (!session) {
    return (
      <Login
        onLogin={(s) => {
          if (isAdmin(s)) {
            setUnauthorized(false);
            setSession(s);
          } else {
            supabase.auth.signOut();
            setUnauthorized(true);
          }
        }}
      />
    );
  }

  if (unauthorized) {
    return (
      <div style={{ minHeight: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center', position: 'relative' }}>
        <div className="space-bg">
          <div className="orb orb-purple" style={{ top: '10%', left: '20%' }} />
          <div className="orb orb-teal" style={{ bottom: '20%', right: '15%' }} />
        </div>
        <div className="glass-panel" style={{ width: '420px', padding: '40px', textAlign: 'center' }}>
          <div style={{ fontSize: '40px', marginBottom: '12px' }}>⛔</div>
          <h1 style={{ fontSize: '22px', fontWeight: '800', color: '#fff', margin: '0 0 8px' }}>Acceso Denegado</h1>
          <p style={{ fontSize: '14px', color: 'var(--text-muted)', lineHeight: 1.6 }}>
            Tu cuenta no tiene el rol de administrador. Contacta al dueño del proyecto para obtener acceso.
          </p>
        </div>
      </div>
    );
  }

  return (
    <div style={{ display: 'flex', minHeight: '100vh', position: 'relative', zIndex: 1 }}>
      <div className="space-bg">
        <div className="orb orb-purple" />
        <div className="orb orb-teal" />
        <div className="orb orb-blue" />
      </div>

      <Sidebar activeTab={activeTab} setActiveTab={setActiveTab} session={session} />

      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', minWidth: 0 }}>
        <Navbar onRefresh={loadAllData} session={session} />

        <main style={{ flex: 1, padding: '32px', overflowY: 'auto' }}>
          {loading ? (
            <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', minHeight: '400px', gap: '16px' }}>
              <div style={{ width: '48px', height: '48px', borderRadius: '50%', border: '3px solid rgba(168, 85, 247, 0.2)', borderTopColor: 'var(--primary-purple)', animation: 'spin 1s linear infinite' }} />
              <style>{`@keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }`}</style>
              <div style={{ fontSize: '14px', color: 'var(--text-muted)', fontFamily: 'var(--font-mono)' }}>Conectando a Supabase DB...</div>
            </div>
          ) : (
            <>
              {activeTab === 'overview' && (
                <AdminOverview lessons={lessons} cefrLevels={cefrLevels} cefrDistribution={cefrDistribution} metrics={overviewMetrics} setActiveTab={setActiveTab} />
              )}
              {activeTab === 'lessons' && (
                <LessonManager lessons={lessons} cefrLevels={cefrLevels} onSaveLesson={handleSaveLesson} onDeleteLesson={handleDeleteLesson} />
              )}
              {activeTab === 'cefr' && (
                <CefrLevelsManager cefrLevels={cefrLevels} onSaveLevel={handleSaveLevel} onDeleteLevel={handleDeleteLevel} />
              )}
              {activeTab === 'users' && (
                <UserBiometricsManager users={users} onSaveUser={handleSaveUser} onDeleteUser={handleDeleteUser} />
              )}
              {activeTab === 'plans' && (
                <SubscriptionPlansManager plans={plans} onSavePlan={handleSavePlan} onDeletePlan={handleDeletePlan} />
              )}
              {activeTab === 'economy' && <EconomyConfig />}
              {activeTab === 'ai-settings' && (
                <AiSettings settings={aiSettings} onSave={handleSaveAiSettings} />
              )}
              {activeTab === 'retention' && (
                <RetentionDashboard metrics={retentionMetrics} />
              )}
            </>
          )}
        </main>
      </div>
    </div>
  );
}
