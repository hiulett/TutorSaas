class OracleQuestion {
  final String id;
  final String questionText;
  final int orderIndex;
  final String emotion;

  const OracleQuestion({
    required this.id,
    required this.questionText,
    this.orderIndex = 0,
    this.emotion = 'calm',
  });

  factory OracleQuestion.fromMap(Map<String, dynamic> map) => OracleQuestion(
    id: map['id'] as String? ?? '',
    questionText: map['question_text'] as String? ?? '',
    orderIndex: (map['order_index'] as num?)?.toInt() ?? 0,
    emotion: map['emotion'] as String? ?? 'calm',
  );
}
