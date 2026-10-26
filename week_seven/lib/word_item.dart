import 'dart:convert';

class WordItem {
  final int id; // 고유 ID
  final String word; // 단어명 (최대 50자 제한)[cite: 18]
  final String meaning; // 정의/뜻 (글자 수 제한 없음)[cite: 18]
  final String usage; // 강의 내 쓰임 (글자 수 제한 없음)[cite: 18]
  final String whyNeeded; // 필요성 (글자 수 제한 없음)[cite: 18]
  final bool isDone; // 복습 완료 여부

  WordItem({
    required this.id,
    required this.word,
    this.meaning = '',
    this.usage = '',
    this.whyNeeded = '',
    this.isDone = false,
  });

  // 복사 및 수정용 copyWith
  WordItem copyWith({
    int? id,
    String? word,
    String? meaning,
    String? usage,
    String? whyNeeded,
    bool? isDone,
  }) {
    return WordItem(
      id: id ?? this.id,
      word: word ?? this.word,
      meaning: meaning ?? this.meaning,
      usage: usage ?? this.usage,
      whyNeeded: whyNeeded ?? this.whyNeeded,
      isDone: isDone ?? this.isDone,
    );
  }

  // JSON -> WordItem
  factory WordItem.fromJson(Map<String, dynamic> json) {
    return WordItem(
      id: json['id'] as int,
      word: json['word'] as String,
      meaning: json['meaning'] as String? ?? '',
      usage: json['usage'] as String? ?? '',
      whyNeeded: json['whyNeeded'] as String? ?? '',
      isDone: json['isDone'] as bool? ?? false,
    );
  }

  // WordItem -> JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'word': word,
      'meaning': meaning,
      'usage': usage,
      'whyNeeded': whyNeeded,
      'isDone': isDone,
    };
  }
}
