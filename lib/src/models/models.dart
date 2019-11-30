class MockDef {
  final String type;
  final String variableName;

  const MockDef({this.type, this.variableName});

  String get targetClassName => "_Mock$type";

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

  MockitoConfig({this.mockDefs, this.mockerName});
}
