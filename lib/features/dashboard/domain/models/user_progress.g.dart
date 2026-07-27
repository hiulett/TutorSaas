// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_progress.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserProgressImpl _$$UserProgressImplFromJson(Map<String, dynamic> json) =>
    _$UserProgressImpl(
      userId: json['userId'] as String,
      xp: (json['xp'] as num?)?.toInt() ?? 0,
      streak: (json['streak'] as num?)?.toInt() ?? 0,
      levelCode: json['levelCode'] as String? ?? 'A1',
      levelName: json['levelName'] as String? ?? 'Principiante',
      targetLanguageCode: json['targetLanguageCode'] as String? ?? 'en',
      targetLanguageName: json['targetLanguageName'] as String? ?? 'Inglés',
      targetLanguageEmoji: json['targetLanguageEmoji'] as String? ?? '🇺🇸',
      totalConversations: (json['totalConversations'] as num?)?.toInt() ?? 0,
      totalMinutesPracticed:
          (json['totalMinutesPracticed'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$UserProgressImplToJson(_$UserProgressImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'xp': instance.xp,
      'streak': instance.streak,
      'levelCode': instance.levelCode,
      'levelName': instance.levelName,
      'targetLanguageCode': instance.targetLanguageCode,
      'targetLanguageName': instance.targetLanguageName,
      'targetLanguageEmoji': instance.targetLanguageEmoji,
      'totalConversations': instance.totalConversations,
      'totalMinutesPracticed': instance.totalMinutesPracticed,
    };
