import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../conversation/presentation/providers/conversation_providers.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../../onboarding/domain/models/cefr_rank.dart';
import '../providers/chat_rooms_providers.dart';
import '../../../../l10n/app_localizations.dart';

/// Fusiona un chunk del stream en el historial del mini-chat del Maestre.
///
/// Issue #62: el historial guarda `_streaming` como String (`'true'`). Antes se
/// comparaba con el booleano `true`, la condición nunca se cumplía y **cada
/// chunk añadía una burbuja nueva** con todo el texto acumulado.
///
/// Se extrae para poder probarlo sin montar el widget completo.
@visibleForTesting
void applyGuildMasterChunk(List<Map<String, String>> history, String text) {
  if (history.isNotEmpty &&
      history.last['role'] == 'assistant' &&
      history.last['_streaming'] == 'true') {
    history.last['content'] = text;
    return;
  }
  history.add({'role': 'assistant', 'content': text, '_streaming': 'true'});
}

/// NPC Maestre de Mesa (Fase 7 · G-F) — control flotante arrastrable.
///
/// Flota sobre el Salón del Gremio, muestra la imagen del Oráculo y, al
/// expandirse, revela la sugerencia de mesa según el nivel CEFR y un
/// mini-chat con el NPC (responde vía el mismo pipeline DeepSeek SSE).
///
/// NOTA: es ESTÁTICO (sin animación de flotación) para evitar relayouts
/// continuos que causaban "RenderBox was not laid out" en el Stack del Salón.
class GuildMasterFloatingBanner extends ConsumerStatefulWidget {
  const GuildMasterFloatingBanner({super.key});

  @override
  ConsumerState<GuildMasterFloatingBanner> createState() =>
      _GuildMasterFloatingBannerState();
}

class _GuildMasterFloatingBannerState extends ConsumerState<GuildMasterFloatingBanner> {
  Offset _position = const Offset(16, 120);
  bool _isExpanded = false;
  bool _isChatOpen = false;
  bool _chatLoading = false;
  final TextEditingController _chatController = TextEditingController();
  final List<Map<String, String>> _chatHistory = [];
  final ScrollController _chatScroll = ScrollController();

  @override
  void dispose() {
    _chatController.dispose();
    _chatScroll.dispose();
    super.dispose();
  }

  String _suggestForLevel(String cefr) {
    switch (cefr.toUpperCase()) {
      case 'PRE-A1':
      case 'A1':
      case 'A2':
        return AppLocalizations.of(context)?.guild_rec_beginner ??
            'Recomiendo la Taberna del Aprendiz: es la mesa perfecta para cazadores novatos.';
      case 'B1':
      case 'B2':
        return AppLocalizations.of(context)?.guild_rec_intermediate ??
            'La Mesa Redonda de Tácticas te espera: debates y fluidez intermedia.';
      case 'C1':
      case 'C2':
        return AppLocalizations.of(context)?.guild_rec_master ??
            'El Consejo Supremo de Altos Cazadores es tu lugar: elocuencia de nivel maestro.';
      default:
        return AppLocalizations.of(context)?.guild_rec_default ??
            'Elige una mesa y comienza tu raid de conversación.';
    }
  }

  String _suggestedRoomKeyword(String cefr) {
    switch (cefr.toUpperCase()) {
      case 'PRE-A1':
      case 'A1':
      case 'A2':
        return AppLocalizations.of(context)?.guild_table_beginner ?? 'Aprendiz';
      case 'B1':
      case 'B2':
        return AppLocalizations.of(context)?.guild_table_tactics ?? 'Tácticas';
      case 'C1':
      case 'C2':
        return AppLocalizations.of(context)?.guild_table_council ?? 'Consejo';
      default:
        return '';
    }
  }

  void _followSuggestion() {
    final rooms = ref.read(chatRoomsListProvider).value ?? [];
    final keyword = _suggestedRoomKeyword(
      (ref.read(userProgressProvider).value?['level_code'] as String? ?? 'A1'),
    );
    final target = rooms
        .where((r) => (r['title'] as String? ?? '').contains(keyword))
        .toList();
    if (target.isNotEmpty) {
      context.push('/voice-room?roomId=${target.first['id']}');
    } else if (rooms.isNotEmpty) {
      context.push('/voice-room?roomId=${rooms.first['id']}');
    }
  }

