import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/system_window.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/chat_rooms_providers.dart';
import '../../../../core/widgets/cyber_manhwa_background.dart';
import '../../../../core/widgets/runic_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../missions/presentation/widgets/guild_quest_board.dart';
import '../widgets/guild_master_npc_banner.dart';
import '../../../economy/presentation/providers/economy_providers.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../../missions/presentation/widgets/mission_board_widget.dart';

/// GUILD-03: conteo de misiones colaborativas completadas por el gremio.
/// La tabla `guild_collaborative_missions` es global al gremio (no expone
/// user_id ni status por jugador), por lo que se cuentan las filas cuyo
/// progreso alcanzó el objetivo (current_value >= target_value). Fallback
/// elegante: 0 (trofeos bloqueados) ante cualquier error de consulta.
final guildCompletedMissionsProvider = FutureProvider.autoDispose<int>((ref) async {
  final supabase = ref.read(supabaseClientProvider);
  try {
    final data = await supabase
        .from('guild_collaborative_missions')
        .select('current_value, target_value');
    final rows = List<Map<String, dynamic>>.from(data as List);
    var completed = 0;
    for (final row in rows) {
      final current = (row['current_value'] as num?)?.toInt() ?? 0;
      final target = (row['target_value'] as num?)?.toInt() ?? 0;
      if (target > 0 && current >= target) completed++;
    }
    return completed;
  } catch (e) {
    debugPrint('GUILD-03: error contando misiones del gremio: $e');
    return 0;
  }
});

class ChatRoomsScreen extends ConsumerStatefulWidget {
  final bool isTab;
  const ChatRoomsScreen({super.key, this.isTab = false});

  @override
  ConsumerState<ChatRoomsScreen> createState() => _ChatRoomsScreenState();
}

class _ChatRoomsScreenState extends ConsumerState<ChatRoomsScreen> {
  String _selectedCategory = 'Todos';
  RealtimeChannel? _roomsChannel;
  SupabaseClient? _supabaseClient;

  // F4: anuncios rotativos del gremio (sensación de comunidad viva).
  static const List<String> _guildAnnouncements = [
    'El Gremio caza en equipo: únete a una mesa y practica en voz.',
    'Raid de vocabulario esta semana: gana doble XP.',
    'El Oráculo recomienda: 15 min de práctica diaria.',
    'Nuevos cazadores han despertado hoy. ¡Bienvenidos!',
  ];
  int _currentAnnouncement = 0;
  Timer? _announcementTimer;

  int _connectedCount(List<Map<String, dynamic>> rooms) {
    var count = 0;
    for (final r in rooms) {
      count += (r['speakers_count'] as int? ?? 0);
      count += (r['listeners_count'] as int? ?? 0);
    }
    return count;
  }

  // Mapeo slug → etiqueta para las categorías (G-H: dinámicas desde DB).
  static const Map<String, String> _categoryLabels = {
    'general': 'General',
    'travel': 'Viajes',
    'business': 'Trabajo',
    'technology': 'Tecnología',
    'art': 'Arte',
    'cooking': 'Cocina',
  };

