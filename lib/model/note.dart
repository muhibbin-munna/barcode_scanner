//Model of the database

final String tableNotes = 'notes';

class NoteFields {
  static final List<String> values = [
    // all fields in database
    id, details, time, isSent
  ];

  static final String id = '_id';
  static final String details = 'description';
  static final String time = 'time';
  static final String isSent = 'isSent';
}

class Note {
  final int? id;
  final String details;
  final DateTime createdTime;
  final bool isSent;

  const Note({
    this.id,
    required this.details,
    required this.createdTime,
    required this.isSent,
  });

  Note copy({
    int? id,
    String? details,
    DateTime? createdTime,
    bool? isSent,
  }) =>
      Note(
        id: id ?? this.id,
        details: details ?? this.details,
        createdTime: createdTime ?? this.createdTime,
        isSent: isSent ?? this.isSent,
      );

  static Note fromJson(Map<String, Object?> json) => Note(
        id: json[NoteFields.id] as int?,
        details: json[NoteFields.details] as String,
        createdTime: DateTime.parse(json[NoteFields.time] as String),
        isSent: json[NoteFields.isSent] == 1,
      );

  Map<String, Object?> toJson() => {
        NoteFields.id: id,
        NoteFields.details: details,
        NoteFields.time: createdTime.toIso8601String(),
        NoteFields.isSent: isSent ? 1 : 0,
      };
}
