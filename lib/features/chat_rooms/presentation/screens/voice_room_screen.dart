import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../economy/presentation/providers/economy_providers.dart';
import '../providers/chat_rooms_providers.dart';
import '../../../../core/widgets/rpg_avatar.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../../../core/widgets/mana_meter_widget.dart';
import '../../../../core/widgets/cyber_manhwa_background.dart';
import '../../../../core/widgets/segmented_bar.dart';
import '../../../../core/widgets/system_snack.dart';
import '../../../../l10n/app_localizations.dart';

class VoiceRoomScreen extends ConsumerStatefulWidget {
  final String roomId;

  const VoiceRoomScreen({super.key, required this.roomId});

  @override
  ConsumerState<VoiceRoomScreen> createState() => _VoiceRoomScreenState();
}

class _VoiceRoomScreenState extends ConsumerState<VoiceRoomScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();

  bool _isHandRaised = false;
  bool _showDemoBanner = true;
  bool _showAudience = true;

  // LiveKit (voz real)
  Room? _room;
  bool _micOn = false;
  Set<String> _speakingIds = const {};
  Timer? _speakingTimer;

  // Presencia en la mesa
  String _presenceState = 'standing'; // 'standing' | 'seated'
  int? _mySeat;
  Timer? _heartbeatTimer;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final user = ref.read(currentUserProvider);
      if (user != null) {
        try {
          // Entrada a la mesa en estado "de pie" (escucha + chat, sin audio).
          await ref.read(chatRoomsRepositoryProvider).joinTable(widget.roomId);
          _startHeartbeat();
        } catch (_) {}
      }
      await _connectLiveKit();
      _startSpeakingPoll();
    });
  }

  @override
  void dispose() {
    _speakingTimer?.cancel();
    _heartbeatTimer?.cancel();
    _room?.disconnect();
    _messageController.dispose();
    _chatScrollController.dispose();
    super.dispose();
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      ref.read(chatRoomsRepositoryProvider).touchPresence(widget.roomId);
    });
  }

  /// Conecta el micrófono real al room de LiveKit (edge function livekit-token).
  /// `canPublish` lo decide el servidor según `presence_state` (solo seated).
  Future<void> _connectLiveKit() async {
    if (_room != null) return;
    try {
      final user = ref.read(currentUserProvider);
      if (user == null) return;
      final supabase = Supabase.instance.client;
      final res = await supabase.functions.invoke(
        'livekit-token',
        queryParameters: {'room': widget.roomId, 'publish': _presenceState == 'seated' ? 'true' : 'false'},
      );
      final data = res.data as Map<String, dynamic>;
      final room = Room();
      await room.connect(data['url'] as String, data['token'] as String);
      // Solo publica audio si está sentado (canPublish lo refuerza el servidor).
      final seated = _presenceState == 'seated';
      if (seated) {
        await room.localParticipant?.setMicrophoneEnabled(true);
      }
      if (!mounted) {
        await room.disconnect();
        return;
      }
      setState(() {
        _room = room;
        _micOn = seated;
      });
    } catch (e) {
      debugPrint('LiveKit connect failed (presencia sin audio): $e');
    }
  }

  /// Reconecta a LiveKit al cambiar de estado (sentado ↔ de pie). Los grants
  /// de LiveKit son inmutables por conexión: hay que reconectar con el token
  /// correspondiente al nuevo estado.
  Future<void> _reconnectLiveKitForState() async {
    await _disconnectLiveKit();
    if (mounted) await _connectLiveKit();
    // _disconnectLiveKit cancela el poll de habla: se reinicia tras reconectar.
    _startSpeakingPoll();
    if (mounted) setState(() {});
  }

  /// Muestra quién habla de verdad usando los niveles de audio de LiveKit.
  void _startSpeakingPoll() {
    _speakingTimer?.cancel();
    _speakingTimer = Timer.periodic(const Duration(milliseconds: 600), (_) {
      if (!mounted || _room == null) return;
      final ids = _room!.activeSpeakers.map((p) => p.identity).toSet();
      if (!setEquals(ids, _speakingIds)) {
        setState(() => _speakingIds = ids);
      }
    });
  }

  Future<void> _toggleMic() async {
    // Solo se puede transmitir estando sentado.
    if (_presenceState != 'seated') {
      SystemSnack.show(context, AppLocalizations.of(context)?.voice_seat_to_speak ?? 'SIÉNTATE EN UNA SILLA PARA HABLAR', type: SystemSnackType.warning);
      return;
    }
    final lp = _room?.localParticipant;
    if (lp == null) return;
    final next = !_micOn;
    try {
      await lp.setMicrophoneEnabled(next);
      setState(() => _micOn = next);
    } catch (_) {}
  }

  Future<void> _disconnectLiveKit() async {
    _speakingTimer?.cancel();
    final r = _room;
    _room = null;
    if (r != null) {
      try {
        await r.disconnect();
      } catch (_) {}
    }
    if (mounted) setState(() => _micOn = false);
  }

  void _leaveRoom() async {
    await _disconnectLiveKit();
    _heartbeatTimer?.cancel();
    final user = ref.read(currentUserProvider);
    if (user != null) {
      await ref.read(chatRoomsRepositoryProvider).leaveRoom(
            roomId: widget.roomId,
            userId: user.id,
          );
    }
    if (mounted) {
      ref.invalidate(chatRoomsListProvider);
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/chat-rooms');
      }
    }
  }

  /// Se sienta en la silla [seat] (1-8). Actualiza el estado local y reconecta
  /// LiveKit con canPublish=true para poder transmitir.
  void _sitDown(int seat) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    try {
      await ref.read(chatRoomsRepositoryProvider).sitDown(
            widget.roomId,
            seat,
          );
      if (!mounted) return;
      setState(() {
        _presenceState = 'seated';
        _mySeat = seat;
      });
      SystemSnack.show(context, AppLocalizations.of(context)?.voice_seated_in('$seat') ?? 'TE SENTASTE EN LA SILLA $seat', type: SystemSnackType.success);
      await _reconnectLiveKitForState();
      if (mounted) ref.invalidate(chatRoomParticipantsProvider(widget.roomId));
    } on ChatRoomException catch (e) {
      if (mounted) {
        SystemSnack.show(context, e.message, type: SystemSnackType.error);
        ref.invalidate(chatRoomParticipantsProvider(widget.roomId));
      }
    } catch (e) {
      if (mounted) {
        SystemSnack.show(context, 'Error al sentarte: $e', type: SystemSnackType.error);
      }
    }
  }

  /// Pide silla: se sienta si hay libre, si no entra a la cola FIFO.
  Future<void> _requestSeat() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    try {
      final outcome = await ref.read(chatRoomsRepositoryProvider).requestSeat(widget.roomId);
      if (!mounted) return;
      if (outcome == 'seated') {
        setState(() {
          _presenceState = 'seated';
          _mySeat = _detectMySeat();
        });
        SystemSnack.show(context, AppLocalizations.of(context)?.voice_seat_assigned ?? 'SILLA ASIGNADA. ¡Bienvenido!', type: SystemSnackType.success);
        await _reconnectLiveKitForState();
        ref.invalidate(chatRoomParticipantsProvider(widget.roomId));
      } else {
        SystemSnack.show(context, AppLocalizations.of(context)?.voice_seats_full_queue ?? 'SILLAS LLENAS: ENTRAS EN COLA', type: SystemSnackType.info);
      }
    } catch (e) {
      if (mounted) {
        SystemSnack.show(context, 'Error al pedir silla: $e', type: SystemSnackType.error);
      }
    }
  }

  /// Se levanta: libera la silla, vuelve a "de pie" y reconecta sin publicar.
  Future<void> _standUp() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    try {
      await ref.read(chatRoomsRepositoryProvider).standUp(widget.roomId);
      if (!mounted) return;
      setState(() {
        _presenceState = 'standing';
        _mySeat = null;
      });
      SystemSnack.show(context, AppLocalizations.of(context)?.voice_seat_freed ?? 'SILLA LIBERADA. DE PIE', type: SystemSnackType.info);
      await _reconnectLiveKitForState();
      if (mounted) ref.invalidate(chatRoomParticipantsProvider(widget.roomId));
    } catch (e) {
      if (mounted) {
        SystemSnack.show(context, 'Error al levantarte: $e', type: SystemSnackType.error);
      }
    }
  }

  /// Modo moderador: pone "de pie" a otro participante (expulsión suave).
  void _moderatorStand(Map<String, dynamic> target) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    final targetId = target['user_id'] as String?;
    if (targetId == null || targetId == user.id) return;
    try {
      final ok = await ref.read(chatRoomsRepositoryProvider).moderatorStand(widget.roomId, targetId);
      if (!mounted) return;
      SystemSnack.show(
        context,
        ok
            ? (AppLocalizations.of(context)?.voice_standing ?? 'CAZADOR PUESTO DE PIE')
            : (AppLocalizations.of(context)?.voice_not_moderator ?? 'NO ERES MODERADOR DE ESTA MESA'),
        type: ok ? SystemSnackType.success : SystemSnackType.error,
      );
      if (ok) ref.invalidate(chatRoomParticipantsProvider(widget.roomId));
    } catch (_) {}
  }

  int? _detectMySeat() {
    final user = ref.read(currentUserProvider);
    if (user == null) return null;
    final participants = ref.read(chatRoomParticipantsProvider(widget.roomId)).value;
    if (participants == null) return null;
    for (final p in participants) {
      if (p['user_id'] == user.id) {
        final slot = p['speaker_slot'];
        if (slot is int) return slot;
      }
    }
    return null;
  }

  /// Posición (1-based) del usuario en la cola FIFO de petición de silla.
  int _myQueuePosition(List<Map<String, dynamic>> requests) {
    final user = ref.read(currentUserProvider);
    if (user == null) return 0;
    for (var i = 0; i < requests.length; i++) {
      if (requests[i]['user_id'] == user.id) return i + 1;
    }
    return 0;
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    await ref.read(chatRoomsRepositoryProvider).sendChatMessage(
          roomId: widget.roomId,
          userId: user.id,
          messageText: text,
        );

    _messageController.clear();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Abre el chat de la cámara como bottom sheet (Fase 2 UX-Audit).
  /// No expande el grid: el chat vive en un overlay para no competir con los oradores.
  void _openChatSheet() {
    final l10n = AppLocalizations.of(context)!;
    final messagesAsync = ref.read(chatRoomMessagesProvider(widget.roomId));
    final user = ref.read(currentUserProvider);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          height: MediaQuery.of(sheetContext).size.height * 0.65,
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppColors.manaCyan.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const Icon(Icons.chat_bubble_rounded, color: AppColors.manaCyan, size: 18),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'CHAMBER TEXT CHAT',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.spaceGrotesk(color: AppColors.onSurface, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.2),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pop(sheetContext),
                      child: const Icon(Icons.close_rounded, color: AppColors.onSurfaceVariant, size: 18),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: AppColors.onSurface.withValues(alpha: 0.1)),
              Expanded(
                child: messagesAsync.when(
                  data: (messages) {
                    if (messages.isEmpty) {
                      return Center(
                        child: Text(l10n.room_no_messages,
                            style: GoogleFonts.jetBrainsMono(color: AppColors.onSurface.withValues(alpha: 0.6), fontSize: 12)),
                      );
                    }
                    return ListView.builder(
                      controller: _chatScrollController,
                      padding: const EdgeInsets.all(12),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        final msgUserId = msg['user_id'] as String;
                        final isSelf = msgUserId == user?.id;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6.0),
                          child: Row(
                            mainAxisAlignment: isSelf ? MainAxisAlignment.end : MainAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelf ? AppColors.runeViolet.withValues(alpha: 0.3) : AppColors.onSurface.withValues(alpha: 0.10),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  msg['message_text'] as String? ?? '',
                                  style: const TextStyle(color: AppColors.onSurface, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator(color: AppColors.runeViolet)),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        style: const TextStyle(color: AppColors.onSurface, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(color: AppColors.onSurface.withValues(alpha: 0.6), fontSize: 12),
                          filled: true,
                          fillColor: AppColors.onSurface.withValues(alpha: 0.05),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send_rounded, color: AppColors.manaCyan),
                      onPressed: () {
                        _sendMessage();
                        Future.delayed(const Duration(milliseconds: 150), () {
                          if (mounted && _chatScrollController.hasClients) {
                            _chatScrollController.animateTo(
                              _chatScrollController.position.maxScrollExtent,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            );
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(currentUserProvider);
    // Maná real (FASE B): única moneda de energía. Saldo = asignación + comprado − usado.
    final manaState = ref.watch(manaStateProvider).value ?? const {};
    final int manaRemaining = (manaState['remaining'] as int?) ?? 0;
    final int manaUsed = (manaState['used'] as int?) ?? 0;
    final participantsAsync = ref.watch(chatRoomParticipantsProvider(widget.roomId));
    final messagesAsync = ref.watch(chatRoomMessagesProvider(widget.roomId));
    final participantProfiles =
        ref.watch(participantProfilesProvider(widget.roomId)).value ?? const <String, Map<String, dynamic>>{};

    Map<String, dynamic>? currentRoom;
    final rooms = ref.watch(chatRoomsListProvider).value;
    if (rooms != null) {
      for (final r in rooms) {
        if (r['id'] == widget.roomId) {
          currentRoom = r;
          break;
        }
      }
    }
    final roomTitle = currentRoom?['title'] as String?;
    final missionName =
        (roomTitle != null && roomTitle.trim().isNotEmpty) ? roomTitle : (AppLocalizations.of(context)?.voice_free_mission ?? 'MISIÓN LIBRE');

    final participants = participantsAsync.value;
    final messages = messagesAsync.value;
    final seatRequests =
        ref.watch(chatRoomSeatRequestsProvider(widget.roomId)).value ?? const <Map<String, dynamic>>[];
    // Resonancia basada en actividad REAL: nº de cazadores conectados.
    final double resonance = (participants != null && participants.isNotEmpty)
        ? (participants.length / 16.0).clamp(0.1, 1.0).toDouble()
        : (messages != null && messages.isNotEmpty)
            ? (messages.length / 15.0).clamp(0.1, 1.0).toDouble()
            : 0.5;

    // Estado de presencia del usuario actual dentro de la mesa.
    //
    // Fuente de verdad: el estado LOCAL (_presenceState/_mySeat), que se
    // actualiza de forma optimista al sentarse/levantarse. El stream de
    // participantes solo se usa en la primera carga (cuando aún no hay
    // interacción local) y para reflejar expulsiones del moderador.
    final bool hasLocalState = _mySeat != null || _presenceState == 'seated';
    String presence = _presenceState;
    int? mySeat = _mySeat;
    if (!hasLocalState && participants != null) {
      for (final p in participants) {
        if (p['user_id'] == user?.id) {
          presence = p['presence_state'] as String? ?? (p['is_speaker'] == true ? 'seated' : 'standing');
          final slot = p['speaker_slot'];
          if (slot is int) mySeat = slot;
          break;
        }
      }
    }
    final isSeated = presence == 'seated';
    final isModerator =
        currentRoom?['moderator_id'] == user?.id || currentRoom?['assigned_moderator_id'] == user?.id;

    // Sincroniza el estado local con el servidor (moderador expulsa, reingreso
    // en otra sesión, etc). No revierte un asiento recién confirmado por RPC.
    ref.listen(chatRoomParticipantsProvider(widget.roomId), (prev, next) {
      final current = ref.read(currentUserProvider);
      if (current == null || !mounted) return;
      final list = next.value ?? const <Map<String, dynamic>>[];
      for (final p in list) {
        if (p['user_id'] == current.id) {
          final serverPresence =
              p['presence_state'] as String? ?? (p['is_speaker'] == true ? 'seated' : 'standing');
          final slot = p['speaker_slot'];
          final serverSeat = slot is int ? slot : null;
          if (serverPresence != _presenceState || serverSeat != _mySeat) {
            setState(() {
              _presenceState = serverPresence;
              _mySeat = serverSeat;
            });
          }
          return;
        }
      }
    });

    return Scaffold(
      backgroundColor: AppColors.screenBg,
      body: CyberManhwaBackground(
        bgMode: CyberBgMode.guildTable,
        child: Stack(
        children: [
          // Background Glow Orbs
          Positioned(
            top: -120,
            left: -100,
            child: Container(
              width: 340,
              height: 340,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.runeViolet.withValues(alpha: 0.15),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: 360,
              height: 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.manaCyan.withValues(alpha: 0.1),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 140, sigmaY: 140),
                child: const SizedBox.expand(),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top Navigation Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                    Expanded(
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.onSurface, size: 20),
                            onPressed: _leaveRoom,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)?.voice_guild_chamber ?? 'GUILD VOICE CHAMBER',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.crimsonRed.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: AppColors.crimsonRed),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.fiber_manual_record, color: AppColors.crimsonRed, size: 6),
                                          const SizedBox(width: 2),
                                          Text(l10n.room_live, style: const TextStyle(color: AppColors.crimsonRed, fontSize: 8, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  AppLocalizations.of(context)?.voice_moderated ?? 'Guild voice room',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ManaMeterWidget(currentMana: manaRemaining, usedInSession: manaUsed),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(Icons.exit_to_app_rounded, color: AppColors.errorRed),
                          onPressed: _leaveRoom,
                          tooltip: AppLocalizations.of(context)?.voice_leave ?? 'Salir de la sala',
                        ),
                      ],
                    ),
                    ],
                  ),
                ),

                // GUILD-01: Demo transparency — chip compacto (colapsable, se expande al tocar)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 2.0),
                  child: GestureDetector(
                    onTap: () => setState(() => _showDemoBanner = !_showDemoBanner),
                    child: GlassCard(
                      blur: 20,
                      opacity: AppColors.glassOpacity,
                      border: Border.all(color: AppColors.guildAmber.withValues(alpha: 0.45)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      child: Row(
                        children: [
                          const Icon(Icons.science_rounded, color: AppColors.guildAmber, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _showDemoBanner
                                  ? (AppLocalizations.of(context)?.voice_demo_banner ??
                                      'AUDIO DEL GREMIO: DEMO — cazadores conectados en vivo. La práctica de voz es 1:1.')
                                  : (AppLocalizations.of(context)?.voice_demo_banner_alt ?? 'AUDIO DEMO · TOCA PARA VER DETALLE'),
                              style: GoogleFonts.jetBrainsMono(
                                color: AppColors.guildAmber,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.9,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(
                            _showDemoBanner ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                            color: AppColors.guildAmber,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Guild-02: Misión + Resonancia fusionadas en una fila compacta
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 2.0),
                  child: GlassCard(
                    blur: 20,
                    opacity: AppColors.glassOpacity,
                    border: Border.all(color: AppColors.royalGold.withValues(alpha: 0.35)),
                    showRunicCorners: true,
                    runicColor: AppColors.royalGold,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.royalGold.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.royalGold.withValues(alpha: 0.4)),
                          ),
                          child: const Icon(Icons.flag_rounded, color: AppColors.royalGold, size: 16),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context)?.voice_room_mission ?? 'MISIÓN DE LA SALA',
                                style: GoogleFonts.jetBrainsMono(
                                  color: AppColors.royalGoldLight,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                missionName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.spaceGrotesk(
                                  color: AppColors.onSurface,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Resonancia compacta
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)?.voice_resonance ?? 'RESONANCIA',
                                    style: GoogleFonts.jetBrainsMono(
                                      color: AppColors.onSurfaceVariant,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                  Text(
                                    '${(resonance * 100).round()}%',
                                    style: GoogleFonts.jetBrainsMono(
                                      color: AppColors.manaCyan,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              SegmentedBar(
                                value: resonance,
                                segments: 10,
                                color: AppColors.manaCyan,
                                height: 4,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Main Stage Speakers Grid & Audience
                Expanded(
                  child: participantsAsync.when(
                    data: (participants) {
                      final seats = List<Map<String, dynamic>?>.filled(8, null);
                      final List<Map<String, dynamic>> standing = [];

                      for (final p in participants) {
                        final presence = p['presence_state'] as String? ?? (p['is_speaker'] == true ? 'seated' : 'standing');
                        if (presence == 'seated') {
                          final slot = p['speaker_slot'] as int?;
                          if (slot != null && slot >= 1 && slot <= 8) {
                            seats[slot - 1] = p;
                          } else {
                            standing.add(p);
                          }
                        } else {
                          standing.add(p);
                        }
                      }

                      return Column(
                        children: [
                          // Seats 8 Grid (4 columns x 2 rows)
                          Expanded(
                            flex: 6,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              child: GridView.builder(
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                  childAspectRatio: 0.82,
                                ),
                                itemCount: 8,
                                itemBuilder: (context, index) {
                                  final slotNum = index + 1;
                                  final speaker = seats[index];

                                  if (speaker == null) {
                                    final isMySeat = mySeat == slotNum;
                                    // onTap nativo de GlassCard: el GestureDetector
                                    // interno no "traga" el tap (ver glass_card.dart).
                                    return GlassCard(
                                      onTap: isSeated ? null : () => _sitDown(slotNum),
                                      blur: 15,
                                      opacity: AppColors.glassOpacity,
                                      border: Border.all(
                                        color: isMySeat ? AppColors.manaCyan : AppColors.onSurface.withValues(alpha: 0.12),
                                        width: isMySeat ? 2 : 1,
                                      ),
                                      padding: const EdgeInsets.all(6),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: isMySeat
                                                  ? AppColors.manaCyan.withValues(alpha: 0.15)
                                                  : AppColors.onSurface.withValues(alpha: 0.05),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              isMySeat ? Icons.event_seat_rounded : Icons.add_rounded,
                                              color: isMySeat ? AppColors.manaCyan : AppColors.onSurface.withValues(alpha: 0.6),
                                              size: 18,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            isMySeat
                                                ? (AppLocalizations.of(context)?.voice_your_seat ?? 'TU SILLA')
                                                : (AppLocalizations.of(context)?.voice_seat_number('$slotNum') ?? 'SILLA $slotNum'),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: isMySeat ? AppColors.manaCyan : AppColors.onSurface.withValues(alpha: 0.6),
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          if (!isSeated && !isMySeat)
                                            Text(
                                              AppLocalizations.of(context)?.voice_tap_to_sit ?? 'TOCAR PARA SENTARSE',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(color: AppColors.manaCyan.withValues(alpha: 0.5), fontSize: 7),
                                            ),
                                        ],
                                      ),
                                    );
                                  }

                                  final speakerUserId = speaker['user_id'] as String;
                                  final isSelf = speakerUserId == user?.id;
                                  final speakerProfile = participantProfiles[speakerUserId];
                                  final otherName = speakerProfile?['display_name'] as String? ?? '';
                                  final speakerName = isSelf
                                      ? (AppLocalizations.of(context)?.voice_you ?? 'YOU')
                                      : (otherName.isNotEmpty ? otherName : (AppLocalizations.of(context)?.voice_hunter_slot('$slotNum') ?? 'HUNTER $slotNum'));
                                  final speakerAvatar = isSelf
                                      ? (ref.read(userProfileProvider).value?['avatar_url'] as String? ?? 'warrior')
                                      : (speakerProfile?['avatar_url'] as String? ?? 'warrior');
                                  final isSpeaking = _speakingIds.contains(speakerUserId);

                                  return GestureDetector(
                                    onLongPress: isModerator && !isSelf ? () => _moderatorStand(speaker) : null,
                                    child: GlassCard(
                                      blur: 20,
                                      opacity: isSpeaking ? 0.15 : 0.08,
                                      border: Border.all(
                                        color: isSpeaking ? AppColors.manaCyan : AppColors.onSurface.withValues(alpha: 0.24),
                                        width: isSpeaking ? 2 : 1,
                                      ),
                                      padding: const EdgeInsets.all(6),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Stack(
                                            clipBehavior: Clip.none,
                                            children: [
                                              RpgAvatar(
                                                avatarUrl: speakerAvatar,
                                                initials: speakerName.isNotEmpty
                                                    ? speakerName.substring(0, 1).toUpperCase()
                                                    : 'H$slotNum',
                                                size: 36,
                                                hunterClass: speakerAvatar,
                                              ),
                                              if (isSpeaking)
                                                const Positioned(
                                                  right: -2,
                                                  bottom: -2,
                                                  child: Icon(Icons.graphic_eq_rounded, color: AppColors.manaCyan, size: 14),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            speakerName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.spaceGrotesk(color: AppColors.onSurface, fontWeight: FontWeight.bold, fontSize: 9),
                                          ),
                                          const SizedBox(height: 1),
                                          Text(
                                            isSpeaking
                                                ? (AppLocalizations.of(context)?.voice_speaking ?? 'HABLANDO')
                                                : (AppLocalizations.of(context)?.voice_seated ?? 'SENTADO'),
                                            style: GoogleFonts.jetBrainsMono(
                                              color: isSpeaking ? AppColors.manaCyan : AppColors.onSurfaceVariant,
                                              fontSize: 8,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                          // Standing Ring (De Pie) — escuchan + chat, sin audio.
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 2),
                            child: GestureDetector(
                              onTap: () => setState(() => _showAudience = !_showAudience),
                              child: GlassCard(
                                blur: 20,
                                opacity: AppColors.glassOpacity,
                                border: Border.all(color: AppColors.manaCyan.withValues(alpha: 0.25)),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                child: Row(
                                  children: [
                                    const Icon(Icons.accessibility_new_rounded, color: AppColors.manaCyan, size: 16),
                                    const SizedBox(width: 8),
                                    Text(
                                      AppLocalizations.of(context)?.voice_standing_count(standing.length) ?? 'DE PIE (${standing.length}/8)',
                                      style: GoogleFonts.spaceGrotesk(color: AppColors.onSurface, fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _showAudience
                                          ? SizedBox(
                                              height: 32,
                                              child: ListView.builder(
                                                scrollDirection: Axis.horizontal,
                                                itemCount: standing.length,
                                                itemBuilder: (context, index) {
                                                  final item = standing[index];
                                                  final audId = item['user_id'] as String;
                                                  final audProfile = participantProfiles[audId];
                                                  final audName = audProfile?['display_name'] as String? ?? '';
                                                  final audInitials = audName.isNotEmpty ? audName.substring(0, 1).toUpperCase() : 'U';
                                                  final isSelfStanding = audId == user?.id;

                                                  return Container(
                                                    margin: const EdgeInsets.only(right: 6),
                                                    child: Tooltip(
                                                      message: isSelfStanding
                                                          ? (AppLocalizations.of(context)?.voice_you_standing ?? 'Tú (de pie)')
                                                          : (audName.isNotEmpty ? audName : (AppLocalizations.of(context)?.voice_standing_hunter ?? 'Cazador de pie')),
                                                      child: Stack(
                                                        clipBehavior: Clip.none,
                                                        children: [
                                                          RpgAvatar(
                                                            avatarUrl: audProfile?['avatar_url'] as String? ?? 'warrior',
                                                            initials: audInitials,
                                                            size: 30,
                                                            hunterClass: audProfile?['avatar_url'] as String? ?? 'warrior',
                                                          ),
                                                          if (isSelfStanding)
                                                            const Positioned(
                                                              right: -3,
                                                              bottom: -3,
                                                              child: Icon(Icons.mic_off_rounded, color: AppColors.errorRed, size: 12),
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            )
                                          : const SizedBox.shrink(),
                                    ),
                                    Icon(
                                      _showAudience ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                                      color: AppColors.onSurfaceVariant,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Chat button (abre bottom sheet — no expande en el grid)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 2),
                            child: GestureDetector(
                              onTap: _openChatSheet,
                              child: GlassCard(
                                blur: 20,
                                opacity: AppColors.glassOpacity,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Row(
                                        children: [
                                          const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.manaCyan, size: 16),
                                          const SizedBox(width: 8),
                                          Flexible(
                                            child: Text(
                                              AppLocalizations.of(context)?.voice_chat_title(messagesAsync.value?.length ?? 0) ??
                                                  'Chamber Text Chat (${messagesAsync.value?.length ?? 0})',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.spaceGrotesk(color: AppColors.onSurface, fontWeight: FontWeight.bold, fontSize: 12),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.open_in_full_rounded, color: AppColors.onSurfaceVariant, size: 16),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator(color: AppColors.runeViolet)),
                    error: (err, _) => Center(child: Text(l10n.room_error('$err'), style: const TextStyle(color: AppColors.errorRed))),
                  ),
                ),

                // Bottom Floating Control Bar — 4 controles compactos (no desborda)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                  child: GlassCard(
                    blur: 30,
                    opacity: AppColors.glassOpacity,
                    border: Border.all(color: AppColors.runeViolet.withValues(alpha: 0.3), width: 1.5),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Row(
                      children: [
                        // Micrófono (LiveKit real — solo si estás sentado)
                        Expanded(
                          child: _controlButton(
                            icon: isSeated ? (_micOn ? Icons.mic_rounded : Icons.mic_off_rounded) : Icons.mic_off_rounded,
                            color: isSeated ? (_micOn ? AppColors.liveGreen : AppColors.errorRed) : AppColors.onSurfaceVariant,
                            label: isSeated
                                ? (_micOn
                                    ? (AppLocalizations.of(context)?.voice_mic_on ?? 'MIC ON')
                                    : (AppLocalizations.of(context)?.voice_mic_off ?? 'MIC OFF'))
                                : (AppLocalizations.of(context)?.voice_stand_up ?? 'LEVANTARSE'),
                            onTap: _toggleMic,
                          ),
                        ),
                        // Práctica con el Oráculo
                        Expanded(
                          child: _controlButton(
                            icon: Icons.auto_awesome_rounded,
                            color: AppColors.royalGold,
                            label: AppLocalizations.of(context)?.oracle ?? 'ORÁCULO',
                            onTap: _startOraclePractice,
                          ),
                        ),
                        // Acción de silla: sentarse / levantarse / pedir silla
                        Expanded(
                          child: _controlButton(
                            icon: isSeated
                                ? Icons.accessibility_new_rounded
                                : Icons.event_seat_rounded,
                            color: isSeated ? AppColors.runeViolet : AppColors.manaCyan,
                            label: isSeated
                                ? (AppLocalizations.of(context)?.voice_stand_up ?? 'LEVANTARSE')
                                : (_isHandRaised
                                    ? (AppLocalizations.of(context)?.voice_in_queue(_myQueuePosition(seatRequests)) ?? 'EN COLA #${_myQueuePosition(seatRequests)}')
                                    : (AppLocalizations.of(context)?.voice_seat ?? 'SILLA')),
                            onTap: isSeated
                                ? _standUp
                                : () {
                                    final seatedCount =
                                        participants?.where((p) =>
                                                (p['presence_state'] as String? ?? (p['is_speaker'] == true ? 'seated' : 'standing')) == 'seated')
                                            .length ??
                                            0;
                                    if (seatedCount >= 8) {
                                      setState(() => _isHandRaised = true);
                                    }
                                    _requestSeat();
                                  },
                          ),
                        ),
                        // Leave
                        Expanded(
                          child: _controlButton(
                            icon: Icons.call_end_rounded,
                            color: AppColors.errorRed,
                            label: AppLocalizations.of(context)?.voice_exit ?? 'SALIR',
                            onTap: _leaveRoom,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Botón compacto de la barra de control inferior (icono + etiqueta corta).
  /// Distribuido con Expanded para no desbordar el ancho disponible.
  Widget _controlButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.jetBrainsMono(
                color: color,
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Práctica individual con el Oráculo dentro de la mesa (Fase 7 · G-E).
  void _startOraclePractice() {
    context.push('/conversation');
  }

}
