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

  String generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    try {
      final generatorConfig = getGeneratorConfig(annotation, element);
      if (generatorConfig != null) {
        final mockitoConfig = MockitoConfigFactory(generatorConfig).create();
        if (mockitoConfig != null) {
          final dartBuilder = MockitoDartBuilder();
          return dartBuilder.buildDartFile(mockitoConfig);
        }
      }
    } catch (e, s) {
      throw Exception("$e, $s");
    }

    return null;
  }

  void error(String message) {
    throw MockitoGeneratorException(message);
  }

  GeneratorConfig getGeneratorConfig(
      ConstantReader annotation, Element element) {
    if (element is FunctionElement) {
      final types = readParam(annotation, 'types')
          .listValue
          .map((x) => x.toTypeValue())
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

  GeneratorConfig({this.types, this.mockerFunction});

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
    final lib = dartType.element.library;
    assert(!lib.isDartAsync);
    assert(!lib.isDartCore);
  }

  MockDef toMockDef(DartType dartType) {
    validateType(dartType);
    // ignore: deprecated_member_use ignore until analyzer can be updated
    return MockDef(type: dartType.name);
  }

  bool notNull(Object o) => o != null;

  MockitoConfig create() {
    return MockitoConfig(
        mockerName: mocker.name,
        mockDefs: generatorConfig.types.map(toMockDef).toSet());
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
