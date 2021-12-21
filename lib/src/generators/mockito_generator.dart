import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:mockito_builder/src/dartbuilders/mockito_builder_dart_builder.dart';
import 'package:mockito_builder/src/models/models.dart';
import 'package:mockito_builder_annotations/mockito_builder_annotations.dart';
import 'package:source_gen/source_gen.dart';

///Generator for the mocker function implementation.
class MockitoGenerator extends GeneratorForAnnotation<GenerateMocker> {
  const MockitoGenerator();

  ConstantReader readParam(ConstantReader annotation, String parameter) {
    final reader = annotation.read(parameter);
    if (reader.isNull) {
      throw ArgumentError.notNull('$parameter');
    }
    return reader;
  }

  List<DartType> readDartTypesParam(
      ConstantReader annotation, String parameter) {
    return readParam(annotation, parameter)
        .listValue
        .map((x) => x.toTypeValue())
        .toList()
        .nonNullUniqueDartTypesOrThrow(attributeName: parameter);
  }

  String? generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    try {
      final generatorConfig = getGeneratorConfig(annotation, element);
      if (generatorConfig != null) {
        final mockitoConfig = MockitoConfigFactory(generatorConfig).create();
        final dartBuilder = MockitoDartBuilder();
        return dartBuilder.buildDartFile(mockitoConfig);
      }
    } catch (e, s) {
      throw Exception("$e, $s");
    }

    return null;
  }

  void error(String message) {
    throw MockitoGeneratorException(message);
  }

  GeneratorConfig? getGeneratorConfig(
      ConstantReader annotation, Element element) {
    if (element is FunctionElement) {
      final types = readDartTypesParam(annotation, 'types');
      final typesMockitoGenerated =
          readDartTypesParam(annotation, 'mockitoGeneratedTypes');
      final generateMockExtensions =
          readParam(annotation, 'generateMockExtensions').boolValue;
      return GeneratorConfig(
        types: types,
        mockerFunction: element,
        generateMockExtensions: generateMockExtensions,
        typesMockitoGenerated: typesMockitoGenerated,
      );
    } else {
      error('mocker must be a function!');
    }
    return null;
  }
}

///Config with mocker function and the types that need mock implementations
class GeneratorConfig {
  final List<DartType> types;
  final List<DartType> typesMockitoGenerated;
  final FunctionElement mockerFunction;
  final bool generateMockExtensions;

  GeneratorConfig(
      {required this.types,
      required this.typesMockitoGenerated,
      required this.mockerFunction,
      required this.generateMockExtensions});
}

///a factory for generating [MockDef] validated instances
class MockitoConfigFactory {
  final GeneratorConfig generatorConfig;

  MockitoConfigFactory(this.generatorConfig);

  void validateType(DartType dartType) {
    final lib = dartType.element?.library;
    lib!;
    assert(!lib.isDartAsync);
    assert(!lib.isDartCore);
  }

  MockDef _toMockDef(DartType dartType, MockDefSource mockDefSource) {
    validateType(dartType);
    return MockDef(
        type: dartType.getDisplayString(withNullability: false),
        mockDefSource: mockDefSource);
  }

  MockitoConfig create() {
    final typesToGenerate = generatorConfig.types
        .map((t) => _toMockDef(t, MockDefSource.INTERNAL))
        .toList();
    final typesMockitoGenerated = generatorConfig.typesMockitoGenerated
        .map((t) => _toMockDef(t, MockDefSource.MOCKITO))
        .toList();
    return MockitoConfig(
      mockerName: generatorConfig.mockerFunction.name,
      generateMockExtensions: generatorConfig.generateMockExtensions,
      mockDefs: (typesToGenerate + typesMockitoGenerated).toSet(),
    );
  }
}

extension<T> on List<T?> {
  void forEachIndexed(void Function(int i, T? item) block) {
    for (var i = 0; i < length; i++) {
      block(i, this[i]);
    }
  }
}

extension on List<DartType?> {
  List<DartType> nonNullUniqueDartTypesOrThrow(
      {required String attributeName}) {
    forEachIndexed((i, item) {
      if (item == null) {
        throw MockitoGeneratorException(
            '$DartType at $i in $attributeName cannot be determined');
      }
    });

    if (toSet().length != length) {
      throw MockitoGeneratorException(
          "Some types were specified twice in '$attributeName'!");
    }

    return where((element) => element != null).cast<DartType>().toList();
  }
}

///Exception that will be thrown on validation errors
class MockitoGeneratorException implements Exception {
  final String cause;

  MockitoGeneratorException(this.cause);

  @override
  String toString() {
    return '$runtimeType: $cause';
  }
}
