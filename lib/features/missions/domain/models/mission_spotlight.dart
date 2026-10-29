import 'mission_models.dart';
import 'mission_visibility.dart';

/// Selección de la "misión del día destacada" (issue #109).
///
/// 1 principal + N secundarias, elegidas entre las misiones visibles y
/// alcanzables: primero las que ya se pueden reclamar, después las que están
/// más cerca de completarse. Lógica pura (sin Flutter) para poder testearla.
class MissionSpotlight {
  final MissionInstance? primary;
  final List<MissionInstance> secondary;

  const MissionSpotlight({this.primary, this.secondary = const []});

  bool get isEmpty => primary == null;

  static const int defaultSecondaryCount = 2;

  /// Construye el destacado a partir de todas las misiones activas.
  ///
  /// Se descartan:
  /// - tipos ocultos (`secondary`, `secret`, `emergency`, `guild`, ...),
  /// - misiones expiradas,
  /// - objetivos sin trigger de servidor o con target fuera de techo.
  static MissionSpotlight from(
    List<MissionInstance> missions, {
    int secondaryCount = defaultSecondaryCount,
  }) {
    final eligible =
        missions
            .where(
              (m) => !m.isExpired && MissionVisibility.isReachableInstance(m),
            )
            .toList()
          ..sort(MissionVisibility.compareForDisplay);

    if (eligible.isEmpty) return const MissionSpotlight();

    final primary = eligible.first;
    final rest = eligible.skip(1).take(secondaryCount).toList(growable: false);
    return MissionSpotlight(primary: primary, secondary: rest);
  }
}
