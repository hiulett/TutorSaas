import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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
                border: Border.all(color: AppColors.primaryPurple.withValues(alpha: 0.4), width: 1.5),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.add_call, color: AppColors.tertiaryTeal, size: 24),
                        const SizedBox(width: 10),
                        Text(
                          'Crear Sala de Voz',
                          style: GoogleFonts.hankenGrotesk(
                            fontSize: 20,
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
                      decoration: InputDecoration(
                        labelText: 'Título de la sala',
                        labelStyle: const TextStyle(color: AppColors.onSurfaceVariant),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: AppColors.primaryPurple),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: category,
                      dropdownColor: const Color(0xFF0F172A),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Categoría',
                        labelStyle: const TextStyle(color: AppColors.onSurfaceVariant),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: _categories.where((c) => c != 'Todos').map((cat) {
                        return DropdownMenuItem<String>(
                          value: cat,
                          child: Text(cat),
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
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      alignment: WrapAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancelar', style: TextStyle(color: AppColors.onSurfaceVariant)),
                        ),
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
                            backgroundColor: AppColors.primaryPurple,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Crear e Ingresar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                'El Gran Hall del Gremio',
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
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
                color: AppColors.tertiaryTeal.withValues(alpha: 0.1),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
                child: const SizedBox.expand(),
              ),
            ),
          ),

          RefreshIndicator(
            onRefresh: () async => ref.invalidate(chatRoomsListProvider),
            color: AppColors.primaryPurple,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Header Banner - El Gran Gremio de Cazadores
                  GlassCard(
                    blur: 25,
                    opacity: 0.1,
                    border: Border.all(color: AppColors.primaryPurple.withValues(alpha: 0.4), width: 1.5),
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text('🏰', style: TextStyle(fontSize: 20)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'EL GRAN GREMIO DE CAZADORES',
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
                              const Text(
                                'Toma asiento en las Mesas de Discusión del Gremio con 6 puestos de oradores y moderación compartida.',
                                style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: _showCreateRoomDialog,
                                icon: const Icon(Icons.add_rounded, size: 16),
                                label: const Text('Establecer Mesa de Gremio', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryPurple,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                                  ? AppColors.primaryPurple.withValues(alpha: 0.2)
                                  : Colors.white.withValues(alpha: 0.03),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? AppColors.primaryPurple : Colors.white.withValues(alpha: 0.08),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _getCategoryIcon(cat),
                                  color: isSelected ? AppColors.tertiaryTeal : AppColors.onSurfaceVariant,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  cat,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
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
                    'Salas Activas de Conversación',
                    style: GoogleFonts.hankenGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
                              'No hay salas activas en esta categoría.',
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
                          final title = room['title'] as String? ?? 'Conversación Libre';

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
                                      color: AppColors.tertiaryTeal.withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: AppColors.tertiaryTeal.withValues(alpha: 0.4)),
                                    ),
                                    child: const Icon(
                                      Icons.graphic_eq_rounded,
                                      color: AppColors.tertiaryTeal,
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
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            const Icon(Icons.record_voice_over_rounded, size: 13, color: AppColors.tertiaryTeal),
                                            const SizedBox(width: 4),
                                            Text(
                                              '$speakersCount/6 Hablantes',
                                              style: const TextStyle(color: AppColors.tertiaryTeal, fontSize: 11, fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(width: 12),
                                            const Icon(Icons.people_alt_rounded, size: 13, color: AppColors.onSurfaceVariant),
                                            const SizedBox(width: 4),
                                            Text(
                                              '$listenersCount en gradas',
                                              style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => context.push('/voice-room?roomId=${room['id']}'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryPurple,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    child: const Text('Unirme', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
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
                        child: CircularProgressIndicator(color: AppColors.primaryPurple),
                      ),
                    ),
                    error: (err, stack) => Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40.0),
                        child: Text(
                          'Error al cargar salas: $err',
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
