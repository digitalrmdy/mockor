import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:mockor/annotations.dart';
import 'package:mockor/src/dartbuilders/mocktail_fallback_values_dart_builder.dart';
import 'package:mockor/src/exceptions/mockor_exception.dart';
import 'package:mockor/src/generators/common/resolve_asset_uri.dart';
import 'package:mockor/src/models/models.dart';
import 'package:source_gen/source_gen.dart';

import 'common/common.dart';

///Generator for the mocker function implementation.
class MocktailFallbackValuesGenerator
    extends GeneratorForAnnotation<GenerateMocker> {
  const MocktailFallbackValuesGenerator();

  @override
  Future<String?> generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) async {
    try {
      final config = await _createConfig(annotation, element, buildStep);
      if (config != null) {
        final dartBuilder = MocktailFallbackValuesDartBuilder();
        return dartBuilder.buildDartFile(config);
      }
    } catch (e, s) {
      throw Exception("$e, $s");
    }

    return null;
  }

  List<InterfaceType> findNonNullFunctionParamsForType(DartType type) {
    final results = <InterfaceType>[];
    final element = type.element;
    if (element is ClassElement) {
      element.methods.forEach((method) {
        method.parameters.forEach((param) {
          final type = param.type;
          final paramElement = param.type.element;
          if (paramElement is ClassElement &&
              !paramElement.isPrivate &&
              type.nullabilitySuffix == NullabilitySuffix.none) {
            try {
              validateDartType(type, error);
              final interfaceType = type as InterfaceType;
              if (interfaceType.typeArguments.isEmpty) {
                results.add(type);
              }
            } on MockorException {
              // ignore
            }
          }
        });
      });
    }
    return results;
  }

  List<DartType> findNonNullFunctionParamsForTypes(List<DartType> types) {
    return types
        .map((type) => findNonNullFunctionParamsForType(type))
        .expand((element) => element)
        .toSet()
        .toList();
  }

  Future<MocktailFallbackValuesConfig?> _createConfig(
      ConstantReader annotation, Element element, BuildStep buildStep) async {
    if (element is FunctionElement) {
      final autoDetect =
          readParamInsideNestedObject(annotation, nestedParameter: "autoDetect")
                  ?.toBoolValue() ??
              false;
      if (autoDetect) {
        final resolver = buildStep.resolver;
        final importAliasTable = ImportAliasTable.empty();
        final types = await readDartTypesParam(annotation, importAliasTable);
        final mocktailFallbackTypes = await findNonNullFunctionParamsForTypes(
                types.map((e) => e.dartType).toList())
            .nonNullUniqueDartTypesOrThrow(importAliasTable,
                attributeName: "$GenerateMocktailFallbackValues.types");
        final entryLib = await buildStep.inputLibrary;
        final entryAssetId =
            await buildStep.resolver.assetIdForElement(entryLib);
        final assetUriMap = await resolveAssetUris(
          dartTypes: mocktailFallbackTypes.map((e) => e.dartType).toList(),
          entryAssetPath: entryAssetId.path,
          resolver: resolver,
        );
        final mocktailFallbackMockDefs = mocktailFallbackTypes
            .makeUnique()
            .map((t) => MockDef(
                  mockDefNaming: MockDefNaming.INTERNAL,
                  returnNullOnMissingStub: false,
                  generateExtension: false,
                  uri: assetUriMap[t.dartType],
                  type: t,
                ))
            .toSet();
        return MocktailFallbackValuesConfig(
            mocktailFallbackMockDefs: mocktailFallbackMockDefs);
      }
    }
    return null;
  }
}

extension on List<ResolvedType> {
  ResolvedType _appendDollar(ResolvedType resolvedType) {
    return resolvedType.copyWith(prefix: "${resolvedType.prefix ?? ''}\$");
  }

  void _makeUnique(
      ResolvedType resolvedType, Map<String, ResolvedType> uniqueEntries) {
    if (uniqueEntries.containsKey(resolvedType.nameUnique)) {
      _makeUnique(_appendDollar(resolvedType), uniqueEntries);
    } else {
      uniqueEntries[resolvedType.nameUnique] = resolvedType;
    }
  }

  List<ResolvedType> makeUnique() {
    final uniqueEntries = <String, ResolvedType>{};
    forEach((type) => _makeUnique(type, uniqueEntries));
    return uniqueEntries.values.toList();
  }
}
