///container for [type] that needs to be generated
class MockDef {
  final String type;
  final MockDefSource mockDefSource;

  const MockDef({required this.type, required this.mockDefSource});

  ///the name of the class based on the [type] which mockito generates
  String get _targetClassNameMockito => "Mock$type";

  ///the name of the class based on the [type] which we generate if needed
  String get _targetClassNameInternal => "_\$Mock$type";

  String get targetClassName => mockDefSource == MockDefSource.INTERNAL
      ? _targetClassNameInternal
      : _targetClassNameMockito;

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

  final bool generateMockExtensions;

  MockitoConfig({
    required this.mockDefs,
    required this.mockerName,
    required this.generateMockExtensions,
  });

  List<MockDef> get mockDefsToGenerate => mockDefs
      .where((element) => element.mockDefSource == MockDefSource.INTERNAL)
      .toList();
  List<MockDef> get mockDefsMockitoGenerated => mockDefs
      .where((element) => element.mockDefSource == MockDefSource.MOCKITO)
      .toList();
}

enum MockDefSource { MOCKITO, INTERNAL }
