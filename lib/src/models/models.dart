///container for [type] that needs to be generated
class MockDef {
  final String type;

  const MockDef({this.type});

  ///the name of the class based on the [type]
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

///config for the mocker method
class MockitoConfig {
  ///name of the mocker method
  final String mockerName;

  ///unique set of types to create mock classes for
  final Set<MockDef> mockDefs;

  MockitoConfig({this.mockDefs, this.mockerName});
}
