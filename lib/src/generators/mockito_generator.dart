import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:mockito_builder/src/dartbuilders/mockito_builder_dart_builder.dart';
import 'package:mockito_builder/src/models/models.dart';
import 'package:mockito_builder_annotations/mockito_builder_annotations.dart';
import 'package:source_gen/source_gen.dart';

class MockitoGenerator extends GeneratorForAnnotation<GenerateMocker> {
  const MockitoGenerator();

  ConstantReader readParam(ConstantReader annotation, String parameter) {
    final reader = annotation.read(parameter);
    if (reader.isNull) {
      throw ArgumentError.notNull('$parameter');
    }
    return reader;
  }

  dynamic generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    final generatorConfig = getGeneratorConfig(annotation, element);
    if (generatorConfig != null) {
      final mockitoConfig = MockitoConfigFactory(generatorConfig).create();
      if (mockitoConfig != null) {
        final dartBuilder = MockitoDartBuilder();
        return dartBuilder.buildDartFile(mockitoConfig);
      }
    }

    return null;
  }

  void error(String message) {
    throw MockitoGeneratorException(message);
  }

  GeneratorConfig? getGeneratorConfig(
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

class GeneratorConfig {
  final List<DartType?> types;
  final FunctionElement mockerFunction;

  GeneratorConfig({required this.types, required this.mockerFunction});

  @override
  String toString() {
    return 'GeneratorConfig{types: $types}';
  }
}

class MockitoConfigFactory {
  final GeneratorConfig generatorConfig;

  MockitoConfigFactory(this.generatorConfig);

  FunctionElement get mocker => generatorConfig.mockerFunction;

  void validateType(DartType dartType) {
    final lib = dartType.element!.library;
    assert(!lib!.isDartAsync);
    assert(!lib!.isDartCore);
  }

  MockDef toMockDef(DartType? dartType) {
    validateType(dartType!);
    return MockDef(type: dartType.name as String);
  }

  bool notNull(Object o) => o != null;

  MockitoConfig create() {
    return MockitoConfig(
        mockerName: mocker.name,
        mockDefs: generatorConfig.types.map(toMockDef).toSet());
  }
}

class MockitoGeneratorException implements Exception {
  final String cause;

  MockitoGeneratorException(this.cause);

  @override
  String toString() {
    return '$runtimeType: $cause';
  }
}
