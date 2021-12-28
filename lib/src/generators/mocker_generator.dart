import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:mockor/annotations.dart';
import 'package:mockor/src/dartbuilders/mocker_dart_builder.dart';
import 'package:mockor/src/models/models.dart';
import 'package:source_gen/source_gen.dart';

///Generator for the mocker function implementation.
class MockerGenerator extends GeneratorForAnnotation<GenerateMocker> {
  const MockerGenerator();

  ConstantReader readParam(ConstantReader annotation, String parameter) {
    final reader = annotation.read(parameter);
    if (reader.isNull) {
      throw ArgumentError.notNull('$parameter');
    }
    return reader;
  }

  Future<List<ResolvedType>> readDartTypesParam(
      ConstantReader annotation, FunctionElement mockerFunction) {
    final importAliasTable = _ImportAliasTable.fromElement(mockerFunction);

    return readParam(annotation, "types")
        .listValue
        .map((x) => x.toTypeValue())
        .toList()
        .nonNullUniqueDartTypesOrThrow(importAliasTable);
  }

  @override
  Future<String?> generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) async {
    try {
      final generatorConfig =
          await getGeneratorConfig(annotation, element, buildStep);
      if (generatorConfig != null) {
        final mockitoConfig = generatorConfig.createMockerConfig();
        final dartBuilder = MockerDartBuilder();
        return dartBuilder.buildDartFile(mockitoConfig);
      }
    } catch (e, s) {
      throw Exception("$e, $s");
    }

    return null;
  }

  void _validateGenerateMocker(GenerateMocker generateMocker) {
    if (generateMocker.generateMockitoAnnotation &&
        !generateMocker.useMockitoGeneratedTypes) {
      _error(
          "if generateMockitoAnnotation is true then useMockitoGeneratedTypes must be true");
    }
  }

  Future<GeneratorConfig?> getGeneratorConfig(
      ConstantReader annotation, Element element, BuildStep buildStep) async {
    if (element is FunctionElement) {
      final mockerFunction = element;
      final types = await readDartTypesParam(annotation, mockerFunction);
      final generateMocker = GenerateMocker(
        [],
        generateMockitoAnnotation:
            readParam(annotation, 'generateMockitoAnnotation').boolValue,
        generateMockExtensions:
            readParam(annotation, 'generateMockExtensions').boolValue,
        useMockitoGeneratedTypes:
            readParam(annotation, 'useMockitoGeneratedTypes').boolValue,
        generateMocktailFallback:
            readParam(annotation, 'generateMocktailFallback').boolValue,
      );
      _validateGenerateMocker(generateMocker);
      return GeneratorConfig(
        types: types,
        mockerFunction: mockerFunction,
        generateMocker: generateMocker,
      );
    } else {
      _error('mocker must be a function!');
    }
    return null;
  }
}

///Config with mocker function and the types that need mock implementations
class GeneratorConfig {
  final GenerateMocker generateMocker;
  final List<ResolvedType> types;
  final FunctionElement mockerFunction;

  GeneratorConfig({
    required this.types,
    required this.generateMocker,
    required this.mockerFunction,
  });

  MockerConfig createMockerConfig() {
    final mockDefs = types
        .map((t) => MockDef(
              mockDefNaming: generateMocker.useMockitoGeneratedTypes
                  ? MockDefNaming.MOCKITO
                  : MockDefNaming.INTERNAL,
              returnNullOnMissingStub: false,
              generateExtension: generateMocker.generateMockExtensions,
              type: t,
            ))
        .toSet();
    return MockerConfig(
        mockerName: mockerFunction.name,
        generateMockitoAnnotation: generateMocker.generateMockitoAnnotation,
        mockDefs: mockDefs,
        generateMocktailFallback: generateMocker.generateMocktailFallback);
  }
}

extension<T> on List<T> {
  // ignore: unused_element
  List<T> onEach(test(T e)) {
    forEach((element) {
      test(element);
    });
    return this;
  }

  // ignore: unused_element
  List<T> onEachIndexed(test(int i, T e)) {
    var i = 0;
    forEach((element) {
      test(i, element);
      i++;
    });
    return this;
  }
}

