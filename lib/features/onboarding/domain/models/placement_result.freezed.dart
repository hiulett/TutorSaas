// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'placement_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PlacementResult _$PlacementResultFromJson(Map<String, dynamic> json) {
  return _PlacementResult.fromJson(json);
}

/// @nodoc
mixin _$PlacementResult {
  String get userId => throw _privateConstructorUsedError;

  /// Estimated CEFR level: A1, A2, B1, B2, C1
  String get cefrLevel => throw _privateConstructorUsedError;
  String get levelName => throw _privateConstructorUsedError;

  /// Short description of what the user can do at this level
  String get levelDescription => throw _privateConstructorUsedError;

  /// User's primary learning goal
  String get learningGoal => throw _privateConstructorUsedError;

  /// Main self-reported difficulty
  String get mainDifficulty => throw _privateConstructorUsedError;

  /// Score on the quick comprehension quiz (0–3)
  int get quizScore => throw _privateConstructorUsedError;

  /// Study plan bullet points generated for this level
  List<String> get studyPlan => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;

  /// Game rank assigned by the AI placement evaluator (E, D, C, B, A, S, SS, SSS)
  String? get gameRank => throw _privateConstructorUsedError;

  /// Dimension scores (0-100) from the AI evaluator
  Map<String, int>? get scores => throw _privateConstructorUsedError;

  /// Strengths detected by the AI evaluator
  List<String>? get strengths => throw _privateConstructorUsedError;

  /// Weaknesses detected by the AI evaluator
  List<String>? get weaknesses => throw _privateConstructorUsedError;

  /// AI explanation of the assigned level
  String? get explanation => throw _privateConstructorUsedError;

  /// Recommended focus area from the AI evaluator
  String? get recommendedFocus => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PlacementResultCopyWith<PlacementResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlacementResultCopyWith<$Res> {
  factory $PlacementResultCopyWith(
          PlacementResult value, $Res Function(PlacementResult) then) =
      _$PlacementResultCopyWithImpl<$Res, PlacementResult>;
  @useResult
  $Res call(
      {String userId,
      String cefrLevel,
      String levelName,
      String levelDescription,
      String learningGoal,
      String mainDifficulty,
      int quizScore,
      List<String> studyPlan,
      DateTime? completedAt,
      String? gameRank,
      Map<String, int>? scores,
      List<String>? strengths,
      List<String>? weaknesses,
      String? explanation,
      String? recommendedFocus});
}

/// @nodoc
class _$PlacementResultCopyWithImpl<$Res, $Val extends PlacementResult>
    implements $PlacementResultCopyWith<$Res> {
  _$PlacementResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? cefrLevel = null,
    Object? levelName = null,
    Object? levelDescription = null,
    Object? learningGoal = null,
    Object? mainDifficulty = null,
    Object? quizScore = null,
    Object? studyPlan = null,
    Object? completedAt = freezed,
    Object? gameRank = freezed,
    Object? scores = freezed,
    Object? strengths = freezed,
    Object? weaknesses = freezed,
    Object? explanation = freezed,
    Object? recommendedFocus = freezed,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      cefrLevel: null == cefrLevel
          ? _value.cefrLevel
          : cefrLevel // ignore: cast_nullable_to_non_nullable
              as String,
      levelName: null == levelName
          ? _value.levelName
          : levelName // ignore: cast_nullable_to_non_nullable
              as String,
      levelDescription: null == levelDescription
          ? _value.levelDescription
          : levelDescription // ignore: cast_nullable_to_non_nullable
              as String,
      learningGoal: null == learningGoal
          ? _value.learningGoal
          : learningGoal // ignore: cast_nullable_to_non_nullable
              as String,
      mainDifficulty: null == mainDifficulty
          ? _value.mainDifficulty
          : mainDifficulty // ignore: cast_nullable_to_non_nullable
              as String,
      quizScore: null == quizScore
          ? _value.quizScore
          : quizScore // ignore: cast_nullable_to_non_nullable
              as int,
      studyPlan: null == studyPlan
          ? _value.studyPlan
          : studyPlan // ignore: cast_nullable_to_non_nullable
              as List<String>,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      gameRank: freezed == gameRank
          ? _value.gameRank
          : gameRank // ignore: cast_nullable_to_non_nullable
              as String?,
      scores: freezed == scores
          ? _value.scores
          : scores // ignore: cast_nullable_to_non_nullable
              as Map<String, int>?,
      strengths: freezed == strengths
          ? _value.strengths
          : strengths // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      weaknesses: freezed == weaknesses
          ? _value.weaknesses
          : weaknesses // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      explanation: freezed == explanation
          ? _value.explanation
          : explanation // ignore: cast_nullable_to_non_nullable
              as String?,
      recommendedFocus: freezed == recommendedFocus
          ? _value.recommendedFocus
          : recommendedFocus // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PlacementResultImplCopyWith<$Res>
    implements $PlacementResultCopyWith<$Res> {
  factory _$$PlacementResultImplCopyWith(_$PlacementResultImpl value,
          $Res Function(_$PlacementResultImpl) then) =
      __$$PlacementResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String userId,
      String cefrLevel,
      String levelName,
      String levelDescription,
      String learningGoal,
      String mainDifficulty,
      int quizScore,
      List<String> studyPlan,
      DateTime? completedAt,
      String? gameRank,
      Map<String, int>? scores,
      List<String>? strengths,
      List<String>? weaknesses,
      String? explanation,
      String? recommendedFocus});
}