  /// Envía un mensaje del aventurero al Maestre de Mesa y muestra la respuesta
  /// del NPC (reutiliza el pipeline DeepSeek SSE, sin TTS).
  Future<void> _sendChatMessage() async {
    final text = _chatController.text.trim();
    if (text.isEmpty || _chatLoading) return;
    _chatController.clear();

    final cefr = (ref.read(userProgressProvider).value?['level_code'] as String? ?? 'A1');
    setState(() {
      _chatHistory.add({'role': 'user', 'content': text});
      _chatLoading = true;
    });

    final system = {
      'role': 'system',
      'content':
          'You are the Guild Master of a medieval adventurer guild. You guide '
          'an English learner (CEFR $cefr) toward the right voice tables, missions '
          'and practice tips. Be brief, warm and RPG-themed (2-3 sentences). Always '
          'answer in English, at CEFR $cefr level.',
    };
    // Issue #62: `_chatHistory` lleva la marca interna `_streaming`, que no
    // forma parte del contrato de DeepSeek; se filtra antes de enviar.
    final history = <Map<String, String>>[
      system,
      for (final m in _chatHistory)
        {'role': m['role'] ?? 'user', 'content': m['content'] ?? ''},
    ];

    try {
      final repo = ref.read(conversationRepositoryProvider);
      final buffer = StringBuffer();
      await for (final chunk in repo.getTutorResponseStream(history)) {
        buffer.write(chunk);
        setState(() {
          applyGuildMasterChunk(_chatHistory, buffer.toString());
        });
        _scrollToBottom();
      }
      // Normalizar: quitar la marca de streaming del último mensaje.
      setState(() {
        if (_chatHistory.isNotEmpty) {
          _chatHistory.last.remove('_streaming');
        }
        _chatLoading = false;
      });
    } catch (e) {
      setState(() {
        _chatHistory.add({
          'role': 'assistant',
          'content':
              AppLocalizations.of(context)?.guild_meditating ??
                  'El Maestre de Mesa está meditando... Inténtalo de nuevo.',
        });
        _chatLoading = false;
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatScroll.hasClients) {
        _chatScroll.animateTo(
          _chatScroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(userProgressProvider).value ?? {};
    final cefr = progress['level_code'] as String? ?? 'A1';
    final gameRank = (progress['game_rank'] as String?)?.isNotEmpty == true
        ? (progress['game_rank'] as String)!
        : CefrRank.gameRankFromCefr(cefr);
    final screenSize = MediaQuery.of(context).size;

    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            final newX = (_position.dx + details.delta.dx)
                .clamp(10.0, screenSize.width - 230.0);
            final newY = (_position.dy + details.delta.dy)
                .clamp(70.0, screenSize.height - 260.0);
            _position = Offset(newX, newY);
          });
        },
        onTap: () => setState(() {
          _isExpanded = !_isExpanded;
          _isChatOpen = false;
        }),
        child: _isExpanded ? _buildExpanded(gameRank) : _buildCollapsed(gameRank),
      ),
    );
  }

  Widget _buildCollapsed(String cefr) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.monsterPillBg.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.royalGold, width: 1.6),
        boxShadow: [
          BoxShadow(
            color: AppColors.royalGold.withValues(alpha: 0.45),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipOval(
            child: Image.asset(
              'assets/images/avatars/oracle_01.png',
              width: 30,
              height: 30,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 30,
                height: 30,
                color: AppColors.surfaceContainerLow,
                child: const Icon(Icons.auto_awesome_rounded, color: AppColors.royalGold, size: 14),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)?.guild_master ?? 'MAESTRE DE MESA',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: AppColors.royalGold,
                ),
              ),
              Text(
                AppLocalizations.of(context)?.guild_rank_level(cefr) ?? 'RANGO $cefr',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(width: 6),
          const Icon(Icons.drag_indicator_rounded,
              color: AppColors.onSurface, size: 14),
        ],
      ),
    );
  }

  Widget _buildExpanded(String cefr) {
    return SizedBox(
      width: 250,
      child: GlassCard(
        borderColor: AppColors.royalGold.withValues(alpha: 0.5),
        showRunicCorners: true,
        runicColor: AppColors.royalGold,
        padding: const EdgeInsets.all(12),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              ClipOval(
                child: Image.asset(
                  'assets/images/avatars/oracle_01.png',
                  width: 34,
                  height: 34,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 34,
                    height: 34,
                    color: AppColors.surfaceContainerLow,
                    child: const Icon(Icons.auto_awesome_rounded, color: AppColors.royalGold, size: 16),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)?.guild_master ?? 'MAESTRE DE MESA',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: AppColors.royalGold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      AppLocalizations.of(context)?.guild_rank_level(cefr) ?? 'RANGO $cefr',
                      style: TextStyle(
                        fontSize: 8,
                        color: AppColors.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _isExpanded = false),
                child: const Icon(Icons.close_rounded,
                    color: AppColors.onSurface, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_isChatOpen) ...[
            _buildChat(cefr),
          ] else ...[
            Text(
              _suggestForLevel(cefr),
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.onSurface.withValues(alpha: 0.8),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _followSuggestion,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.royalGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.royalGold.withValues(alpha: 0.5)),
                ),
                child: Text(
                  AppLocalizations.of(context)?.guild_follow_suggestion ?? 'SIGUE MI SUGERENCIA →',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: AppColors.royalGold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () => setState(() => _isChatOpen = true),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.manaCyan.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.manaCyan.withValues(alpha: 0.4)),
                ),
                child: Text(
                  '💬 HABLAR CON EL MAESTRE',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: AppColors.manaCyan,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
      ),
    );
  }

  /// Mini-chat con el Maestre de Mesa (reutiliza el pipeline DeepSeek SSE).
  Widget _buildChat(String cefr) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)?.guild_ask_master(cefr) ?? 'Consulta al Maestre (Nivel $cefr):',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 8,
            fontWeight: FontWeight.bold,
            color: AppColors.manaCyan,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        // Mensajes (altura fija para evitar fallos de layout durante el streaming)
        SizedBox(
          height: 130,
          child: SingleChildScrollView(
            controller: _chatScroll,
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_chatHistory.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      AppLocalizations.of(context)?.guild_ask_hint ??
                          'Pregúntame qué mesa practicar, qué misión tomar o cómo mejorar tu rango.',
                      style: GoogleFonts.inter(fontSize: 10, color: AppColors.onSurfaceVariant, height: 1.3),
                    ),
                  ),
                for (final msg in _chatHistory) ...[
                  Align(
                    alignment: msg['role'] == 'user' ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      constraints: const BoxConstraints(maxWidth: 190),
                      decoration: BoxDecoration(
                        color: msg['role'] == 'user'
                            ? AppColors.manaCyan.withValues(alpha: 0.15)
                            : AppColors.royalGold.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: msg['role'] == 'user'
                              ? AppColors.manaCyan.withValues(alpha: 0.3)
                              : AppColors.royalGold.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        msg['content'] ?? '',
                        style: GoogleFonts.inter(fontSize: 10, color: AppColors.onSurface, height: 1.3),
                      ),
                    ),
                  ),
                ],
                if (_chatLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.manaCyan),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        // Input
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _chatController,
                style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurface),
                decoration: InputDecoration(
                  hintText:
                      AppLocalizations.of(context)?.guild_input_hint ?? 'Escribe tu pregunta...',
                  hintStyle: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant),
                  filled: true,
                  fillColor: AppColors.onSurface.withValues(alpha: 0.05),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(color: AppColors.onSurface.withValues(alpha: 0.15)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(color: AppColors.onSurface.withValues(alpha: 0.15)),
                  ),
                ),
                onSubmitted: (_) => _sendChatMessage(),
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: _sendChatMessage,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.manaCyan.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.manaCyan.withValues(alpha: 0.4)),
                ),
                child: const Icon(Icons.send_rounded, color: AppColors.manaCyan, size: 14),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
