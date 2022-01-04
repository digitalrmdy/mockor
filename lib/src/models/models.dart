import 'package:analyzer/dart/element/type.dart';

///container for [type] that needs to be generated
class MockDef {
  final ResolvedType type;
  final MockDefNaming mockDefNaming;
  final bool generateExtension;
  final String? uri;

  final MocktailRelaxedVoidConfig? mocktailRelaxedVoidConfig;

  const MockDef(
      {required this.type,
      required this.mockDefNaming,
      required this.generateExtension,
      this.mocktailRelaxedVoidConfig,
      this.uri});

  bool get isRelaxedVoidSupported => mocktailRelaxedVoidConfig != null;

  String _buildTarget(String prefix) => _buildTargetImpl(
      prefix: prefix, mockDefNaming: mockDefNaming, type: type.nameUnique);

  String get targetMockClassName => _buildTarget(_prefixMock);

  String? get import => uri;

  String get relaxedVoidExceptionBuilderMethodName =>
      "_\$${type.nameUnique}ExceptionBuilder";

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

  bool get addRelaxedVoidParam =>
      mockDefs.any((element) => element.isRelaxedVoidSupported);

  bool get hasMockitoGeneratedTypes => mockDefsMockitoGenerated.isNotEmpty;
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

enum VoidReturnType { Void, FutureVoid, FutureOrVoid }

class MocktailRelaxedVoidConfig {
  final List<String> futureVoidMethodNames;
  final List<String> voidMethodNames;

  MocktailRelaxedVoidConfig(
      {required this.futureVoidMethodNames, required this.voidMethodNames});
}
