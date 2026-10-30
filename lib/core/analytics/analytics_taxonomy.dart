/// Taxonomia minima de eventos de producto (P-15 / #100).
///
/// Reglas:
/// - `properties` solo lleva datos no personales: ids, codigos y contadores.
/// - Nunca texto de conversacion, email, nombre, bio, token ni audio.
/// - Solo valores primitivos; listas y mapas se descartan.
///
/// Las vistas `analytics_*` agregan estos eventos (ver migracion
/// `20261028204834_analytics_taxonomy_views.sql`).
abstract final class AnalyticsEvent {
  static const appOpen = 'app_open';

  static const onboardingStarted = 'onboarding_started';
  static const onboardingStep = 'onboarding_step';
  static const onboardingCompleted = 'onboarding_completed';
  static const onboardingFailed = 'onboarding_failed';

  static const sessionStart = 'session_start';
  static const sessionEnd = 'session_end';

  static const invokeLlm = 'invoke_llm';
  static const aiError = 'ai_error';

  // P-29-b (#193): evaluación de correcciones de un turno en chat libre
  // (`action_code = correction_turn`). `result`: ok | no_mana | failed.
  static const correctionEval = 'correction_eval';

  static const paywallViewed = 'paywall_viewed';
  static const purchaseStarted = 'purchase_started';
  static const purchaseSucceeded = 'purchase_succeeded';
  static const purchaseCancelled = 'purchase_cancelled';
  static const purchaseFailed = 'purchase_failed';
  static const restoreResult = 'restore_result';

  static const claimDaily = 'claim_daily';
  static const purchaseItem = 'purchase_item';
  static const purchaseCosmeticGold = 'purchase_cosmetic_gold';

  // P-21 (#106): canal de retorno (recordatorio diario local / push).
  static const notificationPermission = 'notification_permission';
  static const notificationSent = 'notification_sent';
  static const notificationOpened = 'notification_opened';

  // P-34 (#119): experiencia de conversación.
  static const ttsStopped = 'tts_stopped';
  static const ttsSpeedChanged = 'tts_speed_changed';
  static const ttsVoiceChanged = 'tts_voice_changed';
  static const micPermissionDenied = 'mic_permission_denied';
  static const micSettingsOpened = 'mic_settings_opened';
  static const helpPhrasesShown = 'help_phrases_shown';
  static const helpPhraseUsed = 'help_phrase_used';
  static const conversationTurnLatency = 'conversation_turn_latency';

  // P-34f (#198): modo del micrófono y resultado del gesto mantener-hablar.
  // `mic_mode_changed.mode` = tap | hold.
  // `hold_to_talk_turn.result` = sent | too_short | cancelled.
  static const micModeChanged = 'mic_mode_changed';
  static const holdToTalkTurn = 'hold_to_talk_turn';

  // P-25 (#110): mini-conversación de valor tras el onboarding.
  // `turn` lleva el número de turno; `input` = text | voice.
  static const miniConversationStarted = 'mini_conversation_started';
  static const miniConversationTurn = 'mini_conversation_turn';
  static const miniConversationCompleted = 'mini_conversation_completed';
  static const miniConversationSkipped = 'mini_conversation_skipped';

  static const all = <String>{
    appOpen,
    onboardingStarted,
    onboardingStep,
    onboardingCompleted,
    onboardingFailed,
    sessionStart,
    sessionEnd,
    invokeLlm,
    aiError,
    correctionEval,
    paywallViewed,
    purchaseStarted,
    purchaseSucceeded,
    purchaseCancelled,
    purchaseFailed,
    restoreResult,
    claimDaily,
    purchaseItem,
    purchaseCosmeticGold,
    notificationPermission,
    notificationSent,
    notificationOpened,
    ttsStopped,
    ttsSpeedChanged,
    ttsVoiceChanged,
    micPermissionDenied,
    micSettingsOpened,
    helpPhrasesShown,
    helpPhraseUsed,
    conversationTurnLatency,
    micModeChanged,
    holdToTalkTurn,
    miniConversationStarted,
    miniConversationTurn,
    miniConversationCompleted,
    miniConversationSkipped,
  };
}

/// Claves que jamas deben viajar en `properties` (aunque el llamador las pase).
const Set<String> _blockedKeyFragments = {
  'email',
  'name',
  'message',
  'text',
  'content',
  'bio',
  'phone',
  'token',
  'address',
  'password',
  'transcript',
  'audio',
};

/// Limpia las propiedades antes de enviarlas a `analytics_events`.
///
/// - Descarta claves con fragmentos de PII.
/// - Solo conserva `null`, `bool`, `num` y `String` (truncado).
/// - Maximo [maxKeys] claves y [maxStringLength] caracteres por texto.
Map<String, Object?> sanitizeAnalyticsProperties(
  Map<String, dynamic>? input, {
  int maxKeys = 20,
  int maxStringLength = 200,
}) {
  if (input == null || input.isEmpty) return const {};
  final out = <String, Object?>{};
  for (final entry in input.entries) {
    if (out.length >= maxKeys) break;
    final key = entry.key.trim();
    if (key.isEmpty) continue;
    final lower = key.toLowerCase();
    if (_blockedKeyFragments.any(lower.contains)) continue;

    final value = entry.value;
    if (value == null) {
      out[key] = null;
    } else if (value is bool || value is num) {
      out[key] = value;
    } else if (value is String) {
      out[key] = value.length > maxStringLength
          ? value.substring(0, maxStringLength)
          : value;
    }
    // Listas y mapas se descartan: pueden contener texto libre.
  }
  return out;
}
