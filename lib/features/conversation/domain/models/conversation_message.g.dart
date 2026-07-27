// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ConversationMessageImpl _$$ConversationMessageImplFromJson(
        Map<String, dynamic> json) =>
    _$ConversationMessageImpl(
      sender: json['sender'] as String,
      text: json['text'] as String,
      originalText: json['originalText'] as String?,
      correctionExplanation: json['correctionExplanation'] as String?,
      audioUrl: json['audioUrl'] as String?,
    );

Map<String, dynamic> _$$ConversationMessageImplToJson(
        _$ConversationMessageImpl instance) =>
    <String, dynamic>{
      'sender': instance.sender,
      'text': instance.text,
      'originalText': instance.originalText,
      'correctionExplanation': instance.correctionExplanation,
      'audioUrl': instance.audioUrl,
    };
