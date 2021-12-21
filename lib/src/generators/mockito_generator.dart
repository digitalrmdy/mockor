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
      final nullableTypes = readParam(annotation, 'types')
          .listValue
          .map((x) => x.toTypeValue())
          .toList();
      nullableTypes.forEachIndexed((i, item) {
        if (item == null) {
          error('$DartType at $i cannot be determined');
        }
      });
      final types = nullableTypes
          .where((element) => element != null)
          .cast<DartType>()
          .toList();
      if (types.toSet().length != types.length) {
        error('Some types were specified twice!');
      }
      return GeneratorConfig(types: types, mockerFunction: element);
    } else {
      error('mocker must be a function!');
    }
    return null;
  }
}

///Config with mocker function and the types that need mock implementations
class GeneratorConfig {
  final List<DartType> types;
  final FunctionElement mockerFunction;

  GeneratorConfig({required this.types, required this.mockerFunction});

  @override
  String toString() {
    return 'GeneratorConfig{types: $types}';
  }
}

///a factory for generating [MockDef] validated instances
class MockitoConfigFactory {
  final GeneratorConfig generatorConfig;

  MockitoConfigFactory(this.generatorConfig);

  FunctionElement get mocker => generatorConfig.mockerFunction;

  void validateType(DartType dartType) {
    final lib = dartType.element?.library;
    lib!;
    assert(!lib.isDartAsync);
    assert(!lib.isDartCore);
  }

  MockDef toMockDef(DartType dartType) {
    validateType(dartType);
    return MockDef(type: dartType.getDisplayString(withNullability: false));
  }

  MockitoConfig create() {
    return MockitoConfig(
        mockerName: mocker.name,
        mockDefs: generatorConfig.types.map(toMockDef).toSet());
  }
}

extension ListExtension<T> on List<T?> {
  void forEachIndexed(void Function(int i, T? item) block) {
    for (var i = 0; i < length; i++) {
      block(i, this[i]);
    }
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
