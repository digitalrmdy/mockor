class MockDef {
  final String type;

  const MockDef({required this.type});

  String get targetClassName => "_\$Mock$type";

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MockDef &&
          runtimeType == other.runtimeType &&
          type == other.type;

  @override
  int get hashCode => type.hashCode;
}

class MockitoConfig {
  final mockerName;
  final Set<MockDef> mockDefs;

  MockitoConfig({required this.mockDefs, this.mockerName});
}
