/// Grados de respuesta del repaso espaciado (SM-2).
///
/// Issue #24: el mapeo entre botón y calidad vive acá y no en la pantalla,
/// para que se pueda verificar con un test. La RPC `record_vocabulary_review`
/// considera lapso cuando `quality < 3`, así que NORMAL tiene que quedar en
/// 3.0: si bajara a 2.5, repasar bien reiniciaría el intervalo y el usuario
/// nunca progresaría.
enum SrsGrade {
  hard(2.0),
  normal(3.0),
  easy(5.0);

  const SrsGrade(this.quality);

  /// Puntaje de calidad SM-2, en la escala 0-5.
  final double quality;

  /// `true` si el repaso cuenta como lapso y reinicia el intervalo.
  bool get isLapse => quality < 3.0;
}
