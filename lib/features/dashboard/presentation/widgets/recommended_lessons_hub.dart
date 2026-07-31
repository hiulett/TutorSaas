import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../data/models/lesson_catalog.dart';
import '../providers/dashboard_providers.dart';
import 'ai_pick_hero_card.dart';
import 'lesson_preview_sheet.dart';

class RecommendedLessonsHub extends ConsumerStatefulWidget {
  const RecommendedLessonsHub({super.key});

  @override
  ConsumerState<RecommendedLessonsHub> createState() => _RecommendedLessonsHubState();
}

class _RecommendedLessonsHubState extends ConsumerState<RecommendedLessonsHub> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'all';
  String _selectedCefr = 'all';
  String _searchQuery = '';

  final List<Map<String, String>> _categories = const [
    {'code': 'all', 'label': 'Todos', 'icon': '🌟'},
    {'code': 'technology', 'label': 'Tecnología', 'icon': '💻'},
    {'code': 'business', 'label': 'Negocios', 'icon': '💼'},
    {'code': 'travel', 'label': 'Viajes', 'icon': '✈️'},
    {'code': 'social', 'label': 'Social', 'icon': '☕'},
    {'code': 'food', 'label': 'Comida', 'icon': '🍳'},
  ];

  final List<String> _cefrLevels = const ['all', 'A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  IconData _getIconData(String iconKey) {
    switch (iconKey.toLowerCase()) {
      case 'handshake':
        return Icons.handshake_rounded;
      case 'people':
        return Icons.people_alt_rounded;
      case 'schedule':
        return Icons.access_time_filled_rounded;
      case 'coffee':
        return Icons.coffee_rounded;
      case 'flight':
        return Icons.flight_takeoff_rounded;
      case 'restaurant':
        return Icons.restaurant_rounded;
      case 'hotel':
        return Icons.hotel_rounded;
      case 'explore':
        return Icons.explore_rounded;
      case 'devices':
        return Icons.devices_rounded;
      case 'work':
        return Icons.work_rounded;
      default:
        return Icons.school_rounded;
    }
  }

  int _calculateMatchScore(LessonData lesson, Map<String, dynamic> progress) {
    final userCefr = (progress['level_code'] as String? ?? 'B1').toUpperCase();
    int score = 75;

    if (lesson.level.toUpperCase() == userCefr) {
      score += 15;
    }
    if (lesson.category.toLowerCase() == 'technology' || lesson.category.toLowerCase() == 'business') {
      score += 8;
    }
    return score.clamp(75, 99);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progressAsync = ref.watch(userProgressProvider);
    final progress = progressAsync.value ?? {'level_code': 'B1'};
    final userCefr = (progress['level_code'] as String? ?? 'B1').toUpperCase();
    final recommendedAsync = ref.watch(recommendedLessonsProvider);
    final recommendedList = recommendedAsync.value ?? [];
    final completedSet = recommendedList
        .where((m) => m['is_completed'] == true)
        .map((m) => m['id'] as String?)
        .where((id) => id != null)
        .toSet();

    // Filter catalog
    var filteredLessons = LessonCatalog.catalog.where((lesson) {
      // Category filter
      if (_selectedCategory != 'all' &&
          lesson.category.toLowerCase() != _selectedCategory.toLowerCase()) {
        return false;
      }
      // CEFR filter
      if (_selectedCefr != 'all' &&
          lesson.level.toUpperCase() != _selectedCefr.toUpperCase()) {
        return false;
      }
      // Search query filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesTitle = lesson.title.toLowerCase().contains(query);
        final matchesDesc = lesson.description.toLowerCase().contains(query);
        final matchesObj = lesson.mainObjective.toLowerCase().contains(query);
        if (!matchesTitle && !matchesDesc && !matchesObj) {
          return false;
        }
      }
      return true;
    }).toList();

    // Select Hero Lesson
    final heroLesson = filteredLessons.firstWhere(
      (l) => l.level.toUpperCase() == userCefr,
      orElse: () => filteredLessons.isNotEmpty ? filteredLessons.first : LessonCatalog.catalog.first,
    );

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),

            // Header Title
            Row(
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.runeViolet,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Smart Discovery Hub',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => context.push('/chat-rooms'),
                  icon: const Icon(Icons.groups_rounded, size: 16),
                  label: const Text('Salas de Voz', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.manaCyan,
                    foregroundColor: const Color(0xFF0F172A),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Lecciones personalizadas según tu nivel, intereses y metas de onboarding',
              style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12),
            ),

            const SizedBox(height: 16),

            // Search Bar
            TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.trim();
                });
              },
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Buscar lección, rol o tema...',
                hintStyle: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.runeViolet),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, color: Colors.white54, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.04),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppColors.runeViolet,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Category Chips Carousel
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: _categories.map((cat) {
                  final isSelected = _selectedCategory == cat['code'];

                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      selected: isSelected,
                      onSelected: (val) {
                        setState(() {
                          _selectedCategory = cat['code']!;
                        });
                      },
                      avatar: Text(cat['icon']!, style: const TextStyle(fontSize: 12)),
                      label: Text(cat['label']!),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                      selectedColor: AppColors.runeViolet,
                      backgroundColor: Colors.white.withValues(alpha: 0.04),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.runeViolet
                            : Colors.white.withValues(alpha: 0.08),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 8),

            // CEFR Pills Carousel
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: _cefrLevels.map((lvl) {
                  final isSelected = _selectedCefr == lvl;

                  return Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: FilterChip(
                      selected: isSelected,
                      onSelected: (val) {
                        setState(() {
                          _selectedCefr = lvl;
                        });
                      },
                      label: Text(lvl == 'all' ? 'Todos Niveles' : 'Nivel $lvl'),
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.manaCyan : AppColors.onSurfaceVariant,
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      selectedColor: AppColors.manaCyan.withValues(alpha: 0.15),
                      backgroundColor: Colors.transparent,
                      side: BorderSide(
                        color: isSelected ? AppColors.manaCyan : Colors.transparent,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            // AI Pick Hero Card (Only when not actively searching)
            if (_searchQuery.isEmpty && _selectedCategory == 'all' && _selectedCefr == 'all') ...[
              AIPickHeroCard(
                lesson: heroLesson,
                matchPercentage: 98,
                matchReason: '💡 Coincide 100% con tu meta de Carrera e interés en Tecnología',
                onTapPreview: () => LessonPreviewSheet.show(context, heroLesson),
              ),
              const SizedBox(height: 24),
            ],

            // Section Title for List
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Catálogo Personalizado (${filteredLessons.length})',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _selectedCefr == 'all' ? 'Nivel sugerido: $userCefr' : 'Filtro: $_selectedCefr',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Lessons Vanguard List
            if (filteredLessons.isEmpty)
              const GlassCard(
                blur: 15,
                opacity: 0.04,
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'No se encontraron lecciones con los filtros seleccionados.',
                    style: TextStyle(color: AppColors.onSurfaceVariant),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredLessons.length,
                separatorBuilder: (context, index) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final lesson = filteredLessons[index];
                  final matchScore = _calculateMatchScore(lesson, progress);
                  final iconData = _getIconData(lesson.iconKey);

                  final bool isCompleted = completedSet.contains(lesson.id);
                  final bool isNextLesson = !isCompleted &&
                      (index == 0 || completedSet.contains(filteredLessons[index - 1].id));
                  final bool isLocked = !isCompleted && !isNextLesson;

                  return GlassCard(
                    blur: 20,
                    opacity: 0.08,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.05),
                      width: 1,
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.runeViolet.withValues(alpha: 0.2),
                              ),
                              child: Icon(iconData, color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.runeViolet.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          'NIVEL ${lesson.level}',
                                          style: GoogleFonts.hankenGrotesk(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.manaCyan,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '⚡ $matchScore% Match',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF10B981),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    lesson.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          lesson.description,
                          style: const TextStyle(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 11,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 14),

                        // Action Buttons Row
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => LessonPreviewSheet.show(context, lesson),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: BorderSide(
                                    color: Colors.white.withValues(alpha: 0.2),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Ver Objetivos', style: TextStyle(fontSize: 12)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: isLocked
                                    ? () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('🔒 Completa la lección anterior de tu ruta para desbloquear.'),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      }
                                    : () {
                                        context.push(
                                          '/conversation?scenarioId=${lesson.id}&scenarioTitle=${Uri.encodeComponent(lesson.title)}',
                                        );
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isLocked
                                      ? Colors.white12
                                      : (isCompleted ? const Color(0xFF10B981) : AppColors.runeViolet),
                                  foregroundColor: isLocked ? Colors.white38 : Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        isLocked
                                            ? Icons.lock_rounded
                                            : (isCompleted ? Icons.check_circle_rounded : Icons.mic_rounded),
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        isLocked ? 'Bloqueado' : (isCompleted ? 'Repasar ⭐' : 'Hablar'),
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
