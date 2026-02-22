class TermPolicy {
  const TermPolicy({
    required this.code,
    required this.title,
    required this.content,
    required this.version,
    required this.isRequired,
    required this.sortOrder,
  });

  final String code;
  final String title;
  final String content;
  final int version;
  final bool isRequired;
  final int sortOrder;
}
