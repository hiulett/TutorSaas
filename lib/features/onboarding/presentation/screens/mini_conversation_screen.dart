import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/cyber_manhwa_background.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/runic_button.dart';
import '../../../../core/widgets/system_snack.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/models/mini_conversation_script.dart';
import '../providers/mini_conversation_providers.dart';

/// P-25 (#110): mini-conversación de valor tras el onboarding.
///
/// Escena guiada de 1-2 respuestas («pide un café») con Mira. Usa el pipeline
/// existente sin modificarlo: `/transcribe` para la voz y `/chat` (acción
/// gratuita `guild_chat`) para el tutor. Si el modelo o la red fallan, la
/// pantalla ofrece continuar al reino: nunca bloquea.
class MiniConversationScreen extends ConsumerStatefulWidget {
  const MiniConversationScreen({super.key});

  @override
  ConsumerState<MiniConversationScreen> createState() =>
      _MiniConversationScreenState();
}

class _MiniConversationScreenState
    extends ConsumerState<MiniConversationScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final Record _recorder = Record();

  bool _isRecording = false;
  bool _isTranscribing = false;
  bool _isLeaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(miniConversationProvider.notifier).start();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    unawaited(_recorder.dispose());
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _sendText() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    final notifier = ref.read(miniConversationProvider.notifier);
    await notifier.replyText(text);
    _scrollToBottom();
  }

  Future<void> _toggleRecording() async {
    final l10n = AppLocalizations.of(context);
    if (_isTranscribing) return;

    if (_isRecording) {
      setState(() => _isRecording = false);
      final path = await _recorder.stop();
      if (path == null || path.isEmpty) return;
      if (!mounted) return;
      setState(() => _isTranscribing = true);
      final result = await ref
          .read(miniConversationProvider.notifier)
          .replyWithVoice(path);
      if (!mounted) return;
      setState(() => _isTranscribing = false);
      _scrollToBottom();
      if (result == MiniVoiceResult.empty) {
        SystemSnack.show(
          context,
          l10n?.mini_conv_voice_empty ?? 'We did not hear any speech.',
          type: SystemSnackType.warning,
          duration: const Duration(milliseconds: 3000),
        );
      } else if (result == MiniVoiceResult.error) {
        SystemSnack.show(
          context,
          l10n?.mini_conv_voice_failed ?? 'Could not transcribe your audio.',
          type: SystemSnackType.error,
          duration: const Duration(milliseconds: 3000),
        );
      }
      return;
    }

    try {
      final granted = await _recorder.hasPermission();
      if (!granted) {
        if (!mounted) return;
        SystemSnack.show(
          context,
          l10n?.mini_conv_mic_denied ?? 'Microphone unavailable.',
          type: SystemSnackType.warning,
          duration: const Duration(milliseconds: 3000),
        );
        return;
      }
      final tempDir = await getTemporaryDirectory();
      final path =
          '${tempDir.path}/mini_conv_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _recorder.start(
        path: path,
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        samplingRate: 16000,
      );
      if (!mounted) return;
      setState(() => _isRecording = true);
    } catch (e) {
      debugPrint('MiniConversation: no se pudo grabar: $e');
      if (!mounted) return;
      SystemSnack.show(
        context,
        l10n?.mini_conv_mic_denied ?? 'Microphone unavailable.',
        type: SystemSnackType.warning,
        duration: const Duration(milliseconds: 3000),
      );
    }
  }

  Future<void> _leave({required bool skipped}) async {
    if (_isLeaving) return;
    _isLeaving = true;
    if (_isRecording) {
      _isRecording = false;
      unawaited(_recorder.stop());
    }
    await ref.read(miniConversationProvider.notifier).finish(skipped: skipped);
    if (!mounted) return;
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(miniConversationProvider);

    ref.listen(miniConversationProvider, (previous, next) {
      if (previous?.turns.length != next.turns.length) _scrollToBottom();
    });

    return Scaffold(
      body: CyberManhwaBackground(
        bgMode: CyberBgMode.onboardingStep3,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(l10n),
                const SizedBox(height: 10),
                _buildProgress(state),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView(
                    controller: _scroll,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      for (final turn in state.turns) _buildBubble(turn),
                      if (state.isSending) _buildTypingIndicator(),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                if (state.isComplete)
                  _buildFinishPanel(l10n, state)
                else
                  _buildInputPanel(l10n, state),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations? l10n) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n?.mini_conv_badge ?? '60-SECOND TRIAL',
                style: AppTypography.label(
                  context,
                ).copyWith(color: AppColors.royalGold),
              ),
              const SizedBox(height: 4),
              Text(
                l10n?.mini_conv_title ?? 'Order a coffee',
                style: AppTypography.title(context),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: l10n?.mini_conv_skip ?? 'Skip for now',
          onPressed: () => _leave(skipped: true),
          icon: const Icon(Icons.close_rounded, color: AppColors.onSurface),
        ),
      ],
    );
  }

  Widget _buildProgress(MiniConversationState state) {
    return Row(
      children: [
        for (
          var index = 0;
          index < MiniConversationScript.maxUserTurns;
          index++
        )
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              height: 4,
              decoration: BoxDecoration(
                color: index < state.userTurns
                    ? AppColors.royalGold
                    : AppColors.onSurface.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBubble(MiniConversationTurn turn) {
    final fromUser = turn.fromUser;
    final accent = fromUser ? AppColors.manaCyan : AppColors.royalGold;
    return Align(
      alignment: fromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: fromUser ? 0.14 : 0.12),
          border: Border.all(color: accent.withValues(alpha: 0.42)),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: Radius.circular(fromUser ? 12 : 3),
            bottomRight: Radius.circular(fromUser ? 3 : 12),
          ),
        ),
        child: Text(
          turn.text,
          style: AppTypography.body(context).copyWith(height: 1.45),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10, left: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.royalGold,
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildInputPanel(AppLocalizations? l10n, MiniConversationState state) {
    final busy = state.isSending || _isTranscribing || _isRecording;
    final canReply = state.canReply && !_isTranscribing && !_isRecording;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _isRecording
              ? (l10n?.mini_conv_recording ?? 'RECORDING...')
              : _isTranscribing
              ? (l10n?.mini_conv_transcribing ?? 'TRANSCRIBING...')
              : (l10n?.mini_conv_your_turn ?? 'YOUR TURN'),
          style: AppTypography.tiny(context).copyWith(
            color: _isRecording ? AppColors.crimsonRed : AppColors.manaCyan,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                enabled: canReply,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendText(),
                style: AppTypography.body(
                  context,
                ).copyWith(color: AppColors.onSurface),
                decoration: InputDecoration(
                  hintText:
                      l10n?.mini_conv_input_hint ??
                      'Type your answer in English...',
                  hintStyle: AppTypography.bodyMuted(
                    context,
                  ).copyWith(fontSize: 13),
                  filled: true,
                  fillColor: AppColors.onSurface.withValues(alpha: 0.05),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(
                      color: AppColors.onSurface.withValues(alpha: 0.15),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(
                      color: AppColors.onSurface.withValues(alpha: 0.15),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: const BorderSide(color: AppColors.manaCyan),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            IconButton(
              tooltip: l10n?.mini_conv_record ?? 'Answer with your voice',
              onPressed: canReply && !busy ? _toggleRecording : null,
              icon: Icon(
                _isRecording ? Icons.stop_circle : Icons.mic_rounded,
                color: _isRecording
                    ? AppColors.crimsonRed
                    : (canReply && !busy
                          ? AppColors.manaCyan
                          : AppColors.onSurfaceVariant),
              ),
            ),
            IconButton(
              tooltip: l10n?.mini_conv_send ?? 'Send',
              onPressed: canReply && !busy ? _sendText : null,
              icon: Icon(
                Icons.send_rounded,
                color: canReply && !busy
                    ? AppColors.manaCyan
                    : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n?.mini_conv_turn_counter(
                    state.userTurns + 1,
                    MiniConversationScript.maxUserTurns,
                  ) ??
                  '',
              style: AppTypography.tiny(context),
            ),
            TextButton(
              onPressed: () => _leave(skipped: true),
              child: Text(
                l10n?.mini_conv_skip ?? 'SKIP FOR NOW',
                style: AppTypography.tiny(
                  context,
                ).copyWith(color: AppColors.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFinishPanel(
    AppLocalizations? l10n,
    MiniConversationState state,
  ) {
    final failed = state.failure != null;
    return GlassCard(
      borderColor: failed ? AppColors.crimsonRed : AppColors.royalGold,
      border: Border.all(
        color: (failed ? AppColors.crimsonRed : AppColors.royalGold).withValues(
          alpha: 0.6,
        ),
      ),
      showRunicCorners: !failed,
      runicColor: AppColors.royalGold,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (failed) ...[
            Text(
              l10n?.mini_conv_unavailable_title ?? 'MIRA IS NOT AVAILABLE',
              style: AppTypography.label(
                context,
              ).copyWith(color: AppColors.crimsonRed),
            ),
            const SizedBox(height: 8),
            Text(
              l10n?.mini_conv_unavailable_body ??
                  'Your adventure starts anyway.',
              style: AppTypography.bodyMuted(context).copyWith(height: 1.4),
            ),
            const SizedBox(height: 14),
            RunicButton(
              label: l10n?.mini_conv_continue ?? 'CONTINUE',
              icon: Icons.arrow_forward_rounded,
              backgroundColor: AppColors.runeViolet,
              foregroundColor: AppColors.onSurface,
              onPressed: () => _leave(skipped: true),
            ),
          ] else ...[
            Text(
              l10n?.mini_conv_unlocked_label ?? 'PHRASE UNLOCKED',
              textAlign: TextAlign.center,
              style: AppTypography.label(
                context,
              ).copyWith(color: AppColors.royalGold),
            ),
            const SizedBox(height: 8),
            Text(
              MiniConversationScript.unlockedPhrase,
              textAlign: TextAlign.center,
              style: AppTypography.subtitle(
                context,
              ).copyWith(color: AppColors.royalGoldLight, height: 1.35),
            ),
            const SizedBox(height: 4),
            Text(
              l10n?.mini_conv_unlocked_translation ??
                  'A flat white to take away, please.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMuted(
                context,
              ).copyWith(fontSize: 12, height: 1.35),
            ),
            const SizedBox(height: 14),
            RunicButton(
              label: l10n?.mini_conv_cta ?? 'START MY ADVENTURE',
              icon: Icons.door_front_door_rounded,
              backgroundColor: AppColors.royalGold,
              foregroundColor: AppColors.voidBg,
              onPressed: () => _leave(skipped: false),
            ),
          ],
        ],
      ),
    );
  }
}
