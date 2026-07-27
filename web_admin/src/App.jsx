import React, { useState, useEffect } from 'react';
import Sidebar from './components/Sidebar';
import Navbar from './components/Navbar';
import AdminOverview from './pages/AdminOverview';
import LessonManager from './pages/LessonManager';
import CefrLevelsManager from './pages/CefrLevelsManager';
import UserBiometricsManager from './pages/UserBiometricsManager';
import SubscriptionPlansManager from './pages/SubscriptionPlansManager';
import AiSettings from './pages/AiSettings';
import { adminService } from './services/adminService';

export default function App() {
  const [activeTab, setActiveTab] = useState('overview');
  const [lessons, setLessons] = useState([]);
  const [cefrLevels, setCefrLevels] = useState([]);
  const [users, setUsers] = useState([]);
  const [plans, setPlans] = useState([]);
  const [overviewMetrics, setOverviewMetrics] = useState(null);
  const [aiSettings, setAiSettings] = useState(null);
  const [loading, setLoading] = useState(true);

  const loadAllData = async () => {
    setLoading(true);
    try {
      const [fetchedMetrics, fetchedLessons, fetchedLevels, fetchedUsers, fetchedPlans, fetchedAi] = await Promise.all([
        adminService.getOverviewMetrics(),
        adminService.getScenarios(),
        adminService.getCefrLevels(),
        adminService.getUsersWithBiometrics(),
        adminService.getSubscriptionPlans(),
        adminService.getAiSettings(),
      ]);

      setOverviewMetrics(fetchedMetrics);
      setLessons(fetchedLessons);
      setCefrLevels(fetchedLevels);
      setUsers(fetchedUsers);
      setPlans(fetchedPlans);
      setAiSettings(fetchedAi);
    } catch (err) {
      console.error('Error loading admin data:', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadAllData();
  }, []);

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

  const handleAddLevel = async (newLevel) => {
    setCefrLevels((prev) => [...prev, newLevel]);
    try {
      await adminService.saveCefrLevel(newLevel);
    } catch (err) {
      console.error('Error saving CEFR level:', err);
    }
  };

  const handleSavePlan = async (updatedPlan) => {
    setPlans((prev) => prev.map((p) => (p.id === updatedPlan.id ? updatedPlan : p)));
    try {
      await adminService.saveSubscriptionPlan(updatedPlan);
    } catch (err) {
      console.error('Error saving subscription plan:', err);
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

  return (
    <div style={{ display: 'flex', minHeight: '100vh', position: 'relative', zIndex: 1 }}>
      {/* Background Ambient Glow */}
      <div className="space-bg">
        <div className="orb orb-purple" />
        <div className="orb orb-teal" />
        <div className="orb orb-blue" />
      </div>

      {/* Left Navigation Sidebar */}
      <Sidebar activeTab={activeTab} setActiveTab={setActiveTab} />

      {/* Main Command Deck Body */}
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', minWidth: 0 }}>
        <Navbar onRefresh={loadAllData} />

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
                <AdminOverview
                  lessons={lessons}
                  cefrLevels={cefrLevels}
                  users={users}
                  metrics={overviewMetrics}
                />
              )}

              {activeTab === 'lessons' && (
                <LessonManager
                  lessons={lessons}
                  cefrLevels={cefrLevels}
                  onSaveLesson={handleSaveLesson}
                  onDeleteLesson={handleDeleteLesson}
                />
              )}

              {activeTab === 'cefr' && (
                <CefrLevelsManager
                  cefrLevels={cefrLevels}
                  onAddLevel={handleAddLevel}
                />
              )}

              {activeTab === 'users' && (
                <UserBiometricsManager users={users} onSaveUser={handleSaveUser} />
              )}

              {activeTab === 'plans' && (
                <SubscriptionPlansManager plans={plans} onSavePlan={handleSavePlan} />
              )}

              {activeTab === 'ai-settings' && (
                <AiSettings settings={aiSettings} onSave={handleSaveAiSettings} />
              )}
            </>
          )}
        </main>
      </div>
    </div>
  );
}
