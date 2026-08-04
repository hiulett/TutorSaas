// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'placement_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PlacementResultImpl _$$PlacementResultImplFromJson(
        Map<String, dynamic> json) =>
    _$PlacementResultImpl(
      userId: json['userId'] as String,
      cefrLevel: json['cefrLevel'] as String,
      levelName: json['levelName'] as String,
      levelDescription: json['levelDescription'] as String,
      learningGoal: json['learningGoal'] as String,
      mainDifficulty: json['mainDifficulty'] as String,
      quizScore: (json['quizScore'] as num).toInt(),
      studyPlan:
          (json['studyPlan'] as List<dynamic>).map((e) => e as String).toList(),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      gameRank: json['gameRank'] as String?,
      scores: (json['scores'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ),
      strengths: (json['strengths'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      weaknesses: (json['weaknesses'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      explanation: json['explanation'] as String?,
      recommendedFocus: json['recommendedFocus'] as String?,
    );

Map<String, dynamic> _$$PlacementResultImplToJson(
        _$PlacementResultImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'cefrLevel': instance.cefrLevel,
      'levelName': instance.levelName,
      'levelDescription': instance.levelDescription,
      'learningGoal': instance.learningGoal,
      'mainDifficulty': instance.mainDifficulty,
      'quizScore': instance.quizScore,
      'studyPlan': instance.studyPlan,
      'completedAt': instance.completedAt?.toIso8601String(),
      'gameRank': instance.gameRank,
      'scores': instance.scores,
      'strengths': instance.strengths,
      'weaknesses': instance.weaknesses,
      'explanation': instance.explanation,
      'recommendedFocus': instance.recommendedFocus,
    };
