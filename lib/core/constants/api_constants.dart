class ApiConstants {
  // Configuración segura de claves:
  //   flutter run --dart-define-from-file=config.json
  // o --dart-define=DEEPSEEK_API_KEY=... --dart-define=GROQ_API_KEY=...
  // config.json NO se commitea (ver .gitignore). Los default vacíos evitan
  // exponer secretos en el repositorio (IA-01).

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://sipiumfdpvnszthykyog.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNpcGl1bWZkcHZuc3p0aHlreW9nIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQzMzA3MDIsImV4cCI6MjA5OTkwNjcwMn0.VXKRRFqsCNtAmdJtvaGvHQCA7ZNANjxxrBSmshed0jQ',
  );

  /// DeepSeek API key — ya no se usa desde el cliente (IA-01, ver llm-proxy).
  /// Las claves de IA viven SOLO como secrets de la Edge Function `llm-proxy`.
  @Deprecated('Las claves de IA se mueven al servidor (Edge Function llm-proxy).')
  static const String deepseekApiKey = String.fromEnvironment(
    'DEEPSEEK_API_KEY',
    defaultValue: '',
  );

  @Deprecated('Las claves de IA se mueven al servidor (Edge Function llm-proxy).')
  static const String deepseekBaseUrl = String.fromEnvironment(
    'DEEPSEEK_BASE_URL',
    defaultValue: 'https://api.deepseek.com/v1',
  );

  /// Groq API key — ya no se usa desde el cliente (ver llm-proxy).
  @Deprecated('Las claves de IA se mueven al servidor (Edge Function llm-proxy).')
  static const String groqApiKey = String.fromEnvironment(
    'GROQ_API_KEY',
    defaultValue: '',
  );

  @Deprecated('Las claves de IA se mueven al servidor (Edge Function llm-proxy).')
  static const String groqSttUrl = String.fromEnvironment(
    'GROQ_STT_URL',
    defaultValue: 'https://api.groq.com/openai/v1/audio/transcriptions',
  );

  /// URL base de la Edge Function que proxya DeepSeek/Groq con las claves en
  /// el servidor. Derivada del proyecto Supabase (sin secretos en el cliente).
  static String get llmProxyBaseUrl =>
      '$supabaseUrl/functions/v1/llm-proxy';

  static const String sttUrl = String.fromEnvironment(
    'STT_URL',
    defaultValue: 'https://api.tutorsaas.ai/stt/transcribe',
  );

  static const String ttsUrl = String.fromEnvironment(
    'TTS_URL',
    defaultValue: 'https://api.tutorsaas.ai/tts/synthesize',
  );

  /// RevenueCat public SDK key (configuración: copiar config.sample.json).
  /// En producción se inyecta con --dart-define-from-file=config.json
  /// (clave: REVENUECAT_API_KEY). Default = test key pública (solo dev/tests).
  static const String revenueCatApiKey = String.fromEnvironment(
    'REVENUECAT_API_KEY',
    defaultValue: 'test_pZvnwshDFcmtFESTyYwBSYFGdCN',
  );

  /// Entitlement de Premium en RevenueCat (DungeonsSpeak Pro).
  static const String revenueCatProEntitlement = 'DungeonsSpeak Pro';
}
