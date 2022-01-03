import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:mockor/mockor.dart';
import 'package:mockor/src/dartbuilders/mockor_dart_builder.dart';
import 'package:mockor/src/exceptions/mockor_exception.dart';
import 'package:mockor/src/models/models.dart';
import 'package:source_gen/source_gen.dart';

import 'common/common.dart';

///Generator for the mocker function implementation.
class MockerGenerator extends GeneratorForAnnotation<GenerateMocker> {
  const MockerGenerator();

  @override
  Future<String?> generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) async {
    try {
      final mockorConfig =
          await createMockorConfig(annotation, element, buildStep);
      if (mockorConfig != null) {
        final dartBuilder = MockorDartBuilder();
        return dartBuilder.buildDartFile(mockorConfig);
      }
    } catch (e, s) {
      throw Exception("$e, $s");
    }

    return null;
  }

  void _validateGenerateMocker(GenerateMocker generateMocker) {
    if (generateMocker.generateMockitoAnnotation &&
        !generateMocker.useMockitoGeneratedTypes) {
      error(
          "if generateMockitoAnnotation is true then useMockitoGeneratedTypes must be true");
    }
  }

  Future<MockorConfig?> createMockorConfig(
      ConstantReader annotation, Element element, BuildStep buildStep) async {
    if (element is FunctionElement) {
      final mockerFunction = element;
      final importAliasTable = ImportAliasTable.fromElement(mockerFunction);
      final types = await readDartTypesParam(annotation, importAliasTable);
      final generateMocktailFallbackValues = readParamInsideNestedObject(
        annotation,
        nestedParameter: "types",
      );
      final mocktailFallbackTypes = await generateMocktailFallbackValues
          ?.toListValue()
          ?.map((e) => e.toTypeValue())
          .toList()
          .nonNullUniqueDartTypesOrThrow(importAliasTable,
              attributeName: "$GenerateMocktailFallbackValues.types");
      final generateMocker = GenerateMocker([],
          generateMockitoAnnotation:
              readParam(annotation, 'generateMockitoAnnotation').boolValue,
          generateMockExtensions:
              readParam(annotation, 'generateMockExtensions').boolValue,
          useMockitoGeneratedTypes:
              readParam(annotation, 'useMockitoGeneratedTypes').boolValue,
          generateMocktailFallbackValues: mocktailFallbackTypes != null
              ? GenerateMocktailFallbackValues([])
              : null);
      _validateGenerateMocker(generateMocker);
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
      final mocktailFallbackMockDefs = mocktailFallbackTypes
          ?.map((t) => MockDef(
                mockDefNaming: MockDefNaming.INTERNAL,
                returnNullOnMissingStub: false,
                generateExtension: false,
                type: t,
              ))
          .toSet();
      return MockorConfig(
          mockerName: mockerFunction.name,
          generateMockitoAnnotation: generateMocker.generateMockitoAnnotation,
          mockDefs: mockDefs,
          mocktailFallbackMockDefs: mocktailFallbackMockDefs);
    } else {
      error('mocker must be a function!');
    }
    return null;
  }
}
