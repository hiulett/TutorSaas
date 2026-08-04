import 'package:flutter/material.dart';

/// Renderiza el arte de un avatar de cazador con encuadre optimizado.
///
/// Los assets de avatar son panorámicos (2816×1536) con fondo transparente.
/// Este widget centraliza el `BoxFit.cover` + alineación centrada + alta
/// calidad para que se vean consistentes en tarjetas compactas y previews
/// circulares, recortando la imagen sin deformarla.
class HunterAvatar extends StatelessWidget {
  final String imageUrl;
  final double size;
  final IconData fallbackIcon;
  final Color fallbackColor;
  final bool circular;
  final BorderRadius? borderRadius;

  const HunterAvatar({
    super.key,
    required this.imageUrl,
    this.size = 48,
    this.fallbackIcon = Icons.shield_moon_rounded,
    this.fallbackColor = const Color(0xFF00E5FF),
    this.circular = false,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final Widget image = ClipRRect(
      borderRadius: circular
          ? BorderRadius.circular(size / 2)
          : (borderRadius ?? BorderRadius.circular(4.0)),
      child: Image.asset(
        imageUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        alignment: Alignment.center,
        filterQuality: FilterQuality.high,
        errorBuilder: (_, __, ___) => Container(
          width: size,
          height: size,
          color: Colors.transparent,
          child: Icon(fallbackIcon, color: fallbackColor, size: size * 0.6),
        ),
      ),
    );

    if (circular) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: fallbackColor.withValues(alpha: 0.5), width: 1),
        ),
        child: image,
      );
    }
    return image;
  }
}
