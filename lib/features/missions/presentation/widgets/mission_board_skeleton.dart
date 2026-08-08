import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/app_colors.dart';

/// Skeleton loading para la cuadrícula de pergaminos del Tablón de Misiones.
/// Muestra celdas shimmer con la silueta del pergamino mientras carga el pool.
class MissionBoardSkeleton extends StatelessWidget {
  const MissionBoardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final cols = MediaQuery.of(context).size.width >= 1000
        ? 4
        : MediaQuery.of(context).size.width >= 650
            ? 3
            : 2;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final itemWidth = (width - (cols + 1) * 10) / cols;
        final itemHeight = itemWidth * 1.0;
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: itemWidth / itemHeight,
          ),
          itemCount: 6,
          itemBuilder: (context, index) => Shimmer.fromColors(
            baseColor: AppColors.onSurface.withValues(alpha: 0.08),
            highlightColor: AppColors.onSurface.withValues(alpha: 0.16),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.medievalDarkWood,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        );
      },
    );
  }
}
