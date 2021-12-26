import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:mockito_builder/annotations.dart';
import 'package:mockito_builder/src/dartbuilders/mockito_builder_dart_builder.dart';
import 'package:mockito_builder/src/models/models.dart';
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
        final mockitoConfig = generatorConfig.createMocktioConfig();
        final dartBuilder = MockitoDartBuilder();
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

  GeneratorConfig? getGeneratorConfig(
      ConstantReader annotation, Element element) {
    if (element is FunctionElement) {
      final types = readDartTypesParam(annotation, 'types');
      final generateMocker = GenerateMocker([],
          generateMockitoAnnotation:
              readParam(annotation, 'generateMockitoAnnotation').boolValue,
          generateMockExtensions:
              readParam(annotation, 'generateMockExtensions').boolValue,
          useMockitoGeneratedTypes:
              readParam(annotation, 'useMockitoGeneratedTypes').boolValue);
      _validateGenerateMocker(generateMocker);
      return GeneratorConfig(
        types: types,
        mockerFunction: element,
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
  final List<DartType> types;
  final FunctionElement mockerFunction;

  GeneratorConfig({
    required this.types,
    required this.generateMocker,
    required this.mockerFunction,
  });
  MockitoConfig createMocktioConfig() {
    final mockDefs = types
        .map((t) => MockDef(
              mockDefNaming: generateMocker.useMockitoGeneratedTypes
                  ? MockDefNaming.MOCKITO
                  : MockDefNaming.INTERNAL,
              generateExtension: generateMocker.generateMockExtensions,
              type: t.getDisplayString(withNullability: false),
            ))
        .toSet();
    return MockitoConfig(
      mockerName: mockerFunction.name,
      generateMockitoAnnotation: generateMocker.generateMockitoAnnotation,
      mockDefs: mockDefs,
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

void _validateDartType(DartType dartType) {
  final lib = dartType.element?.library;
  lib!;
  assert(!lib.isDartAsync);
  assert(!lib.isDartCore);
}

extension on List<DartType?> {
  List<DartType> nonNullUniqueDartTypesOrThrow(
      {required String attributeName}) {
    forEachIndexed((i, type) {
      if (type == null) {
        _error('$DartType at $i in $attributeName cannot be determined');
      } else {
        _validateDartType(type);
      }
    });

    if (toSet().length != length) {
      _error("Some types were specified twice in '$attributeName'!");
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

void _error(String message) {
  throw MockitoGeneratorException(message);
}
