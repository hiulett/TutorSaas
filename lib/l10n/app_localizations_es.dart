// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get app_name => 'Dungeon of English';

  @override
  String get login_title => 'Bienvenido de nuevo, Cazador';

  @override
  String get login_subtitle => 'Inicia sesión para continuar tu aventura.';

  @override
  String get register_prompt => '¿Nuevo Cazador? Crea una cuenta';

  @override
  String get login_prompt => '¿Ya eres un Cazador? Inicia sesión';

  @override
  String get welcome_title =>
      '[MENSAJE DEL SISTEMA: DESPERTANDO NÚCLEO DE CAZADOR...]';

  @override
  String get welcome_subtitle => 'Aprende Hablando';

  @override
  String get welcome_desc =>
      'Tu tutor personal de idiomas con IA, disponible 24/7 para conversar de manera natural.';

  @override
  String get welcome_warning =>
      'Advertencia: Cazadores no registrados serán designados Rango E';

  @override
  String get login => 'INICIAR SESIÓN';

  @override
  String get register => 'CREAR CUENTA';

  @override
  String get continue_google => 'CONTINUAR CON GOOGLE';

  @override
  String get login_google => 'INICIAR SESIÓN CON GOOGLE';

  @override
  String get register_google => 'REGISTRARSE CON GOOGLE';

  @override
  String get back => 'Atrás';

  @override
  String get skip => 'SALTAR';

  @override
  String get sign_in => 'Iniciar Sesión';

  @override
  String get sign_in_desc =>
      'Inicia sesión con tu cuenta de Google para continuar con tus clases de idiomas.';

  @override
  String get create_account => 'Crear Cuenta';

  @override
  String get create_account_desc =>
      'Regístrate con Google para personalizar tu tutor de idiomas con IA y medir tu progreso.';

  @override
  String get email_label => 'Correo electrónico';

  @override
  String get password_label => 'Contraseña';

  @override
  String get email_required => 'Ingresa tu correo electrónico';

  @override
  String get password_required => 'Ingresa tu contraseña';

  @override
  String get email_invalid => 'Ingresa un correo válido';

  @override
  String get password_short => 'La contraseña debe tener al menos 6 caracteres';

  @override
  String get login_email => 'INICIAR SESIÓN CON CORREO';

  @override
  String get register_email => 'CREAR CUENTA CON CORREO';

  @override
  String get login_email_error => 'Error al iniciar sesión con correo.';

  @override
  String get register_email_error => 'Error al crear la cuenta.';

  @override
  String get email_already_registered =>
      'Este correo ya está registrado. Inicia sesión en su lugar.';

  @override
  String get login_success => 'Inicio de sesión exitoso. Entrando al reino...';

  @override
  String get register_success => 'Cuenta creada. Entrando al reino...';

  @override
  String get login_email_hint => 'tucorreo@email.com';

  @override
  String get forgot_password => '¿OLVIDASTE TU CONTRASEÑA?';

  @override
  String get reset_password_title => 'RECUPERAR CONTRASEÑA';

  @override
  String get reset_password_desc =>
      'Ingresa tu correo y te enviaremos un enlace para recuperar tu contraseña.';

  @override
  String get reset_password_send => 'ENVIAR ENLACE DE RECUPERACIÓN';

  @override
  String get reset_password_sent =>
      'Enlace de recuperación enviado. Revisa tu bandeja de correo.';

  @override
  String get reset_password_error =>
      'Error al enviar el enlace. Revisa el correo e inténtalo de nuevo.';

  @override
  String get reset_password_email_empty =>
      'Ingresa tu correo para recuperar tu contraseña.';

  @override
  String get sync_progress => 'SINCRONIZANDO NIVEL CEFR...';

  @override
  String get dashboard_title => 'ESTADO DEL SISTEMA';

  @override
  String get dashboard_offline =>
      'Sin conexión. Mostrando el último progreso guardado.';

  @override
  String dashboard_offline_age(int minutes) {
    return 'Sin conexión. Último progreso hace $minutes min.';
  }

  @override
  String get dungeons => 'MAZMORRAS';

  @override
  String get guild => 'GREMIO';

  @override
  String get status => 'ESTADO';

  @override
  String get config => 'CONFIG';

  @override
  String get player => 'JUGADOR';

  @override
  String get mp => 'PM';

  @override
  String get days_clear => 'DÍAS ACTIVO';

  @override
  String get urgent_quest => 'MISIÓN URGENTE';

  @override
  String get enter_gateway => 'ENTRAR A LA BATALLA';

  @override
  String get active_quests => 'MISIONES ACTIVAS';

  @override
  String get daily => 'DIARIO';

  @override
  String get weekly => 'SEMANAL';

  @override
  String get speak_words => 'Habla 50 palabras en una sesión';

  @override
  String get keep_streak => 'Mantén tu racha activa';

  @override
  String get clear_vocab => 'Completa 1 Mazmorra de Vocabulario';

  @override
  String get chat_rooms => 'Salas de Chat de Voz';

  @override
  String get chat_rooms_desc =>
      'Practica grupal con moderación de IA en tiempo real';

  @override
  String get settings => 'Configuración';

  @override
  String get language_level => 'Idioma y Nivel';

  @override
  String get tutorial_system => 'Tutorial y Sistema';

  @override
  String get ai_preferences => 'Preferencias de IA';

  @override
  String get reminders => 'Recordatorios';

  @override
  String get account => 'Cuenta';

  @override
  String get target_language => 'Idioma Objetivo';

  @override
  String get active_cefr => 'Nivel CEFR Activo';

  @override
  String get review_tutorial => 'Revisar Tutorial';

  @override
  String get review_tutorial_desc => 'Ver el onboarding completo nuevamente';

  @override
  String get tutorial_dialog_title => 'Revisar Tutorial';

  @override
  String get tutorial_dialog_content =>
      'El tutorial será marcado como pendiente. Regresa al inicio para ser redirigido.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get tutorial_pending =>
      'Tutorial marcado como pendiente. Ve al inicio.';

  @override
  String get correction_level => 'Nivel de Corrección IA';

  @override
  String get tutor_personality => 'Personalidad del Tutor';

  @override
  String get correction_style => 'Estilo de Corrección';

  @override
  String get daily_goal => 'Meta Diaria';

  @override
  String get save_settings => 'Guardar Configuración';

  @override
  String get settings_save_error => 'No se pudo guardar la configuración.';

  @override
  String get settings_delete_error => 'No se pudo eliminar la cuenta.';

  @override
  String get settings_app_language => 'IDIOMA DE LA APLICACIÓN';

  @override
  String get saved => 'Configuración guardada exitosamente';

  @override
  String get error_saving => 'Error al guardar configuración';

  @override
  String get logout => 'Cerrar Sesión';

  @override
  String get select_language => 'Seleccionar Idioma Objetivo';

  @override
  String get select_cefr => 'Selecciona tu Nivel CEFR';

  @override
  String get fluency => 'FLUIDEZ';

  @override
  String get latency => 'LATENCIA';

  @override
  String get pipeline_perf => 'Rendimiento del pipeline';

  @override
  String get score => 'Puntaje';

  @override
  String get achievements => 'Logros y Estadísticas';

  @override
  String get vocabulary_learned => 'Vocabulario Aprendido';

  @override
  String get weekly_practice => 'Práctica Semanal (Minutos de Voz)';

  @override
  String get view_all => 'VER TODO';

  @override
  String get srs_review => 'Repaso SRS';

  @override
  String get fluency_evolution => 'Evolución de Fluidez y Latencia';

  @override
  String get wpm => 'PPM';

  @override
  String get radar_title => 'Radar Holográfico de Habilidades';

  @override
  String get heatmap_title => 'Consistencia de Práctica (4 Semanas)';

  @override
  String get weeks_ago => 'Hace 4 semanas';

  @override
  String get today => 'Hoy';

  @override
  String get profile => 'Perfil';

  @override
  String get edit_profile => 'Editar Perfil';

  @override
  String get status_window => 'VENTANA DE ESTADO DEL CAZADOR';

  @override
  String get status_window_desc =>
      'Matriz de 11 atributos, títulos equipables y radar de poder';

  @override
  String get xp_points => 'Puntos XP';

  @override
  String get active_streak => 'Racha Activa';

  @override
  String get active_level => 'Nivel Activo';

  @override
  String get days => 'Días';

  @override
  String get voice_chat => 'Chat de Voz';

  @override
  String get speak_now => 'HABLAR AHORA';

  @override
  String get hold_speak => 'Mantén presionado para hablar';

  @override
  String get boss_hp => 'HP del Jefe';

  @override
  String get system_analysis => '[ANÁLISIS DEL SISTEMA COMPLETADO]';

  @override
  String get explain_rule => 'Explicar Regla';

  @override
  String get provide_example => 'Dar Ejemplo';

  @override
  String get retry_battle => 'Reintentar Batalla';

  @override
  String get type_command => 'Escribe un comando o entrada...';

  @override
  String get lesson_preview => 'Objetivos y Metas';

  @override
  String get communication_goals => 'Metas de Comunicación';

  @override
  String get recommended_phrases => 'Frases Recomendadas';

  @override
  String get understood => 'Entendido';

  @override
  String get start_voice_lesson => 'Comenzar Lección de Voz';

  @override
  String get objectives => 'Objetivos';

  @override
  String get beginner => 'Principiante';

  @override
  String get intermediate => 'Intermedio';

  @override
  String get advanced => 'Avanzado';

  @override
  String get master => 'Maestro';

  @override
  String get min_day => 'min / día';

  @override
  String get onboarding_lang => 'IDIOMA DE DESPERTAR';

  @override
  String get onboarding_country => 'REGISTRO DE CAZADOR';

  @override
  String get onboarding_target => 'IDIOMA OBJETIVO';

  @override
  String get onboarding_cefr => 'SELECCIÓN DE NIVEL';

  @override
  String get onboarding_goal => 'COMPROMISO DE MISIÓN';

  @override
  String get onboarding_interests => 'ÁRBOL DE HABILIDADES';

  @override
  String get onboarding_correction => 'ENFOQUE TÁCTICO';

  @override
  String get onboarding_obstacle => 'IDENTIFICACIÓN DEL JEFE';

  @override
  String get btn_continue => 'Continuar';

  @override
  String get onboarding_start_eval => 'INICIAR EVALUACIÓN';

  @override
  String get register_confirm_email =>
      'Revisa tu correo y confirma la cuenta para continuar.';

  @override
  String get resend_confirmation => 'REENVIAR';

  @override
  String get login_email_not_confirmed =>
      'Tu correo aún no está confirmado. Revisa tu bandeja o pide un nuevo envío.';

  @override
  String get complete_onboarding => 'Completar Onboarding';

  @override
  String get exam_timer => 'Tiempo Restante';

  @override
  String get exam_pass => 'APROBADO';

  @override
  String get exam_fail => 'REPROBADO';

  @override
  String get new_rank => 'Nuevo Rango Desbloqueado';

  @override
  String get dungeon => 'Mazmorra';

  @override
  String get quest => 'Misión';

  @override
  String get boss => 'Jefe';

  @override
  String get hunter => 'Cazador';

  @override
  String get rank => 'RANGO';

  @override
  String get mission => 'Misión';

  @override
  String get log_entry => 'Entrada';

  @override
  String get system_log => 'Registro del Sistema';

  @override
  String get data_stream => 'Flujo de Datos';

  @override
  String get active => 'Activo';

  @override
  String get inactive => 'Inactivo';

  @override
  String get first_steps => 'Primeros Pasos';

  @override
  String get first_steps_desc =>
      'Completa tu primera conversación para obtener tu equipo inicial';

  @override
  String get fire_streak => 'Racha de Fuego';

  @override
  String get fire_streak_desc => 'Mantén una racha de práctica de 7 días';

  @override
  String get fluent_speaker => 'Hablante Fluido';

  @override
  String get fluent_speaker_desc => 'Habla 100 palabras en una sola sesión';

  @override
  String get goals_completed_desc =>
      'Todos los objetivos principales completados';

  @override
  String get guild_hall => 'SALÓN DEL GREMIO';

  @override
  String get live_coop => 'Salas de Raid Co-Op en Vivo';

  @override
  String get initialize_room => 'Crear Mesa';

  @override
  String get enter_raid => 'Entrar a la Raid';

  @override
  String get hunters_active => 'Cazadores Activos';

  @override
  String get live_voice => 'Voz en Vivo';

  @override
  String get barrier_active => 'Barrera Activa';

  @override
  String get no_vocab =>
      'Aún no has aprendido vocabulario. ¡Inicia una conversación!';

  @override
  String get vocab_detail => 'Detalle de Vocabulario';

  @override
  String get vocab_added => 'Vocabulario agregado';

  @override
  String xp_earned(Object amount) {
    return '+$amount XP';
  }

  @override
  String streak_days(Object count) {
    return 'Racha de $count Días';
  }

  @override
  String conversations_remaining(Object count) {
    return '$count conversaciones restantes';
  }

  @override
  String get character_name => 'NOMBRE DEL CAZADOR';

  @override
  String get character_name_hint => 'Tu nombre aventurero...';

  @override
  String get character_avatar => 'AVATAR';

  @override
  String get character_class => 'CLASE';

  @override
  String get oracle_title => 'EL ORÁCULO DEL GREMIO';

  @override
  String get oracle_assessment => 'Evaluación en curso...';

  @override
  String get oracle_respond => 'Responde al Oráculo...';

  @override
  String get oracle_result => 'Evaluación Completa';

  @override
  String get oracle_strengths => 'FORTALEZAS';

  @override
  String get oracle_weaknesses => 'ÁREAS DE MEJORA';

  @override
  String get oracle_continue => 'RECIBIR CARNET DE CAZADOR';

  @override
  String get nucleo_title => 'EL NÚCLEO ARCANO ESTÁ AGOTÁNDOSE';

  @override
  String nucleo_desc(Object count) {
    return 'El Oráculo ha respondido $count veces hoy. Necesita recargarse con la luz del amanecer.';
  }

  @override
  String get nucleo_rest => 'Descansar hasta mañana — el Núcleo se recargará';

  @override
  String get mod_ai => '🤖 Moderación por IA';

  @override
  String get mod_creator => '👑 Moderación por Creador';

  @override
  String get mod_assigned => '🎯 Moderación Asignada';

  @override
  String get mod_table_new => 'Nueva Mesa del Gremio';

  @override
  String get mod_table_name => 'Nombre de la mesa';

  @override
  String get mod_description => 'Descripción (opcional)';

  @override
  String get mod_category => 'Categoría';

  @override
  String get mod_type => 'TIPO DE MODERACIÓN';

  @override
  String get mod_create => 'Crear Mesa';

  @override
  String get mod_cancel => 'Cancelar';

  @override
  String get mod_ai_desc =>
      'El Tutor IA modera la conversación automáticamente';

  @override
  String get mod_creator_desc =>
      'Tú moderas la mesa. Gestionas oradores y turnos';

  @override
  String get mod_assigned_desc =>
      'Otro usuario será el moderador. Ingresa su email:';

  @override
  String get room_live => 'EN VIVO';

  @override
  String get room_mic => 'Micrófono';

  @override
  String get room_leave => 'Salir';

  @override
  String get room_chat => 'Chat';

  @override
  String get room_audience => 'Audiencia';

  @override
  String get room_hand => 'Pedir Hablar';

  @override
  String get room_hand_raised => 'Solicitado';

  @override
  String room_claim_slot(Object slot) {
    return 'Ocupar Slot $slot';
  }

  @override
  String room_spectators(Object count) {
    return 'Espectadores ($count)';
  }

  @override
  String get room_ai_moderating => 'IA Moderando';

  @override
  String get room_moderating => 'Moderando';

  @override
  String room_slot(Object slot) {
    return 'Slot $slot';
  }

  @override
  String get conversation_title => 'Sala de Voz';

  @override
  String get conversation_input_hint => 'Escribe en inglés...';

  @override
  String get conversation_mission_guide => 'GUÍA DE MISIÓN';

  @override
  String get conversation_voice_mode => 'Modo Voz';

  @override
  String get conversation_text_mode => 'Modo Texto';

  @override
  String get conversation_speech_dna => 'Huella de Voz';

  @override
  String get conversation_replay => 'REPRODUCIR';

  @override
  String get guild_master => 'MAESTRE DE MESA';

  @override
  String get guild_online => 'EN LÍNEA';

  @override
  String get guild_quest_daily => 'MISIÓN DIARIA';

  @override
  String get guild_quest_speak => 'Habla 10 minutos en una sala de voz';

  @override
  String get guild_tables => 'MESAS DEL GREMIO';

  @override
  String get guild_create => 'Crear';

  @override
  String get guild_join => 'Unirse';

  @override
  String get guild_enter => 'Entrar';

  @override
  String get guild_no_rooms => 'No hay salas activas en esta categoría.';

  @override
  String get status_panel => 'PANEL DE ESTADO DEL CAZADOR';

  @override
  String get status_attributes => 'ATRIBUTOS DEL MONARCA (11)';

  @override
  String get status_titles => 'TÍTULOS LEGENDARIOS';

  @override
  String get status_equip => 'Equipar';

  @override
  String get status_equipped => '✓';

  @override
  String get status_combat => 'ATRIBUTOS DE COMBATE';

  @override
  String get status_achievements => 'LOGROS RAROS';

  @override
  String get hud_xp_total => 'XP TOTAL';

  @override
  String get hud_vocabulary => 'VOCABULARIO';

  @override
  String get hud_level => 'NIVEL';

  @override
  String get hud_streak => 'RACHA';

  @override
  String get error_mic_permission =>
      'Sin permiso de micrófono. Actívalo en configuración.';

  @override
  String get error_listening => 'Escuchando tu voz...';

  @override
  String get error_short_audio =>
      'La grabación fue muy corta o vacía. Habla de nuevo.';

  @override
  String get error_no_speech =>
      'No se detectó voz. Intenta hablar más cerca del micrófono.';

  @override
  String get error_recording => 'No se pudo generar la grabación.';

  @override
  String get error_processing =>
      'Error al procesar la respuesta. Intenta de nuevo.';

  @override
  String error_groq_connection(Object code) {
    return 'Error de conexión con STT ($code). Revisa tu internet o la API Key.';
  }

  @override
  String get error_nucleo => 'EL NÚCLEO ARCANO ESTÁ AGOTADO';

  @override
  String get loading => 'Cargando...';

  @override
  String get error => 'Error';

  @override
  String get retry => 'Reintentar';

  @override
  String get success => 'Éxito';

  @override
  String get confirm => 'Confirmar';

  @override
  String get close => 'Cerrar';

  @override
  String get save => 'Guardar';

  @override
  String get delete => 'Eliminar';

  @override
  String get search => 'Buscar';

  @override
  String get filter => 'Filtrar';

  @override
  String get no_results => 'No se encontraron resultados.';

  @override
  String get see_all => 'Ver Todo';

  @override
  String get learn_more => 'Más Información';

  @override
  String get get_started => 'Comenzar';

  @override
  String get register_new_hunter => 'REGISTRAR NUEVO HUNTER';

  @override
  String get onboarding_select_native_warn =>
      'Selecciona tu idioma nativo para continuar.';

  @override
  String get onboarding_select_target_warn =>
      'Selecciona el idioma que deseas aprender.';

  @override
  String get onboarding_switch_interface_lang =>
      'Cambiar idioma de la interfaz';

  @override
  String onboarding_switch_interface_desc(String lang) {
    return 'Cambia los menús y botones de la app a $lang en lugar de inglés.';
  }

  @override
  String get onboarding_country_title => 'PAÍS DE ORIGEN';

  @override
  String get onboarding_country_desc =>
      'Dinos de dónde vienes para adaptar la pronunciación y las expresiones.';

  @override
  String get onboarding_country_search_hint => 'Buscar país...';

  @override
  String get onboarding_country_no_results => 'No se encontraron países.';

  @override
  String get onboarding_oracle_classification => 'EL ORÁCULO TE CLASIFICARÁ';

  @override
  String get onboarding_oracle_classification_desc =>
      'El Oráculo analizará tu dominio del idioma mediante una conversación para determinar tu rango inicial.';

  @override
  String get onboarding_voice_evaluation => 'EVALUACIÓN CONVERSACIONAL POR VOZ';

  @override
  String get onboarding_voice_evaluation_desc =>
      'Habla con el Oráculo y serás evaluado en pronunciación, vocabulario, gramática, comprensión y fluidez. El resultado definirá tu rango inicial.';

  @override
  String get onboarding_start_evaluation => 'INICIAR EVALUACIÓN';

  @override
  String get onboarding_evaluation_optional =>
      'La evaluación es opcional: si la omites, comenzarás en el rango inicial (A1).';

  @override
  String get welcome_hunter_prefix => '¡BIENVENIDO,';

  @override
  String get welcome_hunter_suffix => 'CAZADOR!';

  @override
  String get adventure_begins => 'Tu aventura comienza ahora.';

  @override
  String get enter_realm => 'ENTRAR AL REINO';

  @override
  String get character_creation_title => 'CREA TU PERSONAJE';

  @override
  String get character_creation_desc =>
      'Antes de comenzar tu aventura, necesitamos saber quién eres.';

  @override
  String get character_creation_continue => 'EL ORÁCULO TE ESPERA';

  @override
  String get character_name_optional =>
      'Opcional — si lo dejas vacío se usará el nombre de tu cuenta.';

  @override
  String get character_class_unavailable =>
      'Clases no disponibles. Intenta de nuevo más tarde.';

  @override
  String get character_difficulty_label => 'Dificultad';

  @override
  String get character_combat_label => 'Combate';

  @override
  String get character_affinity_label => 'Afinidad';

  @override
  String get character_abilities_label => 'HABILIDADES';

  @override
  String get character_stat_attack => 'Ataque';

  @override
  String get character_stat_defense => 'Defensa';

  @override
  String get character_stat_magic => 'Magia';

  @override
  String get character_stat_speed => 'Velocidad';

  @override
  String get character_stat_support => 'Soporte';

  @override
  String get character_stat_survival => 'Supervivencia';

  @override
  String get class_warrior_name => 'Berserker';

  @override
  String get class_warrior_desc =>
      'Extrovertido y valiente. Hablas primero y piensas después. Ideal para perder el miedo a hablar.';

  @override
  String get class_warrior_arch =>
      'Extrovertido, habla primero — perder el miedo';

  @override
  String get class_mage_name => 'Mago Arcano';

  @override
  String get class_mage_desc =>
      'Analítico y preciso. Observas y estructuras antes de hablar. Ideal para perfeccionar la gramática.';

  @override
  String get class_mage_arch =>
      'Analítico, estructura antes de hablar — gramática';

  @override
  String get class_assassin_name => 'Asesino';

  @override
  String get class_assassin_desc =>
      'Observador táctico. Buscas la precisión y la eficiencia sigilosa. Ideal para vocabulario de precisión.';

  @override
  String get class_assassin_arch =>
      'Observador táctico — vocabulario de precisión';

  @override
  String get class_knight_name => 'Caballero';

  @override
  String get class_knight_desc =>
      'Constante y metódico. Te mantienes firme en tus rutinas. Ideal para construir rachas y constancia.';

  @override
  String get class_knight_arch => 'Constante y metódico — constancia y rachas';

  @override
  String get class_archer_name => 'Arquero';

  @override
  String get class_archer_desc =>
      'Ágil y rápido. Aprendes sobre la marcha dentro del contexto. Ideal para dominar expresiones útiles.';

  @override
  String get class_archer_arch =>
      'Ágil, aprende en contexto — expresiones útiles';

  @override
  String get class_summoner_name => 'Invocador';

  @override
  String get class_summoner_desc =>
      'Creativo y asociativo. Conectas conceptos e invocas ideas. Ideal para frases idiomáticas.';

  @override
  String get class_summoner_arch =>
      'Creativo, asocia ideas — frases idiomáticas';

  @override
  String get class_paladin_name => 'Paladín';

  @override
  String get class_paladin_desc =>
      'Protector guiado por objetivos. Orientado al deber. Ideal para conversaciones formales y estructuradas.';

  @override
  String get class_paladin_arch => 'Guiado por objetivos — conversación formal';

  @override
  String get class_necromancer_name => 'Nigromante';

  @override
  String get class_necromancer_desc =>
      'Explorador etimológico. Resucitas las raíces del idioma. Ideal para raíces latinas y orígenes de palabras.';

  @override
  String get class_necromancer_arch =>
      'Curioso por la etimología — raíces latinas e historia';

  @override
  String get onboarding_lang_desc =>
      'Personalizaremos tu viaje de aprendizaje según tu idioma materno.';

  @override
  String get onboarding_native_lang => 'Idioma nativo';

  @override
  String get onboarding_target_desc => '¿Qué idioma quieres dominar?';

  @override
  String get onb_validate_native =>
      'Selecciona tu idioma nativo para continuar.';

  @override
  String get onb_validate_target => 'Selecciona el idioma que deseas aprender.';

  @override
  String get login_google_error => 'Error al iniciar sesión con Google.';

  @override
  String get register_google_error => 'Error al registrarse con Google.';

  @override
  String get oracle_no_voice =>
      'No se detectó voz. Habla más cerca del micrófono o usa el teclado.';

  @override
  String get oracle_listening => 'ESCUCHANDO… SUELTA PARA ENVIAR';

  @override
  String get oracle_processing => 'PROCESANDO CON GROQ IA…';

  @override
  String get oracle_skip => 'SALTAR PREGUNTA';

  @override
  String get oracle_complete => 'COMPLETAR EVALUACIÓN';

  @override
  String get room_no_messages => 'Aún no hay mensajes en esta cámara.';

  @override
  String room_error(String err) {
    return 'Error en sala: $err';
  }

  @override
  String get room_hunt_lang => 'Idioma de Caza:';

  @override
  String get room_xp_points => 'Puntos de Experiencia:';

  @override
  String get room_type_ai => 'ENTRENAMIENTO IA';

  @override
  String get room_type_mentorship => 'MENTORÍA (RESONANCIA)';

  @override
  String get room_type_event => 'EVENTO ESPECIAL';

  @override
  String get room_cancel => 'CANCELAR';

  @override
  String room_create_error(String err) {
    return 'Error al crear sala: $err';
  }

  @override
  String get room_initialize => 'INICIAR';

  @override
  String room_prestige(String level) {
    return 'PRESTIGIO $level';
  }

  @override
  String get mission_accept => 'ACEPTAR';

  @override
  String get mission_none => 'SIN MISIONES ACTIVAS';

  @override
  String get mission_generate => 'GENERAR MISIONES';

  @override
  String get mission_claim => 'RECLAMAR';

  @override
  String get srs_close => 'CERRAR';

  @override
  String get srs_hard => 'DIFÍCIL';

  @override
  String get srs_review_title => 'REPASO DEL DÍA';

  @override
  String srs_review_due(int count) {
    return '$count palabras esperan repaso';
  }

  @override
  String get npc_remembers_failure => 'EL NPC RECUERDA TU ÚLTIMO INTENTO';

  @override
  String get npc_remembers_partial => 'EL NPC RECUERDA QUE CASI LO LOGRAS';

  @override
  String get srs_review_cta => 'REPASAR';

  @override
  String srs_retention(int percent, int mastered) {
    return '$percent% recordado a 7 días · $mastered dominadas';
  }

  @override
  String get srs_normal => 'NORMAL';

  @override
  String get srs_easy => 'FÁCIL';

  @override
  String get nucleo_recharge => 'RECARGAR +5';

  @override
  String get nucleo_premium => 'IR PREMIUM';

  @override
  String get nucleo_unlimited => 'Invocaciones Ilimitadas — Cazador de Élite';

  @override
  String get paywall_success =>
      '¡Gracias por suscribirte! Beneficios Premium desbloqueados.';

  @override
  String paywall_failure(String err) {
    return 'Error en la compra: $err';
  }

  @override
  String get paywall_restored => 'Compras restauradas correctamente.';

  @override
  String get paywall_nothing_to_restore => 'No hay compras que restaurar.';

  @override
  String get lessons_voice_rooms => 'Salas de Voz';

  @override
  String get lessons_view_goals => 'Ver Objetivos';

  @override
  String get exam_mute => 'SILENCIAR';

  @override
  String get exam_conclude => 'CONCLUIR RAID';

  @override
  String get exam_return => 'VOLVER AL SANTUARIO';

  @override
  String get progress_xp_points => 'Puntos XP';

  @override
  String get progress_active_streak => 'Racha Activa';

  @override
  String get progress_active_level => 'Nivel Activo';

  @override
  String get progress_active_rank => 'Rango del Gremio';

  @override
  String get radar_fluency => 'Fluidez';

  @override
  String get radar_vocab => 'Vocabulario';

  @override
  String get radar_phonetics => 'Fonética';

  @override
  String get radar_grammar => 'Gramática';

  @override
  String get radar_comprehension => 'Comprensión';

  @override
  String get radar_naturalness => 'Naturalidad';

  @override
  String get progress_srs_review => 'Repaso SRS';

  @override
  String get progress_see_all => 'VER TODO';

  @override
  String get inventory_load_error => 'No se pudo cargar el inventario';

  @override
  String get inventory_empty => 'INVENTARIO VACÍO';

  @override
  String get inventory_visit_shop => 'VISITA LA TIENDA →';

  @override
  String get inventory_equipped => 'EQUIPADO';

  @override
  String get conversation_goals => 'Metas del Escenario:';

  @override
  String get conversation_key_phrases => 'Frases Clave Sugeridas:';

  @override
  String get conversation_phonemes => 'Fonemas recomendados a practicar:';

  @override
  String get hero_got_it => 'Entendido';

  @override
  String get hero_cefr_label => 'CEFR';

  @override
  String get hero_class_label => 'Clase';

  @override
  String get hero_member_since => 'Miembro desde';

  @override
  String get summary_view_vocab => 'VER VOCABULARIO';

  @override
  String get summary_vocab_title => 'VOCABULARIO DE LA SESIÓN';

  @override
  String get summary_vocab_empty =>
      'Aún no hay palabras guardadas de esta sesión.';

  @override
  String get summary_vocab_saved => 'Vocabulario guardado en tu perfil.';

  @override
  String get summary_done => 'LISTO';

  @override
  String get collections_load_error => 'No se pudieron cargar las colecciones';

  @override
  String get profile_total_xp => 'XP Total';

  @override
  String get profile_streak => 'Racha activa';

  @override
  String get profile_cefr_level => 'Nivel CEFR';

  @override
  String get profile_vocab_error => 'Error al cargar vocabulario';

  @override
  String get profile_vocab_empty =>
      'Aún no has aprendido vocabulario en las conversaciones.';

  @override
  String get profile_close => 'Cerrar';

  @override
  String get battlepass_load_error => 'No se pudo cargar el Battle Pass';

  @override
  String get profile_edit_camera => 'CÁMARA';

  @override
  String get profile_edit_gallery => 'GALERÍA';

  @override
  String get chart_4weeks => 'Hace 4 semanas';

  @override
  String get chart_today => 'Hoy';

  @override
  String get chart_latency => 'Latencia (s)';

  @override
  String get aura_title => 'AURA';

  @override
  String get aura_locked => 'AURA BLOQUEADA';

  @override
  String get aura_locked_desc =>
      'Supera la Etapa Básica (PRE-A1 + A1 + A2) para despertar tu poder.';

  @override
  String get aura_awakened => 'USUARIO DEL AURA';

  @override
  String get aura_basic_stage => 'ETAPA BÁSICA';

  @override
  String get aura_power => 'PODER';

  @override
  String get aura_tier_latente => 'LATENTE';

  @override
  String get aura_tier_revelada => 'REVELADA';

  @override
  String get aura_tier_abierta => 'ABIERTA';

  @override
  String get aura_tier_dominante => 'DOMINANTE';

  @override
  String get aura_tier_abisal => 'ABISAL';

  @override
  String get aura_awakening_banner_title => 'EL SISTEMA HA HABLADO';

  @override
  String get aura_awakening_banner_desc =>
      'Has despertado como Usuario del Aura. Tu poder crecerá con tus habilidades.';

  @override
  String get ok => 'OK';

  @override
  String get shop => 'TIENDA';

  @override
  String get map => 'MAPA';

  @override
  String get claimed => 'RECLAMADO';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get missions => 'Misiones';

  @override
  String get oracle => 'ORÁCULO';

  @override
  String get pro_badge => 'PRO';

  @override
  String get go_pro => 'IR PRO';

  @override
  String get logout_confirm_title => '¿CERRAR SESIÓN?';

  @override
  String get logout_confirm_desc =>
      'Tu progreso queda guardado. Necesitarás volver a iniciar sesión para continuar.';

  @override
  String get splash_system_hud => 'SISTEMA HUD · DESPERTANDO';

  @override
  String splash_connecting(int pct) {
    return '$pct% · CONECTANDO AL GRAN REINO';
  }

  @override
  String get connecting_realm => 'CONECTANDO AL GRAN REINO...';

  @override
  String get system_hunter_connected => 'SISTEMA DE CAZADOR — CONECTADO';

  @override
  String cefr_level(String code) {
    return 'CEFR $code';
  }

  @override
  String level_up_banner(int level) {
    return '¡SUBIDA DE NIVEL! $level';
  }

  @override
  String title_earned_banner(String title) {
    return '🏅 TÍTULO GANADO: $title';
  }

  @override
  String get mana_label => 'MANÁ';

  @override
  String get mana_available => 'maná disponible';

  @override
  String get mana_daily_available => 'maná disponible hoy';

  @override
  String get guardian_title => 'SANTUARIO DE MANÁ';

  @override
  String get guardian_sealed => 'Sellada';

  @override
  String get guardian_cry => 'TU MANÁ SE HA AGOTADO.\nEL SANTUARIO TE ESPERA.';

  @override
  String get guardian_desc =>
      'Toda acción de IA cuesta maná. Recupéralo con tu plan, porciones o equipando un elixir o gema de tu bolsa.';

  @override
  String get guardian_get_mana => 'OBTENER MANÁ';

  @override
  String get guardian_get_mana_desc => 'MÁS MANÁ MENSUAL POR ESTAMENTO';

  @override
  String get guardian_equip_item => 'EQUIPAR ELIXIR / GEMA';

  @override
  String get guardian_equip_item_desc => 'Equipa un ítem de maná de tu bolsa';

  @override
  String get guardian_go_back => 'Volver al Gremio';

  @override
  String mana_balance(int remaining, int total) {
    return '$remaining / $total maná';
  }

  @override
  String plus_mana(int count) {
    return '+$count maná';
  }

  @override
  String purchase_confirm_question(String name, String price) {
    return '¿Adquirir \"$name\" por $price?';
  }

  @override
  String get mana_tooltip =>
      'MANÁ: energía para toda acción IA (Oráculo, mazmorras, chats). Se adquiere con tu plan y porciones/gemas; expira con el ciclo.';

  @override
  String mana_expires(String date) {
    return 'expira $date';
  }

  @override
  String get aura_locked_tooltip =>
      'ETAPA BÁSICA: completa los objetivos de las misiones PRE-A1, A1 y A2 para despertar tu Aura.';

  @override
  String get aura_awakened_tooltip =>
      'AURA: mérito sin tope. Sigue acumulando con cada sesión evaluada.';

  @override
  String aura_xp(int xp) {
    return 'AURA XP $xp';
  }

  @override
  String aura_next_rank(int pct) {
    return '$pct% al siguiente rango';
  }

  @override
  String get aura_rank_mismatch => '⚠ RANGO INCONSISTENTE CON CEFR';

  @override
  String get daily_reward_title => 'RECOMPENSA DIARIA';

  @override
  String daily_reward_streak(int streak) {
    return 'RACHA ACTUAL: $streak DÍAS';
  }

  @override
  String daily_reward_gems(int gems) {
    return '$gems GEMAS';
  }

  @override
  String get daily_reward_by_streak => 'POR RACHA';

  @override
  String daily_reward_parchments(int count) {
    return '+$count PERGAMINOS';
  }

  @override
  String get daily_reward_cap => 'TETO DIARIO';

  @override
  String get daily_reward_keep_streak =>
      'MANTÉN TU RACHA: A LOS 7 DÍAS GANAS 50 GEMAS Y 5 PERGAMINOS';

  @override
  String get daily_reward_at_14 => 'A LOS 14 DÍAS: 100 GEMAS Y 8 PERGAMINOS';

  @override
  String get daily_reward_at_30 => 'A LOS 30 DÍAS: 300 GEMAS Y 15 PERGAMINOS';

  @override
  String get daily_reward_max_streak => '¡RACHA MÁXIMA ALCANZADA!';

  @override
  String get claiming => 'RECLAMANDO…';

  @override
  String get daily_reward_claimed_today => 'RECOMPENSA RECLAMADA HOY';

  @override
  String get daily_reward_claim => 'RECLAMAR RECOMPENSA';

  @override
  String get no_mana => 'SIN MANÁ';

  @override
  String mana_exhausted_desc(String renew) {
    return 'Toda acción de IA cuesta maná. Tu saldo se agotó.\n\nEl maná se adquiere con tu plan o porciones/gemas.\n$renew';
  }

  @override
  String mana_renews_on(String date) {
    return 'Tu ciclo renueva el $date.';
  }

  @override
  String get more_mana_monthly => 'MÁS MANÁ MENSUAL POR ESTAMENTO';

  @override
  String get wait_plan_renewal => 'Esperar la renovación de mi plan';

  @override
  String get hunter_collections => 'COLECCIONES DEL CAZADOR';

  @override
  String get no_trophies => 'SIN TROFEOS REGISTRADOS';

  @override
  String get confirm_purchase => 'CONFIRMAR COMPRA';

  @override
  String get buy => 'COMPRAR';

  @override
  String get cosmetic_purchased => '¡COSMÉTICO ADQUIRIDO! 🪙';

  @override
  String get gold_insufficient => 'ORO INSUFICIENTE O YA ADQUIRIDO ❌';

  @override
  String get cosmetic_title => 'TÍTULO';

  @override
  String get cosmetic_frame => 'MARCO';

  @override
  String get cosmetic_aura => 'AURA';

  @override
  String get cosmetic_pet => 'COMPAÑERO';

  @override
  String get cosmetic_emote => 'EMOTE';

  @override
  String get cosmetic_theme => 'TEMA';

  @override
  String get arcane_shop => 'TIENDA ARCANO';

  @override
  String get gold_shop_tab => 'TIENDA DE ORO';

  @override
  String get redeem => 'CANJEAR';

  @override
  String get my_items => 'MIS ÍTEMS';

  @override
  String get mana_potions_title => 'PORCIONES DE MANÁ';

  @override
  String get mana_potions_desc =>
      'El maná es la energía de toda acción IA. Se adquiere con dinero real: tu estamento incluye una asignación mensual y las porciones la amplían.';

  @override
  String get mana_gems_packs_title => 'PACKS DE GEMAS DE MANÁ';

  @override
  String get gold_shop_unavailable =>
      'La Tienda de Oro aún no está disponible.\nVuelve a intentarlo en un momento.';

  @override
  String get owned => 'ADQUIRIDO';

  @override
  String price_gold(String price) {
    return '$price ORO';
  }

  @override
  String price_gems(String price) {
    return '$price GEMAS';
  }

  @override
  String craft_cost(String cost) {
    return '$cost FRAGMENTOS';
  }

  @override
  String get craft_action => 'CRAFTEAR';

  @override
  String get craft_success => '¡COSMÉTICO CRAFTEADO!';

  @override
  String get shop_tab_gems => 'GEMAS';

  @override
  String get shop_tab_gold => 'ORO';

  @override
  String get shop_tab_fragments => 'FRAGMENTOS';

  @override
  String get shop_tab_empty => 'Aún no hay objetos en esta moneda.';

  @override
  String get shop_level_locked => 'NIVEL DE CAZADOR INSUFICIENTE';

  @override
  String shop_next_unlock(String name, int level) {
    return 'PRÓXIMO DESBLOQUEO: $name · NV. $level';
  }

  @override
  String shop_plan_required_body(String plan) {
    return 'Este objeto es exclusivo del plan $plan.';
  }

  @override
  String get gems_insufficient => 'GEMAS INSUFICIENTES';

  @override
  String get purchase_failed => 'NO SE PUDO COMPLETAR LA COMPRA';

  @override
  String level_label(String level) {
    return 'NV. $level';
  }

  @override
  String level_rewards_pending(int count) {
    return '$count RECOMPENSAS DE NIVEL';
  }

  @override
  String level_rewards_banner_hint(String level) {
    return 'NIVEL $level ALCANZADO · RECLAMA TU ORO';
  }

  @override
  String level_rewards_claim(int count) {
    return 'RECLAMAR $count';
  }

  @override
  String level_rewards_claimed_ok(int count) {
    return '¡$count RECOMPENSAS DE NIVEL RECLAMADAS!';
  }

  @override
  String get level_rewards_none => 'SIN RECOMPENSAS PENDIENTES';

  @override
  String get streak_freeze_title => 'FREEZE DE RACHA';

  @override
  String get streak_freeze_desc => 'Protege un día perdido. Máximo 3.';

  @override
  String get streak_freeze_cap => 'MÁXIMO DE FREEZES ALCANZADO';

  @override
  String get streak_freeze_max => 'AL MÁXIMO';

  @override
  String get streak_freeze_bought => '¡FREEZE DE RACHA ADQUIRIDO!';

  @override
  String get fragments_insufficient => 'FRAGMENTOS INSUFICIENTES ❌';

  @override
  String get redeem_error => 'ERROR EN EL CANJE ❌';

  @override
  String get fragments_exchange_title => 'CANJE DE FRAGMENTOS';

  @override
  String get fragments_exchange_desc =>
      'LOS FRAGMENTOS SON LA MONEDA DE CANJE. ELÍGELOS SABIAMENTE, CAZADOR.';

  @override
  String battle_reward_claimed_tier(int tier) {
    return 'RECOMPENSA TIER $tier RECLAMADA';
  }

  @override
  String get not_available => 'NO DISPONIBLE';

  @override
  String get battle_pass => 'BATTLE PASS';

  @override
  String get premium => 'PREMIUM';

  @override
  String get free_tier => 'GRATUITO';

  @override
  String battle_level(int level) {
    return 'NIVEL $level';
  }

  @override
  String get battle_progress_label => 'Progreso del Pase de Batalla: ';

  @override
  String get rewards => 'RECOMPENSAS';

  @override
  String reward_claimed_tier(int tier) {
    return 'Recompensa nivel $tier reclamada';
  }

  @override
  String reward_unlocked_tier(int tier) {
    return 'Recompensa nivel $tier desbloqueada';
  }

  @override
  String reward_locked_tier(int tier) {
    return 'Recompensa nivel $tier bloqueada, desbloquea en nivel $tier';
  }

  @override
  String battle_tier(int tier) {
    return 'TIER $tier';
  }

  @override
  String get reward_unlocked => 'Recompensa desbloqueada';

  @override
  String unlock_at_level(int tier) {
    return 'Desbloquea en nivel $tier';
  }

  @override
  String battle_claim_reward(int tier) {
    return 'Reclamar recompensa nivel $tier';
  }

  @override
  String get equipment_updated => 'EQUIPO ACTUALIZADO';

  @override
  String get inventory => 'INVENTARIO';

  @override
  String get unequip => 'QUITAR';

  @override
  String get equip => 'EQUIPAR';

  @override
  String get chat_category_all => 'Todos';

  @override
  String get chat_cat_general => 'General';

  @override
  String get chat_cat_travel => 'Viajes';

  @override
  String get chat_cat_business => 'Trabajo';

  @override
  String get chat_cat_technology => 'Tecnología';

  @override
  String get chat_cat_art => 'Arte';

  @override
  String get chat_cat_cooking => 'Cocina';

  @override
  String get chat_rank_status => 'ESTADO DE RANGO';

  @override
  String get chat_hunter_details => 'DETALLES DE CAZADOR';

  @override
  String chat_rank_level(String code) {
    return 'RANGO $code';
  }

  @override
  String get chat_establish_table => 'CREAR MESA DE GREMIO';

  @override
  String get chat_create_room => 'CREAR NUEVA SALA';

  @override
  String get chat_table_title => 'TÍTULO DE LA MESA';

  @override
  String get chat_category_path => 'CAMINO DE CATEGORÍA';

  @override
  String get chat_table_type => 'TIPO DE MESA';

  @override
  String get chat_missions => 'MISIONES';

  @override
  String get chat_guild_pass => 'PASE DEL GREMIO';

  @override
  String get chat_rank => 'RANGO';

  @override
  String get chat_collections => 'COLECCIONES';

  @override
  String get chat_music_on => 'MÚSICA ON';

  @override
  String get chat_music => 'MÚSICA';

  @override
  String get chat_status_full => 'LLENA';

  @override
  String get chat_status_nearly_full => 'CASI LLENA';

  @override
  String get chat_status_occupied => 'OCUPADA';

  @override
  String get chat_status_space => 'ESPACIO';

  @override
  String get chat_type_mentorship => 'MENTORÍA';

  @override
  String get chat_type_ai => 'IA';

  @override
  String get chat_type_event => 'EVENTO';

  @override
  String chat_rank_line(String rank, String cefr) {
    return 'RANGO: $rank · $cefr';
  }

  @override
  String get chat_free => 'LIBRE';

  @override
  String get chat_rank_silver => 'PLATA';

  @override
  String get chat_rank_gold => 'ORO';

  @override
  String get chat_rank_iron => 'HIERRO';

  @override
  String get voice_seat_to_speak => 'SIÉNTATE EN UNA SILLA PARA HABLAR';

  @override
  String voice_seated_in(String seat) {
    return 'TE SENTASTE EN LA SILLA $seat';
  }

  @override
  String get voice_seat_assigned => 'SILLA ASIGNADA. ¡Bienvenido!';

  @override
  String get voice_seats_full_queue => 'SILLAS LLENAS: ENTRAS EN COLA';

  @override
  String get voice_seat_freed => 'SILLA LIBERADA. DE PIE';

  @override
  String get voice_standing => 'CAZADOR PUESTO DE PIE';

  @override
  String get voice_not_moderator => 'NO ERES MODERADOR DE ESTA MESA';

  @override
  String get voice_chamber_chat => 'CHAT DE TEXTO DE LA SALA';

  @override
  String get voice_free_mission => 'MISIÓN LIBRE';

  @override
  String get voice_guild_chamber => 'SALA DE VOZ DEL GREMIO';

  @override
  String get voice_moderated => 'Sala de voz del gremio';

  @override
  String get voice_leave => 'Salir de la sala';

  @override
  String get voice_demo_banner =>
      'AUDIO DEL GREMIO: DEMO — cazadores conectados en vivo. La práctica de voz es 1:1.';

  @override
  String get voice_demo_banner_alt => 'AUDIO DEMO — TOCA PARA VER DETALLE';

  @override
  String get voice_room_mission => 'MISIÓN DE LA SALA';

  @override
  String get voice_resonance => 'RESONANCIA';

  @override
  String get voice_your_seat => 'TU SILLA';

  @override
  String voice_seat_number(String slot) {
    return 'SILLA $slot';
  }

  @override
  String get voice_tap_to_sit => 'TOCAR PARA SENTARSE';

  @override
  String get voice_you => 'TÚ';

  @override
  String voice_hunter_slot(String slot) {
    return 'HUNTER $slot';
  }

  @override
  String get voice_speaking => 'HABLANDO';

  @override
  String get voice_seated => 'SENTADO';

  @override
  String voice_standing_count(int count) {
    return 'DE PIE ($count/8)';
  }

  @override
  String get voice_you_standing => 'Tú (de pie)';

  @override
  String get voice_standing_hunter => 'Cazador de pie';

  @override
  String voice_chat_title(int count) {
    return 'Chat de la sala ($count)';
  }

  @override
  String get voice_mic_on => 'MIC ON';

  @override
  String get voice_mic_off => 'MIC OFF';

  @override
  String get voice_stand_up => 'LEVANTARSE';

  @override
  String voice_in_queue(int pos) {
    return 'EN COLA #$pos';
  }

  @override
  String get voice_seat => 'SILLA';

  @override
  String get voice_exit => 'SALIR';

  @override
  String get guild_rec_beginner =>
      'Recomiendo la Taberna del Aprendiz: es la mesa perfecta para cazadores novatos.';

  @override
  String get guild_rec_intermediate =>
      'La Mesa Redonda de Tácticas te espera: debates y fluidez intermedia.';

  @override
  String get guild_rec_master =>
      'El Consejo Supremo de Altos Cazadores es tu lugar: elocuencia de nivel maestro.';

  @override
  String get guild_rec_default =>
      'Elige una mesa y comienza tu raid de conversación.';

  @override
  String get guild_table_beginner => 'Aprendiz';

  @override
  String get guild_table_tactics => 'Tácticas';

  @override
  String get guild_table_council => 'Consejo';

  @override
  String guild_rank_level(String cefr) {
    return 'RANGO $cefr';
  }

  @override
  String get guild_follow_suggestion => 'SIGUE MI SUGERENCIA —>';

  @override
  String guild_ask_master(String cefr) {
    return 'Consulta al Maestre (Nivel $cefr):';
  }

  @override
  String get guild_ask_hint =>
      'Pregúntame qué mesa practicar, qué misión tomar o cómo mejorar tu rango.';

  @override
  String get guild_input_hint => 'Escribe tu pregunta...';

  @override
  String get guild_meditating =>
      'El Maestre de Mesa está meditando... Inténtalo de nuevo.';

  @override
  String get mission_board_title => 'TABLÓN DE MISIONES';

  @override
  String mission_board_player_rank(String playerRank) {
    return 'AVENTURERO · RANGO $playerRank';
  }

  @override
  String get mission_completed_active => '✓ CUMPLIDAS';

  @override
  String get mission_completed => 'CUMPLIDAS';

  @override
  String get mission_filter_all => 'TODAS';

  @override
  String get mission_filter_daily => 'DIARIAS';

  @override
  String get mission_filter_weekly => 'SEMANALES';

  @override
  String get mission_filter_collaborative => 'COLABORATIVAS';

  @override
  String get mission_filter_rarity_all => 'RARO: TODAS';

  @override
  String get mission_search_hint => 'Buscar misión por nombre...';

  @override
  String get mission_board_empty_filtered =>
      'No hay misiones del gremio con estos filtros.';

  @override
  String mission_view_more(int count) {
    return 'VER MÁS MISIONES ($count restantes)';
  }

  @override
  String get mission_completed_empty =>
      'Aún no has completado misiones del gremio.';

  @override
  String get mission_login_required => 'Inicia sesión para aceptar misiones.';

  @override
  String mission_insufficient_rank(String rank) {
    return '🔒 RANGO INSUFICIENTE: necesitas rango $rank.';
  }

  @override
  String mission_accept_success(String title) {
    return '✅ Misión aceptada: $title';
  }

  @override
  String get mission_accept_failed =>
      'No se pudo aceptar (cuota llena o rango insuficiente).';

  @override
  String get mission_high_rank_title => 'MISIÓN DE ALTO RANGO';

  @override
  String mission_high_rank_confirm(String title, String rank) {
    return '¿Seguro que deseas emprender \"$title\" (rango $rank)? Es una misión de élite del gremio.';
  }

  @override
  String mission_reward_earned(int xp, int gems) {
    return '+$xp XP  ·  +$gems 💎';
  }

  @override
  String get mission_claim_failed => 'No se pudo cobrar la recompensa.';

  @override
  String get mission_npc_collaborative => 'Maestre de Mesa · GreMio';

  @override
  String get mission_npc_vocabulary => 'Bibliotecaria del Gremio';

  @override
  String get mission_npc_writing => 'Escriba Real';

  @override
  String get mission_npc_argumentation => 'Cónsul del Debate';

  @override
  String get mission_npc_default => 'Maestre de Mesa';

  @override
  String get mission_difficulty_unknown => 'Desconocida';

  @override
  String mission_difficulty_label(String rank) {
    return 'Rango $rank';
  }

  @override
  String get mission_time_daily => '~10-15 min';

  @override
  String get mission_time_weekly => '~45-60 min';

  @override
  String get mission_time_collaborative => '~30 min';

  @override
  String get mission_time_default => '~20 min';

  @override
  String get mission_load_error => 'No se pudo cargar la misión.';

  @override
  String get mission_not_found => 'Misión no encontrada.';

  @override
  String get mission_detail_title => 'DETALLE DE MISIÓN';

  @override
  String mission_rarity_type_label(String rarity, String type) {
    return '$rarity · $type';
  }

  @override
  String get mission_section_description => 'DESCRIPCIÓN';

  @override
  String get mission_npc_label => 'NPC';

  @override
  String get mission_stat_level => 'NIVEL';

  @override
  String get mission_stat_xp => 'XP';

  @override
  String get mission_stat_gold => 'ORO';

  @override
  String get mission_stat_time => 'TIEMPO';

  @override
  String get mission_stat_objective => 'OBJETIVO';

  @override
  String get mission_section_objectives => 'OBJETIVOS';

  @override
  String mission_objectives_goal(int target, String objectiveType) {
    return 'Completa $target de $objectiveType.';
  }

  @override
  String get mission_claiming => 'COBRANDO...';

  @override
  String get mission_in_progress_chat => 'EN PROGRESO · IR AL CHAT';

  @override
  String get mission_reject => 'RECHAZAR';

  @override
  String mission_rank_required(String rank) {
    return 'RANGO $rank REQUERIDO';
  }

  @override
  String get mission_rarity_common => 'COMÚN';

  @override
  String get mission_rarity_uncommon => 'POCO COMÚN';

  @override
  String get mission_rarity_rare => 'RARO';

  @override
  String get mission_rarity_epic => 'ÉPICO';

  @override
  String get mission_rarity_legendary => 'LEGENDARIO';

  @override
  String get mission_rarity_guild => 'ESPECIAL DEL GREMIO';

  @override
  String get mission_status_available => 'DISPONIBLE';

  @override
  String get mission_status_accepted => 'ACEPTADA';

  @override
  String get mission_status_in_progress => 'EN PROGRESO';

  @override
  String get mission_status_completed => 'COMPLETADA';

  @override
  String get mission_status_repeatable => 'REPETIBLE';

  @override
  String get mission_status_blocked => 'BLOQUEADA';

  @override
  String get mission_status_recommended => 'RECOMENDADA';

  @override
  String get mission_status_special => 'ESPECIAL';

  @override
  String get session_title => 'Resumen';

  @override
  String get summary_reward_gold => 'ORO';

  @override
  String get summary_reward_fragments => 'FRAGMENTOS';

  @override
  String get summary_reward_pending =>
      'No pudimos confirmar tu recompensa. Tu progreso está guardado; se actualizará al volver a cargar.';

  @override
  String get session_completed => 'SESIÓN COMPLETADA';

  @override
  String get session_good_job => '¡Buen trabajo!';

  @override
  String session_words_spoken(int count) {
    return 'Hablaste $count palabras con buen ritmo.';
  }

  @override
  String get summary_remedial_title => 'REFUERZO';

  @override
  String get summary_remedial_generated =>
      'Creamos una lección con tus errores recurrentes y las metas que no cumpliste.';

  @override
  String get summary_remedial_reused => 'Tu lección de refuerzo está lista.';

  @override
  String get summary_remedial_play => 'PRACTICAR MIS DEBILIDADES';

  @override
  String get summary_remedial_no_evidence =>
      'Todavía no hay lección de refuerzo: necesitamos errores registrados o una meta fallada para orientarla.';

  @override
  String get summary_remedial_insufficient_mana =>
      'No tienes maná suficiente para una lección de refuerzo. Estará disponible cuando renueve tu saldo.';

  @override
  String get summary_remedial_failed =>
      'No pudimos crear la lección de refuerzo. Te devolvimos el maná.';

  @override
  String summary_remedial_cost(int cost) {
    return 'Coste: $cost de maná';
  }

  @override
  String get summary_remedial_retry => 'REINTENTAR';

  @override
  String get session_ready => 'Práctica lista para iniciar.';

  @override
  String get session_excellent_performance => '¡Excelente desempeño!';

  @override
  String get session_ready_first => '¡Listo para tu primera sesión!';

  @override
  String get session_duration => 'DURACIÓN';

  @override
  String get session_words => 'PALABRAS';

  @override
  String get session_accuracy => 'PRECISIÓN (EST.)';

  @override
  String get session_fluency => 'Fluidez (est.)';

  @override
  String get session_pronunciation => 'Pronunciación';

  @override
  String get session_feedback => 'Retroalimentación';

  @override
  String get session_no_errors =>
      'No se registraron errores de gramática o fonética.';

  @override
  String get session_talk_tutor =>
      'Habla con el tutor IA para obtener retroalimentación.';

  @override
  String get session_performance => 'Desempeño';

  @override
  String get session_excellent => 'Excelente';

  @override
  String get session_correction => 'Corrección';

  @override
  String get session_grammar => 'Gramática';

  @override
  String get session_bonus => 'Bono Sesión';

  @override
  String get session_maintained => 'Mantenida';

  @override
  String get summary_learned_title => 'QUÉ APRENDISTE';

  @override
  String get summary_learned_words => 'PALABRAS NUEVAS Y REPASADAS';

  @override
  String get summary_learned_word_new => 'NUEVA';

  @override
  String get summary_learned_word_review => 'REPASO';

  @override
  String get summary_learned_no_words =>
      'Todavía no hay vocabulario registrado en esta sesión.';

  @override
  String get summary_learned_corrections => 'CORRECCIONES';

  @override
  String get summary_learned_no_corrections =>
      'Sin correcciones: esta vez te comunicaste con claridad.';

  @override
  String get summary_learned_focus => 'FOCO RECOMENDADO';

  @override
  String get summary_learned_no_focus =>
      'Aún no hay datos suficientes para recomendarte un foco.';

  @override
  String get summary_learned_loading => 'Cargando los datos de tu sesión...';

  @override
  String get summary_learned_error =>
      'No pudimos cargar lo que aprendiste. Revisa tu conexión y reintenta.';

  @override
  String summary_learned_minutes_value(int count) {
    return '$count min';
  }

  @override
  String get summary_goals => 'METAS';

  @override
  String get summary_turns => 'TURNOS';

  @override
  String summary_turns_value(int count) {
    return '$count turnos';
  }

  @override
  String get summary_reward_loading => 'Confirmando tu recompensa...';

  @override
  String get summary_reward_error =>
      'No pudimos confirmar tu recompensa. Revisa tu conexión y reintenta.';

  @override
  String get summary_retry => 'REINTENTAR';

  @override
  String get summary_review_words => 'REPASAR PALABRAS';

  @override
  String get profile_status_panel => 'PANEL DE ESTADO';

  @override
  String get profile_hunter_window => 'VENTANA DE ESTADO DEL CAZADOR';

  @override
  String profile_learning(String language, String emoji) {
    return 'Aprendiendo $language $emoji';
  }

  @override
  String get profile_weekly_minutes => 'Minutos de Práctica Semanal';

  @override
  String get profile_vocab_learned => 'Vocabulario Aprendido';

  @override
  String get profile_explore => 'Explorar';

  @override
  String get profile_learn => 'Aprender';

  @override
  String get profile_title => 'Perfil';

  @override
  String get quest_daily_title => 'Misiones Diarias';

  @override
  String quest_claimed(int xp) {
    return '¡Recompensa canjeada! +$xp XP';
  }

  @override
  String get quest_empty => 'No hay misiones diarias activas por ahora.';

  @override
  String get quest_speak_10min => 'Habla 10 minutos de voz';

  @override
  String get quest_desc_session => 'Completa una sesión conversacional fluida';

  @override
  String get quest_learn_5_words => 'Aprende 5 palabras nuevas';

  @override
  String get quest_desc_vocab => 'Acumula vocabulario en tus llamadas';

  @override
  String get quest_85_pronunciation => 'Logra >85% en Pronunciación';

  @override
  String get quest_desc_pronunciation => 'Supera una prueba de huella de voz';

  @override
  String get missions_title => 'Misiones';

  @override
  String get missions_tab_daily => 'Diarias';

  @override
  String get missions_tab_weekly => 'Semanales';

  @override
  String get missions_spotlight => 'MISIÓN DEL DÍA';

  @override
  String get missions_see_all => 'VER TODAS';

  @override
  String get missions_reset_hint => 'Renovación automática: 00:05 UTC';

  @override
  String get missions_empty_daily =>
      'Aún no tienes misiones diarias. Llegan cada día a las 00:05 UTC.';

  @override
  String get missions_empty_weekly =>
      'Aún no tienes misiones semanales. Se asignan con el ciclo diario de 00:05 UTC.';

  @override
  String get missions_unavailable => 'No disponible';

  @override
  String get missions_unavailable_hint =>
      'Esta misión no se puede completar con el seguimiento actual.';

  @override
  String missions_claim_xp(int xp) {
    return 'Reclamar +$xp XP';
  }

  @override
  String missions_claim_success(int xp, int gems) {
    return 'Recompensa reclamada: +$xp XP · +$gems gemas';
  }

  @override
  String get missions_claim_already => 'Ya reclamaste esta recompensa.';

  @override
  String get missions_claim_error =>
      'No pudimos reclamar la recompensa. Revisa tu conexión e inténtalo de nuevo.';

  @override
  String get missions_load_error =>
      'No pudimos cargar tus misiones. Toca para reintentar.';

  @override
  String get missions_retry => 'REINTENTAR';

  @override
  String get missions_unit_minutes => 'min';

  @override
  String get missions_unit_turns => 'turnos';

  @override
  String get missions_unit_words => 'palabras';

  @override
  String get missions_unit_sessions => 'sesiones';

  @override
  String get league_level_title => 'Liga de Nivel';

  @override
  String get league_you => 'Tú (Estudiante)';

  @override
  String league_ranking(String league) {
    return 'Clasificación $league';
  }

  @override
  String league_top5(String level) {
    return 'Top 5 · Nivel $level';
  }

  @override
  String get recommended_title => 'Centro de descubrimiento';

  @override
  String get recommended_desc =>
      'Lecciones personalizadas según tu nivel, intereses y metas del onboarding';

  @override
  String get recommended_search_hint => 'Busca lección, rol o tema...';

  @override
  String get recommended_cat_all => 'Todo';

  @override
  String get recommended_cat_tech => 'Tecnología';

  @override
  String get recommended_cat_business => 'Negocios';

  @override
  String get recommended_cat_travel => 'Viajes';

  @override
  String get recommended_cat_social => 'Social';

  @override
  String get recommended_cat_food => 'Comida';

  @override
  String get recommended_all_levels => 'Todos los niveles';

  @override
  String recommended_level(String lvl) {
    return 'Nivel $lvl';
  }

  @override
  String recommended_catalog(int count) {
    return 'Catálogo personalizado ($count)';
  }

  @override
  String recommended_suggested_level(String cefr) {
    return 'Nivel sugerido: $cefr';
  }

  @override
  String get recommended_hero_match =>
      '100 % de coincidencia con tu meta profesional e interés en Tecnología';

  @override
  String recommended_filter(String cefr) {
    return 'Filtro: $cefr';
  }

  @override
  String get recommended_empty =>
      'No hay lecciones con los filtros seleccionados.';

  @override
  String recommended_lesson_level(String level) {
    return 'NIVEL $level';
  }

  @override
  String get recommended_locked_hint =>
      'Completa la lección anterior de tu ruta para desbloquearla.';

  @override
  String get recommended_blocked => 'Bloqueada';

  @override
  String get recommended_review => 'Repasar';

  @override
  String get recommended_speak => 'Hablar';

  @override
  String get path_roadmap_title => 'MAPA DE MAZMORRAS';

  @override
  String get path_stage_empty =>
      'Aún no hay lecciones registradas en esta etapa.';

  @override
  String get profile_edit_photo_ok => 'FOTO SUBIDA CORRECTAMENTE';

  @override
  String get profile_edit_choose_photo => 'ELEGIR FOTO PERSONALIZADA';

  @override
  String get profile_edit_license_registry => 'REGISTRO DE LICENCIA DE CAZADOR';

  @override
  String get profile_edit_hunter_name => 'NOMBRE DE CAZADOR';

  @override
  String profile_edit_class_path(String path) {
    return 'RUTA DE CLASE: $path';
  }

  @override
  String get profile_edit_select_class => 'SELECCIONAR RUTA DE CLASE';

  @override
  String get profile_edit_stat_allocation =>
      'ASIGNACIÓN DE PUNTOS DE ESTADÍSTICA';

  @override
  String profile_edit_stat_pool(int points) {
    return 'RESERVA: $points PT';
  }

  @override
  String get profile_edit_full_name => 'NOMBRE COMPLETO DEL CAZADOR';

  @override
  String get profile_edit_name_empty => 'EL NOMBRE NO PUEDE ESTAR VACÍO';

  @override
  String get profile_edit_memoir => 'MEMORIAS / OBJETIVOS';

  @override
  String get profile_edit_license_updated => 'REGISTRO DE LICENCIA ACTUALIZADO';

  @override
  String get profile_edit_save => 'GUARDAR REGISTRO DE LICENCIA';

  @override
  String get profile_edit_class_warrior => 'GUERRERO';

  @override
  String get profile_edit_class_warrior_desc => 'Fuerza física y defensa alta';

  @override
  String get profile_edit_class_mage => 'MAGO';

  @override
  String get profile_edit_class_mage_desc =>
      'Lanzamiento de hechizos y manipulación de maná';

  @override
  String get profile_edit_class_assassin => 'ASESINO';

  @override
  String get profile_edit_class_assassin_desc =>
      'Sigilo, velocidad y golpes críticos';

  @override
  String get profile_edit_class_necromancer => 'NIGROMANTE';

  @override
  String get profile_edit_class_necromancer_desc =>
      'Invocación de muertos y magia oscura';

  @override
  String get profile_edit_class_priest => 'SACERDOTE';

  @override
  String get profile_edit_class_priest_desc =>
      'Curación, mejoras y luz sagrada';

  @override
  String get profile_edit_stat_str_desc => 'Fuerza y potencia muscular';

  @override
  String get profile_edit_stat_int_desc =>
      'Lanzamiento de hechizos y velocidad de análisis';

  @override
  String get profile_edit_stat_dex_desc => 'Agilidad y ritmo de respuesta';

  @override
  String get profile_edit_stat_luk_desc => 'Evitación de correcciones críticas';

  @override
  String get convo_mission_guide => 'Guía y contexto de la misión';

  @override
  String get convo_practice_title => 'Práctica de conversación';

  @override
  String convo_objective(String objective) {
    return 'Objetivo: $objective';
  }

  @override
  String get convo_select_goals =>
      'Selecciona una lección para ver sus objetivos.';

  @override
  String get convo_select_phrases =>
      'Selecciona una lección para ver las frases clave sugeridas.';

  @override
  String get convo_voice_print => 'Huella de voz y pronunciación';

  @override
  String get convo_phonetic_clarity => 'Claridad fonética';

  @override
  String get convo_speech_speed => 'Velocidad del habla';

  @override
  String get convo_words_spoken => 'Palabras dichas';

  @override
  String get convo_cefr_level => 'Nivel CEFR';

  @override
  String get convo_hidden_chat => 'Chat oculto (4.ª/5.ª estrella)';

  @override
  String get convo_visible_chat => 'Chat visible';

  @override
  String get convo_write_mode => 'Modo escritura';

  @override
  String get convo_voice_mode => 'Modo voz';

  @override
  String get convo_input_hint => 'Escribe tu mensaje en inglés...';

  @override
  String get convo_continue => 'CONTINUAR';

  @override
  String get convo_oracle_evaluating =>
      'EL ORÁCULO ESTÁ EVALUANDO TU CONVERSACIÓN...';

  @override
  String get convo_analyzing_level => 'Analizando tu nivel de comunicación...';

  @override
  String get convo_status_listening => 'Escuchando…';

  @override
  String get convo_status_thinking => 'Pensando…';

  @override
  String get convo_status_speaking => 'El tutor está hablando';

  @override
  String get convo_stop_tutor => 'Detener';

  @override
  String get convo_tts_title => 'Voz del tutor';

  @override
  String get convo_tts_speed => 'Velocidad';

  @override
  String get convo_tts_voice => 'Voz';

  @override
  String get convo_tts_default_voice => 'Voz del sistema';

  @override
  String get convo_tts_no_voices =>
      'No se encontraron voces en inglés. Instala una en Ajustes de Android > Idiomas.';

  @override
  String get convo_mic_denied_title => 'Micrófono bloqueado';

  @override
  String get convo_mic_denied_body =>
      'Dungeon of English necesita el micrófono para escucharte. Actívalo en los ajustes de Android y vuelve a intentarlo.';

  @override
  String get convo_mic_open_settings => 'Abrir ajustes';

  @override
  String get convo_mic_retry => 'Reintentar';

  @override
  String get convo_mic_manual_hint =>
      'Abre Ajustes > Apps > Dungeon of English > Permisos > Micrófono.';

  @override
  String get convo_help_title => 'Necesito ayuda';

  @override
  String get convo_help_hint =>
      'Toca una frase para enviarla como tu respuesta.';

  @override
  String get convo_help_empty =>
      'Este escenario todavía no tiene frases de ayuda. Escribe tu respuesta o cambia de tema.';

  @override
  String get settings_system_config => 'CONFIGURACIÓN DEL SISTEMA';

  @override
  String get settings_target_cefr => 'IDIOMA OBJETIVO Y NIVEL CEFR';

  @override
  String get settings_language => 'IDIOMA';

  @override
  String get settings_ai_parameters => 'PARÁMETROS DEL TUTOR IA';

  @override
  String get settings_audio_comms => 'AUDIO Y COMUNICACIONES';

  @override
  String get settings_account => 'CUENTA';

  @override
  String get settings_export_data => 'EXPORTAR MIS DATOS';

  @override
  String get settings_export_copied => 'Tus datos se copiaron al portapapeles.';

  @override
  String get settings_delete_account => 'ELIMINAR MI CUENTA';

  @override
  String get settings_delete_confirm_title => '¿Eliminar tu cuenta?';

  @override
  String get settings_delete_confirm_body =>
      'Esto borra tu cuenta y tu progreso de forma permanente. No se puede deshacer.';

  @override
  String get settings_aligned => 'CONFIGURACIÓN ALINEADA';

  @override
  String get settings_save => 'GUARDAR CONFIGURACIÓN';

  @override
  String get settings_target_language => 'IDIOMA OBJETIVO';

  @override
  String get settings_cefr_practice => 'NIVEL DE PRÁCTICA CEFR';

  @override
  String get settings_logout_dungeon => 'SALIR DE LA MAZMORRA';

  @override
  String get settings_select_path => 'SELECCIONAR RUTA OBJETIVO';

  @override
  String get settings_select_cefr => 'SELECCIONAR RUTA DE NIVEL CEFR';

  @override
  String get settings_correction_scope => 'ALCANCE DE CORRECCIÓN IA';

  @override
  String get settings_tutor_personality => 'PERSONALIDAD DEL TUTOR';

  @override
  String get settings_correction_cadence => 'CADENCIA DE CORRECCIÓN';

  @override
  String get settings_quest_focus => 'ENFOQUE DE MISIÓN DIARIA';

  @override
  String get settings_sfx_channels => 'CANALES DE EFECTOS DE AUDIO';

  @override
  String get settings_alerts => 'AVISOS DIARIOS';

  @override
  String get settings_alert_time => 'HORA DE ENVÍO DE AVISOS';

  @override
  String get settings_select_correction => 'SELECCIONAR NIVEL DE CORRECCIÓN';

  @override
  String get settings_select_personality =>
      'SELECCIONAR PERSONALIDAD DEL TUTOR';

  @override
  String get settings_select_cadence => 'SELECCIONAR CADENCIA DE CORRECCIÓN';

  @override
  String get settings_select_quest => 'SELECCIONAR ENFOQUE DE MISIÓN DIARIA';

  @override
  String get settings_follow_device => 'USAR IDIOMA DEL DISPOSITIVO';

  @override
  String get settings_force_onboarding => 'Forzar onboarding continuo';

  @override
  String get settings_dev_desc =>
      'Modo desarrollador. No bloquea la app: solo afecta al onboarding cuando aún no hay perfil. Usa «Reiniciar historial» para volver a probarlo.';

  @override
  String get settings_profile_deleted =>
      'Perfil de cazador eliminado. Reiniciando...';

  @override
  String get settings_reset_onboarding => 'REINICIAR HISTORIAL DEL ONBOARDING';

  @override
  String onboarding_device_lang(String lang) {
    return 'Hemos detectado que tu dispositivo usa $lang. La app se mostrará en ese idioma.';
  }

  @override
  String get privacy_title => 'PRIVACIDAD';

  @override
  String get privacy_body =>
      'Para corregir tu conversación, la app envía a la IA el audio transcrito, tu nivel CEFR y tu idioma nativo. No se envían tu email, tu nombre ni tu foto. Puedes exportar o borrar tus datos desde Ajustes. También guardamos métricas de uso agregadas (progreso, retención y errores) sin texto de conversación ni datos personales.';

  @override
  String get privacy_accept => 'ENTENDIDO';

  @override
  String get onboarding_privacy_link => 'PRIVACIDAD';

  @override
  String get onboarding_beginner => 'SOY PRINCIPIANTE ABSOLUTO (PRE-A1)';

  @override
  String get onboarding_beginner_desc =>
      'Todavía no formo frases: solo palabras sueltas y vocabulario mínimo. Empezarás en Fundamentos sin examen.';

  @override
  String get hunter_equip_title => 'EQUIPAR TÍTULO';

  @override
  String get hunter_skill_titles => 'TÍTULOS DE HABILIDAD';

  @override
  String hunter_cefr_xp(String code, int xp) {
    return 'CEFR $code · $xp XP';
  }

  @override
  String get hunter_equipped_title => 'TÍTULO EQUIPADO';

  @override
  String get hunter_equip => 'EQUIPAR';

  @override
  String get hunter_fluency_analysis => 'ANÁLISIS DE FLUIDEZ';

  @override
  String get hunter_holographic_radar => 'RADAR HOLOGRÁFICO';

  @override
  String get hunter_practice_consistency => 'CONSISTENCIA DE PRÁCTICA';

  @override
  String hunter_points_pool(int points) {
    return 'PUNTOS DISPONIBLES: $points';
  }

  @override
  String get hunter_str => 'FUE (FUERZA)';

  @override
  String get hunter_luk => 'SUE (SUERTE)';

  @override
  String get hunter_distribute_points => 'DISTRIBUIR PUNTOS';

  @override
  String get hunter_no_title => 'SIN TÍTULO';

  @override
  String get hunter_max_level => 'NIVEL MÁXIMO ALCANZADO';

  @override
  String get dungeon_choose_portal => 'ELIGE UN PORTAL SEGÚN TU RANGO';

  @override
  String dungeon_current_portal(String level) {
    return 'PORTAL ACTUAL · NIVEL $level';
  }

  @override
  String dungeon_level(Object level) {
    return 'NIVEL $level';
  }

  @override
  String get progress_edit_profile => 'Editar perfil';

  @override
  String get progress_hunter_status => 'Estado del cazador';

  @override
  String progress_streak_hint(int streak, String days) {
    return 'Practica hoy para mantener tu racha de $streak días $days';
  }

  @override
  String get progress_practice => 'PRACTICAR';

  @override
  String get settings_haptics => 'VIBRACIÓN';

  @override
  String get settings_haptics_desc =>
      'Vibra al cumplir la meta y al subir de nivel';

  @override
  String get settings_sounds => 'SONIDOS';

  @override
  String get settings_sounds_desc => 'Sonido del sistema en las celebraciones';

  @override
  String get welcome_back_title => 'BIENVENIDO DE VUELTA';

  @override
  String welcome_back_days(int days) {
    return '$days días sin entrenar';
  }

  @override
  String welcome_back_lesson(String lesson) {
    return 'Te quedaste en $lesson';
  }

  @override
  String welcome_back_goals(int count) {
    return 'Te faltan $count metas';
  }

  @override
  String get welcome_back_completed =>
      'La completaste. Puedes repetirla o seguir con la siguiente.';

  @override
  String get welcome_back_streak_reset => 'Empecemos una racha nueva hoy.';

  @override
  String get welcome_back_continue => 'CONTINUAR';

  @override
  String get welcome_back_later => 'Ahora no';

  @override
  String get radar_estimated_tooltip => 'Estimación basada en tu conversación';

  @override
  String get radar_estimated_note => 'Estimación basada en tu conversación';

  @override
  String get radar_pronunciation_unmeasured =>
      'Pronunciación: sin medición real todavía';

  @override
  String get band_low => 'Bajo';

  @override
  String get band_medium => 'Medio';

  @override
  String get band_high => 'Alto';

  @override
  String mana_cost_per_turn(int cost) {
    return '$cost/turno';
  }

  @override
  String mana_low_warning(int count) {
    return 'Te quedan $count turnos hoy';
  }

  @override
  String get mana_empty_warning => 'Sin maná para el próximo turno';

  @override
  String get guardian_alternative_title => 'MIENTRAS TANTO';

  @override
  String guardian_refill_in(int hours, int minutes) {
    return 'Se recarga en $hours h $minutes min';
  }

  @override
  String guardian_refill_at(String date) {
    return 'Renueva el $date';
  }

  @override
  String get guardian_review_vocab => 'Repasar vocabulario (gratis)';

  @override
  String guardian_low_cost_chat(int cost) {
    return 'Chat de texto ($cost de maná)';
  }

  @override
  String get guardian_no_due_words =>
      'No hay palabras pendientes de repaso ahora.';

  @override
  String get daily_goal_title => 'META DIARIA';

  @override
  String daily_goal_minutes(int done, int goal) {
    return '$done / $goal min';
  }

  @override
  String daily_goal_remaining(int minutes) {
    return 'Faltan $minutes min';
  }

  @override
  String get daily_goal_done => 'Meta cumplida';

  @override
  String daily_goal_streak(int days) {
    return 'Racha $days d';
  }

  @override
  String get daily_goal_celebrate => '¡META CUMPLIDA!';

  @override
  String get evidence_title => 'EVIDENCIA DE APRENDIZAJE';

  @override
  String get evidence_disclaimer => 'Evidencia, no una nota.';

  @override
  String get evidence_retention => 'Retención a 7 días';

  @override
  String get evidence_progress => 'Progreso comparable';

  @override
  String get evidence_transfer => 'Transferencia';

  @override
  String get evidence_no_data => 'Aún sin datos';

  @override
  String get evidence_needs_weeks => 'Necesitas 4 semanas';

  @override
  String evidence_progress_value(int first, int last) {
    return '$first → $last misiones/semana';
  }

  @override
  String evidence_transfer_value(int types) {
    return '$types tipos de misión';
  }

  @override
  String get progress_streak_at_risk => '¡RACHA EN PELIGRO!';

  @override
  String get progress_hunter_desc =>
      'Consulta la matriz de 11 atributos, los títulos equipados y el radar de poder';

  @override
  String get progress_weekly_voice => 'Práctica semanal (minutos de voz)';

  @override
  String progress_vocab_learned(int count) {
    return 'Vocabulario aprendido ($count)';
  }

  @override
  String get progress_vocab_empty =>
      'Aún no has acumulado vocabulario en llamadas de voz.';

  @override
  String get progress_vocab_section => 'Vocabulario';

  @override
  String get progress_hunter_attributes => 'ATRIBUTOS DEL CAZADOR';

  @override
  String get progress_xp_rank => 'Rango de XP';

  @override
  String get settings_opt_sfx_desc =>
      'Efectos de combate, cargas de maná y calibración de nivel';

  @override
  String get settings_opt_strict_title => 'ACCIÓN ESTRICTA';

  @override
  String get settings_opt_strict_desc =>
      'La IA solo corregirá rupturas estructurales críticas.';

  @override
  String get settings_opt_compact_title => 'FEEDBACK COMPACTO';

  @override
  String get settings_opt_compact_desc =>
      'Correcciones rápidas con anotaciones de una línea.';

  @override
  String get settings_opt_moderate_title => 'EXPLICACIÓN MODERADA';

  @override
  String get settings_opt_moderate_desc =>
      'Correcciones equilibradas con 1 a 3 frases de detalle.';

  @override
  String get settings_opt_detailed_title => 'DESGLOSE DETALLADO';

  @override
  String get settings_opt_detailed_desc =>
      'Planos gramaticales detallados con ejemplos contextuales.';

  @override
  String get settings_opt_oracle_title => 'MODO MAESTRO DEL ORÁCULO';

  @override
  String get settings_opt_oracle_desc => 'Análisis completo de los errores.';

  @override
  String get settings_opt_companion_title => 'RITMO COMPAÑERO';

  @override
  String get settings_opt_companion_desc =>
      'Respuestas pacientes, cálidas y de apoyo.';

  @override
  String get settings_opt_commander_title => 'INFORME DEL COMANDANTE';

  @override
  String get settings_opt_commander_desc =>
      'Formal, muy estructurado y con correcciones ordenadas.';

  @override
  String get settings_opt_boss_title => 'DESAFÍO CALIBRE JEFE';

  @override
  String get settings_opt_boss_desc =>
      'Vocabulario de alto nivel y respuestas estrictas.';

  @override
  String get settings_opt_strict_style_title => 'ACCIÓN ESTRICTA';

  @override
  String get settings_opt_strict_style_desc =>
      'Interrumpe y corrige los errores al instante.';

  @override
  String get settings_opt_balanced_title => 'BRÚJULA EQUILIBRADA';

  @override
  String get settings_opt_balanced_desc =>
      'Mantiene el ritmo del diálogo con correcciones estructuradas.';

  @override
  String get settings_opt_immersive_title => 'INCURSIONES INMERSIVAS';

  @override
  String get settings_opt_immersive_desc =>
      'Mantiene el flujo del habla; corrige solo cortes graves.';

  @override
  String get settings_opt_casual_title => 'INCURSIÓN CASUAL (10 MIN)';

  @override
  String get settings_opt_casual_desc => 'Práctica diaria de entrada rápida.';

  @override
  String get settings_opt_regular_title => 'INCURSIÓN REGULAR (15 MIN)';

  @override
  String get settings_opt_regular_desc => 'Ritmo de aprendizaje sólido.';

  @override
  String get settings_opt_serious_title => 'CAMPAÑA SERIA (30 MIN)';

  @override
  String get settings_opt_serious_desc =>
      'Adquiere marcadores de fluidez con rapidez.';

  @override
  String get settings_opt_overload_title => 'SOBRECARGA (60 MIN)';

  @override
  String get settings_opt_overload_desc => 'Inmersión total a máxima potencia.';

  @override
  String get hunter_title_orco_caverna_f => 'Escritura de Orco de Caverna';

  @override
  String get hunter_title_orco_caverna_f_desc =>
      'Primeros pasos cometiendo errores con valentía.';

  @override
  String get hunter_title_escriba_novato_e => 'Escriba Novato';

  @override
  String get hunter_title_escriba_novato_e_desc => '50% de oraciones limpias.';

  @override
  String get hunter_title_escriba_ciudad_d => 'Escriba de la Ciudad';

  @override
  String get hunter_title_escriba_ciudad_d_desc =>
      '65% de precisión gramatical.';

  @override
  String get hunter_title_escriba_imperial_c =>
      'Escriba de la Biblioteca Imperial';

  @override
  String get hunter_title_escriba_imperial_c_desc =>
      '75% de precisión gramatical.';

  @override
  String get hunter_title_pluma_erudito_b => 'Pluma del Erudito Real';

  @override
  String get hunter_title_pluma_erudito_b_desc =>
      '85% de precisión gramatical.';

  @override
  String get hunter_title_pluma_archimago_a => 'Pluma Arcanista del Archimago';

  @override
  String get hunter_title_pluma_archimago_a_desc =>
      '92% de precisión gramatical.';

  @override
  String get hunter_title_pluma_celestial_s => 'Pluma Celestial del Sabio';

  @override
  String get hunter_title_pluma_celestial_s_desc =>
      '97% de precisión gramatical.';

  @override
  String get hunter_title_monarca_sintaxis_ss =>
      'Monarca de la Sintaxis Sagrada';

  @override
  String get hunter_title_monarca_sintaxis_ss_desc =>
      '99% de precisión gramatical.';

  @override
  String get hunter_title_creador_abismo_sss =>
      'Creador de Lenguajes del Abismo';

  @override
  String get hunter_title_creador_abismo_sss_desc =>
      '100% de precisión gramatical impecable.';

  @override
  String get hunter_title_murcielago_ciego_f => 'Murciélago Ciego';

  @override
  String get hunter_title_murcielago_ciego_f_desc =>
      'Escuchas iniciales con chat de texto.';

  @override
  String get hunter_title_oido_halcon_novato_d => 'Oído de Halcón Novato';

  @override
  String get hunter_title_oido_halcon_novato_d_desc => '2 lecciones sin chat.';

  @override
  String get hunter_title_oido_halcon_abismo_c => 'Oído de Halcón del Abismo';

  @override
  String get hunter_title_oido_halcon_abismo_c_desc =>
      '4 lecciones superadas a ciegas.';

  @override
  String get hunter_title_sonar_monarca_sombras_s =>
      'Sonar Absoluto del Monarca de las Sombras';

  @override
  String get hunter_title_sonar_monarca_sombras_s_desc =>
      '16 lecciones superadas a ciegas.';

  @override
  String get hunter_title_oidor_susurros_sss =>
      'Oidor de los Susurros del Universo';

  @override
  String get hunter_title_oidor_susurros_sss_desc =>
      'Más de 30 lecciones pasadas a ciegas.';

  @override
  String get hunter_title_monarca_impecable_5star =>
      'Monarca Impecable de la Perfección';

  @override
  String get hunter_title_monarca_impecable_5star_desc =>
      'Otorgado por lograr la 5ª Estrella Mítica (0 errores a ciegas).';

  @override
  String get skill_fluidez_1 => 'Aprendiz de Palabras';

  @override
  String get skill_fluidez_1_desc => 'Empiezas a expresarte con continuidad.';

  @override
  String get skill_fluidez_2 => 'El Correo Veloz';

  @override
  String get skill_fluidez_2_desc => 'Hablas con ritmo y fluidez notable.';

  @override
  String get skill_fluidez_3 => 'Heraldo del Vendaval';

  @override
  String get skill_fluidez_3_desc => 'Tu discurso fluye sin esfuerzo.';

  @override
  String get skill_fluidez_4 => 'Vocero de los Dioses';

  @override
  String get skill_fluidez_4_desc => 'Fluidez casi divina al conversar.';

  @override
  String get skill_fonetica_1 => 'Aprendiz de la Voz';

  @override
  String get skill_fonetica_1_desc => 'Tu pronunciación empieza a ser clara.';

  @override
  String get skill_fonetica_2 => 'Eco del Coliseo';

  @override
  String get skill_fonetica_2_desc => 'Pronuncias con precisión destacable.';

  @override
  String get skill_fonetica_3 => 'Cantor de Cristal';

  @override
  String get skill_fonetica_3_desc => 'Tu fonética es limpia y brillante.';

  @override
  String get skill_fonetica_4 => 'Afinador Celestial';

  @override
  String get skill_fonetica_4_desc => 'Claridad fonética de otro plano.';

  @override
  String get skill_lexico_1 => 'Recolector de Palabras';

  @override
  String get skill_lexico_1_desc => 'Sumas tus primeras palabras dominadas.';

  @override
  String get skill_lexico_2 => 'Bibliotecario de Aldea';

  @override
  String get skill_lexico_2_desc => 'Tu vocabulario crece con solidez.';

  @override
  String get skill_lexico_3 => 'Escriba del Abismo';

  @override
  String get skill_lexico_3_desc => 'Dominas un vocabulario extenso.';

  @override
  String get skill_lexico_4 => 'Lexicógrafo Eterno';

  @override
  String get skill_lexico_4_desc => 'Tu léxico no tiene fronteras.';

  @override
  String get skill_precision_1 => 'Aprendiz de las Reglas';

  @override
  String get skill_precision_1_desc => 'Estructuras simples ya son sólidas.';

  @override
  String get skill_precision_2 => 'Aprendiz de Runas';

  @override
  String get skill_precision_2_desc => 'Tu gramática gana consistencia.';

  @override
  String get skill_precision_3 => 'Gramático del Coliseo';

  @override
  String get skill_precision_3_desc => 'Construyes oraciones con dominio.';

  @override
  String get skill_precision_4 => 'Forjador de Sintaxis';

  @override
  String get skill_precision_4_desc => 'Tu precisión gramatical es legendaria.';

  @override
  String get skill_constancia_1 => 'Aprendiz Constante';

  @override
  String get skill_constancia_1_desc => 'Tres días seguidos practicando.';

  @override
  String get skill_constancia_2 => 'Guardián del Fuego';

  @override
  String get skill_constancia_2_desc => 'Una semana ininterrumpida.';

  @override
  String get skill_constancia_3 => 'Centinela del Amanecer';

  @override
  String get skill_constancia_3_desc => 'Un mes de constancia férrea.';

  @override
  String get skill_constancia_4 => 'Leyenda de la Racha';

  @override
  String get skill_constancia_4_desc => 'Cien días de dedicación absoluta.';

  @override
  String get skill_carisma_1 => 'Novato del Gremio';

  @override
  String get skill_carisma_1_desc => 'Te desenvuelves en conversaciones.';

  @override
  String get skill_carisma_2 => 'Alma de la Taberna';

  @override
  String get skill_carisma_2_desc => 'Conectas naturalmente con los demás.';

  @override
  String get skill_carisma_3 => 'Embajador del Reino';

  @override
  String get skill_carisma_3_desc => 'Llevas la conversación con soltura.';

  @override
  String get skill_carisma_4 => 'Oráculo Menor';

  @override
  String get skill_carisma_4_desc =>
      'Tu carisma conversacional es de otro mundo.';

  @override
  String get paywall_upgrade_title => 'SUBÍ DE NIVEL A PREMIUM';

  @override
  String get paywall_upgrade_subtitle =>
      'Tu estamento define tu maná mensual y tu techo de prestigio. El esfuerzo (Aura) decide tu título.';

  @override
  String get paywall_f_monthly => 'MENSUAL';

  @override
  String get paywall_f_annual => 'ANUAL';

  @override
  String get paywall_subscribe => 'SUSCRIBIRSE AHORA';

  @override
  String get paywall_restore => 'RESTAURAR';

  @override
  String get paywall_legal =>
      'Cancela cuando quieras desde App Store / Play Store. Se aplican Términos y Condiciones.';

  @override
  String get paywall_err_checkout => 'No se pudo abrir el checkout.';

  @override
  String get paywall_feature_mana =>
      'Consumo de maná en tiempo real y métricas de voz';

  @override
  String get paywall_feature_titles =>
      'Desbloquea el inventario de 63 títulos de rango (de F a SSS)';

  @override
  String get paywall_feature_rooms =>
      'Acceso 24/7 a las salas de voz del Gran Salón de Debate';

  @override
  String get paywall_feature_modes =>
      'Selector táctico entre Modo Voz y Modo Escritura';

  @override
  String get paywall_feature_missions =>
      'Misiones premium y recompensas de incursión semanal';

  @override
  String get paywall_active_title => 'TU PLAN ACTUAL';

  @override
  String get paywall_active_subtitle =>
      'Ya disfrutas de Premium. Gestiona o cambia tu plan aquí.';

  @override
  String get paywall_load_error => 'No se pudieron cargar los planes.';

  @override
  String get paywall_no_packages =>
      'No hay planes disponibles para este ciclo de facturación.';

  @override
  String get paywall_nothing_restored => 'No hay compras para restaurar.';

  @override
  String get paywall_current_plan => 'PLAN ACTUAL';

  @override
  String get paywall_manage_subscription => 'GESTIONAR SUSCRIPCIÓN';

  @override
  String get paywall_plans_title => 'ELIGE TU ESTAMENTO';

  @override
  String get paywall_per_month => '/mes';

  @override
  String paywall_plan_mana(String amount) {
    return '$amount de maná/mes';
  }

  @override
  String paywall_plan_report_weeks(int weeks) {
    String _temp0 = intl.Intl.pluralLogic(
      weeks,
      locale: localeName,
      other: '$weeks semanas de historial en el informe',
      one: '1 semana de historial en el informe',
    );
    return '$_temp0';
  }

  @override
  String paywall_plan_exclusives(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cosméticos exclusivos',
      one: '1 cosmético exclusivo',
    );
    return '$_temp0';
  }

  @override
  String paywall_trial_then(int days, String price) {
    return '$days días gratis, luego $price/mes';
  }

  @override
  String get mana_inventory_title => 'INVENTARIO DE MANÁ';

  @override
  String get mana_inventory_empty =>
      'Aún no tienes elixires ni gemas en la bolsa.';

  @override
  String get mana_gem_label => 'GEMA';

  @override
  String get mana_elixir_label => 'ELIXIR';

  @override
  String mana_expiry_countdown(Object hours, Object minutes) {
    return 'Expira en ${hours}h ${minutes}m';
  }

  @override
  String get mana_item_equipped => 'Ítem de maná equipado';

  @override
  String get mana_equip => 'EQUIPAR';

  @override
  String get summary_next_lesson => 'SIGUIENTE LECCIÓN';

  @override
  String get oracle_challenge_title => 'EVALUACIÓN DEL ORÁCULO';

  @override
  String get oracle_challenge_ready =>
      'El Oráculo te espera. ¡Reto disponible!';

  @override
  String oracle_challenge_progress(Object percent) {
    return 'Completa el 80% para retar al Oráculo ($percent%)';
  }

  @override
  String get onboarding_english_only =>
      'Aprenderás inglés. El idioma de la interfaz puedes cambiarlo en Ajustes.';

  @override
  String corrections_chip_label(int count) {
    return 'CORREGIR $count';
  }

  @override
  String get corrections_you_wrote => 'Escribiste';

  @override
  String get corrections_suggested => 'Mejor';

  @override
  String get my_errors_title => 'MIS ERRORES';

  @override
  String get my_errors_short => 'ERRORES';

  @override
  String get my_errors_subtitle =>
      'Agrupados por tipo y recurrencia. Los errores recurrentes alimentan tus misiones de refuerzo.';

  @override
  String get my_errors_empty =>
      'Todavía no hay errores registrados. Termina una lección y tus correcciones aparecerán aquí.';

  @override
  String get my_errors_error =>
      'No pudimos cargar tus errores. Revisa tu conexión y reintenta.';

  @override
  String get my_errors_retry => 'REINTENTAR';

  @override
  String my_errors_times(int count) {
    return '${count}x';
  }

  @override
  String get my_errors_recurring_badge => 'RECURRENTE';

  @override
  String get correction_type_grammar => 'Gramática';

  @override
  String get correction_type_vocabulary => 'Vocabulario';

  @override
  String get correction_type_word_choice => 'Elección de palabra';

  @override
  String get correction_type_pronunciation_hint => 'Pronunciación';

  @override
  String get correction_type_typo_stt => 'Transcripción';

  @override
  String get notif_settings_title => 'RECORDATORIO DIARIO';

  @override
  String get notif_settings_desc =>
      'Un recordatorio al día, a la hora que elijas. Nunca de noche.';

  @override
  String get notif_time_label => 'HORA DEL RECORDATORIO';

  @override
  String get notif_days_label => 'DÍAS ACTIVOS';

  @override
  String get notif_quiet_hours =>
      'El silencio nocturno va de 22:00 a 08:00, así que el recordatorio se movió a las 08:00.';

  @override
  String notif_time_updated(String time) {
    return 'Recordatorio fijado a las $time.';
  }

  @override
  String get widget_streak_label => 'RACHA';

  @override
  String get widget_minutes_label => 'HOY';

  @override
  String get widget_minutes_unit => 'min';

  @override
  String get widget_practice => 'PRACTICAR';

  @override
  String get widget_empty_title => 'Abre la app para empezar';

  @override
  String get widget_empty_body =>
      'Tu racha y los minutos de hoy aparecen aquí al abrir la app.';

  @override
  String get notif_permission_denied =>
      'Las notificaciones están bloqueadas. Actívalas en Ajustes de Android > Aplicaciones > Dungeon of English > Notificaciones.';

  @override
  String get notif_permission_open_settings => 'ABRIR AJUSTES DE ANDROID';

  @override
  String get notif_prompt_title => 'NO PIERDAS TU RACHA';

  @override
  String get notif_prompt_body =>
      'Activa un recordatorio diario y te avisaremos a la hora que elijas. Puedes cambiarlo o desactivarlo en Ajustes.';

  @override
  String get notif_prompt_accept => 'ACTIVARLO';

  @override
  String get mini_conv_badge => 'PRUEBA DE 60 SEGUNDOS';

  @override
  String get mini_conv_title => 'Pide un café';

  @override
  String get mini_conv_subtitle =>
      'Habla con Mira, la posadera. Una o dos respuestas, sin examen y sin gastar maná.';

  @override
  String mini_conv_turn_counter(int current, int total) {
    return 'Respuesta $current de $total';
  }

  @override
  String get mini_conv_your_turn => 'TU TURNO';

  @override
  String get mini_conv_input_hint => 'Escribe tu respuesta en inglés...';

  @override
  String get mini_conv_send => 'ENVIAR';

  @override
  String get mini_conv_record => 'RESPONDER CON LA VOZ';

  @override
  String get mini_conv_recording => 'GRABANDO... TOCA PARA PARAR';

  @override
  String get mini_conv_transcribing => 'TRANSCRIBIENDO...';

  @override
  String get mini_conv_skip => 'SALTAR POR AHORA';

  @override
  String get mini_conv_mic_denied =>
      'No pudimos usar el micrófono. Aún puedes escribir tu respuesta.';

  @override
  String get mini_conv_voice_empty =>
      'No oímos ninguna voz. Reintenta o escribe tu respuesta.';

  @override
  String get mini_conv_voice_failed =>
      'No pudimos transcribir tu audio. Reintenta o escribe tu respuesta.';

  @override
  String get mini_conv_unlocked_label => 'FRASE DESBLOQUEADA';

  @override
  String get mini_conv_unlocked_translation =>
      'Un café con leche para llevar, por favor.';

  @override
  String get mini_conv_cta => 'EMPEZAR MI AVENTURA';

  @override
  String get mini_conv_unavailable_title => 'MIRA NO ESTÁ DISPONIBLE';

  @override
  String get mini_conv_unavailable_body =>
      'Tu aventura empieza igualmente. No se ha gastado maná: esta prueba invita la casa.';

  @override
  String get mini_conv_continue => 'CONTINUAR';

  @override
  String get notif_prompt_later => 'AHORA NO';

  @override
  String get notif_enabled_ok => 'Recordatorio diario activado.';

  @override
  String get notif_save_error =>
      'No se pudo guardar el recordatorio. Revisa tu conexión e inténtalo de nuevo.';

  @override
  String get notif_reminder_title => 'Tu racha te espera';

  @override
  String get notif_reminder_body =>
      'Una incursión corta hoy mantiene la racha viva. Tu tutor está listo.';

  @override
  String get boss_exam_title => 'JEFE DE MAZMORRA: EL ORÁCULO';

  @override
  String get boss_exam_state_ready => 'El jefe te espera. ¡Reto disponible!';

  @override
  String get boss_exam_state_locked =>
      'Cumple los requisitos para retar al jefe.';

  @override
  String boss_exam_state_locked_progress(int percent) {
    return 'Completa el 80% de las lecciones del nivel ($percent%)';
  }

  @override
  String boss_exam_state_cooldown(String time) {
    return 'El jefe descansa hasta $time.';
  }

  @override
  String get boss_req_level => 'Nivel asignado';

  @override
  String get boss_req_practice => 'Práctica: metas, racha o minutos';

  @override
  String get boss_req_cooldown => 'Espera entre intentos';

  @override
  String get boss_hud_title => 'JEFE: EL ORÁCULO';

  @override
  String boss_hud_turns(int current, int max) {
    return 'TURNO $current/$max';
  }

  @override
  String get boss_result_victory => 'JEFE DERROTADO';

  @override
  String get boss_result_defeat => 'EL JEFE RESISTE';

  @override
  String get boss_result_initial => 'NIVEL ASIGNADO';

  @override
  String get boss_result_missing => 'No hay resultado disponible.';

  @override
  String boss_result_level_up(String from, String to) {
    return '$from a $to';
  }

  @override
  String boss_result_level_assigned(String level) {
    return 'Tu nivel: $level';
  }

  @override
  String boss_result_level_kept(String level) {
    return 'Mantienes $level';
  }

  @override
  String get boss_result_forced =>
      'El examen llegó a su límite y se evaluó con las respuestas dadas.';

  @override
  String get boss_result_rubric => 'RÚBRICA (6 DIMENSIONES)';

  @override
  String boss_result_average(int value, int threshold) {
    return 'media $value/100 - aprueba $threshold';
  }

  @override
  String get boss_result_no_scores =>
      'El Oráculo no pudo puntuar la rúbrica en este intento.';

  @override
  String get boss_result_reason_title => 'POR QUÉ AÚN NO';

  @override
  String get boss_result_reason_rubric =>
      'Estuviste cerca: la media o alguna dimensión queda por debajo del umbral.';

  @override
  String get boss_result_reason_no_improvement =>
      'Tu nivel es sólido, pero aún no supera tu banda actual.';

  @override
  String get boss_result_reason_unavailable =>
      'El Oráculo no pudo puntuar la rúbrica, así que se mantiene el nivel.';

  @override
  String boss_result_retry_at(String time) {
    return 'Próximo intento: $time';
  }

  @override
  String get boss_result_focus_title => 'QUÉ REFORZAR';

  @override
  String get boss_result_reinforce => 'PRACTICAR LECCIONES DE REFUERZO';

  @override
  String get boss_result_home => 'VOLVER A LA RUTA';

  @override
  String get boss_dim_listening => 'Comprensión';

  @override
  String get boss_dim_fluency => 'Fluidez';

  @override
  String get boss_dim_grammar => 'Gramática';

  @override
  String get boss_dim_vocabulary => 'Vocabulario';

  @override
  String get boss_dim_pronunciation => 'Pronunciación';

  @override
  String get boss_dim_naturalness => 'Naturalidad';

  @override
  String get weekly_title => 'INFORME SEMANAL';

  @override
  String get weekly_subtitle =>
      'Datos calculados en el servidor. Una semana sin actividad lo dice en vez de mostrar ceros.';

  @override
  String get weekly_empty => 'Esta semana no hay actividad registrada.';

  @override
  String get weekly_empty_hint =>
      'Practica una conversación o una lección y el informe se rellena.';

  @override
  String get weekly_new_words => 'Palabras nuevas';

  @override
  String get weekly_words_reviewed => 'Palabras repasadas';

  @override
  String get weekly_words_mastered => 'Palabras dominadas';

  @override
  String get weekly_corrections => 'Errores corregidos';

  @override
  String get weekly_top_error => 'Error más frecuente';

  @override
  String get weekly_lessons => 'Lecciones superadas';

  @override
  String get weekly_minutes => 'Minutos';

  @override
  String get weekly_practice_days => 'Días practicados';

  @override
  String get weekly_per_day => 'Media por día practicado';

  @override
  String get weekly_level => 'Nivel estimado';

  @override
  String get weekly_level_unknown => 'Sin evaluar todavía';

  @override
  String get weekly_this_week => 'Esta semana';

  @override
  String get weekly_previous_week => 'Semana anterior';

  @override
  String get weekly_next_week => 'Semana siguiente';

  @override
  String weekly_range(String start, String end) {
    return '$start a $end';
  }

  @override
  String get weekly_error => 'No pudimos cargar tu informe semanal.';

  @override
  String get weekly_retry => 'REINTENTAR';

  @override
  String get weekly_open => 'VER INFORME';

  @override
  String weekly_history_locked(int weeks) {
    String _temp0 = intl.Intl.pluralLogic(
      weeks,
      locale: localeName,
      other: 'Tu plan guarda $weeks semanas de historial.',
      one: 'Tu plan guarda 1 semana de historial.',
    );
    return '$_temp0';
  }

  @override
  String get weekly_history_upgrade =>
      'Mejora tu plan para abrir semanas anteriores.';

  @override
  String get checkpoint_title => 'CHEQUEO DE NIVEL';

  @override
  String checkpoint_body(int count) {
    return 'Has completado $count lecciones desde tu último reto con el Oráculo.';
  }

  @override
  String get checkpoint_action => 'RETAR AL ORÁCULO';

  @override
  String checkpoint_remaining(int count) {
    return '$count lecciones para el próximo chequeo de nivel';
  }

  @override
  String boss_exam_not_enough(int min) {
    return 'El Oráculo necesita al menos $min respuestas para juzgar el examen. Este intento no cuenta.';
  }

  @override
  String boss_exam_cooldown(String time) {
    return 'El jefe no acepta otro reto hasta $time.';
  }

  @override
  String get listening_path_title => 'COMPRENSIÓN AUDITIVA';

  @override
  String listening_path_next(String title) {
    return 'Siguiente: $title';
  }

  @override
  String listening_path_progress(int done, int total) {
    return '$done/$total superados';
  }

  @override
  String get listening_empty =>
      'Aún no hay ejercicios de escucha para este nivel.';

  @override
  String get listening_play => 'ESCUCHAR DIÁLOGO';

  @override
  String get listening_stop => 'DETENER';

  @override
  String get listening_play_again => 'ESCUCHAR OTRA VEZ';

  @override
  String get listening_transcript_show => 'MOSTRAR TRANSCRIPCIÓN';

  @override
  String get listening_transcript_hide => 'OCULTAR TRANSCRIPCIÓN';

  @override
  String listening_question_counter(int current, int total) {
    return 'PREGUNTA $current DE $total';
  }

  @override
  String get listening_next => 'SIGUIENTE';

  @override
  String get listening_previous => 'ANTERIOR';

  @override
  String get listening_submit => 'COMPROBAR RESPUESTAS';

  @override
  String get listening_submitting => 'CORRIGIENDO...';

  @override
  String get listening_result_passed => 'EJERCICIO SUPERADO';

  @override
  String get listening_result_failed => 'TODAVÍA NO';

  @override
  String listening_result_score(int score, int total) {
    return '$score de $total correctas';
  }

  @override
  String listening_result_missions(int count) {
    return '+$count de progreso en misiones';
  }

  @override
  String listening_result_practice(int minutes) {
    return '$minutes min de práctica registrados';
  }

  @override
  String get listening_result_retry => 'REPETIR';

  @override
  String get listening_back_path => 'VOLVER A LA RUTA';

  @override
  String get listening_error_load =>
      'No pudimos cargar este ejercicio. Revisa tu conexión e inténtalo de nuevo.';

  @override
  String get listening_retry_send => 'REINTENTAR ENVÍO';

  @override
  String listening_explanation(String answer) {
    return 'Respuesta correcta: $answer';
  }

  @override
  String get path_recommended => 'RECOMENDADA';

  @override
  String get path_recommended_interest => 'Por tus intereses';

  @override
  String get path_recommended_error => 'Refuerza tus errores';

  @override
  String get path_recommended_review => 'Repaso de lo aprendido';

  @override
  String get path_recommended_next => 'Siguiente paso';
}
