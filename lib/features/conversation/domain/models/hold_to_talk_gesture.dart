/// P-34f (#198): máquina de estados pura del gesto «mantener para hablar».
///
/// No conoce Flutter ni el grabador: recibe instantes y distancias y devuelve
/// la acción que la UI debe ejecutar. Así el comportamiento (umbral mínimo,
/// cancelación por arrastre, liberación sin pulsación previa) se prueba sin
/// dispositivo ni plugin nativo.
enum HoldToTalkAction {
  /// Sin efecto (evento fuera de secuencia o ya gestionado).
  none,

  /// La pulsación empezó: la UI debe iniciar la grabación.
  start,

  /// Se soltó dentro del botón y por encima del umbral: enviar al STT.
  send,

  /// Se soltó dentro del botón pero antes del umbral: descartar sin STT.
  tooShort,

  /// Se soltó fuera del botón o se canceló el puntero: descartar sin STT.
  cancel,
}

class HoldToTalkGesture {
  HoldToTalkGesture({
    this.minHoldDuration = defaultMinHoldDuration,
    this.cancelDistance = defaultCancelDistance,
  });

  /// Umbral mínimo para considerar que el alumno habló (issue #198).
  static const Duration defaultMinHoldDuration = Duration(milliseconds: 300);

  /// Distancia al centro del botón (en píxeles) a partir de la cual soltar
  /// cancela la grabación, para que arrastrar fuera no transcriba.
  static const double defaultCancelDistance = 96;

  final Duration minHoldDuration;
  final double cancelDistance;

  DateTime? _startedAt;
  bool _draggedOut = false;

  bool get isHolding => _startedAt != null;

  /// `true` cuando el puntero está lo bastante lejos del botón y soltar
  /// cancelaría la grabación.
  bool get willCancel => _draggedOut;

  /// Duración transcurrida desde la pulsación (cero si no hay gesto activo).
  Duration elapsedAt(DateTime now) {
    final startedAt = _startedAt;
    if (startedAt == null) return Duration.zero;
    final elapsed = now.difference(startedAt);
    return elapsed.isNegative ? Duration.zero : elapsed;
  }

  /// Botón pulsado. Ignora pulsaciones repetidas mientras el gesto está vivo.
  HoldToTalkAction press(DateTime now) {
    if (_startedAt != null) return HoldToTalkAction.none;
    _startedAt = now;
    _draggedOut = false;
    return HoldToTalkAction.start;
  }

  /// Movimiento del puntero; [distanceFromCenter] se mide respecto al centro
  /// del botón. Solo actualiza la intención de cancelar.
  HoldToTalkAction drag(double distanceFromCenter) {
    if (_startedAt == null) return HoldToTalkAction.none;
    _draggedOut = distanceFromCenter > cancelDistance;
    return HoldToTalkAction.none;
  }

  /// Puntero levantado. Decide entre enviar, descartar por corto o cancelar.
  HoldToTalkAction release(DateTime now) {
    final startedAt = _startedAt;
    if (startedAt == null) return HoldToTalkAction.none;
    final draggedOut = _draggedOut;
    final elapsed = elapsedAt(now);
    reset();
    if (draggedOut) return HoldToTalkAction.cancel;
    if (elapsed < minHoldDuration) return HoldToTalkAction.tooShort;
    return HoldToTalkAction.send;
  }

  /// Puntero cancelado por el sistema (llamada, gesto del SO, etc.).
  HoldToTalkAction cancel() {
    if (_startedAt == null) return HoldToTalkAction.none;
    reset();
    return HoldToTalkAction.cancel;
  }

  void reset() {
    _startedAt = null;
    _draggedOut = false;
  }
}
