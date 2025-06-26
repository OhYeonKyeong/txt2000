class TextModel {
  final int? seq;
  final String title;
  final String content;
  final String createdAt;
  final String modifiedAt;

  TextModel({
    this.seq,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.modifiedAt,
  });

  factory TextModel.fromMap(Map<String, dynamic> map) => TextModel(
    seq: map['seq'],
    title: map['title'],
    content: map['content'],
    createdAt: map['createdAt'],
    modifiedAt: map['modifiedAt'],
  );

  Map<String, dynamic> toMap() {
    // final map = { 으로 선언하면 seq 타입 캐스트 오류가 난다.
    // 타입을 명시해줘야 한다.
    final Map<String, dynamic> map = {
      'title': title,
      'content': content,
      'createdAt': createdAt,
      'modifiedAt': modifiedAt,
    };

    if (seq != null) {
      map['seq'] = seq;
    }

    return map;
  }

}
