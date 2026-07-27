import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';

class CompletedLessonsHistoryList extends StatefulWidget {
  final List<Map<String, dynamic>> completedLessons;

  const CompletedLessonsHistoryList({
    super.key,
    required this.completedLessons,
  });

  static const Color accentGreen = Color(0xFF10B981);

  @override
  State<CompletedLessonsHistoryList> createState() => _CompletedLessonsHistoryListState();
}

class _CompletedLessonsHistoryListState extends State<CompletedLessonsHistoryList> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final rawList = widget.completedLessons.isNotEmpty
        ? widget.completedLessons
        : [
            {
              'title': 'Saludos y Presentaciones',
              'level': 'A1',
              'score': 94,
              'date': 'Hace 2 días',
              'pronunciation': 92,
              'grammar': 95,
              'fluency': 94,
              'feedback': 'Excelente fluidez y entonación inicial.',
            },
            {
              'title': 'Pedir Comida en un Café',
              'level': 'A1',
              'score': 88,
              'date': 'Hace 5 días',
              'pronunciation': 85,
              'grammar': 90,
              'fluency': 89,
              'feedback': 'Buena elección de vocabulario y frases útiles.',
            },
            {
              'title': 'Entrevista de Trabajo Inicial',
              'level': 'B1',
              'score': 91,
              'date': 'Hace 1 semana',
              'pronunciation': 90,
              'grammar': 92,
              'fluency': 91,
              'feedback': 'Gran manejo de preguntas y vocabulario profesional.',
            },
            {
              'title': 'Check-in en Hotel y Turismo',
              'level': 'A2',
              'score': 86,
              'date': 'Hace 2 semanas',
              'pronunciation': 84,
              'grammar': 88,
              'fluency': 86,
              'feedback': 'Comprensión clara de direcciones e indicaciones.',
            },
            {
              'title': 'Reunión de Negocios y Presentación',
              'level': 'B2',
              'score': 95,
              'date': 'Hace 3 semanas',
              'pronunciation': 94,
              'grammar': 96,
              'fluency': 95,
              'feedback': 'Discurso formal estructurado sin vacilaciones.',
            },
          ];

    final displayList = _isExpanded ? rawList : rawList.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  const Icon(
                    Icons.task_alt_rounded,
                    color: CompletedLessonsHistoryList.accentGreen,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Historial de Lecciones Superadas',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (rawList.length > 3)
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                icon: Icon(
                  _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  color: AppColors.tertiaryTeal,
                  size: 16,
                ),
                label: Text(
                  _isExpanded ? 'VER MENOS' : 'VER MÁS (${rawList.length})',
                  style: const TextStyle(
                    color: AppColors.tertiaryTeal,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),

        _isExpanded
            ? Container(
                height: 380, // Fixed scroll container showing ~4 cards at once with internal scroll
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: rawList.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) => _buildLessonCard(rawList[index]),
                ),
              )
            : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: displayList.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) => _buildLessonCard(displayList[index]),
              ),
      ],
    );
  }

  Widget _buildLessonCard(Map<String, dynamic> item) {
    final title = item['title'] as String? ?? 'Lección Superada';
    final level = item['level'] as String? ?? 'A1';
    final score = item['score'] as int? ?? 90;
    final pron = item['pronunciation'] as int? ?? 90;
    final gram = item['grammar'] as int? ?? 92;
    final flue = item['fluency'] as int? ?? 88;
    final feedback = item['feedback'] as String? ?? '¡Buen trabajo en esta lección!';

    return GlassCard(
      blur: 15,
      opacity: 0.06,
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.05),
        width: 1,
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primaryPurple.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        level,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.tertiaryTeal,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: CompletedLessonsHistoryList.accentGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: CompletedLessonsHistoryList.accentGreen.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: CompletedLessonsHistoryList.accentGreen,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$score%',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: CompletedLessonsHistoryList.accentGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            feedback,
            style: const TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMiniMetric('Pronunciación', '$pron%'),
              _buildMiniMetric('Gramática', '$gram%'),
              _buildMiniMetric('Fluidez', '$flue%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.onSurfaceVariant,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
