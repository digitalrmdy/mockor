// ignore: deprecated_member_use
import 'package:analyzer/analyzer.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:mockito_builder/src/dartbuilders/mockito_builder_dart_builder.dart';
import 'package:mockito_builder/src/generators/util/util.dart';
import 'package:mockito_builder/src/models/models.dart';
import 'package:mockito_builder_annotations/mockito_builder_annotations.dart';
import 'package:source_gen/source_gen.dart';

class MockitoGenerator extends Generator {
  const MockitoGenerator();

  @override
  Future<String> generate(LibraryReader library, BuildStep buildStep) async {
    final generatorConfig = getGeneratorConfig(library);
    if (generatorConfig != null) {
      final mockitoConfig =
          await MockitoConfigFactory(generatorConfig).create();
      if (mockitoConfig != null) {
        final dartBuilder = MockitoDartBuilder();
        return dartBuilder.buildDartFile(mockitoConfig);
      }
    }

    return null;
  }

  GeneratorConfig getGeneratorConfig(LibraryReader library) {
    final mockerFunction = library
        .annotatedWith(TypeChecker.fromRuntime(Mocker))
        .map((x) => x.element)
        .whereType<FunctionElement>()
        .firstWhere((_) => true, orElse: () => null);
    if (mockerFunction != null) {
      assert(mockerFunction.parameters.isEmpty);
      final mainFunction = library.allElements
          .whereType<FunctionElement>()
          .firstWhere((x) => x.isEntryPoint, orElse: null);
      if (mainFunction != null)
        return GeneratorConfig(
            mainFunction: mainFunction, mockerFunction: mockerFunction);
    }

    return null;
  }
}

class GeneratorConfig {
  final FunctionElement mockerFunction;
  final FunctionElement mainFunction;

  GeneratorConfig({this.mockerFunction, this.mainFunction});

  @override
  String toString() {
    return 'GeneratorConfig{mockerFunction: $mockerFunction, mainFunction: $mainFunction}';
  }
}

class MockitoConfigFactory {
  final GeneratorConfig generatorConfig;

  MockitoConfigFactory(this.generatorConfig);

  FunctionElement get mocker => generatorConfig.mockerFunction;

  FunctionElement get main => generatorConfig.mainFunction;

  void validateType(DartType dartType) {
    final lib = dartType.element.library;
    assert(!lib.isDartAsync);
    assert(!lib.isDartCore);
  }

  MockDef toMockerAssignment(AssignmentExpression assignmentExpression) {
    final rightHandSide = assignmentExpression.rightHandSide;
    if (rightHandSide is MethodInvocation) {
      final function = rightHandSide.function;
      if (function is SimpleIdentifier && function.name == mocker.name) {
        if (function.staticElement == mocker) {
          final leftHandSide = assignmentExpression.leftHandSide;
          if (leftHandSide is SimpleIdentifier) {
            final element = leftHandSide.staticElement;
            if (element is LocalVariableElement) {
              final dartType = element.type;
              validateType(dartType);
              return MockDef(type: dartType.name, variableName: element.name);
            }
          }
          return null;
        }
      }
    }
    return null;
  }

  bool notNull(Object o) => o != null;

  Future<MockitoConfig> create() async {
    final x = await main.session.getResolvedLibraryByElement(main.library);
    final declaration = x.getElementDeclaration(main);
    final node = declaration.node;
    final assignmentsExpressions = findAssignmentExpressions(node);
    final mockDefs =
        assignmentsExpressions.map(toMockerAssignment).where(notNull).toSet();
    if (mockDefs.isNotEmpty) {
      return MockitoConfig(mockDefs: mockDefs, mockerName: mocker.name);
    } else
      return null;
  }
}
