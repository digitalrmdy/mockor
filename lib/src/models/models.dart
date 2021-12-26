///container for [type] that needs to be generated
class MockDef {
  final String type;
  final MockDefNaming mockDefNaming;
  final bool generateExtension;

  const MockDef(
      {required this.type,
      required this.mockDefNaming,
      required this.generateExtension});

  String _buildTarget(String prefix) {
    var s = "";
    if (mockDefNaming == MockDefNaming.INTERNAL) {
      s += "_\$";
    }
    s += "$prefix$type";
    return s;
  }

  String get targetMockClassName => _buildTarget(_prefixMock);
  String get targetMockClassNameRelaxed => '${targetMockClassName}Relaxed';

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

  final bool generateMockitoAnnotation;

  MockitoConfig(
      {required this.mockDefs,
      required this.mockerName,
      required this.generateMockitoAnnotation});

  List<MockDef> get mockDefsToGenerate => mockDefs
      .where((element) => element.mockDefNaming == MockDefNaming.INTERNAL)
      .toList();
  List<MockDef> get mockDefsMockitoGenerated => mockDefs
      .where((element) => element.mockDefNaming == MockDefNaming.MOCKITO)
      .toList();
}

enum MockDefNaming { MOCKITO, INTERNAL }

const _prefixMock = "Mock";