  @override
  void initState() {
    super.initState();
    _subscribeToRoomsRealtime();
    _announcementTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (mounted) {
        setState(() {
          _currentAnnouncement = (_currentAnnouncement + 1) % _guildAnnouncements.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _announcementTimer?.cancel();
    if (_roomsChannel != null && _supabaseClient != null) {
      try {
        _supabaseClient!.removeChannel(_roomsChannel!);
      } catch (e) {
        debugPrint('Error removing realtime channel: $e');
      }
    }
    super.dispose();
  }

  void _subscribeToRoomsRealtime() {
    _supabaseClient = ref.read(supabaseClientProvider);
    _roomsChannel = _supabaseClient!
        .channel('public:chat_rooms')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'chat_rooms',
          callback: (payload) {
            if (mounted) {
              ref.invalidate(chatRoomsListProvider);
            }
          },
        );
    _roomsChannel?.subscribe();
  }

  IconData _getCategoryIcon(String cat) {
    switch (cat.toLowerCase()) {
      case 'viajes':
        return Icons.explore_rounded;
      case 'trabajo':
        return Icons.work_rounded;
      case 'tecnología':
        return Icons.computer_rounded;
      case 'arte':
        return Icons.palette_rounded;
      case 'cocina':
        return Icons.soup_kitchen_rounded;
      default:
        return Icons.forum_rounded;
    }
  }

  String _getCategorySlug(String cat) {
    switch (cat) {
      case 'Viajes':
        return 'travel';
      case 'Trabajo':
        return 'business';
      case 'Tecnología':
        return 'technology';
      case 'Arte':
        return 'art';
      case 'Cocina':
        return 'cooking';
      default:
        return 'general';
    }
  }

  String _slugForLabel(String label) {
    for (final e in _categoryLabels.entries) {
      if (e.value == label) return e.key;
    }
    return 'general';
  }

  void _showRankModal(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final progress = ref.read(userProgressProvider).value ?? {};
    final xp = progress['xp'] as int? ?? 0;
    final cefrCode = progress['level_code'] as String? ?? 'A1';
    final cefrLevel = progress['level'] as String? ?? 'Principiante';
    final language = progress['language'] as String? ?? 'Inglés';
    final languageEmoji = progress['language_emoji'] as String? ?? '🇺🇸';

    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: SystemWindow(
          title: 'ESTADO DE RANGO',
          subtitle: 'DETALLES DE CAZADOR',
          icon: Icons.military_tech_rounded,
          accentColor: AppColors.royalGold,
          showCloseButton: true,
          onClose: () => Navigator.pop(context),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.shield_rounded, color: AppColors.royalGold, size: 50),
              const SizedBox(height: 12),
              Text(
                'RANGO $cefrCode',
                style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.royalGold),
              ),
              Text(
                cefrLevel.toUpperCase(),
                style: GoogleFonts.jetBrainsMono(fontSize: 12, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Divider(color: AppColors.deepSlate),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.room_hunt_lang, style: const TextStyle(color: AppColors.onSurfaceVariant)),
                  Text('$language $languageEmoji', style: const TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.room_xp_points, style: const TextStyle(color: AppColors.onSurfaceVariant)),
                  Text('$xp XP', style: const TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateRoomDialog() {
    final l10n = AppLocalizations.of(context)!;
    final titleController = TextEditingController();
    String category = 'Viajes';
    String selectedRoomType = 'ai_practice';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: SystemWindow(
                title: 'ESTABLISH GUILD TABLE',
                subtitle: 'CREATE NEW CHAT ROOM',
                icon: Icons.add_call,
                showCloseButton: true,
                accentColor: AppColors.runeViolet,
                onClose: () => Navigator.pop(context),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: titleController,
                      style: const TextStyle(color: AppColors.onSurface),
                      decoration: InputDecoration(
                        labelText: 'GUILD TABLE TITLE',
                        labelStyle: TextStyle(color: AppColors.onSurfaceVariant),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.onSurface.withValues(alpha: 0.10)),
                          borderRadius: BorderRadius.all(Radius.circular(4.0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.runeViolet),
                          borderRadius: BorderRadius.all(Radius.circular(4.0)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: category,
                      dropdownColor: AppColors.deepSlate,
                      style: const TextStyle(color: AppColors.onSurface),
                      decoration: InputDecoration(
                        labelText: 'CATEGORY PATH',
                        labelStyle: TextStyle(color: AppColors.onSurfaceVariant),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.onSurface.withValues(alpha: 0.10)),
                          borderRadius: BorderRadius.all(Radius.circular(4.0)),
                        ),
                      ),
                      items: _categoryLabels.values.map((cat) {
                        return DropdownMenuItem<String>(
                          value: cat,
                          child: Text(cat.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            category = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: selectedRoomType,
                      dropdownColor: AppColors.deepSlate,
                      style: const TextStyle(color: AppColors.onSurface),
                      decoration: InputDecoration(
                        labelText: 'TABLE TYPE',
                        labelStyle: TextStyle(color: AppColors.onSurfaceVariant),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.onSurface.withValues(alpha: 0.10)),
                          borderRadius: BorderRadius.all(Radius.circular(4.0)),
                        ),
                      ),
                      items: [
                        DropdownMenuItem(value: 'ai_practice', child: Text(l10n.room_type_ai, overflow: TextOverflow.ellipsis)),
                        DropdownMenuItem(value: 'mentorship', child: Text(l10n.room_type_mentorship, overflow: TextOverflow.ellipsis)),
                        DropdownMenuItem(value: 'event', child: Text(l10n.room_type_event, overflow: TextOverflow.ellipsis)),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            selectedRoomType = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(l10n.room_cancel, style: GoogleFonts.jetBrainsMono(color: AppColors.onSurfaceVariant, fontSize: 12)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () async {
                            final title = titleController.text.trim();
                            if (title.isEmpty) return;

                            final user = ref.read(currentUserProvider);
                            if (user == null) return;

                            try {
                              final room = await ref.read(chatRoomsRepositoryProvider).createRoom(
                                    title: title,
                                    category: _getCategorySlug(category),
                                    moderatorId: user.id,
                                    roomType: selectedRoomType,
                                  );

                              if (context.mounted) {
                                Navigator.pop(context);
                                ref.invalidate(chatRoomsListProvider);
                                context.push('/voice-room?roomId=${room['id']}');
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(l10n.room_create_error('$e'))),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.runeViolet,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(4.0)),
                            ),
                          ),
                          child: Text(l10n.room_initialize, style: GoogleFonts.jetBrainsMono(color: AppColors.onSurface, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final roomsAsync = ref.watch(chatRoomsListProvider);
    final l10n = AppLocalizations.of(context)!;

    final contentWidget = Stack(
      children: [
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.manaCyan.withValues(alpha: 0.1),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
              child: const SizedBox.expand(),
            ),
          ),
        ),

        Positioned.fill(
          child: RefreshIndicator(
            onRefresh: () async => ref.invalidate(chatRoomsListProvider),
            color: AppColors.runeViolet,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cabecera del gremio (F1: título + rango + prestigio compacto)
                  const _GuildHallHeader(),

                  const SizedBox(height: 10),

                  // F4: Banner de "gremio vivo" — conectados + anuncio rotativo
                  GlassCard(
                    blur: 20,
                    opacity: AppColors.glassOpacity,
                    border: Border.all(color: AppColors.manaCyan.withValues(alpha: 0.2)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.people_alt_rounded, color: AppColors.manaCyan, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          '${_connectedCount(roomsAsync.value ?? [])} CONECTADOS',
                          style: GoogleFonts.jetBrainsMono(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.manaCyan, letterSpacing: 0.6),
                        ),
                        const SizedBox(width: 16),
                        const Icon(Icons.campaign_rounded, color: AppColors.royalGold, size: 14),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _guildAnnouncements[_currentAnnouncement % _guildAnnouncements.length],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(fontSize: 10, color: AppColors.onSurfaceVariant),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 1. MESAS (Lobby)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          l10n.guild_tables.toUpperCase(),
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurface,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      RunicButton(
                        label: l10n.initialize_room.toUpperCase(),
                        icon: Icons.add_rounded,
                        onPressed: _showCreateRoomDialog,
                        backgroundColor: AppColors.runeViolet,
                        foregroundColor: AppColors.onSurface,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Categories Selector Slider (G-H: dinámicas desde DB)
                  Builder(builder: (context) {
                    final rooms = roomsAsync.value ?? [];
                    final categories = <String>['Todos'];
                    for (final r in rooms) {
                      final slug = r['category'] as String? ?? 'general';
                      final label = _categoryLabels[slug] ?? slug;
                      if (!categories.contains(label)) categories.add(label);
                    }
                    return SizedBox(
                      height: 48,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final cat = categories[index];
                          final isSelected = _selectedCategory == cat;

                          return ConstrainedBox(
                            constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedCategory = cat;
                                });
                              },
                              child: Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.runeViolet.withValues(alpha: 0.2)
                                      : AppColors.onSurface.withValues(alpha: 0.03),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: isSelected ? AppColors.runeViolet : AppColors.onSurface.withValues(alpha: 0.08),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _getCategoryIcon(_slugForLabel(cat)),
                                      color: isSelected ? AppColors.manaCyan : AppColors.onSurfaceVariant,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      cat.toUpperCase(),
                                      style: GoogleFonts.jetBrainsMono(
                                        color: isSelected ? AppColors.onSurface : AppColors.onSurfaceVariant,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }),

                  const SizedBox(height: 16),

                  roomsAsync.when(
                    data: (rooms) {
                      final filtered = _selectedCategory == 'Todos'
                          ? rooms
                          : rooms.where((r) => r['category'] == _getCategorySlug(_selectedCategory)).toList();

                      if (filtered.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40.0),
                            child: Text(
                              l10n.guild_no_rooms,
                              style: const TextStyle(color: AppColors.onSurfaceVariant),
                            ),
                          ),
                        );
                      }

                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filtered.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final room = filtered[index];
                          final speakersCount = room['speakers_count'] as int? ?? 1;
                          final listenersCount = room['listeners_count'] as int? ?? 0;
                          final title = room['title'] as String? ?? 'Free Discussion';

                          return GestureDetector(
                            onTap: () {
                              context.push('/voice-room?roomId=${room['id']}');
                            },
                            child: GlassCard(
                              blur: 20,
                              opacity: AppColors.glassOpacity,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.manaCyan.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: AppColors.manaCyan.withValues(alpha: 0.4)),
                                    ),
                                    child: Icon(
                                      _getCategoryIcon(room['category'] as String? ?? 'general'),
                                      color: AppColors.manaCyan,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                title.toUpperCase(),
                                                style: GoogleFonts.spaceGrotesk(
                                                  color: AppColors.onSurface,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Builder(builder: (context) {
                                              final type = room['room_type'] as String? ?? 'ai_practice';
                                              final String label;
                                              final Color color;
                                              if (type == 'mentorship') {
                                                label = 'MENTORÍA';
                                                color = AppColors.runeViolet;
                                              } else if (type == 'event') {
                                                label = 'EVENTO';
                                                color = AppColors.royalGold;
                                              } else {
                                                label = 'IA';
                                                color = AppColors.manaCyan;
                                              }
                                              return Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: color.withValues(alpha: 0.15),
                                                  borderRadius: BorderRadius.circular(2),
                                                  border: Border.all(color: color.withValues(alpha: 0.4)),
                                                ),
                                                child: Text(
                                                  label,
                                                  style: TextStyle(
                                                    color: color,
                                                    fontSize: 8,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              );
                                            }),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.record_voice_over_rounded, size: 12, color: AppColors.manaCyan),
                                            const SizedBox(width: 4),
                                            Flexible(
                                              child: Text('$speakersCount/6', overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.jetBrainsMono(color: AppColors.manaCyan, fontSize: 10, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            const Spacer(),
                                            const Icon(Icons.people_alt_rounded, size: 12, color: AppColors.onSurfaceVariant),
                                            const SizedBox(width: 4),
                                            Flexible(
                                              child: Text('$listenersCount', overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.jetBrainsMono(color: AppColors.onSurfaceVariant, fontSize: 10),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () => context.push('/voice-room?roomId=${room['id']}'),
                                    child: Container(
                                      constraints: const BoxConstraints(minHeight: 40, minWidth: 56),
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: AppColors.runeViolet.withValues(alpha: 0.9),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        l10n.guild_join.toUpperCase(),
                                        style: GoogleFonts.jetBrainsMono(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40.0),
                        child: CircularProgressIndicator(color: AppColors.runeViolet),
                      ),
                    ),
                    error: (err, stack) => Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40.0),
                        child: Text(
                          'Error loading active gates: $err',
                          style: const TextStyle(color: AppColors.errorRed),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // 2. MISIONES
                  const GuildQuestBoard(),

                  const SizedBox(height: 20),

                  const MissionBoardWidget(),

                  const SizedBox(height: 28),

                  // 3. NPC Maestre de Mesa
                  const GuildMasterNpcBanner(),

                  const SizedBox(height: 28),

                  // 4. TROFEOS del gremio (vitrina al final)
                  const _GuildTrophies(),

                  const SizedBox(height: 28),

                  // 5. Acceso a Tabla de Rango (modal)
                  Align(
                    alignment: Alignment.centerRight,
                    child: _GuildPoster(
                      title: 'TABLA DE RANGO',
                      caption: 'Progreso y rango de cazador.',
                      icon: Icons.military_tech_rounded,
                      accent: AppColors.royalGold,
                      onTap: () => _showRankModal(context, ref),
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ],
    );

    if (widget.isTab) {
      return contentWidget;
    }

    return Scaffold(
      backgroundColor: AppColors.screenBg,
      body: CyberManhwaBackground(
        bgMode: CyberBgMode.guildHall,
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.onSurface),
                onPressed: () => context.pop(),
              ),
              title: Text(
                l10n.guild_hall.toUpperCase(),
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.onSurface,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            Expanded(
              child: contentWidget,
            ),
          ],
        ),
      ),
    );
  }
}

/// Cabecera del Guild Hall (F1 · UX-Audit): título + rango + prestigio compactos
/// en una sola fila. El prestigio ya no ocupa una tarjeta completa.
class _GuildHallHeader extends ConsumerWidget {
  const _GuildHallHeader();

  (String, Color) _rankForCefr(String cefr) {
    final band = cefr.isEmpty ? 'A' : cefr.substring(0, 1).toUpperCase();
    switch (band) {
      case 'B':
        return ('PLATA', AppColors.manaCyan);
      case 'C':
        return ('ORO', AppColors.royalGold);
      default:
        return ('HIERRO', AppColors.emeraldGreen);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final progress = ref.watch(userProgressProvider).value ?? {};
    final cefr = progress['level_code'] as String? ?? 'A';
    final (rankLabel, rankColor) = _rankForCefr(cefr);

    final bpAsync = ref.watch(battlePassProvider);
    final bp = bpAsync.value ?? {};
    final level = (bp['level'] as num?)?.toInt() ?? 1;
    final isPremium = bp['is_premium'] as bool? ?? false;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.guild_hall.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.onSurface,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'RANGO: $rankLabel · $cefr',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: rankColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // Prestigio compacto (chip)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.royalGold.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppColors.royalGold.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.military_tech_rounded, color: AppColors.royalGold, size: 14),
              const SizedBox(width: 6),
              Text(l10n.room_prestige('$level'), style: GoogleFonts.jetBrainsMono(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.royalGold)),
              const SizedBox(width: 6),
              Text(isPremium ? 'PREMIUM' : 'LIBRE', style: GoogleFonts.jetBrainsMono(fontSize: 8, color: isPremium ? AppColors.manaCyan : AppColors.onSurfaceVariant)),
            ],
          ),
        ),
      ],
    );
  }
}

/// Cartel decorativo RPG del gremio (GUILD-01).
/// Con `onTap` se comporta como acceso a una sección (p. ej. /hunter-status);
/// sin `onTap` permanece como elemento visual junto a la lista de salas.
class _GuildPoster extends StatelessWidget {
  const _GuildPoster({
    required this.title,
    required this.caption,
    required this.icon,
    required this.accent,
    this.onTap,
  });

  final String title;
  final String caption;
  final IconData icon;
  final Color accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        blur: 12,
        opacity: AppColors.glassOpacity,
        borderColor: accent,
        showRunicCorners: true,
        runicColor: accent,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: accent.withValues(alpha: 0.5)),
                  ),
                  child: Icon(icon, color: accent, size: 20),
                ),
                const Spacer(),
                if (onTap != null)
                  Icon(Icons.arrow_forward_ios_rounded, color: accent.withValues(alpha: 0.6), size: 12),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              caption,
              style: GoogleFonts.inter(fontSize: 10, color: AppColors.onSurfaceVariant, height: 1.3),
            ),
          ],
        ),
      ),
    );
  }
}

/// Trofeo del gremio (GUILD-03).
class _GuildTrophyData {
  const _GuildTrophyData({
    required this.name,
    required this.threshold,
    required this.accent,
  });

