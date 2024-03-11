class Todo {
  final int id;
  final String title;
  final String createdAt;
  final String? updatedAt;

  Todo(
      {required this.id,
      required this.title,
      required this.createdAt,
      this.updatedAt});

  factory Todo.fromSqfliteDatabase(Map<String, dynamic> map) {
    return Todo(
        id: map['id'] as int,
        title: map['title'] as String,
        createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'])
            .toIso8601String(),
        updatedAt: map['updated_at'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(map['updated_at'])
                .toIso8601String());
  }
}
