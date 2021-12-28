import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';

///container for [type] that needs to be generated
class MockDef {
  final ResolvedType type;
  final MockDefNaming mockDefNaming;
  final bool generateExtension;
  final bool returnNullOnMissingStub;

  const MockDef(
      {required this.type,
      required this.mockDefNaming,
      required this.generateExtension,
      required this.returnNullOnMissingStub});

  String _buildTarget(String prefix) => _buildTargetImpl(
      prefix: prefix,
      mockDefNaming: mockDefNaming,
      type: type.displayNameUnique);

  String get targetMockClassName => _buildTarget(_prefixMock);

  bool get isCustomMock => type.prefix != null || returnNullOnMissingStub;

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

  String get registerFallbackValuesName => "registerFallbackValues";

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
  final String displayName;
  final String librarySource;
  final String? prefix;

  ResolvedType({
    required this.displayName,
    required this.librarySource,
    required this.prefix,
  });

  String get displayNameUnique {
    var s = "";
    if (prefix != null) {
      s += "$prefix";
    }
    s += displayName;
    return s;
  }

  String get displayNameWithPrefix {
    var s = "";
    if (prefix != null) {
      s += "$prefix.";
    }
    s += displayName;
    return s;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResolvedType &&
          runtimeType == other.runtimeType &&
          displayName == other.displayName &&
          librarySource == other.librarySource &&
          prefix == other.prefix;

  @override
  int get hashCode =>
      displayName.hashCode ^ librarySource.hashCode ^ prefix.hashCode;

  @override
  String toString() {
    return displayName;
  }
}
