import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SegmentedBar extends StatelessWidget {
  final double value;
  final int segments;
  final Color color;
  final Color? backgroundColor;
  final double height;

  const SegmentedBar({
    super.key,
    required this.value,
    this.segments = 10,
    this.color = AppColors.manaCyan,
    this.backgroundColor,
    this.height = 6,
  });

  @override
  Widget build(BuildContext context) {
    final filled = (value * segments).round().clamp(0, segments);
    final bgColor = backgroundColor ?? AppColors.surfaceContainerHigh;

    return Row(
      children: List.generate(segments, (i) {
        return Expanded(
          child: Container(
            height: height,
            margin: EdgeInsets.only(right: i < segments - 1 ? 2 : 0),
            decoration: BoxDecoration(
              color: i < filled ? color : bgColor,
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
        );
      }),
    );
  }
}
