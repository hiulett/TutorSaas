class ApiConstants {
  // To set these keys, use --dart-define=SUPABASE_URL=your_url
  // or --dart-define-from-file=config.json

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://sipiumfdpvnszthykyog.supabase.co',
  );
  
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNpcGl1bWZkcHZuc3p0aHlreW9nIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQzMzA3MDIsImV4cCI6MjA5OTkwNjcwMn0.VXKRRFqsCNtAmdJtvaGvHQCA7ZNANjxxrBSmshed0jQ',
  );

  static const String deepseekApiKey = String.fromEnvironment(
    'DEEPSEEK_API_KEY',
    defaultValue: 'sk-592200e11f164db5b054a9421d98bd53',
  );

  static const String deepseekBaseUrl = String.fromEnvironment(
    'DEEPSEEK_BASE_URL',
    defaultValue: 'https://api.deepseek.com/v1',
  );

  static const String groqApiKey = String.fromEnvironment(
    'GROQ_API_KEY',
    defaultValue: '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',
  );

  static const String groqSttUrl = String.fromEnvironment(
    'GROQ_STT_URL',
    defaultValue: 'https://api.groq.com/openai/v1/audio/transcriptions',
  );

  static const String sttUrl = String.fromEnvironment(
    'STT_URL',
    defaultValue: 'https://api.tutorsaas.ai/stt/transcribe',
  );

  static const String ttsUrl = String.fromEnvironment(
    'TTS_URL',
    defaultValue: 'https://api.tutorsaas.ai/tts/synthesize',
  );
}
