import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/chat_rooms_providers.dart';
import '../../../../core/widgets/cyber_manhwa_background.dart';

class ChatRoomsScreen extends ConsumerStatefulWidget {
  const ChatRoomsScreen({super.key});

  @override
  ConsumerState<ChatRoomsScreen> createState() => _ChatRoomsScreenState();
}

class _ChatRoomsScreenState extends ConsumerState<ChatRoomsScreen> {
  String _selectedCategory = 'Todos';
  final List<String> _categories = ['Todos', 'Viajes', 'Trabajo', 'Tecnología', 'Arte', 'Cocina'];
  RealtimeChannel? _roomsChannel;

  @override
  void initState() {
    super.initState();
    _subscribeToRoomsRealtime();
  }

  void _subscribeToRoomsRealtime() {
    final supabase = ref.read(supabaseClientProvider);
    _roomsChannel = supabase
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

  @override
  void dispose() {
    if (_roomsChannel != null) {
      ref.read(supabaseClientProvider).removeChannel(_roomsChannel!);
    }
    super.dispose();
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

  void _showCreateRoomDialog() {
    final titleController = TextEditingController();
    String category = 'Viajes';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: GlassCard(
                blur: 30,
                opacity: 0.1,
                border: Border.all(color: AppColors.runeViolet.withValues(alpha: 0.4), width: 1.5),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.add_call, color: AppColors.manaCyan, size: 24),
                        const SizedBox(width: 10),
                        Text(
                          'ESTABLISH GUILD TABLE',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'GUILD TABLE TITLE',
                        labelStyle: TextStyle(color: AppColors.onSurfaceVariant),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white10),
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
                      dropdownColor: const Color(0xFF0F172A),
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'CATEGORY PATH',
                        labelStyle: TextStyle(color: AppColors.onSurfaceVariant),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white10),
                          borderRadius: BorderRadius.all(Radius.circular(4.0)),
                        ),
                      ),
                      items: _categories.where((c) => c != 'Todos').map((cat) {
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
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('CANCEL', style: GoogleFonts.jetBrainsMono(color: AppColors.onSurfaceVariant, fontSize: 12)),
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
                                  );

                              if (context.mounted) {
                                Navigator.pop(context);
                                ref.invalidate(chatRoomsListProvider);
                                context.push('/voice-room?roomId=${room['id']}');
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error al crear sala: $e')),
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
                          child: Text('INITIALIZE', style: GoogleFonts.jetBrainsMono(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
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

    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      body: CyberManhwaBackground(
        bgMode: CyberBgMode.guildHall,
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                onPressed: () => context.pop(),
              ),
              title: Text(
                'THE GRAND GUILD HALL',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            Expanded(
              child: Stack(
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

                  RefreshIndicator(
                    onRefresh: () async => ref.invalidate(chatRoomsListProvider),
                    color: AppColors.runeViolet,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Hero Header Banner
                          GlassCard(
                            blur: 25,
                            opacity: 0.1,
                            border: Border.all(color: AppColors.runeViolet.withValues(alpha: 0.4), width: 1.5),
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.castle_rounded, color: AppColors.manaCyan, size: 24),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              'GUILD DISCUSSION GATES',
                                              style: GoogleFonts.orbitron(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                letterSpacing: 0.5,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Join discussion tables with up to 6 speakers and shared moderation in the Grand Guild Hall.',
                                        style: GoogleFonts.inter(color: AppColors.onSurfaceVariant, fontSize: 12),
                                      ),
                                      const SizedBox(height: 12),
                                      ElevatedButton.icon(
                                        onPressed: _showCreateRoomDialog,
                                        icon: const Icon(Icons.add_rounded, size: 16),
                                        label: Text('ESTABLISH DISCUSSION TABLE', style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.bold)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.runeViolet,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4.0))),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Categories Selector Slider
                          SizedBox(
                            height: 40,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _categories.length,
                              separatorBuilder: (context, index) => const SizedBox(width: 8),
                              itemBuilder: (context, index) {
                                final cat = _categories[index];
                                final isSelected = _selectedCategory == cat;

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedCategory = cat;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.runeViolet.withValues(alpha: 0.2)
                                          : Colors.white.withValues(alpha: 0.03),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: isSelected ? AppColors.runeViolet : Colors.white.withValues(alpha: 0.08),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          _getCategoryIcon(cat),
                                          color: isSelected ? AppColors.manaCyan : AppColors.onSurfaceVariant,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          cat.toUpperCase(),
                                          style: GoogleFonts.jetBrainsMono(
                                            color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 24),

                          Text(
                            'ACTIVE GATES',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 16),

                          roomsAsync.when(
                            data: (rooms) {
                              final filtered = _selectedCategory == 'Todos'
                                  ? rooms
                                  : rooms.where((r) => r['category'] == _getCategorySlug(_selectedCategory)).toList();

                              if (filtered.isEmpty) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 40.0),
                                    child: Text(
                                      'No active gates in this path.',
                                      style: TextStyle(color: AppColors.onSurfaceVariant),
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
                                      opacity: 0.05,
                                      padding: const EdgeInsets.all(18),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: AppColors.manaCyan.withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(4),
                                              border: Border.all(color: AppColors.manaCyan.withValues(alpha: 0.4)),
                                            ),
                                            child: const Icon(
                                              Icons.graphic_eq_rounded,
                                              color: AppColors.manaCyan,
                                              size: 24,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  title,
                                                  style: GoogleFonts.spaceGrotesk(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Row(
                                                  children: [
                                                    const Icon(Icons.record_voice_over_rounded, size: 13, color: AppColors.manaCyan),
                                                    const SizedBox(width: 4),
                                                    Flexible(
                                                      child: Text('$speakersCount/6', overflow: TextOverflow.ellipsis,
                                                        style: GoogleFonts.jetBrainsMono(color: AppColors.manaCyan, fontSize: 11, fontWeight: FontWeight.bold),
                                                      ),
                                                    ),
                                                    const Spacer(),
                                                    const Icon(Icons.people_alt_rounded, size: 13, color: AppColors.onSurfaceVariant),
                                                    const SizedBox(width: 4),
                                                    Flexible(
                                                      child: Text('$listenersCount', overflow: TextOverflow.ellipsis,
                                                        style: GoogleFonts.jetBrainsMono(color: AppColors.onSurfaceVariant, fontSize: 11),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          ElevatedButton(
                                            onPressed: () => context.push('/voice-room?roomId=${room['id']}'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.runeViolet,
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4.0))),
                                            ),
                                            child: Text('JOIN', style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.bold)),
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
                          const SizedBox(height: 100),
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
}
