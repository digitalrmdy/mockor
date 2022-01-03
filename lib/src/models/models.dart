import 'package:analyzer/dart/element/type.dart';

///container for [type] that needs to be generated
class MockDef {
  final ResolvedType type;
  final MockDefNaming mockDefNaming;
  final bool generateExtension;
  final bool returnNullOnMissingStub;
  final String? uri;

  const MockDef(
      {required this.type,
      required this.mockDefNaming,
      required this.generateExtension,
      required this.returnNullOnMissingStub,
      this.uri});

  String _buildTarget(String prefix) => _buildTargetImpl(
      prefix: prefix, mockDefNaming: mockDefNaming, type: type.nameUnique);

  String get targetMockClassName => _buildTarget(_prefixMock);

  bool get isCustomMock => type.prefix != null || returnNullOnMissingStub;

  String? get import => uri;

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
class MockorConfig {
  ///name of the mocker method
  final String mockerName;

  ///unique set of types to create mock classes for
  final Set<MockDef> mockDefs;

  final bool generateMockitoAnnotation;

  final Set<MockDef>? mocktailFallbackMockDefs;

  MockorConfig({
    required this.mockDefs,
    required this.mockerName,
    required this.generateMockitoAnnotation,
    required this.mocktailFallbackMockDefs,
  });

  String get registerFallbackValuesName => "_\$registerFallbackValues";

  List<MockDef> get mockDefsToGenerate => mockDefs
      .where((element) => element.mockDefNaming == MockDefNaming.INTERNAL)
      .toList();
  List<MockDef> get mockDefsMockitoGenerated => mockDefs
      .where((element) => element.mockDefNaming == MockDefNaming.MOCKITO)
      .toList();
}

enum MockDefNaming { MOCKITO, INTERNAL }

const _prefixMock = "Mock";

String _buildTargetImpl(
    {required String prefix,
    required MockDefNaming mockDefNaming,
    required String type}) {
  var s = "";
  if (mockDefNaming == MockDefNaming.INTERNAL) {
    s += "_\$";
  }
  s += "$prefix$type";
  return s;
}

class ResolvedType {
  final String name;
  final String librarySource;
  final String? prefix;
  final InterfaceType dartType;

  ResolvedType({
    required this.name,
    required this.librarySource,
    required this.prefix,
    required this.dartType,
  });

  ResolvedType copyWith({required String? prefix}) {
    return ResolvedType(
        name: name,
        librarySource: librarySource,
        prefix: prefix,
        dartType: dartType);
  }

  String get nameUnique {
    var s = "";
    if (prefix != null) {
      s += "$prefix";
    }
    s += name;
    return s;
  }

  String get nameWithPrefix {
    var s = "";
    if (prefix != null) {
      s += "$prefix.";
    }
    s += name;
    return s;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResolvedType &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          librarySource == other.librarySource &&
          prefix == other.prefix;

  @override
  int get hashCode => name.hashCode ^ librarySource.hashCode ^ prefix.hashCode;

  @override
  String toString() {
    return name;
  }
}

class MocktailFallbackValuesConfig {
  final Set<MockDef> mocktailFallbackMockDefs;

  MocktailFallbackValuesConfig({required this.mocktailFallbackMockDefs});

  String get registerFallbackValuesName => "registerFallbackValuesAutoDetected";
}
