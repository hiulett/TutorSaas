// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'conversation_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ConversationState {
  List<ConversationMessage> get messages => throw _privateConstructorUsedError;
  bool get isRecording => throw _privateConstructorUsedError;
  bool get isProcessing => throw _privateConstructorUsedError;
  bool get isPlaying => throw _privateConstructorUsedError;
  String get currentTranscribingText => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Optional scenario context loaded before a roleplay session
  String? get activeScenarioId => throw _privateConstructorUsedError;
  String? get activeScenarioName => throw _privateConstructorUsedError;

  /// AI-evaluated goal results: key = goal.id, value = achieved
  Map<String, bool> get goalEvaluationResults =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ConversationStateCopyWith<ConversationState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConversationStateCopyWith<$Res> {
  factory $ConversationStateCopyWith(
          ConversationState value, $Res Function(ConversationState) then) =
      _$ConversationStateCopyWithImpl<$Res, ConversationState>;
  @useResult
  $Res call(
      {List<ConversationMessage> messages,
      bool isRecording,
      bool isProcessing,
      bool isPlaying,
      String currentTranscribingText,
      String? errorMessage,
      String? activeScenarioId,
      String? activeScenarioName,
      Map<String, bool> goalEvaluationResults});
}

/// @nodoc
class _$ConversationStateCopyWithImpl<$Res, $Val extends ConversationState>
    implements $ConversationStateCopyWith<$Res> {
  _$ConversationStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? messages = null,
    Object? isRecording = null,
    Object? isProcessing = null,
    Object? isPlaying = null,
    Object? currentTranscribingText = null,
    Object? errorMessage = freezed,
    Object? activeScenarioId = freezed,
    Object? activeScenarioName = freezed,
    Object? goalEvaluationResults = null,
  }) {
    return _then(_value.copyWith(
      messages: null == messages
          ? _value.messages
          : messages // ignore: cast_nullable_to_non_nullable
              as List<ConversationMessage>,
      isRecording: null == isRecording
          ? _value.isRecording
          : isRecording // ignore: cast_nullable_to_non_nullable
              as bool,
      isProcessing: null == isProcessing
          ? _value.isProcessing
          : isProcessing // ignore: cast_nullable_to_non_nullable
              as bool,
      isPlaying: null == isPlaying
          ? _value.isPlaying
          : isPlaying // ignore: cast_nullable_to_non_nullable
              as bool,
      currentTranscribingText: null == currentTranscribingText
          ? _value.currentTranscribingText
          : currentTranscribingText // ignore: cast_nullable_to_non_nullable
              as String,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      activeScenarioId: freezed == activeScenarioId
          ? _value.activeScenarioId
          : activeScenarioId // ignore: cast_nullable_to_non_nullable
              as String?,
      activeScenarioName: freezed == activeScenarioName
          ? _value.activeScenarioName
          : activeScenarioName // ignore: cast_nullable_to_non_nullable
              as String?,
      goalEvaluationResults: null == goalEvaluationResults
          ? _value.goalEvaluationResults
          : goalEvaluationResults // ignore: cast_nullable_to_non_nullable
              as Map<String, bool>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ConversationStateImplCopyWith<$Res>
    implements $ConversationStateCopyWith<$Res> {
  factory _$$ConversationStateImplCopyWith(_$ConversationStateImpl value,
          $Res Function(_$ConversationStateImpl) then) =
      __$$ConversationStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<ConversationMessage> messages,
      bool isRecording,
      bool isProcessing,
      bool isPlaying,
      String currentTranscribingText,
      String? errorMessage,
      String? activeScenarioId,
      String? activeScenarioName,
      Map<String, bool> goalEvaluationResults});
}

/// @nodoc
class __$$ConversationStateImplCopyWithImpl<$Res>
    extends _$ConversationStateCopyWithImpl<$Res, _$ConversationStateImpl>
    implements _$$ConversationStateImplCopyWith<$Res> {
  __$$ConversationStateImplCopyWithImpl(_$ConversationStateImpl _value,
      $Res Function(_$ConversationStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? messages = null,
    Object? isRecording = null,
    Object? isProcessing = null,
    Object? isPlaying = null,
    Object? currentTranscribingText = null,
    Object? errorMessage = freezed,
    Object? activeScenarioId = freezed,
    Object? activeScenarioName = freezed,
    Object? goalEvaluationResults = null,
  }) {
    return _then(_$ConversationStateImpl(
      messages: null == messages
          ? _value._messages
          : messages // ignore: cast_nullable_to_non_nullable
              as List<ConversationMessage>,
      isRecording: null == isRecording
          ? _value.isRecording
          : isRecording // ignore: cast_nullable_to_non_nullable
              as bool,
      isProcessing: null == isProcessing
          ? _value.isProcessing
          : isProcessing // ignore: cast_nullable_to_non_nullable
              as bool,
      isPlaying: null == isPlaying
          ? _value.isPlaying
          : isPlaying // ignore: cast_nullable_to_non_nullable
              as bool,
      currentTranscribingText: null == currentTranscribingText
          ? _value.currentTranscribingText
          : currentTranscribingText // ignore: cast_nullable_to_non_nullable
              as String,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      activeScenarioId: freezed == activeScenarioId
          ? _value.activeScenarioId
          : activeScenarioId // ignore: cast_nullable_to_non_nullable
              as String?,
      activeScenarioName: freezed == activeScenarioName
          ? _value.activeScenarioName
          : activeScenarioName // ignore: cast_nullable_to_non_nullable
              as String?,
      goalEvaluationResults: null == goalEvaluationResults
          ? _value._goalEvaluationResults
          : goalEvaluationResults // ignore: cast_nullable_to_non_nullable
              as Map<String, bool>,
    ));
  }
}

/// @nodoc

class _$ConversationStateImpl implements _ConversationState {
  const _$ConversationStateImpl(
      {required final List<ConversationMessage> messages,
      this.isRecording = false,
      this.isProcessing = false,
      this.isPlaying = false,
      this.currentTranscribingText = '',
      this.errorMessage,
      this.activeScenarioId,
      this.activeScenarioName,
      final Map<String, bool> goalEvaluationResults = const {}})
      : _messages = messages,
        _goalEvaluationResults = goalEvaluationResults;

  final List<ConversationMessage> _messages;
  @override
  List<ConversationMessage> get messages {
    if (_messages is EqualUnmodifiableListView) return _messages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_messages);
  }

  @override
  @JsonKey()
  final bool isRecording;
  @override
  @JsonKey()
  final bool isProcessing;
  @override
  @JsonKey()
  final bool isPlaying;
  @override
  @JsonKey()
  final String currentTranscribingText;
  @override
  final String? errorMessage;

  /// Optional scenario context loaded before a roleplay session
  @override
  final String? activeScenarioId;
  @override
  final String? activeScenarioName;

  /// AI-evaluated goal results: key = goal.id, value = achieved
  final Map<String, bool> _goalEvaluationResults;

  /// AI-evaluated goal results: key = goal.id, value = achieved
  @override
  @JsonKey()
  Map<String, bool> get goalEvaluationResults {
    if (_goalEvaluationResults is EqualUnmodifiableMapView)
      return _goalEvaluationResults;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_goalEvaluationResults);
  }

  @override
  String toString() {
    return 'ConversationState(messages: $messages, isRecording: $isRecording, isProcessing: $isProcessing, isPlaying: $isPlaying, currentTranscribingText: $currentTranscribingText, errorMessage: $errorMessage, activeScenarioId: $activeScenarioId, activeScenarioName: $activeScenarioName, goalEvaluationResults: $goalEvaluationResults)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConversationStateImpl &&
            const DeepCollectionEquality().equals(other._messages, _messages) &&
            (identical(other.isRecording, isRecording) ||
                other.isRecording == isRecording) &&
            (identical(other.isProcessing, isProcessing) ||
                other.isProcessing == isProcessing) &&
            (identical(other.isPlaying, isPlaying) ||
                other.isPlaying == isPlaying) &&
            (identical(
                    other.currentTranscribingText, currentTranscribingText) ||
                other.currentTranscribingText == currentTranscribingText) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.activeScenarioId, activeScenarioId) ||
                other.activeScenarioId == activeScenarioId) &&
            (identical(other.activeScenarioName, activeScenarioName) ||
                other.activeScenarioName == activeScenarioName) &&
            const DeepCollectionEquality()
                .equals(other._goalEvaluationResults, _goalEvaluationResults));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_messages),
      isRecording,
      isProcessing,
      isPlaying,
      currentTranscribingText,
      errorMessage,
      activeScenarioId,
      activeScenarioName,
      const DeepCollectionEquality().hash(_goalEvaluationResults));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ConversationStateImplCopyWith<_$ConversationStateImpl> get copyWith =>
      __$$ConversationStateImplCopyWithImpl<_$ConversationStateImpl>(
          this, _$identity);
}

abstract class _ConversationState implements ConversationState {
  const factory _ConversationState(
      {required final List<ConversationMessage> messages,
      final bool isRecording,
      final bool isProcessing,
      final bool isPlaying,
      final String currentTranscribingText,
      final String? errorMessage,
      final String? activeScenarioId,
      final String? activeScenarioName,
      final Map<String, bool> goalEvaluationResults}) = _$ConversationStateImpl;

  @override
  List<ConversationMessage> get messages;
  @override
  bool get isRecording;
  @override
  bool get isProcessing;
  @override
  bool get isPlaying;
  @override
  String get currentTranscribingText;
  @override
  String? get errorMessage;
  @override

  /// Optional scenario context loaded before a roleplay session
  String? get activeScenarioId;
  @override
  String? get activeScenarioName;
  @override

  /// AI-evaluated goal results: key = goal.id, value = achieved
  Map<String, bool> get goalEvaluationResults;
  @override
  @JsonKey(ignore: true)
  _$$ConversationStateImplCopyWith<_$ConversationStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