/// @nodoc
class __$$PlacementResultImplCopyWithImpl<$Res>
    extends _$PlacementResultCopyWithImpl<$Res, _$PlacementResultImpl>
    implements _$$PlacementResultImplCopyWith<$Res> {
  __$$PlacementResultImplCopyWithImpl(
      _$PlacementResultImpl _value, $Res Function(_$PlacementResultImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? cefrLevel = null,
    Object? levelName = null,
    Object? levelDescription = null,
    Object? learningGoal = null,
    Object? mainDifficulty = null,
    Object? quizScore = null,
    Object? studyPlan = null,
    Object? completedAt = freezed,
    Object? gameRank = freezed,
    Object? scores = freezed,
    Object? strengths = freezed,
    Object? weaknesses = freezed,
    Object? explanation = freezed,
    Object? recommendedFocus = freezed,
  }) {
    return _then(_$PlacementResultImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      cefrLevel: null == cefrLevel
          ? _value.cefrLevel
          : cefrLevel // ignore: cast_nullable_to_non_nullable
              as String,
      levelName: null == levelName
          ? _value.levelName
          : levelName // ignore: cast_nullable_to_non_nullable
              as String,
      levelDescription: null == levelDescription
          ? _value.levelDescription
          : levelDescription // ignore: cast_nullable_to_non_nullable
              as String,
      learningGoal: null == learningGoal
          ? _value.learningGoal
          : learningGoal // ignore: cast_nullable_to_non_nullable
              as String,
      mainDifficulty: null == mainDifficulty
          ? _value.mainDifficulty
          : mainDifficulty // ignore: cast_nullable_to_non_nullable
              as String,
      quizScore: null == quizScore
          ? _value.quizScore
          : quizScore // ignore: cast_nullable_to_non_nullable
              as int,
      studyPlan: null == studyPlan
          ? _value._studyPlan
          : studyPlan // ignore: cast_nullable_to_non_nullable
              as List<String>,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      gameRank: freezed == gameRank
          ? _value.gameRank
          : gameRank // ignore: cast_nullable_to_non_nullable
              as String?,
      scores: freezed == scores
          ? _value._scores
          : scores // ignore: cast_nullable_to_non_nullable
              as Map<String, int>?,
      strengths: freezed == strengths
          ? _value._strengths
          : strengths // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      weaknesses: freezed == weaknesses
          ? _value._weaknesses
          : weaknesses // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      explanation: freezed == explanation
          ? _value.explanation
          : explanation // ignore: cast_nullable_to_non_nullable
              as String?,
      recommendedFocus: freezed == recommendedFocus
          ? _value.recommendedFocus
          : recommendedFocus // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlacementResultImpl implements _PlacementResult {
  const _$PlacementResultImpl(
      {required this.userId,
      required this.cefrLevel,
      required this.levelName,
      required this.levelDescription,
      required this.learningGoal,
      required this.mainDifficulty,
      required this.quizScore,
      required final List<String> studyPlan,
      this.completedAt,
      this.gameRank,
      final Map<String, int>? scores,
      final List<String>? strengths,
      final List<String>? weaknesses,
      this.explanation,
      this.recommendedFocus})
      : _studyPlan = studyPlan,
        _scores = scores,
        _strengths = strengths,
        _weaknesses = weaknesses;

  factory _$PlacementResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlacementResultImplFromJson(json);

  @override
  final String userId;

  /// Estimated CEFR level: A1, A2, B1, B2, C1
  @override
  final String cefrLevel;
  @override
  final String levelName;

  /// Short description of what the user can do at this level
  @override
  final String levelDescription;

  /// User's primary learning goal
  @override
  final String learningGoal;

  /// Main self-reported difficulty
  @override
  final String mainDifficulty;

  /// Score on the quick comprehension quiz (0–3)
  @override
  final int quizScore;

  /// Study plan bullet points generated for this level
  final List<String> _studyPlan;

  /// Study plan bullet points generated for this level
  @override
  List<String> get studyPlan {
    if (_studyPlan is EqualUnmodifiableListView) return _studyPlan;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_studyPlan);
  }

  @override
  final DateTime? completedAt;

  /// Game rank assigned by the AI placement evaluator (E, D, C, B, A, S, SS, SSS)
  @override
  final String? gameRank;

  /// Dimension scores (0-100) from the AI evaluator
  final Map<String, int>? _scores;

  /// Dimension scores (0-100) from the AI evaluator
  @override
  Map<String, int>? get scores {
    final value = _scores;
    if (value == null) return null;
    if (_scores is EqualUnmodifiableMapView) return _scores;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  /// Strengths detected by the AI evaluator
  final List<String>? _strengths;

  /// Strengths detected by the AI evaluator
  @override
  List<String>? get strengths {
    final value = _strengths;
    if (value == null) return null;
    if (_strengths is EqualUnmodifiableListView) return _strengths;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  /// Weaknesses detected by the AI evaluator
  final List<String>? _weaknesses;

  /// Weaknesses detected by the AI evaluator
  @override
  List<String>? get weaknesses {
    final value = _weaknesses;
    if (value == null) return null;
    if (_weaknesses is EqualUnmodifiableListView) return _weaknesses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  /// AI explanation of the assigned level
  @override
  final String? explanation;

  /// Recommended focus area from the AI evaluator
  @override
  final String? recommendedFocus;

  @override
  String toString() {
    return 'PlacementResult(userId: $userId, cefrLevel: $cefrLevel, levelName: $levelName, levelDescription: $levelDescription, learningGoal: $learningGoal, mainDifficulty: $mainDifficulty, quizScore: $quizScore, studyPlan: $studyPlan, completedAt: $completedAt, gameRank: $gameRank, scores: $scores, strengths: $strengths, weaknesses: $weaknesses, explanation: $explanation, recommendedFocus: $recommendedFocus)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlacementResultImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.cefrLevel, cefrLevel) ||
                other.cefrLevel == cefrLevel) &&
            (identical(other.levelName, levelName) ||
                other.levelName == levelName) &&
            (identical(other.levelDescription, levelDescription) ||
                other.levelDescription == levelDescription) &&
            (identical(other.learningGoal, learningGoal) ||
                other.learningGoal == learningGoal) &&
            (identical(other.mainDifficulty, mainDifficulty) ||
                other.mainDifficulty == mainDifficulty) &&
            (identical(other.quizScore, quizScore) ||
                other.quizScore == quizScore) &&
            const DeepCollectionEquality()
                .equals(other._studyPlan, _studyPlan) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.gameRank, gameRank) ||
                other.gameRank == gameRank) &&
            const DeepCollectionEquality().equals(other._scores, _scores) &&
            const DeepCollectionEquality()
                .equals(other._strengths, _strengths) &&
            const DeepCollectionEquality()
                .equals(other._weaknesses, _weaknesses) &&
            (identical(other.explanation, explanation) ||
                other.explanation == explanation) &&
            (identical(other.recommendedFocus, recommendedFocus) ||
                other.recommendedFocus == recommendedFocus));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      userId,
      cefrLevel,
      levelName,
      levelDescription,
      learningGoal,
      mainDifficulty,
      quizScore,
      const DeepCollectionEquality().hash(_studyPlan),
      completedAt,
      gameRank,
      const DeepCollectionEquality().hash(_scores),
      const DeepCollectionEquality().hash(_strengths),
      const DeepCollectionEquality().hash(_weaknesses),
      explanation,
      recommendedFocus);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PlacementResultImplCopyWith<_$PlacementResultImpl> get copyWith =>
      __$$PlacementResultImplCopyWithImpl<_$PlacementResultImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlacementResultImplToJson(
      this,
    );
  }
}