  final String name;
  final int threshold;
  final Color accent;
}

/// Sección "TROFEOS DEL GREMIO" (GUILD-03).
/// GlassCard con esquinas rúnicas que lista logros desbloqueables por
/// misiones colaborativas. Sigue el patrón de estilo de las colecciones
/// del cazador (economy/collections_screen.dart).
class _GuildTrophies extends ConsumerWidget {
  const _GuildTrophies();

  static const List<_GuildTrophyData> _trophies = [
    _GuildTrophyData(name: 'PRIMERA RAID', threshold: 1, accent: AppColors.royalGold),
    _GuildTrophyData(name: '5 RAIDS', threshold: 5, accent: AppColors.manaCyan),
    _GuildTrophyData(name: '10 RAIDS', threshold: 10, accent: AppColors.runeViolet),
    _GuildTrophyData(name: 'RAID DE ÉPICO', threshold: 20, accent: AppColors.emeraldGreen),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final missionsAsync = ref.watch(guildCompletedMissionsProvider);
    final completed = missionsAsync.value ?? 0;
    final unlocked = _trophies.where((t) => completed >= t.threshold).length;

    return GlassCard(
      blur: 16,
      opacity: AppColors.glassOpacity,
      borderColor: AppColors.royalGold,
      showRunicCorners: true,
      runicColor: AppColors.royalGold,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events_rounded, color: AppColors.royalGold, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'TROFEOS DEL GREMIO',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              if (missionsAsync.isLoading)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.royalGold),
                )
              else
                Text(
                  '$unlocked/${_trophies.length}',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.manaCyan,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Logros desbloqueables por misiones colaborativas del gremio.',
            style: GoogleFonts.inter(fontSize: 10, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 14),
          Column(
            children: [
              for (final t in _trophies) ...[
                _GuildTrophyTile(trophy: t, isUnlocked: completed >= t.threshold),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Tile de trofeo del gremio (GUILD-03).
/// Desbloqueado: acento del trofeo + check dorado. Bloqueado: escala de
/// grises con candado (mismo patrón que las colecciones del cazador).
class _GuildTrophyTile extends StatelessWidget {
  const _GuildTrophyTile({required this.trophy, required this.isUnlocked});

  final _GuildTrophyData trophy;
  final bool isUnlocked;

  @override
  Widget build(BuildContext context) {
    final accent = trophy.accent;

    final tile = Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isUnlocked ? accent.withValues(alpha: 0.12) : AppColors.onSurface.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isUnlocked ? accent.withValues(alpha: 0.5) : AppColors.onSurface.withValues(alpha: 0.10),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.emoji_events_rounded,
            color: isUnlocked ? accent : AppColors.onSurfaceVariant,
            size: 26,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trophy.name,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  isUnlocked ? 'DESBLOQUEADO' : 'BLOQUEADO',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 8,
                    letterSpacing: 0.5,
                    color: isUnlocked ? AppColors.royalGold : AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          if (isUnlocked)
            const Icon(Icons.check_circle_rounded, color: AppColors.royalGold, size: 16)
          else
            Icon(Icons.lock_rounded, color: AppColors.onSurfaceVariant.withValues(alpha: 0.7), size: 14),
        ],
      ),
    );

    if (isUnlocked) return tile;

    // Bloqueado: escala de grises + opacidad reducida.
    return ColorFiltered(
      colorFilter: const ColorFilter.matrix(<double>[
        0.2126, 0.7152, 0.0722, 0, 0,
        0.2126, 0.7152, 0.0722, 0, 0,
        0.2126, 0.7152, 0.0722, 0, 0,
        0, 0, 0, 1, 0,
      ]),
      child: Opacity(opacity: 0.4, child: tile),
    );
  }
}
