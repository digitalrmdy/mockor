import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
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
    if (generateMocker.generateRelaxedVoidParameter &&
        generateMocker.useMockitoGeneratedTypes) {
      error("relaxedVoid parameter cannot be generated for Mockito");
    }
  }

  MocktailRelaxedVoidConfig _createMocktailRelaxedVoidConfig(
      ResolvedType resolvedType, LibraryElement libraryElement) {
    final type = resolvedType.dartType;
    final futureVoidMethods = <String>{};
    final voidMethods = <String>{};
    final executableElements = type.findAllExecutableElements();
    for (final executableElement in executableElements) {
      final returnType = executableElement.returnType.toVoidReturnType();
      if (returnType == null) continue;
      switch (returnType) {
        case VoidReturnType.Void:
          voidMethods.add(executableElement.name);
          break;
        case VoidReturnType.FutureVoid:
        case VoidReturnType.FutureOrVoid:
          futureVoidMethods.add(executableElement.name);
          break;
      }
    }
    return MocktailRelaxedVoidConfig(
        futureVoidMethodNames: futureVoidMethods.toList(),
        voidMethodNames: voidMethods.toList());
  }

  Future<MockorConfig?> createMockorConfig(
      ConstantReader annotation, Element element, BuildStep buildStep) async {
    if (element is FunctionElement) {
      final entryLib = await buildStep.inputLibrary;
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
          generateRelaxedVoidParameter:
              readParam(annotation, 'generateRelaxedVoidParameter').boolValue,
          generateMocktailFallbackValues: mocktailFallbackTypes != null
              ? GenerateMocktailFallbackValues([])
              : null);
      _validateGenerateMocker(generateMocker);
      final mockDefs = types
          .map((t) => MockDef(
              mockDefNaming: generateMocker.useMockitoGeneratedTypes
                  ? MockDefNaming.MOCKITO
                  : MockDefNaming.INTERNAL,
              generateExtension: generateMocker.generateMockExtensions,
              type: t,
              mocktailRelaxedVoidConfig:
                  generateMocker.generateRelaxedVoidParameter
                      ? _createMocktailRelaxedVoidConfig(t, entryLib)
                      : null))
          .toSet();
      final mocktailFallbackMockDefs = mocktailFallbackTypes
          ?.map((t) => MockDef(
                mockDefNaming: MockDefNaming.INTERNAL,
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

extension on DartType {
  VoidReturnType? toVoidReturnType() {
    final type = this;
    if (type.isVoid) {
      return VoidReturnType.Void;
    }
    if (type is InterfaceType && type.typeArguments.length == 1) {
      final typeArg = type.typeArguments.first;
      if (typeArg.isVoid) {
        if (type.isDartAsyncFuture) {
          return VoidReturnType.FutureVoid;
        } else if (type.isDartAsyncFutureOr) {
          return VoidReturnType.FutureOrVoid;
        }
      }
    }
    return null;
  }
}