abstract class _PlacementResult implements PlacementResult {
  const factory _PlacementResult(
      {required final String userId,
      required final String cefrLevel,
      required final String levelName,
      required final String levelDescription,
      required final String learningGoal,
      required final String mainDifficulty,
      required final int quizScore,
      required final List<String> studyPlan,
      final DateTime? completedAt,
      final String? gameRank,
      final Map<String, int>? scores,
      final List<String>? strengths,
      final List<String>? weaknesses,
      final String? explanation,
      final String? recommendedFocus}) = _$PlacementResultImpl;

  factory _PlacementResult.fromJson(Map<String, dynamic> json) =
      _$PlacementResultImpl.fromJson;

  @override
  String get userId;
  @override

  /// Estimated CEFR level: A1, A2, B1, B2, C1
  String get cefrLevel;
  @override
  String get levelName;
  @override

  /// Short description of what the user can do at this level
  String get levelDescription;
  @override

  /// User's primary learning goal
  String get learningGoal;
  @override

  /// Main self-reported difficulty
  String get mainDifficulty;
  @override

  /// Score on the quick comprehension quiz (0–3)
  int get quizScore;
  @override

  /// Study plan bullet points generated for this level
  List<String> get studyPlan;
  @override
  DateTime? get completedAt;
  @override

  /// Game rank assigned by the AI placement evaluator (E, D, C, B, A, S, SS, SSS)
  String? get gameRank;
  @override

  /// Dimension scores (0-100) from the AI evaluator
  Map<String, int>? get scores;
  @override

  /// Strengths detected by the AI evaluator
  List<String>? get strengths;
  @override

  /// Weaknesses detected by the AI evaluator
  List<String>? get weaknesses;
  @override

  /// AI explanation of the assigned level
  String? get explanation;
  @override

  /// Recommended focus area from the AI evaluator
  String? get recommendedFocus;
  @override
  @JsonKey(ignore: true)
  _$$PlacementResultImplCopyWith<_$PlacementResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
