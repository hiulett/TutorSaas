/// Identidad del jugador (P-11i / #157).
///
/// La clase vive en `user_language_profiles.character_class`; `users.avatar_url`
/// solo debe contener la URL de la foto. El fallback tolera datos antiguos
/// donde `avatar_url` guardaba el id de clase.
String playerClassOf(
  Map<String, dynamic>? profile, {
  String fallback = 'warrior',
}) {
  final cls = profile?['character_class'];
  if (cls is String && cls.isNotEmpty) return cls;
  final avatar = profile?['avatar_url'];
  if (avatar is String && avatar.isNotEmpty && !avatar.startsWith('http')) {
    return avatar;
  }
  return fallback;
}

/// URL de la foto de perfil (null si no hay o si el valor es legado).
String? playerAvatarUrlOf(Map<String, dynamic>? profile) {
  final avatar = profile?['avatar_url'];
  if (avatar is String && avatar.startsWith('http')) return avatar;
  return null;
}
