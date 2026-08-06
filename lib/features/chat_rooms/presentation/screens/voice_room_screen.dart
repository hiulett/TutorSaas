import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
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

  bool _isMuted = false;
  bool _isHandRaised = false;
  bool _showTipBanner = true;
  bool _showDemoBanner = true;
  bool _showAudience = true;

  final Map<String, bool> _speakingSimState = {};
  Timer? _speakingTimer;
  late AnimationController _pulseController;

  final List<String> _aiTips = [
    'ADVISOR TIP: Use conjunctions like "However" or "In addition" to enrich your sentences.',
    'RAID GOAL: Achieve 3 conversation turns without long pauses.',
    'PHONETIC TIP: Pay close attention to rising intonation during questions.',
    'KEY VOCABULARY: Try incorporating the term "Collaborate" in your speech.',
  ];
  int _currentTipIndex = 0;
  Timer? _tipTimer;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final user = ref.read(currentUserProvider);
      if (user != null) {
        try {
          await ref.read(chatRoomsRepositoryProvider).joinRoom(
                roomId: widget.roomId,
                userId: user.id,
                isSpeaker: false,
              );
        } catch (_) {}
      }
    });

    _speakingTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      final participants = ref.read(chatRoomParticipantsProvider(widget.roomId)).value;
      if (participants != null && participants.isNotEmpty) {
        final random = Random();
        if (mounted) {
          setState(() {
            for (final p in participants) {
              final userId = p['user_id'] as String;
              _speakingSimState[userId] = p['is_speaker'] == true && random.nextBool();
            }
          });
        }
      }
    });

    _tipTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
      if (mounted) {
        setState(() {
          _currentTipIndex = (_currentTipIndex + 1) % _aiTips.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _speakingTimer?.cancel();
    _tipTimer?.cancel();
    _pulseController.dispose();
    _messageController.dispose();
    _chatScrollController.dispose();
    super.dispose();
  }

  void _leaveRoom() async {
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

  void _claimSlot(int slot) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    try {
      await ref.read(chatRoomsRepositoryProvider).claimSpeakerSlot(
            roomId: widget.roomId,
            userId: user.id,
            speakerSlot: slot,
          );
      if (mounted) {
        SystemSnack.show(context, 'SUCCESSFULLY MOUNTED GUILD STAGE SLOT $slot!', type: SystemSnackType.success);
        ref.invalidate(chatRoomParticipantsProvider(widget.roomId));
      }
    } catch (e) {
      if (mounted) {
        SystemSnack.show(context, 'Error al subir al escenario: $e', type: SystemSnackType.error);
      }
    }
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
                          hintStyle: TextStyle(color: AppColors.onSurface.withValues(alpha: 0.38), fontSize: 12),
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
    final participantsAsync = ref.watch(chatRoomParticipantsProvider(widget.roomId));
    final messagesAsync = ref.watch(chatRoomMessagesProvider(widget.roomId));

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
        (roomTitle != null && roomTitle.trim().isNotEmpty) ? roomTitle : 'MISIÓN LIBRE';

    double resonance;
    final participants = participantsAsync.value;
    final messages = messagesAsync.value;
    if (participants != null && participants.isNotEmpty) {
      final speakers = participants.where((p) => p['is_speaker'] == true).toList();
      if (speakers.isNotEmpty) {
        var active = 0;
        for (final s in speakers) {
          final uid = s['user_id'] as String?;
          if (uid != null && _speakingSimState[uid] == true) active++;
        }
        resonance = (active / speakers.length).clamp(0.1, 1.0).toDouble();
      } else {
        resonance = 0.5;
      }
    } else if (messages != null && messages.isNotEmpty) {
      resonance = (messages.length / 15.0).clamp(0.1, 1.0).toDouble();
    } else {
      resonance = 0.5;
    }

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
                                        'GUILD VOICE CHAMBER',
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
                                const Text(
                                  'Moderated by AI Tutor in Real Time',
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
                        const ManaMeterWidget(currentMana: 448, usedInSession: 2),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(Icons.exit_to_app_rounded, color: AppColors.errorRed),
                          onPressed: _leaveRoom,
                          tooltip: 'Salir de la sala',
                        ),
                      ],
                    ),
                    ],
                  ),
                ),

                // AI Tutor Tip Banner (colapsable — se muestra al entrar y se cierra)
                if (_showTipBanner)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
                    child: GlassCard(
                      blur: 20,
                      opacity: AppColors.glassOpacity,
                      border: Border.all(color: AppColors.manaCyan.withValues(alpha: 0.3)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.psychology_rounded, color: AppColors.manaCyan, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 400),
                              child: Text(
                                _aiTips[_currentTipIndex],
                                key: ValueKey(_currentTipIndex),
                                style: const TextStyle(color: AppColors.onSurface, fontSize: 11, fontWeight: FontWeight.w600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () => setState(() => _showTipBanner = false),
                            child: const Icon(Icons.close_rounded, color: AppColors.onSurfaceVariant, size: 16),
                          ),
                        ],
                      ),
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
                              _showDemoBanner ? 'AUDIO DEL GREMIO: DEMO — los oradores son simulados. Tu voz sí se graba.'
                                              : 'AUDIO DEMO · TOCA PARA VER DETALLE',
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
                                'MISIÓN DE LA SALA',
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
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.spaceGrotesk(
                                  color: AppColors.onSurface,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
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
                                    'RESONANCIA',
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
                      final speakers = List<Map<String, dynamic>?>.filled(6, null);
                      final List<Map<String, dynamic>> audience = [];

                      for (final p in participants) {
                        if (p['is_speaker'] == true) {
                          final slot = p['speaker_slot'] as int?;
                          if (slot != null && slot >= 1 && slot <= 6) {
                            speakers[slot - 1] = p;
                          }
                        } else {
                          audience.add(p);
                        }
                      }

                      return Column(
                        children: [
                          // Speakers 6 Grid (2 rows x 3 columns)
                          Expanded(
                            flex: 6,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              child: GridView.builder(
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  childAspectRatio: 1.0,
                                ),
                                itemCount: 6,
                                itemBuilder: (context, index) {
                                  final slotNum = index + 1;
                                  final speaker = speakers[index];

                                  // Slot 1: Tutor IA Moderador Slot
                                  if (slotNum == 1) {
                                    return _buildAiModeratorCard();
                                  }

                                  if (speaker == null) {
                                    return GestureDetector(
                                      onTap: () => _claimSlot(slotNum),
                                      child: GlassCard(
                                        blur: 15,
                                        opacity: AppColors.glassOpacity,
                                        border: Border.all(color: AppColors.onSurface.withValues(alpha: 0.12), width: 1),
                                        padding: const EdgeInsets.all(8),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: AppColors.onSurface.withValues(alpha: 0.05),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(Icons.add_rounded, color: AppColors.onSurface.withValues(alpha: 0.38), size: 24),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Subir al Slot $slotNum',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(color: AppColors.onSurface.withValues(alpha: 0.6), fontSize: 10, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }

                                  final speakerUserId = speaker['user_id'] as String;
                                  final isSpeaking = _speakingSimState[speakerUserId] ?? false;
                                  final isSelf = speakerUserId == user?.id;

                                  return GlassCard(
                                    blur: 20,
                                    opacity: isSpeaking ? 0.15 : 0.06,
                                    border: Border.all(
                                      color: isSpeaking ? AppColors.manaCyan : AppColors.onSurface.withValues(alpha: 0.24),
                                      width: isSpeaking ? 2 : 1,
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            if (isSpeaking)
                                              AnimatedBuilder(
                                                animation: _pulseController,
                                                builder: (context, child) {
                                                  return Container(
                                                    width: 52 + (_pulseController.value * 10),
                                                    height: 52 + (_pulseController.value * 10),
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(4),
                                                      border: Border.all(
                                                        color: AppColors.manaCyan.withValues(alpha: 1.0 - _pulseController.value),
                                                        width: 2,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            RpgAvatar(
                                              avatarUrl: isSelf
                                                  ? (ref.read(userProfileProvider).value?['avatar_url'] as String? ?? 'warrior')
                                                  : ['warrior', 'mage', 'assassin', 'necromancer', 'priest'][speakerUserId.hashCode % 5],
                                              initials: isSelf ? 'ME' : 'H$slotNum',
                                              size: 44,
                                              hunterClass: isSelf
                                                  ? 'assassin'
                                                  : ['warrior', 'mage', 'assassin', 'necromancer', 'priest'][speakerUserId.hashCode % 5],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                isSelf ? 'YOU' : 'HUNTER $slotNum',
                                                style: GoogleFonts.spaceGrotesk(color: AppColors.onSurface, fontWeight: FontWeight.bold, fontSize: 10),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          isSpeaking ? 'SPEAKING...' : 'LIVE',
                                          style: GoogleFonts.jetBrainsMono(
                                            color: isSpeaking ? AppColors.manaCyan : AppColors.onSurfaceVariant,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                          // Audience Horizontal Strip (Gradas) — colapsable
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 2),
                            child: GestureDetector(
                              onTap: () => setState(() => _showAudience = !_showAudience),
                              child: GlassCard(
                                blur: 20,
                                opacity: AppColors.glassOpacity,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                child: Row(
                                  children: [
                                    const Icon(Icons.people_alt_rounded, color: AppColors.onSurfaceVariant, size: 16),
                                    const SizedBox(width: 8),
                                    Text(
                                      'GUILD BENCH (${audience.length})',
                                      style: GoogleFonts.spaceGrotesk(color: AppColors.onSurface, fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _showAudience
                                          ? SizedBox(
                                              height: 32,
                                              child: ListView.builder(
                                                scrollDirection: Axis.horizontal,
                                                itemCount: audience.length,
                                                itemBuilder: (context, index) {
                                                  final item = audience[index];
                                                  final audId = item['user_id'] as String;
                                                  final initials = audId.length >= 2 ? audId.substring(0, 2).toUpperCase() : 'U';

                                                  return Container(
                                                    margin: const EdgeInsets.only(right: 6),
                                                    child: RpgAvatar(
                                                      avatarUrl: ['warrior', 'mage', 'assassin', 'necromancer', 'priest'][audId.hashCode % 5],
                                                      initials: initials,
                                                      size: 32,
                                                      hunterClass: ['warrior', 'mage', 'assassin', 'necromancer', 'priest'][audId.hashCode % 5],
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
                        // Mute
                        Expanded(
                          child: _controlButton(
                            icon: _isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                            color: _isMuted ? AppColors.errorRed : AppColors.liveGreen,
                            label: _isMuted ? 'MUTED' : 'MIC',
                            onTap: () {
                              setState(() => _isMuted = !_isMuted);
                              SystemSnack.show(
                                context,
                                _isMuted ? 'MICROPHONE MUTED' : 'MICROPHONE ACTIVATED',
                                type: _isMuted ? SystemSnackType.warning : SystemSnackType.success,
                              );
                            },
                          ),
                        ),
                        // Práctica con el Oráculo
                        Expanded(
                          child: _controlButton(
                            icon: Icons.auto_awesome_rounded,
                            color: AppColors.royalGold,
                            label: 'ORÁCULO',
                            onTap: _startOraclePractice,
                          ),
                        ),
                        // Raise Hand
                        Expanded(
                          child: _controlButton(
                            icon: _isHandRaised ? Icons.back_hand : Icons.back_hand_outlined,
                            color: _isHandRaised ? AppColors.runeViolet : AppColors.onSurfaceVariant,
                            label: _isHandRaised ? 'PEDIDO' : 'HAND',
                            onTap: () {
                              setState(() => _isHandRaised = !_isHandRaised);
                              SystemSnack.show(
                                context,
                                _isHandRaised ? 'REQUEST SENT TO GUILD' : 'HAND LOWERED',
                                type: SystemSnackType.info,
                              );
                            },
                          ),
                        ),
                        // Leave
                        Expanded(
                          child: _controlButton(
                            icon: Icons.call_end_rounded,
                            color: AppColors.errorRed,
                            label: 'SALIR',
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

  Widget _buildAiModeratorCard() {
    return GlassCard(
      blur: 20,
      opacity: AppColors.glassOpacity,
      border: Border.all(color: AppColors.aiGold, width: 1.5),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.aiGold, width: 1.5),
                  boxShadow: [
                    BoxShadow(color: AppColors.aiGold.withValues(alpha: 0.3), blurRadius: 6),
                  ],
                ),
              ),
              ClipOval(
                child: Image.asset(
                  'assets/images/avatars/oracle_01.png',
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'AI TUTOR',
            style: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.bold, fontSize: 10),
          ),
          const SizedBox(height: 1),
          const Text(
            'AI MODERATOR',
            style: TextStyle(color: AppColors.aiGold, fontSize: 8, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
