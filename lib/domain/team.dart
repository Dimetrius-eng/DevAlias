class Team {
  const Team({required this.name});

  final String name;

  bool get hasName => name.isNotEmpty;
}