extension<T> on List<T?> {
  void forEachIndexed(void Function(int i, T? item) block) {
    for (var i = 0; i < length; i++) {
      block(i, this[i]);
    }
  }

  // ignore: unused_element
  List<T> filterNotNull() =>
      where((element) => element != null).cast<T>().toList();
}

extension<T> on List<Future<T>> {
  // ignore: unused_element
  Future<List<T>> toFuture() => Stream.fromFutures(this).toList();
}

void _validateDartType(DartType dartType, onError(String message)) {
  if (dartType.isDynamic) {
    onError("cannot mock `dynamic`");
  }
  if (dartType.alias?.element != null) {
    onError("cannot mock a typedef");
  }
  final element = dartType.element;
  if (element == null) {
    onError("could not obtain element");
  } else {
    final library = element.library;
    if (library == null) {
      onError("could not obtain library element");
    } else {
      final typeProvider = library.typeProvider;
      if (element is ClassElement) {
        if (typeProvider.isNonSubtypableClass(element)) {
          onError("This type is non-subtypable so cannot be mocked");
        }
      }
    }
  }
}

class _ClassName {
  final DartType dartType;
  final String name;
  final String librarySource;

  _ClassName(this.dartType, this.name, this.librarySource);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ClassName &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          librarySource == other.librarySource;

  @override
  int get hashCode => name.hashCode ^ librarySource.hashCode;

  @override
  String toString() {
    return name;
  }
}

extension on DartType {
  _ClassName toClassName() {
    final librarySource = element?.librarySource?.toString();
    if (librarySource == null) {
      throw MockorException("error librarySource is null for $this");
    }
    return _ClassName(this, getDisplayString(withNullability: false),
        element!.librarySource!.toString());
  }
}

class _ImportAliasTable {
  final Map<String, String> _importAliasMap = {};

  _ImportAliasTable();

  String? operator [](String? import) {
    return _importAliasMap[import];
  }

  void operator []=(String import, String alias) {
    _importAliasMap[import] = alias;
  }

  factory _ImportAliasTable.fromElement(Element element) {
    final table = _ImportAliasTable();
    element.library?.imports.forEach((importElement) {
      final prefix = importElement.prefix?.name;
      if (prefix != null) {
        final import = importElement.importedLibrary?.source.toString();
        if (import == null) {
          throw MockorException(
              "Could not resolve full library name for ${importElement.uri} in ${importElement.librarySource}");
        }
        table[import] = prefix;
      }
    });
    return table;
  }

  @override
  String toString() {
    return '_ImportAliasTable{_importAliasMap: $_importAliasMap}';
  }
}

extension on List<DartType?> {
  Future<List<ResolvedType>> nonNullUniqueDartTypesOrThrow(
      _ImportAliasTable importAliasTable) async {
    print(importAliasTable);
    forEachIndexed((i, type) {
      void errorF(String msg) => _error(
          "Error with type ${type != null ? "`$type`" : ""} at position $i in 'types' argument: $msg");
      if (type == null) {
        errorF("this is not a type");
      } else {
        _validateDartType(type, _error);
      }
    });
    final nonNullDartTypes = where((element) => element != null)
        .cast<DartType>()
        .map((e) => e.toClassName())
        .toList()
        .onEachIndexed((i, e) => print("type $i ${e.name} ${e.librarySource}"));
    final resolvedTypes = nonNullDartTypes
        .map((type) => ResolvedType(
            displayName: type.name,
            librarySource: type.librarySource,
            prefix: importAliasTable[type.librarySource]))
        .toList();
    // check if resolvedTypes is unique
    resolvedTypes.forEach((type) {
      final occurrence = resolvedTypes.where((x) => x == type).length;
      if (occurrence > 1) {
        _error("Identical type '$type' appears $occurrence times");
      }
    });
    return resolvedTypes;
  }
}

///Exception that will be thrown on validation errors
class MockorException implements Exception {
  final String cause;

  MockorException(this.cause);

  @override
  String toString() {
    return '$runtimeType: $cause';
  }
}

void _error(String message) {
  throw MockorException(message);
}
