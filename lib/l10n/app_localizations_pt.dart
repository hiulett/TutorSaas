// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get app_name => 'Dungeon of English';

  @override
  String get login_title => 'Bem-vindo de volta, Caçador';

  @override
  String get login_subtitle => 'Entre para continuar sua jornada.';

  @override
  String get register_prompt => 'Novo Caçador? Crie uma conta';

  @override
  String get login_prompt => 'Já é um Caçador? Entre';

  @override
  String get welcome_title =>
      '[MENSAGEM DO SISTEMA: DESPERTANDO NÚCLEO DE CAÇADOR...]';

  @override
  String get welcome_subtitle => 'Aprenda Falando';

  @override
  String get welcome_desc =>
      'Seu tutor pessoal de idiomas com IA, disponível 24/7 para conversar naturalmente.';

  @override
  String get welcome_warning =>
      'Aviso: Caçadores não registrados serão designados Rank E';

  @override
  String get login => 'ENTRAR';

  @override
  String get register => 'CRIAR CONTA';

  @override
  String get continue_google => 'CONTINUAR COM GOOGLE';

  @override
  String get login_google => 'ENTRAR COM GOOGLE';

  @override
  String get register_google => 'REGISTRAR COM GOOGLE';

  @override
  String get back => 'Voltar';

  @override
  String get skip => 'PULAR';

  @override
  String get sign_in => 'Entrar';

  @override
  String get sign_in_desc =>
      'Faça login com sua conta Google para continuar suas aulas de idiomas.';

  @override
  String get create_account => 'Criar Conta';

  @override
  String get create_account_desc =>
      'Registre-se com Google para personalizar seu tutor de idiomas com IA.';

  @override
  String get email_label => 'E-mail';

  @override
  String get password_label => 'Senha';

  @override
  String get email_required => 'Digite seu e-mail';

  @override
  String get password_required => 'Digite sua senha';

  @override
  String get email_invalid => 'Digite um e-mail válido';

  @override
  String get password_short => 'A senha deve ter pelo menos 6 caracteres';

  @override
  String get login_email => 'ENTRAR COM E-MAIL';

  @override
  String get register_email => 'CRIAR CONTA COM E-MAIL';

  @override
  String get login_email_error => 'Erro ao entrar com e-mail.';

  @override
  String get register_email_error => 'Erro ao criar a conta.';

  @override
  String get email_already_registered =>
      'Este e-mail já está registrado. Faça login.';

  @override
  String get login_success => 'Login realizado. Entrando no reino...';

  @override
  String get register_success => 'Conta criada. Entrando no reino...';

  @override
  String get login_email_hint => 'seuemail@email.com';

  @override
  String get forgot_password => 'ESQUECEU A SENHA?';

  @override
  String get reset_password_title => 'RECUPERAR SENHA';

  @override
  String get reset_password_desc =>
      'Digite seu e-mail e enviaremos um link para recuperar sua senha.';

  @override
  String get reset_password_send => 'ENVIAR LINK DE RECUPERAÇÃO';

  @override
  String get reset_password_sent =>
      'Link de recuperação enviado. Verifique sua caixa de e-mail.';

  @override
  String get reset_password_error =>
      'Erro ao enviar o link. Verifique o e-mail e tente novamente.';

  @override
  String get reset_password_email_empty =>
      'Digite seu e-mail para recuperar sua senha.';

  @override
  String get sync_progress => 'SINCRONIZANDO NÍVEL CEFR...';

  @override
  String get dashboard_title => 'STATUS DO SISTEMA';

  @override
  String get dashboard_offline =>
      'Sem conexão. Mostrando o último progresso guardado.';

  @override
  String dashboard_offline_age(int minutes) {
    return 'Sem conexão. Último progresso há $minutes min.';
  }

  @override
  String get dungeons => 'MASMORRAS';

  @override
  String get guild => 'GRÊMIO';

  @override
  String get status => 'STATUS';

  @override
  String get config => 'CONFIG';

  @override
  String get player => 'JOGADOR';

  @override
  String get mp => 'MP';

  @override
  String get days_clear => 'DIAS LIMPOS';

  @override
  String get urgent_quest => 'MISSÃO URGENTE';

  @override
  String get enter_gateway => 'ENTRAR NA BATALHA';

  @override
  String get active_quests => 'MISSÕES ATIVAS';

  @override
  String get daily => 'DIÁRIO';

  @override
  String get weekly => 'SEMANAL';

  @override
  String get speak_words => 'Fale 50 palavras em uma sessão';

  @override
  String get keep_streak => 'Mantenha sua sequência ativa';

  @override
  String get clear_vocab => 'Limpe 1 Masmorra de Vocabulário';

  @override
  String get chat_rooms => 'Salas de Voz';

  @override
  String get chat_rooms_desc =>
      'Prática em grupo com moderação de IA em tempo real';

  @override
  String get settings => 'Configurações';

  @override
  String get language_level => 'Idioma e Nível';

  @override
  String get tutorial_system => 'Tutorial e Sistema';

  @override
  String get ai_preferences => 'Preferências de IA';

  @override
  String get reminders => 'Lembretes';

  @override
  String get account => 'Conta';

  @override
  String get target_language => 'Idioma Alvo';

  @override
  String get active_cefr => 'Nível CEFR Ativo';

  @override
  String get review_tutorial => 'Rever Tutorial';

  @override
  String get review_tutorial_desc => 'Ver o onboarding completo novamente';

  @override
  String get tutorial_dialog_title => 'Rever Tutorial';

  @override
  String get tutorial_dialog_content =>
      'O tutorial será marcado como pendente. Volte ao início para ser redirecionado.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get tutorial_pending =>
      'Tutorial marcado como pendente. Vá para o início.';

  @override
  String get correction_level => 'Nível de Correção IA';

  @override
  String get tutor_personality => 'Personalidade do Tutor';

  @override
  String get correction_style => 'Estilo de Correção';

  @override
  String get daily_goal => 'Meta Diária';

  @override
  String get save_settings => 'Salvar Configurações';

  @override
  String get settings_save_error => 'Não foi possível salvar as configurações.';

  @override
  String get settings_delete_error => 'Não foi possível excluir a conta.';

  @override
  String get settings_app_language => 'IDIOMA DO APLICATIVO';

  @override
  String get saved => 'Configurações salvas com sucesso';

  @override
  String get error_saving => 'Erro ao salvar configurações';

  @override
  String get logout => 'Sair';

  @override
  String get select_language => 'Selecionar Idioma Alvo';

  @override
  String get select_cefr => 'Selecione seu Nível CEFR';

  @override
  String get fluency => 'FLUÊNCIA';

  @override
  String get latency => 'LATÊNCIA';

  @override
  String get pipeline_perf => 'Desempenho do pipeline';

  @override
  String get score => 'Pontuação';

  @override
  String get achievements => 'Conquistas e Estatísticas';

  @override
  String get vocabulary_learned => 'Vocabulário Aprendido';

  @override
  String get weekly_practice => 'Prática Semanal (Minutos de Voz)';

  @override
  String get view_all => 'VER TUDO';

  @override
  String get srs_review => 'Revisão SRS';

  @override
  String get fluency_evolution => 'Evolução de Fluência e Latência';

  @override
  String get wpm => 'PPM';

  @override
  String get radar_title => 'Radar Holográfico de Habilidades';

  @override
  String get heatmap_title => 'Consistência de Prática (4 Semanas)';

  @override
  String get weeks_ago => '4 semanas atrás';

  @override
  String get today => 'Hoje';

  @override
  String get profile => 'Perfil';

  @override
  String get edit_profile => 'Editar Perfil';

  @override
  String get status_window => 'JANELA DE STATUS DO CAÇADOR';

  @override
  String get status_window_desc =>
      'Matriz de 11 atributos, títulos equipáveis e radar de poder';

  @override
  String get xp_points => 'Pontos XP';

  @override
  String get active_streak => 'Sequência Ativa';

  @override
  String get active_level => 'Nível Ativo';

  @override
  String get days => 'Dias';

  @override
  String get voice_chat => 'Chat de Voz';

  @override
  String get speak_now => 'FALAR AGORA';

  @override
  String get hold_speak => 'Segure para falar';

  @override
  String get boss_hp => 'HP do Chefe';

  @override
  String get system_analysis => '[ANÁLISE DO SISTEMA COMPLETA]';

  @override
  String get explain_rule => 'Explicar Regra';

  @override
  String get provide_example => 'Dar Exemplo';

  @override
  String get retry_battle => 'Tentar Batalha Novamente';

  @override
  String get type_command => 'Digite um comando...';

  @override
  String get lesson_preview => 'Objetivos e Metas';

  @override
  String get communication_goals => 'Metas de Comunicação';

  @override
  String get recommended_phrases => 'Frases Recomendadas';

  @override
  String get understood => 'Entendido';

  @override
  String get start_voice_lesson => 'Iniciar Lição de Voz';

  @override
  String get objectives => 'Objetivos';

  @override
  String get beginner => 'Iniciante';

  @override
  String get intermediate => 'Intermediário';

  @override
  String get advanced => 'Avançado';

  @override
  String get master => 'Mestre';

  @override
  String get min_day => 'min / dia';

  @override
  String get onboarding_lang => 'IDIOMA DE DESPERTAR';

  @override
  String get onboarding_country => 'REGISTRO DE CAÇADOR';

  @override
  String get onboarding_target => 'IDIOMA ALVO';

  @override
  String get onboarding_cefr => 'SELEÇÃO DE GATE';

  @override
  String get onboarding_goal => 'COMPROMISSO DE MISSÃO';

  @override
  String get onboarding_interests => 'ÁRVORE DE HABILIDADES';

  @override
  String get onboarding_correction => 'ABORDAGEM TÁTICA';

  @override
  String get onboarding_obstacle => 'IDENTIFICAÇÃO DO CHEFE';

  @override
  String get btn_continue => 'Continuar';

  @override
  String get onboarding_start_eval => 'INICIAR AVALIAÇÃO';

  @override
  String get register_confirm_email =>
      'Verifique seu e-mail e confirme a conta para continuar.';

  @override
  String get resend_confirmation => 'REENVIAR';

  @override
  String get login_email_not_confirmed =>
      'Seu e-mail ainda não foi confirmado. Verifique a caixa de entrada ou peça um novo envio.';

  @override
  String get complete_onboarding => 'Completar Onboarding';

  @override
  String get exam_timer => 'Tempo Restante';

  @override
  String get exam_pass => 'APROVADO';

  @override
  String get exam_fail => 'REPROVADO';

  @override
  String get new_rank => 'Novo Rank Desbloqueado';

  @override
  String get dungeon => 'Masmorra';

  @override
  String get quest => 'Missão';

  @override
  String get boss => 'Chefe';

  @override
  String get hunter => 'Caçador';

  @override
  String get rank => 'RANGO';

  @override
  String get mission => 'Missão';

  @override
  String get log_entry => 'Entrada';

  @override
  String get system_log => 'Registro do Sistema';

  @override
  String get data_stream => 'Fluxo de Dados';

  @override
  String get active => 'Ativo';

  @override
  String get inactive => 'Inativo';

  @override
  String get first_steps => 'Primeiros Passos';

  @override
  String get first_steps_desc =>
      'Complete sua primeira conversa para obter equipamento inicial';

  @override
  String get fire_streak => 'Sequência de Fogo';

  @override
  String get fire_streak_desc => 'Mantenha uma sequência de 7 dias de prática';

  @override
  String get fluent_speaker => 'Falante Fluente';

  @override
  String get fluent_speaker_desc => 'Fale 100 palavras em uma única sessão';

  @override
  String get goals_completed_desc => 'Todos os objetivos principais concluídos';

  @override
  String get guild_hall => 'SALÃO DA GUILD';

  @override
  String get live_coop => 'Salas de Raid Co-Op ao Vivo';

  @override
  String get initialize_room => 'Criar Mesa';

  @override
  String get enter_raid => 'Entrar na Raid';

  @override
  String get hunters_active => 'Caçadores Ativos';

  @override
  String get live_voice => 'Voz ao Vivo';

  @override
  String get barrier_active => 'Barreira Ativa';

  @override
  String get no_vocab =>
      'Você ainda não aprendeu vocabulário. Inicie uma conversa!';

  @override
  String get vocab_detail => 'Detalhe do Vocabulário';

  @override
  String get vocab_added => 'Vocabulário adicionado';

  @override
  String xp_earned(Object amount) {
    return '+$amount XP';
  }

  @override
  String streak_days(Object count) {
    return 'Sequência de $count Dias';
  }

  @override
  String conversations_remaining(Object count) {
    return '$count conversas restantes';
  }

  @override
  String get character_name => 'NOME DO CAÇADOR';

  @override
  String get character_name_hint => 'Seu nome aventureiro...';

  @override
  String get character_avatar => 'AVATAR';

  @override
  String get character_class => 'CLASSE';

  @override
  String get oracle_title => 'O ORÁCULO DA GUILD';

  @override
  String get oracle_assessment => 'Avaliação em andamento...';

  @override
  String get oracle_respond => 'Responda ao Oráculo...';

  @override
  String get oracle_result => 'Avaliação Completa';

  @override
  String get oracle_strengths => 'PONTOS FORTES';

  @override
  String get oracle_weaknesses => 'ÁREAS DE MELHORIA';

  @override
  String get oracle_continue => 'RECEBER LICENÇA DE CAÇADOR';

  @override
  String get nucleo_title => 'O NÚCLEO ARCANO ESTÁ SE ESGOTANDO';

  @override
  String nucleo_desc(Object count) {
    return 'O Oráculo respondeu $count vezes hoje. Precisa recarregar com a luz da manhã.';
  }

  @override
  String get nucleo_rest => 'Descansar até amanhã — o Núcleo recarregará';

  @override
  String get mod_ai => '🤖 Moderação por IA';

  @override
  String get mod_creator => '👑 Moderação pelo Criador';

  @override
  String get mod_assigned => '🎯 Moderação Atribuída';

  @override
  String get mod_table_new => 'Nova Mesa da Guild';

  @override
  String get mod_table_name => 'Nome da mesa';

  @override
  String get mod_description => 'Descrição (opcional)';

  @override
  String get mod_category => 'Categoria';

  @override
  String get mod_type => 'TIPO DE MODERAÇÃO';

  @override
  String get mod_create => 'Criar Mesa';

  @override
  String get mod_cancel => 'Cancelar';

  @override
  String get mod_ai_desc => 'O Tutor IA modera automaticamente';

  @override
  String get mod_creator_desc => 'Você modera. Gerencie oradores e turnos';

  @override
  String get mod_assigned_desc =>
      'Outro usuário será o moderador. Digite o email:';

  @override
  String get room_live => 'AO VIVO';

  @override
  String get room_mic => 'Microfone';

  @override
  String get room_leave => 'Sair';

  @override
  String get room_chat => 'Chat';

  @override
  String get room_audience => 'Audiência';

  @override
  String get room_hand => 'Pedir para Falar';

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
  String get conversation_input_hint => 'Digite em inglês...';

  @override
  String get conversation_mission_guide => 'GUIA DE MISSÃO';

  @override
  String get conversation_voice_mode => 'Modo Voz';

  @override
  String get conversation_text_mode => 'Modo Texto';

  @override
  String get conversation_speech_dna => 'Impressão de Voz';

  @override
  String get conversation_replay => 'REPRODUZIR';

  @override
  String get guild_master => 'MESTRE DE MESA';

  @override
  String get guild_online => 'ONLINE';

  @override
  String get guild_quest_daily => 'MISSÃO DIÁRIA';

  @override
  String get guild_quest_speak => 'Fale 10 minutos em uma sala de voz';

  @override
  String get guild_tables => 'MESAS DA GUILD';

  @override
  String get guild_create => 'Criar';

  @override
  String get guild_join => 'Entrar';

  @override
  String get guild_enter => 'Entrar';

  @override
  String get guild_no_rooms => 'Nenhuma sala ativa nesta categoria.';

  @override
  String get status_panel => 'PAINEL DE STATUS DO CAÇADOR';

  @override
  String get status_attributes => 'ATRIBUTOS DO MONARCA (11)';

  @override
  String get status_titles => 'TÍTULOS LENDÁRIOS';

  @override
  String get status_equip => 'Equipar';

  @override
  String get status_equipped => '✓';

  @override
  String get status_combat => 'ATRIBUTOS DE COMBATE';

  @override
  String get status_achievements => 'CONQUISTAS RARAS';

  @override
  String get hud_xp_total => 'XP TOTAL';

  @override
  String get hud_vocabulary => 'VOCABULÁRIO';

  @override
  String get hud_level => 'NÍVEL';

  @override
  String get hud_streak => 'SEQUÊNCIA';

  @override
  String get error_mic_permission =>
      'Sem permissão do microfone. Ative nas configurações.';

  @override
  String get error_listening => 'Ouvindo sua voz...';

  @override
  String get error_short_audio => 'A gravação foi muito curta. Fale novamente.';

  @override
  String get error_no_speech =>
      'Nenhuma fala detectada. Tente falar mais perto do microfone.';

  @override
  String get error_recording => 'Não foi possível gerar a gravação.';

  @override
  String get error_processing =>
      'Erro ao processar a resposta. Tente novamente.';

  @override
  String error_groq_connection(Object code) {
    return 'Erro de conexão com STT ($code). Verifique sua internet.';
  }

  @override
  String get error_nucleo => 'O NÚCLEO ARCANO ESTÁ ESGOTADO';

  @override
  String get loading => 'Carregando...';

  @override
  String get error => 'Erro';

  @override
  String get retry => 'Tentar Novamente';

  @override
  String get success => 'Sucesso';

  @override
  String get confirm => 'Confirmar';

  @override
  String get close => 'Fechar';

  @override
  String get save => 'Salvar';

  @override
  String get delete => 'Excluir';

  @override
  String get search => 'Buscar';

  @override
  String get filter => 'Filtrar';

  @override
  String get no_results => 'Nenhum resultado encontrado.';

  @override
  String get see_all => 'Ver Tudo';

  @override
  String get learn_more => 'Saiba Mais';

  @override
  String get get_started => 'Começar';

  @override
  String get register_new_hunter => 'REGISTAR NOVO CAÇADOR';

  @override
  String get onboarding_select_native_warn =>
      'Selecione seu idioma nativo para continuar.';

  @override
  String get onboarding_select_target_warn =>
      'Selecione o idioma que deseja aprender.';

  @override
  String get onboarding_switch_interface_lang => 'Alterar idioma da interface';

  @override
  String onboarding_switch_interface_desc(String lang) {
    return 'Altere os menus e botões do aplicativo para $lang em vez de inglês.';
  }

  @override
  String get onboarding_country_title => 'PAÍS DE ORIGEM';

  @override
  String get onboarding_country_desc =>
      'Diga-nos de onde você vem para adaptar a pronúncia e as expressões.';

  @override
  String get onboarding_country_search_hint => 'Buscar país...';

  @override
  String get onboarding_country_no_results => 'Nenhum país encontrado.';

  @override
  String get onboarding_oracle_classification =>
      'O ORÁCULO IRÁ CLASSIFICAR VOCÊ';

  @override
  String get onboarding_oracle_classification_desc =>
      'O Oráculo analisará sua proficiência no idioma por meio de uma conversa para determinar seu rank inicial.';

  @override
  String get onboarding_voice_evaluation => 'AVALIAÇÃO CONVERSACIONAL POR VOZ';

  @override
  String get onboarding_voice_evaluation_desc =>
      'Fale com o Oráculo e você será avaliado em pronúncia, vocabulário, gramática, compreensão e fluência. O resultado definirá seu rank inicial.';

  @override
  String get onboarding_start_evaluation => 'INICIAR AVALIAÇÃO';

  @override
  String get onboarding_evaluation_optional =>
      'A avaliação é opcional: se você pular, começará no rank inicial (A1).';

  @override
  String get welcome_hunter_prefix => 'BEM-VINDO,';

  @override
  String get welcome_hunter_suffix => 'CAÇADOR!';

  @override
  String get adventure_begins => 'Sua aventura começa agora.';

  @override
  String get enter_realm => 'ENTRAR NO REINO';

  @override
  String get character_creation_title => 'CRIE SEU PERSONAGEM';

  @override
  String get character_creation_desc =>
      'Antes de começar sua aventura, precisamos saber quem você é.';

  @override
  String get character_creation_continue => 'O ORÁCULO ESPERA POR VOCÊ';

  @override
  String get character_name_optional =>
      'Opcional — se usará o nome da sua conta se vazio.';

  @override
  String get character_class_unavailable =>
      'Classes indisponíveis. Tente novamente mais tarde.';

  @override
  String get character_difficulty_label => 'Dificuldade';

  @override
  String get character_combat_label => 'Combate';

  @override
  String get character_affinity_label => 'Afinidade';

  @override
  String get character_abilities_label => 'HABILIDADES';

  @override
  String get character_stat_attack => 'Ataque';

  @override
  String get character_stat_defense => 'Defesa';

  @override
  String get character_stat_magic => 'Magia';

  @override
  String get character_stat_speed => 'Velocidade';

  @override
  String get character_stat_support => 'Suporte';

  @override
  String get character_stat_survival => 'Sobrevivência';

  @override
  String get class_warrior_name => 'Berserker';

  @override
  String get class_warrior_desc =>
      'Extrovertido e corajoso. Você fala primeiro e pensa depois. Ideal para perder o medo de falar.';

  @override
  String get class_warrior_arch =>
      'Extrovertido, fala primeiro — superar o medo';

  @override
  String get class_mage_name => 'Mago Arcano';

  @override
  String get class_mage_desc =>
      'Analítico e preciso. Você observa e estrutura antes de falar. Ideal para aperfeiçoar a gramática.';

  @override
  String get class_mage_arch =>
      'Analítico, estrutura antes de falar — gramática';

  @override
  String get class_assassin_name => 'Assassino';

  @override
  String get class_assassin_desc =>
      'Observador tático. Você busca precisão e eficiência furtiva. Ideal para vocabulário de alta precisão.';

  @override
  String get class_assassin_arch =>
      'Observador tático — vocabulário de precisão';

  @override
  String get class_knight_name => 'Cavaleiro';

  @override
  String get class_knight_desc =>
      'Constante e metódico. Mantém-se firme em suas rotinas. Ideal para construir sequências e consistência.';

  @override
  String get class_knight_arch =>
      'Constante e metódico — consistência e sequências';

  @override
  String get class_archer_name => 'Arqueiro';

  @override
  String get class_archer_desc =>
      'Ágil e rápido. Você aprende na prática dentro do contexto. Ideal para dominar expressões úteis.';

  @override
  String get class_archer_arch =>
      'Ágil, aprende em contexto — expressões diárias';

  @override
  String get class_summoner_name => 'Invocador';

  @override
  String get class_summoner_desc =>
      'Criativo e associativo. Você conecta conceitos e conjura ideias. Ideal para frases idiomáticas.';

  @override
  String get class_summoner_arch =>
      'Criativo, associa ideias — expressões idiomáticas';

  @override
  String get class_paladin_name => 'Paladino';

  @override
  String get class_paladin_desc =>
      'Protetor guiado por objetivos. Orientado ao dever. Ideal para conversas formais e estruturadas.';

  @override
  String get class_paladin_arch => 'Guiado por objetivos — conversação formal';

  @override
  String get class_necromancer_name => 'Necromante';

  @override
  String get class_necromancer_desc =>
      'Explorador etimológico. Ressuscita as raízes do idioma. Ideal para raízes latinas e origens de palavras.';

  @override
  String get class_necromancer_arch =>
      'Curioso sobre etimologia — raízes latinas e história';

  @override
  String get onboarding_lang_desc =>
      'Personalizaremos sua jornada de aprendizado de acordo com sua língua nativa.';

  @override
  String get onboarding_native_lang => 'Idioma nativo';

  @override
  String get onboarding_target_desc => 'Qual idioma você quer dominar?';

  @override
  String get onb_validate_native =>
      'Selecione seu idioma nativo para continuar.';

  @override
  String get onb_validate_target => 'Selecione o idioma que deseja aprender.';

  @override
  String get login_google_error => 'Erro ao entrar com o Google.';

  @override
  String get register_google_error => 'Erro ao registrar com o Google.';

  @override
  String get oracle_no_voice =>
      'Nenhuma voz detectada. Fale mais perto do microfone ou use o teclado.';

  @override
  String get oracle_listening => 'OUVINDO... SOLTE PARA ENVIAR';

  @override
  String get oracle_processing => 'PROCESSANDO COM GROQ IA...';

  @override
  String get oracle_skip => 'PULAR PERGUNTA';

  @override
  String get oracle_complete => 'CONCLUIR AVALIAÇÃO';

  @override
  String get room_no_messages => 'Ainda não há mensagens nesta câmara.';

  @override
  String room_error(String err) {
    return 'Erro na sala: $err';
  }

  @override
  String get room_hunt_lang => 'Idioma de Caça:';

  @override
  String get room_xp_points => 'Pontos de Experiência:';

  @override
  String get room_type_ai => 'TREINO IA';

  @override
  String get room_type_mentorship => 'MENTORIA (RESSONÂNCIA)';

  @override
  String get room_type_event => 'EVENTO ESPECIAL';

  @override
  String get room_cancel => 'CANCELAR';

  @override
  String room_create_error(String err) {
    return 'Erro ao criar sala: $err';
  }

  @override
  String get room_initialize => 'INICIAR';

  @override
  String room_prestige(String level) {
    return 'PRESTÍGIO $level';
  }

  @override
  String get mission_accept => 'ACEITAR';

  @override
  String get mission_none => 'SEM MISSÕES ATIVAS';

  @override
  String get mission_generate => 'GERAR MISSÕES';

  @override
  String get mission_claim => 'RESGATAR';

  @override
  String get srs_close => 'FECHAR';

  @override
  String get srs_hard => 'DIFÍCIL';

  @override
  String get srs_review_title => 'REVISÃO DO DIA';

  @override
  String srs_review_due(int count) {
    return '$count palavras aguardam revisão';
  }

  @override
  String get npc_remembers_failure => 'O NPC LEMBRA DA SUA ÚLTIMA TENTATIVA';

  @override
  String get npc_remembers_partial => 'O NPC LEMBRA QUE VOCÊ QUASE CONSEGUIU';

  @override
  String get srs_review_cta => 'REVISAR';

  @override
  String srs_retention(int percent, int mastered) {
    return '$percent% lembrado em 7 dias · $mastered dominadas';
  }

  @override
  String get srs_normal => 'NORMAL';

  @override
  String get srs_easy => 'FÁCIL';

  @override
  String get nucleo_recharge => 'RECARREGAR +5';

  @override
  String get nucleo_premium => 'IR PREMIUM';

  @override
  String get nucleo_unlimited => 'Invocação Ilimitada — Caçador de Elite';

  @override
  String get paywall_success =>
      'Obrigado por assinar! Benefícios Premium desbloqueados.';

  @override
  String paywall_failure(String err) {
    return 'Falha na compra: $err';
  }

  @override
  String get paywall_restored => 'Compras restauradas com sucesso.';

  @override
  String get paywall_nothing_to_restore => 'Não há compras para restaurar.';

  @override
  String get lessons_voice_rooms => 'Salas de Voz';

  @override
  String get lessons_view_goals => 'Ver Objetivos';

  @override
  String get exam_mute => 'MUDO';

  @override
  String get exam_conclude => 'CONCLUIR RAID';

  @override
  String get exam_return => 'VOLTAR AO SANTUÁRIO';

  @override
  String get progress_xp_points => 'Pontos XP';

  @override
  String get progress_active_streak => 'Sequência Ativa';

  @override
  String get progress_active_level => 'Nível Ativo';

  @override
  String get progress_active_rank => 'Ranking do Grêmio';

  @override
  String get radar_fluency => 'Fluência';

  @override
  String get radar_vocab => 'Vocabulário';

  @override
  String get radar_phonetics => 'Fonética';

  @override
  String get radar_grammar => 'Gramática';

  @override
  String get radar_comprehension => 'Compreensão';

  @override
  String get radar_naturalness => 'Naturalidade';

  @override
  String get progress_srs_review => 'Revisão SRS';

  @override
  String get progress_see_all => 'VER TUDO';

  @override
  String get inventory_load_error => 'Não foi possível carregar o inventário';

  @override
  String get inventory_empty => 'INVENTÁRIO VAZIO';

  @override
  String get inventory_visit_shop => 'VISITE A LOJA →';

  @override
  String get inventory_equipped => 'EQUIPADO';

  @override
  String get conversation_goals => 'Metas do Cenário:';

  @override
  String get conversation_key_phrases => 'Frases-chave Sugeridas:';

  @override
  String get conversation_phonemes => 'Fonemas recomendados para praticar:';

  @override
  String get hero_got_it => 'Entendi';

  @override
  String get hero_cefr_label => 'CEFR';

  @override
  String get hero_class_label => 'Classe';

  @override
  String get hero_member_since => 'Membro desde';

  @override
  String get summary_view_vocab => 'VER VOCABULÁRIO';

  @override
  String get summary_vocab_title => 'VOCABULÁRIO DA SESSÃO';

  @override
  String get summary_vocab_empty =>
      'Ainda não há palavras guardadas desta sessão.';

  @override
  String get summary_vocab_saved => 'Vocabulário salvo no seu perfil.';

  @override
  String get summary_done => 'PRONTO';

  @override
  String get collections_load_error => 'Não foi possível carregar as coleções';

  @override
  String get profile_total_xp => 'XP Total';

  @override
  String get profile_streak => 'Sequência ativa';

  @override
  String get profile_cefr_level => 'Nível CEFR';

  @override
  String get profile_vocab_error => 'Erro ao carregar vocabulário';

  @override
  String get profile_vocab_empty =>
      'Você ainda não aprendeu vocabulário nas conversas.';

  @override
  String get profile_close => 'Fechar';

  @override
  String get battlepass_load_error => 'Não foi possível carregar o Battle Pass';

  @override
  String get profile_edit_camera => 'CÂMERA';

  @override
  String get profile_edit_gallery => 'GALERIA';

  @override
  String get chart_4weeks => 'Há 4 semanas';

  @override
  String get chart_today => 'Hoje';

  @override
  String get chart_latency => 'Latência (s)';

  @override
  String get aura_title => 'AURA';

  @override
  String get aura_locked => 'AURA BLOQUEADA';

  @override
  String get aura_locked_desc =>
      'Supere a Etapa Básica (PRE-A1 + A1 + A2) para despertar seu poder.';

  @override
  String get aura_awakened => 'USUÁRIO DO AURA';

  @override
  String get aura_basic_stage => 'ETAPA BÁSICA';

  @override
  String get aura_power => 'PODER';

  @override
  String get aura_tier_latente => 'LATENTE';

  @override
  String get aura_tier_revelada => 'REVELADA';

  @override
  String get aura_tier_abierta => 'ABERTA';

  @override
  String get aura_tier_dominante => 'DOMINANTE';

  @override
  String get aura_tier_abisal => 'ABISAL';

  @override
  String get aura_awakening_banner_title => 'O SISTEMA FALOU';

  @override
  String get aura_awakening_banner_desc =>
      'VocǦ despertou como Usuǭrio do Aura. Seu poder crescerǭ com suas habilidades.';

  @override
  String get ok => 'OK';

  @override
  String get shop => 'LOJA';

  @override
  String get map => 'MAPA';

  @override
  String get claimed => 'RECLAMADO';

  @override
  String get notifications => 'Notificações';

  @override
  String get missions => 'Missões';

  @override
  String get oracle => 'ORÁCULO';

  @override
  String get pro_badge => 'PRO';

  @override
  String get go_pro => 'IR PRO';

  @override
  String get logout_confirm_title => 'SAIR?';

  @override
  String get logout_confirm_desc =>
      'Seu progresso fica salvo. Você precisará fazer login novamente para continuar.';

  @override
  String get splash_system_hud => 'SISTEMA HUD · DESPERTANDO';

  @override
  String splash_connecting(int pct) {
    return '$pct% · CONECTANDO AO GRANDE REINO';
  }

  @override
  String get connecting_realm => 'CONECTANDO AO GRANDE REINO...';

  @override
  String get system_hunter_connected => 'SISTEMA DE CAÇADOR — CONECTADO';

  @override
  String cefr_level(String code) {
    return 'CEFR $code';
  }

  @override
  String level_up_banner(int level) {
    return '¡SUBIDA DE NÍVEL! $level';
  }

  @override
  String title_earned_banner(String title) {
    return '🏅 TÍTULO GANHO: $title';
  }

  @override
  String get mana_label => 'MANA';

  @override
  String get mana_available => 'mana disponível';

  @override
  String get mana_daily_available => 'mana disponível hoje';

  @override
  String get guardian_title => 'SANTUÁRIO DE MANA';

  @override
  String get guardian_sealed => 'Selada';

  @override
  String get guardian_cry => 'SEU MANA ACABOU.\nO SANTUÁRIO O AGUARDA.';

  @override
  String get guardian_desc =>
      'Toda ação de IA custa mana. Recupere com seu plano, poções ou equipando um elixir/gema da sua bolsa.';

  @override
  String get guardian_get_mana => 'OBTER MANA';

  @override
  String get guardian_get_mana_desc => 'MAIS MANA MENSAL POR NÍVEL';

  @override
  String get guardian_equip_item => 'EQUIPAR ELIXIR / GEMA';

  @override
  String get guardian_equip_item_desc => 'Equipe um item de mana da sua bolsa';

  @override
  String get guardian_go_back => 'Voltar ao Grêmio';

  @override
  String mana_balance(int remaining, int total) {
    return '$remaining / $total mana';
  }

  @override
  String plus_mana(int count) {
    return '+$count mana';
  }

  @override
  String purchase_confirm_question(String name, String price) {
    return 'Adquirir \"$name\" por $price?';
  }

  @override
  String get mana_tooltip =>
      'MANA: energia para toda ação de IA (Oráculo, masmorras, chats). Adquire-se com o plano e porções/gemas; expira com o ciclo.';

  @override
  String mana_expires(String date) {
    return 'expira $date';
  }

  @override
  String get aura_locked_tooltip =>
      'ETAPA BÁSICA: complete os objetivos das missões PRE-A1, A1 e A2 para despertar sua Aura.';

  @override
  String get aura_awakened_tooltip =>
      'AURA: mérito sem limite. Continue acumulando a cada sessão avaliada.';

  @override
  String aura_xp(int xp) {
    return 'AURA XP $xp';
  }

  @override
  String aura_next_rank(int pct) {
    return '$pct% para o próximo nível';
  }

  @override
  String get aura_rank_mismatch => '⚠ NÍVEL INCONSISTENTE COM CEFR';

  @override
  String get daily_reward_title => 'RECOMPENSA DIÁRIA';

  @override
  String daily_reward_streak(int streak) {
    return 'SEQUÊNCIA ATUAL: $streak DIAS';
  }

  @override
  String daily_reward_gems(int gems) {
    return '$gems GEMAS';
  }

  @override
  String get daily_reward_by_streak => 'POR SEQUÊNCIA';

  @override
  String daily_reward_parchments(int count) {
    return '+$count PERGAMINHOS';
  }

  @override
  String get daily_reward_cap => 'TETO DIÁRIO';

  @override
  String get daily_reward_keep_streak =>
      'MANTENHA SUA SEQUÊNCIA: AOS 7 DIAS VOCÊ GANHA 50 GEMAS E 5 PERGAMINHOS';

  @override
  String get daily_reward_at_14 => 'AOS 14 DIAS: 100 GEMAS E 8 PERGAMINHOS';

  @override
  String get daily_reward_at_30 => 'AOS 30 DIAS: 300 GEMAS E 15 PERGAMINHOS';

  @override
  String get daily_reward_max_streak => 'SEQUÊNCIA MÁXIMA ALCANÇADA!';

  @override
  String get claiming => 'RECLAMANDO…';

  @override
  String get daily_reward_claimed_today => 'RECOMPENSA RECLAMADA HOJE';

  @override
  String get daily_reward_claim => 'RECLAMAR RECOMPENSA';

  @override
  String get no_mana => 'SEM MANA';

  @override
  String mana_exhausted_desc(String renew) {
    return 'Toda ação de IA custa mana. Seu saldo acabou.\n\nO mana é adquirido com seu plano ou porções/gemas.\n$renew';
  }

  @override
  String mana_renews_on(String date) {
    return 'Seu ciclo renova em $date.';
  }

  @override
  String get more_mana_monthly => 'MAIS MANA MENSAL POR NÍVEL';

  @override
  String get wait_plan_renewal => 'Aguardar a renovação do meu plano';

  @override
  String get hunter_collections => 'COLEÇÕES DO CAÇADOR';

  @override
  String get no_trophies => 'SEM TROFÉUS REGISTRADOS';

  @override
  String get confirm_purchase => 'CONFIRMAR COMPRA';

  @override
  String get buy => 'COMPRAR';

  @override
  String get cosmetic_purchased => 'COSMÉTICO ADQUIRIDO! 🪙';

  @override
  String get gold_insufficient => 'OURO INSUFICIENTE OU JÁ ADQUIRIDO ❌';

  @override
  String get cosmetic_title => 'TÍTULO';

  @override
  String get cosmetic_frame => 'MOLDURA';

  @override
  String get cosmetic_aura => 'AURA';

  @override
  String get cosmetic_pet => 'COMPANHEIRO';

  @override
  String get cosmetic_emote => 'EMOTE';

  @override
  String get cosmetic_theme => 'TEMA';

  @override
  String get arcane_shop => 'LOJA ARCANO';

  @override
  String get gold_shop_tab => 'LOJA DE OURO';

  @override
  String get redeem => 'RESGATAR';

  @override
  String get my_items => 'MEUS ITENS';

  @override
  String get mana_potions_title => 'POÇÕES DE MANA';

  @override
  String get mana_potions_desc =>
      'O mana é a energia de toda ação de IA. Adquire-se com dinheiro real: seu nível inclui uma cota mensal e as poções a ampliam.';

  @override
  String get mana_gems_packs_title => 'PACOTES DE GEMAS DE MANA';

  @override
  String get gold_shop_unavailable =>
      'A Loja de Ouro ainda não está disponível.\nTente novamente em instantes.';

  @override
  String get owned => 'ADQUIRIDO';

  @override
  String price_gold(String price) {
    return '$price OURO';
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
  String get craft_action => 'CRIAR';

  @override
  String get craft_success => 'COSMÉTICO CRIADO!';

  @override
  String get shop_tab_gems => 'GEMAS';

  @override
  String get shop_tab_gold => 'OURO';

  @override
  String get shop_tab_fragments => 'FRAGMENTOS';

  @override
  String get shop_tab_empty => 'Ainda não há itens nesta moeda.';

  @override
  String get shop_level_locked => 'NÍVEL DE CAÇADOR INSUFICIENTE';

  @override
  String shop_next_unlock(String name, int level) {
    return 'PRÓXIMO DESBLOQUEIO: $name · NV. $level';
  }

  @override
  String shop_plan_required_body(String plan) {
    return 'Este item é exclusivo do plano $plan.';
  }

  @override
  String get gems_insufficient => 'GEMAS INSUFICIENTES';

  @override
  String get purchase_failed => 'NÃO FOI POSSÍVEL COMPLETAR A COMPRA';

  @override
  String level_label(String level) {
    return 'NV. $level';
  }

  @override
  String level_rewards_pending(int count) {
    return '$count RECOMPENSAS DE NÍVEL';
  }

  @override
  String level_rewards_banner_hint(String level) {
    return 'NÍVEL $level ALCANÇADO · RESGATE SEU OURO';
  }

  @override
  String level_rewards_claim(int count) {
    return 'RESGATAR $count';
  }

  @override
  String level_rewards_claimed_ok(int count) {
    return '$count RECOMPENSAS DE NÍVEL RESGATADAS!';
  }

  @override
  String get level_rewards_none => 'SEM RECOMPENSAS PENDENTES';

  @override
  String get streak_freeze_title => 'CONGELAMENTO DE SEQUÊNCIA';

  @override
  String get streak_freeze_desc => 'Protege um dia perdido. Máximo 3.';

  @override
  String get streak_freeze_cap => 'MÁXIMO DE CONGELAMENTOS ALCANÇADO';

  @override
  String get streak_freeze_max => 'NO MÁXIMO';

  @override
  String get streak_freeze_bought => 'CONGELAMENTO DE SEQUÊNCIA ADQUIRIDO!';

  @override
  String get fragments_insufficient => 'FRAGMENTOS INSUFICIENTES ❌';

  @override
  String get redeem_error => 'ERRO NO RESGATE ❌';

  @override
  String get fragments_exchange_title => 'RESGATE DE FRAGMENTOS';

  @override
  String get fragments_exchange_desc =>
      'OS FRAGMENTOS SÃO A MOEDA DE RESGATE. ESCOLHA COM SABEDORIA, CAÇADOR.';

  @override
  String battle_reward_claimed_tier(int tier) {
    return 'RECOMPENSA TIER $tier RECLAMADA';
  }

  @override
  String get not_available => 'NÃO DISPONÍVEL';

  @override
  String get battle_pass => 'BATTLE PASS';

  @override
  String get premium => 'PREMIUM';

  @override
  String get free_tier => 'GRATUITO';

  @override
  String battle_level(int level) {
    return 'NÍVEL $level';
  }

  @override
  String get battle_progress_label => 'Progresso do Passe de Batalha: ';

  @override
  String get rewards => 'RECOMPENSAS';

  @override
  String reward_claimed_tier(int tier) {
    return 'Recompensa nível $tier reclamada';
  }

  @override
  String reward_unlocked_tier(int tier) {
    return 'Recompensa nível $tier desbloqueada';
  }

  @override
  String reward_locked_tier(int tier) {
    return 'Recompensa nível $tier bloqueada, desbloqueie no nível $tier';
  }

  @override
  String battle_tier(int tier) {
    return 'TIER $tier';
  }

  @override
  String get reward_unlocked => 'Recompensa desbloqueada';

  @override
  String unlock_at_level(int tier) {
    return 'Desbloqueie no nível $tier';
  }

  @override
  String battle_claim_reward(int tier) {
    return 'Reclamar recompensa nível $tier';
  }

  @override
  String get equipment_updated => 'EQUIPAMENTO ATUALIZADO';

  @override
  String get inventory => 'INVENTÁRIO';

  @override
  String get unequip => 'REMOVER';

  @override
  String get equip => 'EQUIPAR';

  @override
  String get chat_category_all => 'Todas';

  @override
  String get chat_cat_general => 'Geral';

  @override
  String get chat_cat_travel => 'Viagens';

  @override
  String get chat_cat_business => 'Trabalho';

  @override
  String get chat_cat_technology => 'Tecnologia';

  @override
  String get chat_cat_art => 'Arte';

  @override
  String get chat_cat_cooking => 'Culinária';

  @override
  String get chat_rank_status => 'ESTADO DE NÍVEL';

  @override
  String get chat_hunter_details => 'DETALHES DO CAÇADOR';

  @override
  String chat_rank_level(String code) {
    return 'NÍVEL $code';
  }

  @override
  String get chat_establish_table => 'CRIAR MESA DE GUILDA';

  @override
  String get chat_create_room => 'CRIAR NOVA SALA';

  @override
  String get chat_table_title => 'TÍTULO DA MESA';

  @override
  String get chat_category_path => 'CAMINHO DE CATEGORIA';

  @override
  String get chat_table_type => 'TIPO DE MESA';

  @override
  String get chat_missions => 'MISSÕES';

  @override
  String get chat_guild_pass => 'PASSE DA GUILDA';

  @override
  String get chat_rank => 'NÍVEL';

  @override
  String get chat_collections => 'COLEÇÕES';

  @override
  String get chat_music_on => 'MÚSICA ON';

  @override
  String get chat_music => 'MÚSICA';

  @override
  String get chat_status_full => 'CHEIA';

  @override
  String get chat_status_nearly_full => 'QUASE CHEIA';

  @override
  String get chat_status_occupied => 'OCUPADA';

  @override
  String get chat_status_space => 'ESPAÇO';

  @override
  String get chat_type_mentorship => 'MENTORIA';

  @override
  String get chat_type_ai => 'IA';

  @override
  String get chat_type_event => 'EVENTO';

  @override
  String chat_rank_line(String rank, String cefr) {
    return 'NÍVEL: $rank · $cefr';
  }

  @override
  String get chat_free => 'LIVRE';

  @override
  String get chat_rank_silver => 'PRATA';

  @override
  String get chat_rank_gold => 'OURO';

  @override
  String get chat_rank_iron => 'FERRO';

  @override
  String get voice_seat_to_speak => 'SENTE-SE PARA FALAR';

  @override
  String voice_seated_in(String seat) {
    return 'VOCÊ SENTOU NA CADEIRA $seat';
  }

  @override
  String get voice_seat_assigned => 'CADEIRA ATRIBUÍDA. Bem-vindo!';

  @override
  String get voice_seats_full_queue => 'CADEIRAS CHEIAS: VOCÊ ENTRA NA FILA';

  @override
  String get voice_seat_freed => 'CADEIRA LIBERADA. EM PÉ';

  @override
  String get voice_standing => 'CAÇADOR EM PÉ';

  @override
  String get voice_not_moderator => 'VOCÊ NÃO É MODERADOR DESTA MESA';

  @override
  String get voice_chamber_chat => 'CHAT DE TEXTO DA SALA';

  @override
  String get voice_free_mission => 'MISSÃO LIVRE';

  @override
  String get voice_guild_chamber => 'SALA DE VOZ DA GUILDA';

  @override
  String get voice_moderated => 'Sala de voz da guilda';

  @override
  String get voice_leave => 'Sair da sala';

  @override
  String get voice_demo_banner =>
      'ÁUDIO DA GUILDA: DEMO — caçadores conectados ao vivo. A prática de voz é 1:1.';

  @override
  String get voice_demo_banner_alt => 'ÁUDIO DEMO — TOQUE PARA VER DETALHES';

  @override
  String get voice_room_mission => 'MISSÃO DA SALA';

  @override
  String get voice_resonance => 'RESSONÂNCIA';

  @override
  String get voice_your_seat => 'SUA CADEIRA';

  @override
  String voice_seat_number(String slot) {
    return 'CADEIRA $slot';
  }

  @override
  String get voice_tap_to_sit => 'TOQUE PARA SENTAR';

  @override
  String get voice_you => 'VOCÊ';

  @override
  String voice_hunter_slot(String slot) {
    return 'HUNTER $slot';
  }

  @override
  String get voice_speaking => 'FALANDO';

  @override
  String get voice_seated => 'SENTADO';

  @override
  String voice_standing_count(int count) {
    return 'EM PÉ ($count/8)';
  }

  @override
  String get voice_you_standing => 'Você (em pé)';

  @override
  String get voice_standing_hunter => 'Caçador em pé';

  @override
  String voice_chat_title(int count) {
    return 'Chat da sala ($count)';
  }

  @override
  String get voice_mic_on => 'MIC ON';

  @override
  String get voice_mic_off => 'MIC OFF';

  @override
  String get voice_stand_up => 'LEVANTAR';

  @override
  String voice_in_queue(int pos) {
    return 'NA FILA #$pos';
  }

  @override
  String get voice_seat => 'CADEIRA';

  @override
  String get voice_exit => 'SAIR';

  @override
  String get guild_rec_beginner =>
      'Recomendo a Taverna do Aprendiz: é a mesa perfeita para caçadores novatos.';

  @override
  String get guild_rec_intermediate =>
      'A Mesa Redonda de Táticas espera: debates e fluência intermediária.';

  @override
  String get guild_rec_master =>
      'O Conselho Supremo dos Altos Caçadores é o seu lugar: eloquência de nível mestre.';

  @override
  String get guild_rec_default =>
      'Escolha uma mesa e comece sua raid de conversação.';

  @override
  String get guild_table_beginner => 'Aprendiz';

  @override
  String get guild_table_tactics => 'Táticas';

  @override
  String get guild_table_council => 'Conselho';

  @override
  String guild_rank_level(String cefr) {
    return 'RANQUE $cefr';
  }

  @override
  String get guild_follow_suggestion => 'SIGA MINHA SUGESTÃO —>';

  @override
  String guild_ask_master(String cefr) {
    return 'Pergunte ao Mestre (Nível $cefr):';
  }

  @override
  String get guild_ask_hint =>
      'Pergunte-me qual mesa praticar, qual missão aceitar ou como melhorar seu nível.';

  @override
  String get guild_input_hint => 'Escreva sua pergunta...';

  @override
  String get guild_meditating =>
      'O Mestre de Mesa está meditando... Tente novamente.';

  @override
  String get mission_board_title => 'QUADRO DE MISSÕES';

  @override
  String mission_board_player_rank(String playerRank) {
    return 'AVENTUREIRO · NÍVEL $playerRank';
  }

  @override
  String get mission_completed_active => '✓ CONCLUÍDAS';

  @override
  String get mission_completed => 'CONCLUÍDAS';

  @override
  String get mission_filter_all => 'TODAS';

  @override
  String get mission_filter_daily => 'DIÁRIAS';

  @override
  String get mission_filter_weekly => 'SEMANAIS';

  @override
  String get mission_filter_collaborative => 'COLABORATIVAS';

  @override
  String get mission_filter_rarity_all => 'RARIDADE: TODAS';

  @override
  String get mission_search_hint => 'Buscar missão por nome...';

  @override
  String get mission_board_empty_filtered =>
      'Nenhuma missão da guilda corresponde a esses filtros.';

  @override
  String mission_view_more(int count) {
    return 'VER MAIS MISSÕES ($count restantes)';
  }

  @override
  String get mission_completed_empty =>
      'Você ainda não completou missões da guilda.';

  @override
  String get mission_login_required => 'Faça login para aceitar missões.';

  @override
  String mission_insufficient_rank(String rank) {
    return '🔒 NÍVEL INSUFICIENTE: você precisa do nível $rank.';
  }

  @override
  String mission_accept_success(String title) {
    return '✅ Missão aceita: $title';
  }

  @override
  String get mission_accept_failed =>
      'Não foi possível aceitar (cota cheia ou nível insuficiente).';

  @override
  String get mission_high_rank_title => 'MISSÃO DE ALTO NÍVEL';

  @override
  String mission_high_rank_confirm(String title, String rank) {
    return 'Tem certeza de que deseja empreender \"$title\" (nível $rank)? É uma missão de elite da guilda.';
  }

  @override
  String mission_reward_earned(int xp, int gems) {
    return '+$xp XP  ·  +$gems 💎';
  }

  @override
  String get mission_claim_failed => 'Não foi possível resgatar a recompensa.';

  @override
  String get mission_npc_collaborative => 'Mestre de Mesa · Guilda';

  @override
  String get mission_npc_vocabulary => 'Bibliotecária da Guilda';

  @override
  String get mission_npc_writing => 'Escriba Real';

  @override
  String get mission_npc_argumentation => 'Cônsul do Debate';

  @override
  String get mission_npc_default => 'Mestre de Mesa';

  @override
  String get mission_difficulty_unknown => 'Desconhecida';

  @override
  String mission_difficulty_label(String rank) {
    return 'Nível $rank';
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
  String get mission_load_error => 'Não foi possível carregar a missão.';

  @override
  String get mission_not_found => 'Missão não encontrada.';

  @override
  String get mission_detail_title => 'DETALHE DA MISSÃO';

  @override
  String mission_rarity_type_label(String rarity, String type) {
    return '$rarity · $type';
  }

  @override
  String get mission_section_description => 'DESCRIÇÃO';

  @override
  String get mission_npc_label => 'NPC';

  @override
  String get mission_stat_level => 'NÍVEL';

  @override
  String get mission_stat_xp => 'XP';

  @override
  String get mission_stat_gold => 'OURO';

  @override
  String get mission_stat_time => 'TEMPO';

  @override
  String get mission_stat_objective => 'OBJETIVO';

  @override
  String get mission_section_objectives => 'OBJETIVOS';

  @override
  String mission_objectives_goal(int target, String objectiveType) {
    return 'Complete $target de $objectiveType.';
  }

  @override
  String get mission_claiming => 'RESGATANDO...';

  @override
  String get mission_in_progress_chat => 'EM ANDAMENTO · IR PARA O CHAT';

  @override
  String get mission_reject => 'RECUSAR';

  @override
  String mission_rank_required(String rank) {
    return 'NÍVEL $rank NECESSÁRIO';
  }

  @override
  String get mission_rarity_common => 'COMUM';

  @override
  String get mission_rarity_uncommon => 'INCOMUM';

  @override
  String get mission_rarity_rare => 'RARO';

  @override
  String get mission_rarity_epic => 'ÉPICO';

  @override
  String get mission_rarity_legendary => 'LENDÁRIO';

  @override
  String get mission_rarity_guild => 'ESPECIAL DA GUILDA';

  @override
  String get mission_status_available => 'DISPONÍVEL';

  @override
  String get mission_status_accepted => 'ACEITA';

  @override
  String get mission_status_in_progress => 'EM ANDAMENTO';

  @override
  String get mission_status_completed => 'CONCLUÍDA';

  @override
  String get mission_status_repeatable => 'REPETÍVEL';

  @override
  String get mission_status_blocked => 'BLOQUEADA';

  @override
  String get mission_status_recommended => 'RECOMENDADA';

  @override
  String get mission_status_special => 'ESPECIAL';

  @override
  String get session_title => 'Resumo';

  @override
  String get summary_reward_gold => 'OURO';

  @override
  String get summary_reward_fragments => 'FRAGMENTOS';

  @override
  String get summary_reward_pending =>
      'Não foi possível confirmar sua recompensa. Seu progresso está salvo; ele será atualizado ao recarregar.';

  @override
  String get session_completed => 'SESSÃO CONCLUÍDA';

  @override
  String get session_good_job => 'Ótimo trabalho!';

  @override
  String session_words_spoken(int count) {
    return 'Você falou $count palavras com bom ritmo.';
  }

  @override
  String get summary_remedial_title => 'REFORÇO';

  @override
  String get summary_remedial_generated =>
      'Criamos uma lição com seus erros recorrentes e as metas que você não cumpriu.';

  @override
  String get summary_remedial_reused => 'Sua lição de reforço está pronta.';

  @override
  String get summary_remedial_play => 'PRATICAR MINHAS DIFICULDADES';

  @override
  String get summary_remedial_no_evidence =>
      'Ainda não há lição de reforço: precisamos de erros registrados ou uma meta não cumprida para orientá-la.';

  @override
  String get summary_remedial_insufficient_mana =>
      'Você não tem mana suficiente para uma lição de reforço. Estará disponível quando seu saldo renovar.';

  @override
  String get summary_remedial_failed =>
      'Não foi possível criar a lição de reforço. Devolvemos sua mana.';

  @override
  String summary_remedial_cost(int cost) {
    return 'Custo: $cost de mana';
  }

  @override
  String get summary_remedial_retry => 'TENTAR DE NOVO';

  @override
  String get session_ready => 'Prática pronta para começar.';

  @override
  String get session_excellent_performance => 'Desempenho excelente!';

  @override
  String get session_ready_first => 'Pronto para sua primeira sessão!';

  @override
  String get session_duration => 'DURAÇÃO';

  @override
  String get session_words => 'PALAVRAS';

  @override
  String get session_accuracy => 'PRECISÃO (EST.)';

  @override
  String get session_fluency => 'Fluência (est.)';

  @override
  String get session_pronunciation => 'Pronúncia';

  @override
  String get session_feedback => 'Feedback';

  @override
  String get session_no_errors =>
      'Nenhum erro de gramática ou fonética foi registrado.';

  @override
  String get session_talk_tutor => 'Fale com o tutor IA para obter feedback.';

  @override
  String get session_performance => 'Desempenho';

  @override
  String get session_excellent => 'Excelente';

  @override
  String get session_correction => 'Correção';

  @override
  String get session_grammar => 'Gramática';

  @override
  String get session_bonus => 'Bônus de Sessão';

  @override
  String get session_maintained => 'Mantida';

  @override
  String get summary_learned_title => 'O QUE VOCÊ APRENDEU';

  @override
  String get summary_learned_words => 'PALAVRAS NOVAS E REVISADAS';

  @override
  String get summary_learned_word_new => 'NOVA';

  @override
  String get summary_learned_word_review => 'REVISÃO';

  @override
  String get summary_learned_no_words =>
      'Ainda não há vocabulário registrado nesta sessão.';

  @override
  String get summary_learned_corrections => 'CORREÇÕES';

  @override
  String get summary_learned_no_corrections =>
      'Sem correções: desta vez você se comunicou com clareza.';

  @override
  String get summary_learned_focus => 'FOCO RECOMENDADO';

  @override
  String get summary_learned_no_focus =>
      'Ainda não há dados suficientes para uma recomendação.';

  @override
  String get summary_learned_loading => 'Carregando os dados da sua sessão...';

  @override
  String get summary_learned_error =>
      'Não conseguimos carregar o que você aprendeu. Verifique sua conexão e tente novamente.';

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
  String get summary_reward_loading => 'Confirmando sua recompensa...';

  @override
  String get summary_reward_error =>
      'Não conseguimos confirmar sua recompensa. Verifique sua conexão e tente novamente.';

  @override
  String get summary_retry => 'TENTAR NOVAMENTE';

  @override
  String get summary_review_words => 'REVISAR PALAVRAS';

  @override
  String get profile_status_panel => 'PAINEL DE ESTADO';

  @override
  String get profile_hunter_window => 'JANELA DE STATUS DO CAÇADOR';

  @override
  String profile_learning(String language, String emoji) {
    return 'Aprendendo $language $emoji';
  }

  @override
  String get profile_weekly_minutes => 'Minutos de Prática Semanal';

  @override
  String get profile_vocab_learned => 'Vocabulário Aprendido';

  @override
  String get profile_explore => 'Explorar';

  @override
  String get profile_learn => 'Aprender';

  @override
  String get profile_title => 'Perfil';

  @override
  String get quest_daily_title => 'Missões Diárias';

  @override
  String quest_claimed(int xp) {
    return 'Recompensa resgatada! +$xp XP';
  }

  @override
  String get quest_empty => 'Não há missões diárias ativas no momento.';

  @override
  String get quest_speak_10min => 'Fale 10 minutos de voz';

  @override
  String get quest_desc_session => 'Complete uma sessão conversacional fluida';

  @override
  String get quest_learn_5_words => 'Aprenda 5 palavras novas';

  @override
  String get quest_desc_vocab => 'Acumule vocabulário nas suas chamadas';

  @override
  String get quest_85_pronunciation => 'Alcance >85% em Pronúncia';

  @override
  String get quest_desc_pronunciation =>
      'Passe em um teste de impressão de voz';

  @override
  String get missions_title => 'Missões';

  @override
  String get missions_tab_daily => 'Diárias';

  @override
  String get missions_tab_weekly => 'Semanais';

  @override
  String get missions_spotlight => 'MISSÃO DO DIA';

  @override
  String get missions_see_all => 'VER TODAS';

  @override
  String get missions_reset_hint => 'Renovação automática: 00:05 UTC';

  @override
  String get missions_empty_daily =>
      'Você ainda não tem missões diárias. Elas chegam todos os dias às 00:05 UTC.';

  @override
  String get missions_empty_weekly =>
      'Você ainda não tem missões semanais. Elas são atribuídas com o ciclo diário das 00:05 UTC.';

  @override
  String get missions_unavailable => 'Indisponível';

  @override
  String get missions_unavailable_hint =>
      'Esta missão não pode ser concluída com o rastreamento atual.';

  @override
  String missions_claim_xp(int xp) {
    return 'Resgatar +$xp XP';
  }

  @override
  String missions_claim_success(int xp, int gems) {
    return 'Recompensa resgatada: +$xp XP · +$gems gemas';
  }

  @override
  String get missions_claim_already => 'Você já resgatou esta recompensa.';

  @override
  String get missions_claim_error =>
      'Não foi possível resgatar a recompensa. Verifique sua conexão e tente novamente.';

  @override
  String get missions_load_error =>
      'Não foi possível carregar suas missões. Toque para tentar novamente.';

  @override
  String get missions_retry => 'TENTAR NOVAMENTE';

  @override
  String get missions_unit_minutes => 'min';

  @override
  String get missions_unit_turns => 'turnos';

  @override
  String get missions_unit_words => 'palavras';

  @override
  String get missions_unit_sessions => 'sessões';

  @override
  String get league_level_title => 'Liga de Nível';

  @override
  String get league_you => 'Você (Estudante)';

  @override
  String league_ranking(String league) {
    return 'Classificação $league';
  }

  @override
  String league_top5(String level) {
    return 'Top 5 · Nível $level';
  }

  @override
  String get recommended_title => 'Central de descobertas';

  @override
  String get recommended_desc =>
      'Lições personalizadas conforme seu nível, interesses e metas do onboarding';

  @override
  String get recommended_search_hint => 'Busque lição, papel ou tema...';

  @override
  String get recommended_cat_all => 'Tudo';

  @override
  String get recommended_cat_tech => 'Tecnologia';

  @override
  String get recommended_cat_business => 'Negócios';

  @override
  String get recommended_cat_travel => 'Viagens';

  @override
  String get recommended_cat_social => 'Social';

  @override
  String get recommended_cat_food => 'Comida';

  @override
  String get recommended_all_levels => 'Todos os níveis';

  @override
  String recommended_level(String lvl) {
    return 'Nível $lvl';
  }

  @override
  String recommended_catalog(int count) {
    return 'Catálogo personalizado ($count)';
  }

  @override
  String recommended_suggested_level(String cefr) {
    return 'Nível sugerido: $cefr';
  }

  @override
  String get recommended_hero_match =>
      '100% de combinação com sua meta profissional e interesse em Tecnologia';

  @override
  String recommended_filter(String cefr) {
    return 'Filtro: $cefr';
  }

  @override
  String get recommended_empty => 'Nenhuma lição com os filtros selecionados.';

  @override
  String recommended_lesson_level(String level) {
    return 'NÍVEL $level';
  }

  @override
  String get recommended_locked_hint =>
      'Conclua a lição anterior do seu caminho para desbloquear.';

  @override
  String get recommended_blocked => 'Bloqueada';

  @override
  String get recommended_review => 'Revisar';

  @override
  String get recommended_speak => 'Falar';

  @override
  String get path_roadmap_title => 'MAPA DE MASMORRAS';

  @override
  String get path_stage_empty => 'Ainda não há lições registradas nesta etapa.';

  @override
  String get profile_edit_photo_ok => 'FOTO ENVIADA COM SUCESSO';

  @override
  String get profile_edit_choose_photo => 'ESCOLHER FOTO PERSONALIZADA';

  @override
  String get profile_edit_license_registry => 'REGISTRO DE LICENÇA DE CAÇADOR';

  @override
  String get profile_edit_hunter_name => 'NOME DE CAÇADOR';

  @override
  String profile_edit_class_path(String path) {
    return 'CAMINHO DE CLASSE: $path';
  }

  @override
  String get profile_edit_select_class => 'SELECIONAR CAMINHO DE CLASSE';

  @override
  String get profile_edit_stat_allocation =>
      'DISTRIBUIÇÃO DE PONTOS DE ATRIBUTO';

  @override
  String profile_edit_stat_pool(int points) {
    return 'RESERVA: $points PT';
  }

  @override
  String get profile_edit_full_name => 'NOME COMPLETO DO CAÇADOR';

  @override
  String get profile_edit_name_empty => 'O NOME NÃO PODE FICAR VAZIO';

  @override
  String get profile_edit_memoir => 'MEMÓRIAS / OBJETIVOS';

  @override
  String get profile_edit_license_updated => 'REGISTRO DE LICENÇA ATUALIZADO';

  @override
  String get profile_edit_save => 'SALVAR REGISTRO DE LICENÇA';

  @override
  String get profile_edit_class_warrior => 'GUERREIRO';

  @override
  String get profile_edit_class_warrior_desc => 'Força física e defesa alta';

  @override
  String get profile_edit_class_mage => 'MAGO';

  @override
  String get profile_edit_class_mage_desc =>
      'Lançamento de feitiços e manipulação de mana';

  @override
  String get profile_edit_class_assassin => 'ASSASSINO';

  @override
  String get profile_edit_class_assassin_desc =>
      'Furtividade, velocidade e golpes críticos';

  @override
  String get profile_edit_class_necromancer => 'NECROMANTE';

  @override
  String get profile_edit_class_necromancer_desc =>
      'Invocação dos mortos e magia sombria';

  @override
  String get profile_edit_class_priest => 'SACERDOTE';

  @override
  String get profile_edit_class_priest_desc => 'Cura, buffs e luz sagrada';

  @override
  String get profile_edit_stat_str_desc => 'Força e potência muscular';

  @override
  String get profile_edit_stat_int_desc =>
      'Lançamento de feitiços e velocidade de análise';

  @override
  String get profile_edit_stat_dex_desc => 'Agilidade e ritmo de resposta';

  @override
  String get profile_edit_stat_luk_desc => 'Evitação de correções críticas';

  @override
  String get convo_mission_guide => 'Guia e contexto da missão';

  @override
  String get convo_practice_title => 'Prática de conversação';

  @override
  String convo_objective(String objective) {
    return 'Objetivo: $objective';
  }

  @override
  String get convo_select_goals => 'Selecione uma lição para ver os objetivos.';

  @override
  String get convo_select_phrases =>
      'Selecione uma lição para ver as frases-chave sugeridas.';

  @override
  String get convo_voice_print => 'Impressão vocal e pronúncia';

  @override
  String get convo_phonetic_clarity => 'Clareza fonética';

  @override
  String get convo_speech_speed => 'Velocidade da fala';

  @override
  String get convo_words_spoken => 'Palavras ditas';

  @override
  String get convo_cefr_level => 'Nível CEFR';

  @override
  String get convo_hidden_chat => 'Chat oculto (4.ª/5.ª estrela)';

  @override
  String get convo_visible_chat => 'Chat visível';

  @override
  String get convo_write_mode => 'Modo escrita';

  @override
  String get convo_voice_mode => 'Modo voz';

  @override
  String get convo_input_hint => 'Escreva sua mensagem em inglês...';

  @override
  String get convo_continue => 'CONTINUAR';

  @override
  String get convo_oracle_evaluating =>
      'O ORÁCULO ESTÁ AVALIANDO SUA CONVERSA...';

  @override
  String get convo_analyzing_level => 'Analisando seu nível de comunicação...';

  @override
  String get convo_status_listening => 'Ouvindo…';

  @override
  String get convo_status_thinking => 'Pensando…';

  @override
  String get convo_status_speaking => 'O tutor está falando';

  @override
  String get convo_stop_tutor => 'Parar';

  @override
  String get convo_tts_title => 'Voz do tutor';

  @override
  String get convo_tts_speed => 'Velocidade';

  @override
  String get convo_tts_voice => 'Voz';

  @override
  String get convo_tts_default_voice => 'Voz do sistema';

  @override
  String get convo_tts_no_voices =>
      'Nenhuma voz em inglês encontrada. Instale uma em Configurações do Android > Idiomas.';

  @override
  String get convo_mic_denied_title => 'Microfone bloqueado';

  @override
  String get convo_mic_denied_body =>
      'O Dungeon of English precisa do microfone para ouvir você. Ative-o nas configurações do Android e volte.';

  @override
  String get convo_mic_open_settings => 'Abrir configurações';

  @override
  String get convo_mic_retry => 'Tentar novamente';

  @override
  String get convo_mic_manual_hint =>
      'Abra Configurações > Apps > Dungeon of English > Permissões > Microfone.';

  @override
  String get convo_mic_label => 'Microfone';

  @override
  String get convo_hold_too_short =>
      'Muito curto: mantenha o microfone pressionado enquanto fala e solte para enviar.';

  @override
  String get convo_help_title => 'Preciso de ajuda';

  @override
  String get convo_help_hint =>
      'Toque em uma frase para enviá-la como sua resposta.';

  @override
  String get convo_help_empty =>
      'Este cenário ainda não tem frases de ajuda. Escreva sua resposta ou mude de assunto.';

  @override
  String get settings_system_config => 'CONFIGURAÇÃO DO SISTEMA';

  @override
  String get settings_target_cefr => 'IDIOMA ALVO E NÍVEL CEFR';

  @override
  String get settings_language => 'IDIOMA';

  @override
  String get settings_ai_parameters => 'PARÂMETROS DO TUTOR DE IA';

  @override
  String get settings_audio_comms => 'ÁUDIO E COMUNICAÇÕES';

  @override
  String get settings_account => 'CONTA';

  @override
  String get settings_export_data => 'EXPORTAR MEUS DADOS';

  @override
  String get settings_export_copied =>
      'Seus dados foram copiados para a área de transferência.';

  @override
  String get settings_delete_account => 'EXCLUIR MINHA CONTA';

  @override
  String get settings_delete_confirm_title => 'Excluir sua conta?';

  @override
  String get settings_delete_confirm_body =>
      'Isso apaga sua conta e seu progresso permanentemente. Não pode ser desfeito.';

  @override
  String get settings_aligned => 'CONFIGURAÇÃO ALINHADA';

  @override
  String get settings_save => 'SALVAR CONFIGURAÇÃO';

  @override
  String get settings_target_language => 'IDIOMA ALVO';

  @override
  String get settings_cefr_practice => 'NÍVEL DE PRÁTICA CEFR';

  @override
  String get settings_logout_dungeon => 'SAIR DA MASMORRA';

  @override
  String get settings_select_path => 'SELECIONAR CAMINHO ALVO';

  @override
  String get settings_select_cefr => 'SELECIONAR CAMINHO DE NÍVEL CEFR';

  @override
  String get settings_correction_scope => 'ESCOPO DA CORREÇÃO IA';

  @override
  String get settings_tutor_personality => 'PERSONALIDADE DO TUTOR';

  @override
  String get settings_correction_cadence => 'CADÊNCIA DE CORREÇÃO';

  @override
  String get settings_quest_focus => 'FOCO DA MISSÃO DIÁRIA';

  @override
  String get settings_sfx_channels => 'CANAIS DE EFEITOS DE ÁUDIO';

  @override
  String get settings_alerts => 'AVISOS DIÁRIOS';

  @override
  String get settings_alert_time => 'HORÁRIO DOS AVISOS';

  @override
  String get settings_select_correction => 'SELECIONAR NÍVEL DE CORREÇÃO';

  @override
  String get settings_select_personality => 'SELECIONAR PERSONALIDADE DO TUTOR';

  @override
  String get settings_select_cadence => 'SELECIONAR CADÊNCIA DE CORREÇÃO';

  @override
  String get settings_select_quest => 'SELECIONAR FOCO DA MISSÃO DIÁRIA';

  @override
  String get settings_follow_device => 'USAR IDIOMA DO DISPOSITIVO';

  @override
  String get settings_force_onboarding => 'Forçar onboarding contínuo';

  @override
  String get settings_dev_desc =>
      'Modo desenvolvedor. Não bloqueia o app: só afeta o onboarding quando ainda não há perfil. Use \"Redefinir histórico\" para testar de novo.';

  @override
  String get settings_profile_deleted =>
      'Perfil de caçador excluído. Reiniciando...';

  @override
  String get settings_reset_onboarding => 'REDEFINIR HISTÓRICO DO ONBOARDING';

  @override
  String onboarding_device_lang(String lang) {
    return 'Detectamos que seu dispositivo usa $lang. O app será exibido nesse idioma.';
  }

  @override
  String get privacy_title => 'PRIVACIDADE';

  @override
  String get privacy_body =>
      'Para corrigir sua conversa, o app envia à IA o áudio transcrito, seu nível CEFR e seu idioma nativo. Seu e-mail, nome e foto não são enviados. Você pode exportar ou excluir seus dados em Ajustes. Também guardamos métricas de uso agregadas (progresso, retenção e erros) sem texto de conversa nem dados pessoais.';

  @override
  String get privacy_accept => 'ENTENDIDO';

  @override
  String get onboarding_privacy_link => 'PRIVACIDADE';

  @override
  String get onboarding_beginner => 'SOU INICIANTE ABSOLUTO (PRE-A1)';

  @override
  String get onboarding_beginner_desc =>
      'Ainda não formo frases: apenas palavras soltas e vocabulário mínimo. Você começará em Fundamentos sem exame.';

  @override
  String get hunter_equip_title => 'EQUIPAR TÍTULO';

  @override
  String get hunter_skill_titles => 'TÍTULOS DE HABILIDADE';

  @override
  String hunter_cefr_xp(String code, int xp) {
    return 'CEFR $code · $xp XP';
  }

  @override
  String get hunter_equipped_title => 'TÍTULO EQUIPADO';

  @override
  String get hunter_equip => 'EQUIPAR';

  @override
  String get hunter_fluency_analysis => 'ANÁLISE DE FLUÊNCIA';

  @override
  String get hunter_holographic_radar => 'RADAR HOLOGRÁFICO';

  @override
  String get hunter_practice_consistency => 'CONSISTÊNCIA DE PRÁTICA';

  @override
  String hunter_points_pool(int points) {
    return 'PONTOS DISPONÍVEIS: $points';
  }

  @override
  String get hunter_str => 'FOR (FORÇA)';

  @override
  String get hunter_luk => 'SOR (SORTE)';

  @override
  String get hunter_distribute_points => 'DISTRIBUIR PONTOS';

  @override
  String get hunter_no_title => 'SEM TÍTULO';

  @override
  String get hunter_max_level => 'NÍVEL MÁXIMO ALCANÇADO';

  @override
  String get dungeon_choose_portal =>
      'ESCOLHA UM PORTAL DE ACORDO COM SEU RANK';

  @override
  String dungeon_current_portal(String level) {
    return 'PORTAL ATUAL · NÍVEL $level';
  }

  @override
  String dungeon_level(Object level) {
    return 'NÍVEL $level';
  }

  @override
  String get progress_edit_profile => 'Editar perfil';

  @override
  String get progress_hunter_status => 'Status do caçador';

  @override
  String progress_streak_hint(int streak, String days) {
    return 'Pratique hoje para manter sua sequência de $streak dias $days';
  }

  @override
  String get progress_practice => 'PRATICAR';

  @override
  String get settings_haptics => 'VIBRAÇÃO';

  @override
  String get settings_haptics_desc =>
      'Vibra ao cumprir a meta e ao subir de nível';

  @override
  String get settings_hold_to_talk => 'SEGURE PARA FALAR';

  @override
  String get settings_hold_to_talk_desc =>
      'Mantenha o microfone pressionado enquanto fala e solte para enviar. Desligado: toque para gravar e parar.';

  @override
  String get settings_sounds => 'SONS';

  @override
  String get settings_sounds_desc => 'Som do sistema nas celebrações';

  @override
  String get welcome_back_title => 'BEM-VINDO DE VOLTA';

  @override
  String welcome_back_days(int days) {
    return '$days dias sem treinar';
  }

  @override
  String welcome_back_lesson(String lesson) {
    return 'Você parou em $lesson';
  }

  @override
  String welcome_back_goals(int count) {
    return 'Faltam $count metas';
  }

  @override
  String get welcome_back_completed =>
      'Você concluiu. Pode repetir ou seguir para a próxima.';

  @override
  String get welcome_back_streak_reset =>
      'Vamos começar uma nova sequência hoje.';

  @override
  String get welcome_back_continue => 'CONTINUAR';

  @override
  String get welcome_back_later => 'Agora não';

  @override
  String get radar_estimated_tooltip => 'Estimativa baseada na sua conversa';

  @override
  String get radar_estimated_note => 'Estimativa baseada na sua conversa';

  @override
  String get radar_pronunciation_unmeasured =>
      'Pronúncia: ainda sem medição real';

  @override
  String get band_low => 'Baixo';

  @override
  String get band_medium => 'Médio';

  @override
  String get band_high => 'Alto';

  @override
  String mana_cost_per_turn(int cost) {
    return '$cost/turno';
  }

  @override
  String mana_low_warning(int count) {
    return 'Restam $count turnos hoje';
  }

  @override
  String get mana_empty_warning => 'Sem mana para o próximo turno';

  @override
  String get guardian_alternative_title => 'ENQUANTO ISSO';

  @override
  String guardian_refill_in(int hours, int minutes) {
    return 'Recarrega em $hours h $minutes min';
  }

  @override
  String guardian_refill_at(String date) {
    return 'Renova em $date';
  }

  @override
  String get guardian_review_vocab => 'Revisar vocabulário (grátis)';

  @override
  String guardian_low_cost_chat(int cost) {
    return 'Chat de texto ($cost de mana)';
  }

  @override
  String get guardian_no_due_words =>
      'Nenhuma palavra pendente de revisão agora.';

  @override
  String get daily_goal_title => 'META DIÁRIA';

  @override
  String daily_goal_minutes(int done, int goal) {
    return '$done / $goal min';
  }

  @override
  String daily_goal_remaining(int minutes) {
    return 'Faltam $minutes min';
  }

  @override
  String get daily_goal_done => 'Meta cumprida';

  @override
  String daily_goal_streak(int days) {
    return 'Sequência $days d';
  }

  @override
  String get daily_goal_celebrate => 'META CUMPRIDA!';

  @override
  String get evidence_title => 'EVIDÊNCIA DE APRENDIZAGEM';

  @override
  String get evidence_disclaimer => 'Evidência, não uma nota.';

  @override
  String get evidence_retention => 'Retenção em 7 dias';

  @override
  String get evidence_progress => 'Progresso comparável';

  @override
  String get evidence_transfer => 'Transferência';

  @override
  String get evidence_no_data => 'Ainda sem dados';

  @override
  String get evidence_needs_weeks => 'Você precisa de 4 semanas';

  @override
  String evidence_progress_value(int first, int last) {
    return '$first → $last missões/semana';
  }

  @override
  String evidence_transfer_value(int types) {
    return '$types tipos de missão';
  }

  @override
  String get progress_streak_at_risk => 'SEQUÊNCIA EM RISCO!';

  @override
  String get progress_hunter_desc =>
      'Veja a matriz de 11 atributos, os títulos equipados e o radar de poder';

  @override
  String get progress_weekly_voice => 'Prática semanal (minutos de voz)';

  @override
  String progress_vocab_learned(int count) {
    return 'Vocabulário aprendido ($count)';
  }

  @override
  String get progress_vocab_empty =>
      'Você ainda não acumulou vocabulário em chamadas de voz.';

  @override
  String get progress_vocab_section => 'Vocabulário';

  @override
  String get progress_hunter_attributes => 'ATRIBUTOS DO CAÇADOR';

  @override
  String get progress_xp_rank => 'Rank de XP';

  @override
  String get settings_opt_sfx_desc =>
      'Efeitos de combate, cargas de mana e calibração de nível';

  @override
  String get settings_opt_strict_title => 'AÇÃO ESTRITA';

  @override
  String get settings_opt_strict_desc =>
      'A IA só corrige quebras estruturais críticas.';

  @override
  String get settings_opt_compact_title => 'FEEDBACK COMPACTO';

  @override
  String get settings_opt_compact_desc =>
      'Correções rápidas com anotações de uma linha.';

  @override
  String get settings_opt_moderate_title => 'EXPLICAÇÃO MODERADA';

  @override
  String get settings_opt_moderate_desc =>
      'Correções equilibradas com 1 a 3 frases de detalhe.';

  @override
  String get settings_opt_detailed_title => 'DETALHAMENTO';

  @override
  String get settings_opt_detailed_desc =>
      'Explicações gramaticais detalhadas com exemplos contextuais.';

  @override
  String get settings_opt_oracle_title => 'MODO MESTRE DO ORÁCULO';

  @override
  String get settings_opt_oracle_desc => 'Análise completa dos erros.';

  @override
  String get settings_opt_companion_title => 'RITMO COMPANHEIRO';

  @override
  String get settings_opt_companion_desc =>
      'Respostas pacientes, calorosas e de apoio.';

  @override
  String get settings_opt_commander_title => 'RELATÓRIO DO COMANDANTE';

  @override
  String get settings_opt_commander_desc =>
      'Formal, muito estruturado e com correções organizadas.';

  @override
  String get settings_opt_boss_title => 'DESAFIO CALIBRE CHEFE';

  @override
  String get settings_opt_boss_desc =>
      'Vocabulário avançado e respostas rígidas.';

  @override
  String get settings_opt_strict_style_title => 'AÇÃO ESTRITA';

  @override
  String get settings_opt_strict_style_desc =>
      'Interrompe e corrige erros na hora.';

  @override
  String get settings_opt_balanced_title => 'BÚSSOLA EQUILIBRADA';

  @override
  String get settings_opt_balanced_desc =>
      'Mantém o ritmo do diálogo com correções estruturadas.';

  @override
  String get settings_opt_immersive_title => 'INCURSÕES IMERSIVAS';

  @override
  String get settings_opt_immersive_desc =>
      'Mantém o fluxo da fala; corrige apenas quebras graves.';

  @override
  String get settings_opt_casual_title => 'INCURSÃO CASUAL (10 MIN)';

  @override
  String get settings_opt_casual_desc => 'Prática diária de entrada rápida.';

  @override
  String get settings_opt_regular_title => 'INCURSÃO REGULAR (15 MIN)';

  @override
  String get settings_opt_regular_desc => 'Ritmo de aprendizado sólido.';

  @override
  String get settings_opt_serious_title => 'CAMPANHA SÉRIA (30 MIN)';

  @override
  String get settings_opt_serious_desc =>
      'Adquira marcadores de fluência rapidamente.';

  @override
  String get settings_opt_overload_title => 'SOBRECARGA (60 MIN)';

  @override
  String get settings_opt_overload_desc => 'Imersão total no máximo.';

  @override
  String get hunter_title_orco_caverna_f => 'Escrita de Orc da Caverna';

  @override
  String get hunter_title_orco_caverna_f_desc =>
      'Primeiros passos cometendo erros com coragem.';

  @override
  String get hunter_title_escriba_novato_e => 'Escriba Novato';

  @override
  String get hunter_title_escriba_novato_e_desc => '50% de frases limpas.';

  @override
  String get hunter_title_escriba_ciudad_d => 'Escriba da Cidade';

  @override
  String get hunter_title_escriba_ciudad_d_desc =>
      '65% de precisão gramatical.';

  @override
  String get hunter_title_escriba_imperial_c =>
      'Escriba da Biblioteca Imperial';

  @override
  String get hunter_title_escriba_imperial_c_desc =>
      '75% de precisão gramatical.';

  @override
  String get hunter_title_pluma_erudito_b => 'Pena do Erudito Real';

  @override
  String get hunter_title_pluma_erudito_b_desc => '85% de precisão gramatical.';

  @override
  String get hunter_title_pluma_archimago_a => 'Pena Arcanista do Arquimago';

  @override
  String get hunter_title_pluma_archimago_a_desc =>
      '92% de precisão gramatical.';

  @override
  String get hunter_title_pluma_celestial_s => 'Pena Celestial do Sábio';

  @override
  String get hunter_title_pluma_celestial_s_desc =>
      '97% de precisão gramatical.';

  @override
  String get hunter_title_monarca_sintaxis_ss => 'Monarca da Sintaxe Sagrada';

  @override
  String get hunter_title_monarca_sintaxis_ss_desc =>
      '99% de precisão gramatical.';

  @override
  String get hunter_title_creador_abismo_sss =>
      'Criador de Linguagens do Abismo';

  @override
  String get hunter_title_creador_abismo_sss_desc =>
      '100% de precisão gramatical impecável.';

  @override
  String get hunter_title_murcielago_ciego_f => 'Morcego Cego';

  @override
  String get hunter_title_murcielago_ciego_f_desc =>
      'Escutas iniciais com chat de texto.';

  @override
  String get hunter_title_oido_halcon_novato_d => 'Ouvido de Falcão Novato';

  @override
  String get hunter_title_oido_halcon_novato_d_desc => '2 lições sem chat.';

  @override
  String get hunter_title_oido_halcon_abismo_c => 'Ouvido de Falcão do Abismo';

  @override
  String get hunter_title_oido_halcon_abismo_c_desc =>
      '4 lições superadas às cegas.';

  @override
  String get hunter_title_sonar_monarca_sombras_s =>
      'Sonar Absoluto do Monarca das Sombras';

  @override
  String get hunter_title_sonar_monarca_sombras_s_desc =>
      '16 lições superadas às cegas.';

  @override
  String get hunter_title_oidor_susurros_sss =>
      'Ouvinte dos Sussurros do Universo';

  @override
  String get hunter_title_oidor_susurros_sss_desc =>
      'Mais de 30 lições às cegas.';

  @override
  String get hunter_title_monarca_impecable_5star =>
      'Monarca Impecável da Perfeição';

  @override
  String get hunter_title_monarca_impecable_5star_desc =>
      'Concedido por alcançar a 5ª Estrela Mítica (0 erros às cegas).';

  @override
  String get skill_fluidez_1 => 'Aprendiz de Palavras';

  @override
  String get skill_fluidez_1_desc => 'Começa a se expressar com continuidade.';

  @override
  String get skill_fluidez_2 => 'O Correio Veloz';

  @override
  String get skill_fluidez_2_desc => 'Fala com ritmo e fluência notável.';

  @override
  String get skill_fluidez_3 => 'Heraldo da Ventania';

  @override
  String get skill_fluidez_3_desc => 'Seu discurso flui sem esforço.';

  @override
  String get skill_fluidez_4 => 'Porta-voz dos Deuses';

  @override
  String get skill_fluidez_4_desc => 'Fluência quase divina ao conversar.';

  @override
  String get skill_fonetica_1 => 'Aprendiz da Voz';

  @override
  String get skill_fonetica_1_desc => 'Sua pronúncia começa a ficar clara.';

  @override
  String get skill_fonetica_2 => 'Eco do Coliseu';

  @override
  String get skill_fonetica_2_desc => 'Pronuncia com precisão notável.';

  @override
  String get skill_fonetica_3 => 'Cantor de Cristal';

  @override
  String get skill_fonetica_3_desc => 'Sua fonética é limpa e brilhante.';

  @override
  String get skill_fonetica_4 => 'Afinador Celestial';

  @override
  String get skill_fonetica_4_desc => 'Clareza fonética de outro plano.';

  @override
  String get skill_lexico_1 => 'Coletor de Palavras';

  @override
  String get skill_lexico_1_desc => 'Soma suas primeiras palavras dominadas.';

  @override
  String get skill_lexico_2 => 'Bibliotecário da Aldeia';

  @override
  String get skill_lexico_2_desc => 'Seu vocabulário cresce com solidez.';

  @override
  String get skill_lexico_3 => 'Escriba do Abismo';

  @override
  String get skill_lexico_3_desc => 'Domina um vocabulário extenso.';

  @override
  String get skill_lexico_4 => 'Lexicógrafo Eterno';

  @override
  String get skill_lexico_4_desc => 'Seu léxico não tem fronteiras.';

  @override
  String get skill_precision_1 => 'Aprendiz das Regras';

  @override
  String get skill_precision_1_desc => 'Estruturas simples já são sólidas.';

  @override
  String get skill_precision_2 => 'Aprendiz de Runas';

  @override
  String get skill_precision_2_desc => 'Sua gramática ganha consistência.';

  @override
  String get skill_precision_3 => 'Gramático do Coliseu';

  @override
  String get skill_precision_3_desc => 'Constrói frases com domínio.';

  @override
  String get skill_precision_4 => 'Forjador de Sintaxe';

  @override
  String get skill_precision_4_desc => 'Sua precisão gramatical é lendária.';

  @override
  String get skill_constancia_1 => 'Aprendiz Constante';

  @override
  String get skill_constancia_1_desc => 'Três dias seguidos praticando.';

  @override
  String get skill_constancia_2 => 'Guardião do Fogo';

  @override
  String get skill_constancia_2_desc => 'Uma semana ininterrupta.';

  @override
  String get skill_constancia_3 => 'Sentinela do Amanhecer';

  @override
  String get skill_constancia_3_desc => 'Um mês de constância firme.';

  @override
  String get skill_constancia_4 => 'Lenda da Sequência';

  @override
  String get skill_constancia_4_desc => 'Cem dias de dedicação absoluta.';

  @override
  String get skill_carisma_1 => 'Novato da Guilda';

  @override
  String get skill_carisma_1_desc => 'Você se desenvolve em conversas.';

  @override
  String get skill_carisma_2 => 'Alma da Taberna';

  @override
  String get skill_carisma_2_desc => 'Conecta-se naturalmente com os outros.';

  @override
  String get skill_carisma_3 => 'Embaixador do Reino';

  @override
  String get skill_carisma_3_desc => 'Conduz a conversa com desenvoltura.';

  @override
  String get skill_carisma_4 => 'Oráculo Menor';

  @override
  String get skill_carisma_4_desc =>
      'Seu carisma conversacional é de outro mundo.';

  @override
  String get paywall_upgrade_title => 'SUBINHA PARA PREMIUM';

  @override
  String get paywall_upgrade_subtitle =>
      'Seu estamento define seu mana mensal e seu teto de prestígio. O esforço (Aura) decide seu título.';

  @override
  String get paywall_f_monthly => 'MENSAL';

  @override
  String get paywall_f_annual => 'ANUAL';

  @override
  String get paywall_subscribe => 'ASSINAR AGORA';

  @override
  String get paywall_restore => 'RESTAURAR';

  @override
  String get paywall_legal =>
      'Cancele quando quiser pela App Store / Play Store. Aplicam-se Termos e Condições.';

  @override
  String get paywall_err_checkout => 'Não foi possível abrir o checkout.';

  @override
  String get paywall_feature_mana =>
      'Consumo de mana em tempo real e métricas de voz';

  @override
  String get paywall_feature_titles =>
      'Desbloqueie o inventário de 63 títulos de ranque (de F a SSS)';

  @override
  String get paywall_feature_rooms =>
      'Acesso 24/7 às salas de voz do Grande Salão de Debate';

  @override
  String get paywall_feature_modes =>
      'Seletor tático entre Modo Voz e Modo Escrita';

  @override
  String get paywall_feature_missions =>
      'Missões premium e recompensas de investida semanal';

  @override
  String get paywall_active_title => 'SEU PLANO ATUAL';

  @override
  String get paywall_active_subtitle =>
      'Você já tem Premium. Gerencie ou mude seu plano aqui.';

  @override
  String get paywall_load_error => 'Não foi possível carregar os planos.';

  @override
  String get paywall_no_packages =>
      'Nenhum plano disponível para este ciclo de cobrança.';

  @override
  String get paywall_nothing_restored => 'Nenhuma compra para restaurar.';

  @override
  String get paywall_current_plan => 'PLANO ATUAL';

  @override
  String get paywall_manage_subscription => 'GERENCIAR ASSINATURA';

  @override
  String get paywall_plans_title => 'ESCOLHA SEU ESTAMENTO';

  @override
  String get paywall_per_month => '/mês';

  @override
  String paywall_plan_mana(String amount) {
    return '$amount de mana/mês';
  }

  @override
  String paywall_plan_report_weeks(int weeks) {
    String _temp0 = intl.Intl.pluralLogic(
      weeks,
      locale: localeName,
      other: '$weeks semanas de histórico no relatório',
      one: '1 semana de histórico no relatório',
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
    return '$days dias grátis, depois $price/mês';
  }

  @override
  String get mana_inventory_title => 'INVENTÁRIO DE MANA';

  @override
  String get mana_inventory_empty => 'Ainda não há elixires ou gemas na bolsa.';

  @override
  String get mana_gem_label => 'GEMA';

  @override
  String get mana_elixir_label => 'ELIXIR';

  @override
  String mana_expiry_countdown(Object hours, Object minutes) {
    return 'Expira em ${hours}h ${minutes}m';
  }

  @override
  String get mana_item_equipped => 'Item de mana equipado';

  @override
  String get mana_equip => 'EQUIPAR';

  @override
  String get summary_next_lesson => 'PRÓXIMA LIÇÃO';

  @override
  String get oracle_challenge_title => 'AVALIAÇÃO DO ORÁCULO';

  @override
  String get oracle_challenge_ready =>
      'O Oráculo o espera. Desafio disponível!';

  @override
  String oracle_challenge_progress(Object percent) {
    return 'Complete 80% para desafiar o Oráculo ($percent%)';
  }

  @override
  String get onboarding_english_only =>
      'Você aprenderá inglês. Pode alterar o idioma da interface nas Configurações.';

  @override
  String corrections_chip_label(int count) {
    return 'CORRIGIR $count';
  }

  @override
  String get corrections_you_wrote => 'Escreveste';

  @override
  String get corrections_suggested => 'Melhor';

  @override
  String get my_errors_title => 'MEUS ERROS';

  @override
  String get my_errors_short => 'ERROS';

  @override
  String get my_errors_subtitle =>
      'Agrupados por tipo e recorrência. Os erros recorrentes alimentam as tuas missões de reforço.';

  @override
  String get my_errors_empty =>
      'Ainda não há erros registados. Termina uma lição e as tuas correções aparecerão aqui.';

  @override
  String get my_errors_error =>
      'Não foi possível carregar os teus erros. Verifica a ligação e tenta novamente.';

  @override
  String get my_errors_retry => 'TENTAR NOVAMENTE';

  @override
  String my_errors_times(int count) {
    return '${count}x';
  }

  @override
  String get my_errors_recurring_badge => 'RECORRENTE';

  @override
  String get correction_type_grammar => 'Gramática';

  @override
  String get correction_type_vocabulary => 'Vocabulário';

  @override
  String get correction_type_word_choice => 'Escolha de palavra';

  @override
  String get correction_type_pronunciation_hint => 'Pronúncia';

  @override
  String get correction_type_typo_stt => 'Transcrição';

  @override
  String get notif_settings_title => 'LEMBRETE DIÁRIO';

  @override
  String get notif_settings_desc =>
      'Um lembrete por dia, na hora que você escolher. Nunca à noite.';

  @override
  String get notif_time_label => 'HORA DO LEMBRETE';

  @override
  String get notif_days_label => 'DIAS ATIVOS';

  @override
  String get notif_quiet_hours =>
      'O silêncio noturno vai das 22:00 às 08:00, então o lembrete mudou para as 08:00.';

  @override
  String notif_time_updated(String time) {
    return 'Lembrete definido para as $time.';
  }

  @override
  String get widget_streak_label => 'SEQUÊNCIA';

  @override
  String get widget_minutes_label => 'HOJE';

  @override
  String get widget_minutes_unit => 'min';

  @override
  String get widget_practice => 'PRATICAR';

  @override
  String get widget_empty_title => 'Abra o app para começar';

  @override
  String get widget_empty_body =>
      'Sua sequência e os minutos de hoje aparecem aqui ao abrir o app.';

  @override
  String get notif_permission_denied =>
      'As notificações estão bloqueadas. Ative-as em Configurações do Android > Apps > Dungeon of English > Notificações.';

  @override
  String get notif_permission_open_settings => 'ABRIR CONFIGURAÇÕES DO ANDROID';

  @override
  String get notif_prompt_title => 'NÃO PERCA SUA SEQUÊNCIA';

  @override
  String get notif_prompt_body =>
      'Ative um lembrete diário e avisaremos na hora que você escolher. Você pode mudar ou desativar em Configurações.';

  @override
  String get notif_prompt_accept => 'ATIVAR';

  @override
  String get mini_conv_badge => 'TESTE DE 60 SEGUNDOS';

  @override
  String get mini_conv_title => 'Peça um café';

  @override
  String get mini_conv_subtitle =>
      'Fale com Mira, a taberneira. Uma ou duas respostas, sem prova e sem gastar mana.';

  @override
  String mini_conv_turn_counter(int current, int total) {
    return 'Resposta $current de $total';
  }

  @override
  String get mini_conv_your_turn => 'SUA VEZ';

  @override
  String get mini_conv_input_hint => 'Escreva sua resposta em inglês...';

  @override
  String get mini_conv_send => 'ENVIAR';

  @override
  String get mini_conv_record => 'RESPONDER COM A VOZ';

  @override
  String get mini_conv_recording => 'GRAVANDO... TOQUE PARA PARAR';

  @override
  String get mini_conv_transcribing => 'TRANSCREVENDO...';

  @override
  String get mini_conv_skip => 'PULAR POR ENQUANTO';

  @override
  String get mini_conv_mic_denied =>
      'Não foi possível usar o microfone. Você ainda pode escrever sua resposta.';

  @override
  String get mini_conv_voice_empty =>
      'Não ouvimos nenhuma voz. Tente de novo ou escreva sua resposta.';

  @override
  String get mini_conv_voice_failed =>
      'Não foi possível transcrever seu áudio. Tente de novo ou escreva sua resposta.';

  @override
  String get mini_conv_unlocked_label => 'FRASE DESBLOQUEADA';

  @override
  String get mini_conv_unlocked_translation =>
      'Um café com leite para levar, por favor.';

  @override
  String get mini_conv_cta => 'COMEÇAR MINHA AVENTURA';

  @override
  String get mini_conv_unavailable_title => 'MIRA NÃO ESTÁ DISPONÍVEL';

  @override
  String get mini_conv_unavailable_body =>
      'Sua aventura começa de qualquer forma. Nenhum mana foi gasto: esta prova é por nossa conta.';

  @override
  String get mini_conv_continue => 'CONTINUAR';

  @override
  String get notif_prompt_later => 'AGORA NÃO';

  @override
  String get notif_enabled_ok => 'Lembrete diário ativado.';

  @override
  String get notif_save_error =>
      'Não foi possível salvar o lembrete. Verifique sua conexão e tente de novo.';

  @override
  String get notif_reminder_title => 'Sua sequência espera';

  @override
  String get notif_reminder_body =>
      'Uma incursão curta hoje mantém a sequência viva. Seu tutor está pronto.';

  @override
  String get boss_exam_title => 'CHEFE DA MASMORRA: O ORÁCULO';

  @override
  String get boss_exam_state_ready =>
      'O chefe espera por você. Desafio disponível!';

  @override
  String get boss_exam_state_locked =>
      'Cumpra os requisitos para desafiar o chefe.';

  @override
  String boss_exam_state_locked_progress(int percent) {
    return 'Complete 80% das lições do nível ($percent%)';
  }

  @override
  String boss_exam_state_cooldown(String time) {
    return 'O chefe descansa até $time.';
  }

  @override
  String get boss_req_level => 'Nível atribuído';

  @override
  String get boss_req_practice => 'Prática: metas, sequência ou minutos';

  @override
  String get boss_req_cooldown => 'Espera entre tentativas';

  @override
  String get boss_hud_title => 'CHEFE: O ORÁCULO';

  @override
  String boss_hud_turns(int current, int max) {
    return 'TURNO $current/$max';
  }

  @override
  String get boss_result_victory => 'CHEFE DERROTADO';

  @override
  String get boss_result_defeat => 'O CHEFE RESISTE';

  @override
  String get boss_result_initial => 'NÍVEL ATRIBUÍDO';

  @override
  String get boss_result_missing => 'Nenhum resultado disponível.';

  @override
  String boss_result_level_up(String from, String to) {
    return '$from para $to';
  }

  @override
  String boss_result_level_assigned(String level) {
    return 'Seu nível: $level';
  }

  @override
  String boss_result_level_kept(String level) {
    return 'Você mantém $level';
  }

  @override
  String get boss_result_forced =>
      'O exame atingiu o limite e foi avaliado com as respostas dadas.';

  @override
  String get boss_result_rubric => 'RÚBRICA (6 DIMENSÕES)';

  @override
  String boss_result_average(int value, int threshold) {
    return 'média $value/100 - aprova $threshold';
  }

  @override
  String get boss_result_no_scores =>
      'O Oráculo não conseguiu pontuar a rúbrica nesta tentativa.';

  @override
  String get boss_result_reason_title => 'POR QUE AINDA NÃO';

  @override
  String get boss_result_reason_rubric =>
      'Foi perto: a média ou alguma dimensão fica abaixo do limite.';

  @override
  String get boss_result_reason_no_improvement =>
      'Seu nível é sólido, mas ainda não supera sua faixa atual.';

  @override
  String get boss_result_reason_unavailable =>
      'O Oráculo não conseguiu pontuar a rúbrica, então o nível é mantido.';

  @override
  String boss_result_retry_at(String time) {
    return 'Próxima tentativa: $time';
  }

  @override
  String get boss_result_focus_title => 'O QUE REFORÇAR';

  @override
  String get boss_result_reinforce => 'PRATICAR LIÇÕES DE REFORÇO';

  @override
  String get boss_result_home => 'VOLTAR À ROTA';

  @override
  String get boss_dim_listening => 'Compreensão';

  @override
  String get boss_dim_fluency => 'Fluência';

  @override
  String get boss_dim_grammar => 'Gramática';

  @override
  String get boss_dim_vocabulary => 'Vocabulário';

  @override
  String get boss_dim_pronunciation => 'Pronúncia';

  @override
  String get boss_dim_naturalness => 'Naturalidade';

  @override
  String get weekly_title => 'RELATORIO SEMANAL';

  @override
  String get weekly_subtitle =>
      'Dados calculados no servidor. Uma semana sem atividade diz isso em vez de mostrar zeros.';

  @override
  String get weekly_empty => 'Esta semana não tem atividade registrada.';

  @override
  String get weekly_empty_hint =>
      'Pratique uma conversa ou uma lição e o relatório se completa.';

  @override
  String get weekly_new_words => 'Palavras novas';

  @override
  String get weekly_words_reviewed => 'Palavras revisadas';

  @override
  String get weekly_words_mastered => 'Palavras dominadas';

  @override
  String get weekly_corrections => 'Erros corrigidos';

  @override
  String get weekly_top_error => 'Erro mais frequente';

  @override
  String get weekly_lessons => 'Lições concluídas';

  @override
  String get weekly_minutes => 'Minutos';

  @override
  String get weekly_practice_days => 'Dias praticados';

  @override
  String get weekly_per_day => 'Média por dia praticado';

  @override
  String get weekly_level => 'Nível estimado';

  @override
  String get weekly_level_unknown => 'Ainda sem avaliação';

  @override
  String get weekly_this_week => 'Esta semana';

  @override
  String get weekly_previous_week => 'Semana anterior';

  @override
  String get weekly_next_week => 'Próxima semana';

  @override
  String weekly_range(String start, String end) {
    return '$start a $end';
  }

  @override
  String get weekly_error => 'Não foi possível carregar seu relatório semanal.';

  @override
  String get weekly_retry => 'TENTAR DE NOVO';

  @override
  String get weekly_open => 'VER RELATÓRIO';

  @override
  String weekly_history_locked(int weeks) {
    String _temp0 = intl.Intl.pluralLogic(
      weeks,
      locale: localeName,
      other: 'Seu plano guarda $weeks semanas de histórico.',
      one: 'Seu plano guarda 1 semana de histórico.',
    );
    return '$_temp0';
  }

  @override
  String get weekly_history_upgrade =>
      'Melhore seu plano para abrir semanas anteriores.';

  @override
  String get checkpoint_title => 'CHECAGEM DE NÍVEL';

  @override
  String checkpoint_body(int count) {
    return 'Você concluiu $count lições desde seu último desafio com o Oráculo.';
  }

  @override
  String get checkpoint_action => 'DESAFIAR O ORÁCULO';

  @override
  String checkpoint_remaining(int count) {
    return '$count lições para a próxima checagem de nível';
  }

  @override
  String boss_exam_not_enough(int min) {
    return 'O Oráculo precisa de pelo menos $min respostas para julgar o exame. Esta tentativa não conta.';
  }

  @override
  String boss_exam_cooldown(String time) {
    return 'O chefe não aceita outro desafio até $time.';
  }

  @override
  String get listening_path_title => 'COMPREENSÃO AUDITIVA';

  @override
  String listening_path_next(String title) {
    return 'Próximo: $title';
  }

  @override
  String listening_path_progress(int done, int total) {
    return '$done/$total superados';
  }

  @override
  String get listening_empty =>
      'Ainda não há exercícios de escuta para este nível.';

  @override
  String get listening_play => 'OUVIR DIÁLOGO';

  @override
  String get listening_stop => 'PARAR';

  @override
  String get listening_play_again => 'OUVIR NOVAMENTE';

  @override
  String get listening_transcript_show => 'MOSTRAR TRANSCRIÇÃO';

  @override
  String get listening_transcript_hide => 'OCULTAR TRANSCRIÇÃO';

  @override
  String listening_question_counter(int current, int total) {
    return 'PERGUNTA $current DE $total';
  }

  @override
  String get listening_next => 'PRÓXIMO';

  @override
  String get listening_previous => 'ANTERIOR';

  @override
  String get listening_submit => 'VERIFICAR RESPOSTAS';

  @override
  String get listening_submitting => 'CORRIGINDO...';

  @override
  String get listening_result_passed => 'EXERCÍCIO CONCLUÍDO';

  @override
  String get listening_result_failed => 'AINDA NÃO';

  @override
  String listening_result_score(int score, int total) {
    return '$score de $total corretas';
  }

  @override
  String listening_result_missions(int count) {
    return '+$count de progresso nas missões';
  }

  @override
  String listening_result_practice(int minutes) {
    return '$minutes min de prática registrados';
  }

  @override
  String get listening_result_retry => 'REPETIR';

  @override
  String get listening_back_path => 'VOLTAR À ROTA';

  @override
  String get listening_error_load =>
      'Não foi possível carregar este exercício. Verifique sua conexão e tente novamente.';

  @override
  String get listening_retry_send => 'TENTAR ENVIAR DE NOVO';

  @override
  String listening_explanation(String answer) {
    return 'Resposta correta: $answer';
  }
}
