class AppVersion {
  final String version;
  final String date;
  final List<String> content;

  AppVersion({required this.version, required this.date, required this.content});

  factory AppVersion.fromMap(Map<dynamic, dynamic> map) {
    return AppVersion(
      version: map['version'] as String,
      date: map['date'] as String,
      content: List<String>.from(map['content'] as List),
    );
  }
}
