import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/models/tts_preferences.dart';

/// P-34c (#119): hoja de ajustes de voz del tutor.
///
/// Solo presenta valores y emite callbacks; la persistencia vive en
/// `ConversationNotifier.setTtsSpeed` / `setTutorVoice`.
class TtsSettingsSheet extends StatelessWidget {
  const TtsSettingsSheet({
    super.key,
    required this.speed,
    required this.voiceId,
    required this.voices,
    required this.title,
    required this.speedLabel,
    required this.voiceLabel,
    required this.defaultVoiceLabel,
    required this.noVoicesMessage,
    required this.onSpeedChanged,
    required this.onVoiceChanged,
  });

  final double speed;
  final String? voiceId;

  /// Cada entrada: `{'name': ..., 'locale': ...}`.
  final List<Map<String, String>> voices;
  final String title;
  final String speedLabel;
  final String voiceLabel;
  final String defaultVoiceLabel;
  final String noVoicesMessage;
  final ValueChanged<double> onSpeedChanged;
  final ValueChanged<String?> onVoiceChanged;

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.72;
    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: AppColors.surfaceDeep,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: Colors.white12)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(
                    Icons.record_voice_over_rounded,
                    color: AppColors.runeViolet,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _sectionLabel(speedLabel),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: TtsPreferences.supportedSpeeds
                    .map(_buildSpeedChip)
                    .toList(growable: false),
              ),
              const SizedBox(height: 20),
              _sectionLabel(voiceLabel),
              const SizedBox(height: 6),
              _voiceTile(
                key: const Key('tts-voice-default'),
                label: defaultVoiceLabel,
                subtitle: null,
                selected: voiceId == null || voiceId!.isEmpty,
                onTap: () => onVoiceChanged(null),
              ),
              if (voices.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    noVoicesMessage,
                    key: const Key('tts-no-voices'),
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                )
              else
                ...voices.map(
                  (voice) => _voiceTile(
                    key: Key('tts-voice-${voice['name']}'),
                    label: voice['name'] ?? '',
                    subtitle: (voice['locale'] ?? '').isEmpty
                        ? null
                        : voice['locale'],
                    selected: voiceId == voice['name'],
                    onTap: () => onVoiceChanged(voice['name']),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: AppColors.manaCyan,
        fontSize: 10,
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildSpeedChip(double value) {
    final selected =
        (TtsPreferences.normalizeSpeed(speed) - value).abs() < 0.001;
    return InkWell(
      key: Key('tts-speed-${TtsPreferences.label(value)}'),
      onTap: () => onSpeedChanged(value),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.runeViolet.withValues(alpha: 0.25)
              : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.runeViolet : Colors.white24,
          ),
        ),
        child: Text(
          TtsPreferences.label(value),
          style: TextStyle(
            color: selected ? AppColors.runeVioletText : Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _voiceTile({
    required Key key,
    required String label,
    required String? subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      type: MaterialType.transparency,
      child: ListTile(
        key: key,
        onTap: onTap,
        dense: true,
        contentPadding: EdgeInsets.zero,
        leading: Icon(
          selected
              ? Icons.radio_button_checked_rounded
              : Icons.radio_button_unchecked_rounded,
          color: selected ? AppColors.manaCyan : Colors.white38,
          size: 20,
        ),
        title: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: selected ? Colors.white : Colors.white70,
            fontSize: 13,
          ),
        ),
        subtitle: subtitle == null
            ? null
            : Text(
                subtitle,
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
      ),
    );
  }
}
