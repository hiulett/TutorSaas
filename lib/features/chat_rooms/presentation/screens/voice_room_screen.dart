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
  bool _showChatSheet = false;

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('SUCCESSFULLY MOUNTED GUILD STAGE SLOT $slot!'),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
        ref.invalidate(chatRoomParticipantsProvider(widget.roomId));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al subir al escenario: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
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

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final participantsAsync = ref.watch(chatRoomParticipantsProvider(widget.roomId));
    final messagesAsync = ref.watch(chatRoomMessagesProvider(widget.roomId));

    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
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
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                            onPressed: _leaveRoom,
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'GUILD VOICE CHAMBER',
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: Colors.redAccent),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.fiber_manual_record, color: Colors.redAccent, size: 8),
                                        const SizedBox(width: 4),
                                        Text('LIVE', style: TextStyle(color: Colors.redAccent, fontSize: 9, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Text(
                                'Moderated by AI Tutor in Real Time',
                                style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
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

                // AI Tutor Tip Banner
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
                  child: GlassCard(
                    blur: 20,
                    opacity: 0.08,
                    border: Border.all(color: AppColors.manaCyan.withValues(alpha: 0.3)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Row(
                      children: [
                        const Icon(Icons.psychology_rounded, color: AppColors.manaCyan, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            child: Text(
                              _aiTips[_currentTipIndex],
                              key: ValueKey(_currentTipIndex),
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

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
                                  crossAxisSpacing: 14,
                                  mainAxisSpacing: 14,
                                  childAspectRatio: 0.85,
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
                                        opacity: 0.03,
                                        border: Border.all(color: Colors.white12, width: 1),
                                        padding: const EdgeInsets.all(8),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withValues(alpha: 0.05),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(Icons.add_rounded, color: Colors.white38, size: 24),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Subir al Slot $slotNum',
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold),
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
                                      color: isSpeaking ? AppColors.manaCyan : Colors.white24,
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
                                                    width: 58 + (_pulseController.value * 12),
                                                    height: 58 + (_pulseController.value * 12),
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
                                              size: 48,
                                              hunterClass: isSelf
                                                  ? 'assassin'
                                                  : ['warrior', 'mage', 'assassin', 'necromancer', 'priest'][speakerUserId.hashCode % 5],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          isSelf ? 'YOU' : 'HUNTER $slotNum',
                                          style: GoogleFonts.spaceGrotesk(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                                          overflow: TextOverflow.ellipsis,
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

                          // Audience Horizontal Strip (Gradas)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
                            child: GlassCard(
                              blur: 20,
                              opacity: 0.05,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              child: Row(
                                children: [
                                  const Icon(Icons.people_alt_rounded, color: AppColors.onSurfaceVariant, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    'GUILD BENCH (${audience.length}):',
                                    style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: SizedBox(
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
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Expandable Chat Area / Button
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _showChatSheet = !_showChatSheet;
                                });
                              },
                              child: GlassCard(
                                blur: 20,
                                opacity: 0.08,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.manaCyan, size: 18),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Chamber Text Chat (${messagesAsync.value?.length ?? 0})',
                                          style: GoogleFonts.spaceGrotesk(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                    Icon(
                                      _showChatSheet ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_up_rounded,
                                      color: Colors.white70,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          if (_showChatSheet)
                            Expanded(
                              flex: 4,
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F172A),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: Colors.white12),
                                ),
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: messagesAsync.when(
                                        data: (messages) {
                                          if (messages.isEmpty) {
                                            return Center(
                                              child: Text('No messages in this chamber yet.', style: GoogleFonts.jetBrainsMono(color: Colors.white38, fontSize: 12)),
                                            );
                                          }
                                          return ListView.builder(
                                            controller: _chatScrollController,
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
                                                        color: isSelf ? AppColors.runeViolet.withValues(alpha: 0.3) : Colors.white10,
                                                        borderRadius: BorderRadius.circular(4),
                                                      ),
                                                      child: Text(
                                                        msg['message_text'] as String? ?? '',
                                                        style: const TextStyle(color: Colors.white, fontSize: 12),
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
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            controller: _messageController,
                                            style: const TextStyle(color: Colors.white, fontSize: 13),
                                            decoration: InputDecoration(
                                              hintText: 'Type a message...',
                                              hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                                              filled: true,
                                              fillColor: Colors.white.withValues(alpha: 0.05),
                                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          icon: const Icon(Icons.send_rounded, color: AppColors.manaCyan),
                                          onPressed: _sendMessage,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator(color: AppColors.runeViolet)),
                    error: (err, _) => Center(child: Text('Error en sala: $err', style: const TextStyle(color: AppColors.errorRed))),
                  ),
                ),

                // Bottom Floating Control Bar
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: GlassCard(
                    blur: 30,
                    opacity: 0.1,
                    border: Border.all(color: AppColors.runeViolet.withValues(alpha: 0.3), width: 1.5),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // Mute Toggle Button
                        IconButton(
                          icon: Icon(
                            _isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                            color: _isMuted ? AppColors.errorRed : const Color(0xFF10B981),
                            size: 26,
                          ),
                          onPressed: () {
                            setState(() {
                              _isMuted = !_isMuted;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(_isMuted ? 'MICROPHONE MUTED' : 'MICROPHONE ACTIVATED'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          tooltip: 'Micrófono',
                        ),

                        // Raise Hand Button
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _isHandRaised = !_isHandRaised;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(_isHandRaised ? 'REQUEST SENT TO GUILD' : 'HAND LOWERED'),
                                backgroundColor: AppColors.runeViolet,
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          icon: Icon(_isHandRaised ? Icons.back_hand : Icons.back_hand_outlined, size: 16),
                          label: Text(
                            _isHandRaised ? 'REQUESTED' : 'ASK TO SPEAK',
                            style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isHandRaised ? AppColors.runeViolet : Colors.white10,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          ),
                        ),

                        // Leave Room Button
                        IconButton(
                          icon: const Icon(Icons.call_end_rounded, color: AppColors.errorRed, size: 26),
                          onPressed: _leaveRoom,
                          tooltip: 'Salir',
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

  Widget _buildAiModeratorCard() {
    return GlassCard(
      blur: 20,
      opacity: 0.12,
      border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFFD700), width: 2),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFFFFD700).withValues(alpha: 0.3), blurRadius: 10),
                  ],
                ),
              ),
              const CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.runeViolet,
                child: Icon(Icons.smart_toy_rounded, color: Color(0xFFFFD700), size: 24),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'AI TUTOR',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
          ),
          const SizedBox(height: 2),
          const Text(
            'AI MODERATOR',
            style: TextStyle(color: Color(0xFFFFD700), fontSize: 9, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
