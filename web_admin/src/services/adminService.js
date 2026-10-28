import { supabase } from '../lib/supabaseClient';

function toNumericId(idStr) {
  if (!idStr) return 101;
  const parsed = parseInt(idStr, 10);
  if (!isNaN(parsed)) return parsed;
  let hash = 0;
  for (let i = 0; i < idStr.length; i++) {
    hash = (hash * 31 + idStr.charCodeAt(i)) % 900000 + 1000;
  }
  return hash;
}

export const adminService = {
  // ── 1. OVERVIEW & AGGREGATE METRICS ──────────────────────────────────────────
  async getOverviewMetrics() {
    try {
      const { count: totalUsersCount } = await supabase
        .from('user_language_profiles')
        .select('*', { count: 'exact', head: true });

      const { count: totalConversationsCount } = await supabase
        .from('conversations')
        .select('*', { count: 'exact', head: true });

      const { count: totalScenariosCount } = await supabase
        .from('scenarios')
        .select('*', { count: 'exact', head: true });

      // Estimación: 15 min de práctica por conversación registrada.
      const practiceHours = Math.round(((totalConversationsCount || 0) * 15) / 60);

      return {
        totalUsers: totalUsersCount || 0,
        totalHours: practiceHours,
        totalLessons: totalScenariosCount || 0,
        totalConversations: totalConversationsCount || 0,
      };
    } catch (err) {
      console.error('Error fetching overview metrics:', err);
      return {
        totalUsers: 0,
        totalHours: 0,
        totalLessons: 0,
        totalConversations: 0,
      };
    }
  },

  // ── 2. SCENARIOS / LESSONS CRUD ─────────────────────────────────────────────
  async getScenarios() {
    try {
      const { data: dbData, error } = await supabase
        .from('scenarios')
        .select('*')
        .order('id', { ascending: true });

      if (error) {
        console.warn('Scenarios read query warning:', error.message);
      }

      return (dbData || []).map((sc) => ({
        id: sc.id.toString(),
        title: sc.title || 'Escenario Supabase',
        category: sc.category || 'general',
        level: sc.difficulty_level || 'A1',
        difficulty: 1,
        description: sc.description || '',
        assistantRole: sc.assistant_role || 'Tutor IA',
        userRole: sc.user_role || 'Estudiante',
        initialAssistantMessage: sc.initial_assistant_message || "Hello! Let's start practice.",
        mainObjective: sc.main_objective || sc.title,
        goals: sc.goals || [],
        usefulPhrases: sc.useful_phrases || [],
      }));
    } catch (err) {
      console.error('Error fetching scenarios:', err);
      return [];
    }
  },

  /// Distribución real de usuarios por nivel CEFR (counts desde la DB).
  async getCefrDistribution() {
    try {
      const { data: profiles } = await supabase
        .from('user_language_profiles')
        .select('cefr_level_id');

      const { data: levels } = await supabase
        .from('cefr_levels')
        .select('id, code, name, color');

      const levelMap = new Map((levels || []).map((l) => [l.id, l]));
      const counts = new Map();
      (profiles || []).forEach((p) => {
        const lvl = p.cefr_level_id != null ? levelMap.get(p.cefr_level_id) : null;
        if (lvl?.code) counts.set(lvl.code, (counts.get(lvl.code) || 0) + 1);
      });

      const total = [...counts.values()].reduce((a, b) => a + b, 0);
      return (levels || [])
        .map((l) => ({
          code: l.code,
          name: l.name,
          color: l.color || '#a855f7',
          count: counts.get(l.code) || 0,
          pct: total > 0 ? Math.round(((counts.get(l.code) || 0) / total) * 100) : 0,
        }))
        .filter((x) => x.count > 0);
    } catch (err) {
      console.error('Error fetching CEFR distribution:', err);
      return [];
    }
  },

  async saveScenario(scenarioObj) {
    const numericId = toNumericId(scenarioObj.id);

    try {
      const fullPayload = {
        id: numericId,
        title: scenarioObj.title,
        description: scenarioObj.description,
        difficulty_level: scenarioObj.level,
        category: scenarioObj.category,
        main_objective: scenarioObj.mainObjective,
        assistant_role: scenarioObj.assistantRole,
        user_role: scenarioObj.userRole,
        initial_assistant_message: scenarioObj.initialAssistantMessage,
        goals: scenarioObj.goals,
        useful_phrases: scenarioObj.usefulPhrases,
        language_id: 1,
        estimated_minutes: 15,
      };

      const { data, error } = await supabase.from('scenarios').upsert(fullPayload);
      if (!error) return data;
    } catch (_) {}

    try {
      const leanPayload = {
        id: numericId,
        title: scenarioObj.title,
        description: scenarioObj.description,
        difficulty_level: scenarioObj.level,
        category: scenarioObj.category,
      };

      const { data } = await supabase.from('scenarios').upsert(leanPayload);
      return data;
    } catch (err) {
      console.error('Error saving scenario:', err);
    }
  },

  async deleteScenario(scenarioId) {
    try {
      const numericId = toNumericId(scenarioId);
      await supabase.from('scenarios').delete().eq('id', numericId);
    } catch (err) {
      console.error('Error deleting scenario:', err);
    }
  },

  // ── 3. CEFR LEVELS ──────────────────────────────────────────────────────────
  async getCefrLevels() {
    try {
      const { data } = await supabase
        .from('cefr_levels')
        .select('*')
        .order('code', { ascending: true });

      if (data && data.length > 0) {
        return data.map((lvl) => ({
          code: lvl.code,
          name: lvl.name,
          description: lvl.description || 'Nivel del Marco Común Europeo',
          color: lvl.color || '#a855f7',
          difficultyRange: lvl.difficulty_range || '1 - 5',
          activeLessons: 0,
          enrolledStudents: 0,
        }));
      }
    } catch (err) {
      console.error('Error fetching CEFR levels:', err);
    }

    return [];
  },

  async saveCefrLevel(levelObj) {
    try {
      await supabase.from('cefr_levels').upsert({
        code: levelObj.code,
        name: levelObj.name,
        description: levelObj.description,
        color: levelObj.color,
        difficulty_range: levelObj.difficultyRange,
        order_index: 1,
      });
    } catch (err) {
      console.error('Error saving CEFR level:', err);
    }
  },

  async deleteCefrLevel(code) {
    try {
      const { error } = await supabase.from('cefr_levels').delete().eq('code', code);
      if (error) console.warn('CEFR delete error:', error.message);
    } catch (err) {
      console.error('Error deleting CEFR level:', err);
    }
  },

  // ── 4. USERS & SPEECH DNA BIOMETRICS ─────────────────────────────────────────
  async getUsersWithBiometrics() {
    try {
      const userMap = new Map();

      try {
        const { data: usersData } = await supabase.from('users').select('*');
        if (usersData && usersData.length > 0) {
          usersData.forEach((u) => {
            const uid = (u.id || u.user_id).toString();
            userMap.set(uid, {
              id: uid,
              displayName: u.display_name || u.full_name || u.name || 'Sin display_name',
              name: u.display_name || u.full_name || u.name || `Estudiante ${uid.slice(0, 8)}`,
              avatarUrl: u.avatar_url || `https://api.dicebear.com/7.x/bottts-neutral/svg?seed=${uid}`,
              level: u.level || 'A1',
              xp: u.xp_points || u.xp || 0,
              streak: u.current_streak || u.streak || 0,
              practiceMinutes: 0,
              plan: null,
              clarityScore: null,
              wpm: null,
              problemPhonemes: [],
              nativeLanguage: u.native_language || '',
              lastActive: 'Registrado en users',
            });
          });
        }
      } catch (_) {}

      const { data: profiles } = await supabase.from('user_language_profiles').select('*');
      const existingProfiles = profiles || [];

      const { data: cefrLevels } = await supabase.from('cefr_levels').select('*');
      const levelMap = new Map((cefrLevels || []).map((c) => [c.id?.toString(), c.code]));

      const { data: biometrics } = await supabase.from('speech_dna_metrics').select('*');
      const bioMap = new Map((biometrics || []).map((b) => [b.user_id?.toString(), b]));

      const { data: subscriptions } = await supabase.from('user_subscriptions').select('*, subscription_plans(*)');
      const subMap = new Map((subscriptions || []).map((s) => [s.user_id?.toString(), s]));

      existingProfiles.forEach((p) => {
        const uid = (p.user_id || p.id).toString();
        const bio = bioMap.get(uid);
        const sub = subMap.get(uid);
        const levelCode = p.cefr_level_id ? (levelMap.get(p.cefr_level_id.toString()) || `Nivel ${p.cefr_level_id}`) : (p.level || 'A1');
        const xp = p.xp_points || 0;
        const existing = userMap.get(uid) || {};

        const rawDisplayName = p.display_name || existing.displayName || p.full_name || p.name;
        const displayName = (rawDisplayName && rawDisplayName !== 'Sin display_name') ? rawDisplayName : (existing.displayName || 'Sin display_name');

        const planName = sub?.subscription_plans?.name || (sub ? 'Plan Gratuito' : null);
        const audioLimitMinutes = sub?.subscription_plans?.monthly_audio_minutes_limit ?? null;
        const usedAudioMinutes = sub?.used_audio_seconds ? Math.round(sub.used_audio_seconds / 60) : (bio?.total_practice_minutes ?? null);

        userMap.set(uid, {
          id: uid,
          name: (displayName !== 'Sin display_name') ? displayName : `Estudiante Anon. (${uid.slice(0, 8)})`,
          displayName: displayName,
          avatarUrl: p.avatar_url || existing.avatarUrl || `https://api.dicebear.com/7.x/bottts-neutral/svg?seed=${uid}`,
          level: levelCode,
          xp: xp,
          streak: p.current_streak || 0,
          practiceMinutes: usedAudioMinutes,
          audioLimitMinutes: audioLimitMinutes,
          remainingMinutes: (audioLimitMinutes != null && usedAudioMinutes != null) ? Math.max(0, audioLimitMinutes - usedAudioMinutes) : null,
          plan: planName,
          planId: sub?.plan_id || null,
          clarityScore: bio?.phonetic_clarity_score ?? null,
          wpm: bio?.speaking_wpm ?? null,
          problemPhonemes: bio?.problem_phonemes || [],
          nativeLanguage: existing.nativeLanguage || p.native_language || '',
          lastActive: 'Registrado en Supabase',
        });
      });

      return Array.from(userMap.values());
    } catch (err) {
      console.error('Error fetching real users with biometrics:', err);
      return [];
    }
  },

  async saveUserProfile(userProfileData) {
    try {
      const payload = {
        user_id: userProfileData.id,
        display_name: userProfileData.displayName,
        full_name: userProfileData.name,
        xp_points: userProfileData.xp,
        current_streak: userProfileData.streak,
      };

      const { data, error } = await supabase.from('user_language_profiles').upsert(payload);
      if (error) {
        await supabase.from('user_language_profiles').upsert({
          user_id: userProfileData.id,
          xp_points: userProfileData.xp,
          current_streak: userProfileData.streak,
        });
      }

      try {
        await supabase.from('users').upsert({
          id: userProfileData.id,
          display_name: userProfileData.displayName,
        });
      } catch (_) {}

      return data;
    } catch (err) {
      console.error('Error saving user profile:', err);
    }
  },

  async deleteUserProfile(userId) {
    try {
      await supabase.from('user_language_profiles').delete().eq('user_id', userId);
    } catch (err) {
      console.error('Error deleting user profile:', err);
    }
    try {
      await supabase.from('users').delete().eq('id', userId);
    } catch (_) {}
  },

  // ── 5. SUBSCRIPTION PLANS CRUD (STRICTLY REAL DB DATA ONLY) ───────────────────
  async getSubscriptionPlans() {
    try {
      const { data, error } = await supabase
        .from('subscription_plans')
        .select('*')
        .eq('is_active', true)
        .order('order_index', { ascending: true })
        .order('id', { ascending: true });

      if (!error && data) {
        return data.map((p) => ({
          id: p.id,
          name: p.name,
          price: p.price,
          priceAnnual: p.price_annual || '',
          billingCycle: p.billing_cycle || 'monthly',
          billing: 'Mensual o Anual (el ciclo se elige al comprar)',
          monthlyAudioMinutesLimit: p.monthly_audio_minutes_limit || 300,
          orderIndex: p.order_index || 1,
          description: p.description || '',
          tag: p.badge_tag,
          features: p.features || [],
          isActive: p.is_active ?? true,
          className: p.class_name || 'plebeyo',
          manaAllowance: p.mana_allowance || (p.monthly_audio_minutes_limit || 300) * 60,
          stripePriceId: p.stripe_price_id || '',
          stripePriceAnnualId: p.stripe_price_annual_id || '',
          updatedBy: p.updated_by || '',
          updatedAt: p.updated_at || '',
        }));
      }
    } catch (err) {
      console.warn('Subscription plans fetch warning:', err);
    }

    return [];
  },

  async saveSubscriptionPlan(planObj) {
    try {
      const payload = {
        id: planObj.id,
        name: planObj.name,
        price: planObj.price,
        price_annual: planObj.priceAnnual || null,
        billing_cycle: 'monthly', // el ciclo real se elige en la compra
        monthly_audio_minutes_limit: parseInt(planObj.monthlyAudioMinutesLimit, 10) || 300,
        order_index: parseInt(planObj.orderIndex, 10) || 1,
        description: planObj.description,
        badge_tag: planObj.tag,
        features: planObj.features,
        is_active: planObj.isActive ?? true,
        class_name: planObj.className || 'plebeyo',
        mana_allowance: parseInt(planObj.manaAllowance, 10) || ((planObj.monthlyAudioMinutesLimit || 300) * 60),
        stripe_price_id: planObj.stripePriceId || null,
        stripe_price_annual_id: planObj.stripePriceAnnualId || null,
      };

      const { data, error } = await supabase.from('subscription_plans').upsert(payload);
      if (error) console.warn('Subscription plan upsert error:', error.message);
      return data;
    } catch (err) {
      console.error('Error saving subscription plan:', err);
    }
  },

  /// Elimina (desactiva) un plan. Soft-delete: is_active=false para no romper
  /// las FKs de user_subscriptions ni perder el histórico.
  async deleteSubscriptionPlan(planId) {
    try {
      const { error } = await supabase
        .from('subscription_plans')
        .update({ is_active: false })
        .eq('id', planId);
      if (error) console.warn('Subscription plan deactivate error:', error.message);
    } catch (err) {
      console.error('Error deactivating subscription plan:', err);
    }
  },

  // ── 6. AI SYSTEM SETTINGS ───────────────────────────────────────────────────
  async getAiSettings() {
    try {
      const { data } = await supabase.from('system_ai_settings').select('*').eq('id', 1).maybeSingle();
      if (data) {
        return {
          sttModel: data.stt_model || 'whisper-large-v3-turbo',
          llmModel: data.llm_model || 'deepseek-chat',
          temperature: parseFloat(data.temperature) || 0.7,
          correctionLevel: data.correction_level || 'moderate',
        };
      }
    } catch (_) {}

    return {
      sttModel: 'whisper-large-v3-turbo',
      llmModel: 'deepseek-chat',
      temperature: 0.7,
      correctionLevel: 'moderate',
    };
  },

  async getRetentionMetrics() {
    try {
      const [funnel, activation, retention, sessions] = await Promise.all([
        supabase.from('analytics_onboarding_funnel').select('*').order('ord', { ascending: true }),
        supabase.from('analytics_activation').select('*').limit(8),
        supabase.from('analytics_retention').select('*').limit(60),
        supabase.from('analytics_sessions_per_week').select('*').limit(8),
      ]);
      return {
        funnel: funnel.data ?? [],
        activation: activation.data ?? [],
        retention: retention.data ?? [],
        sessions: sessions.data ?? [],
      };
    } catch (err) {
      console.error('Error loading retention metrics:', err);
      return { funnel: [], activation: [], retention: [], sessions: [] };
    }
  },

  async updateAiSettings(settings) {
    try {
      await supabase.from('system_ai_settings').upsert({
        id: 1,
        stt_model: settings.sttModel,
        llm_model: settings.llmModel,
        temperature: settings.temperature,
        correction_level: settings.correctionLevel,
        updated_at: new Date().toISOString(),
      });
    } catch (err) {
      console.error('Error updating AI settings:', err);
    }
  },
};
