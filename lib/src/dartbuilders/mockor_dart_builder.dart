import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:mockor/mockor.dart';
import 'package:mockor/src/models/models.dart';

///Builds Dart code of the mocker function
class MockorDartBuilder {
  String buildDartFile(MockorConfig mockorConfig) {
    final lib = Library(
      (b) {
        final mockDefsToGenerate = mockorConfig.mockDefsToGenerate;
        b
          ..body.add(_buildMockerMethod(mockorConfig))
          ..body.addAll(mockDefsToGenerate.map(_buildMockClass).toList())
          ..body.addAll(mockorConfig.mockDefs
              .where((element) => element.generateExtension)
              .map(buildAsMockExtension)
              .toList());
        final mocktailFallbackMockDefs = mockorConfig.mocktailFallbackMockDefs;
        if (mocktailFallbackMockDefs != null) {
          final types = mockDefsToGenerate.map((e) => e.type).toList();
          final newMocks = mocktailFallbackMockDefs
              .where((element) => !types.contains(element.type))
              .toList();
          b
            ..body.add(_buildRegisterFallbackValuesMethod(mockorConfig))
            ..body.addAll(newMocks.map(_buildMockClass).toList());
        }
      },
    );
    final emitter = DartEmitter();
    return DartFormatter().format('${lib.accept(emitter)}');
  }

  Class _buildMockClass(MockDef mockitoDef) {
    assert(mockitoDef.mockDefNaming == MockDefNaming.INTERNAL);
    return Class((b) => b
      ..name = mockitoDef.targetMockClassName
      ..extend = refer("Mock")
      ..implements.add(refer(mockitoDef.type.nameWithPrefix)));
  }

  String createUnimplementedErrorMessage(MockorConfig mockorConfig) {
    final mockerName = mockorConfig.mockerName;
    return '''Error, a mock class for \'\$T\' has not been generated yet.
Navigate to the \'$mockerName\' method and add the type to the types list in the \'$GenerateMocker\' annotation.
Finally run the build command: \'flutter packages pub run build_runner build\'.''';
  }

  Block _createMockerMethodBody(MockorConfig mockorConfig) {
    final list = <String>[];
    // switch statement
    list.add("switch(T) {");
    mockorConfig.mockDefs.forEach((mockDef) {
      list.add("case ${mockDef.type.nameWithPrefix}:");
      list.add("final mock = ${mockDef.targetMockClassName}();");
      list.add("if (!relaxed) {");
      list.add("throwOnMissingStub(mock);");
      list.add("}");
      list.add("return mock;");
    });
    list.add(
        "default: throw UnimplementedError(\'\'\'${createUnimplementedErrorMessage(mockorConfig)}\'\'\');");
    list.add("}");
    return Block.of(list.map((e) => Code(e)).toList());
  }

  Expression _buildGenerateMocksAnnotation(MockorConfig mockorConfig) {
    final mockDefsDefault = mockorConfig.mockDefsMockitoGenerated
        .where((element) => !element.isCustomMock)
        .toList();
    final customMocks = mockorConfig.mockDefsMockitoGenerated
        .where((element) => element.isCustomMock)
        .toList();
    final typesJoined = mockDefsDefault.map((e) => e.type).join(",");
    var code = "GenerateMocks([$typesJoined]";
    if (customMocks.isNotEmpty) {
      code += ", customMocks: [";
      customMocks.forEach((mockDef) {
        final customName = mockDef.targetMockClassName;
        code += "MockSpec<${mockDef.type.nameWithPrefix}>(as: #$customName, ";
        if (mockDef.returnNullOnMissingStub) {
          code += "returnNullOnMissingStub: true, ";
        }
        code += "), ";
      });
      code += "]";
    }
    code += ")";
    return CodeExpression(Code(code));
  }

  Block _createRegisterFallbackValuesMethodBody(MockorConfig mockorConfig) {
    final list = <String>[];
    mockorConfig.mocktailFallbackMockDefs?.forEach((mockDef) {
      list.add("registerFallbackValue(${mockDef.targetMockClassName}());");
    });
    return Block.of(list.map((e) => Code(e)).toList());
  }

  Method _buildRegisterFallbackValuesMethod(MockorConfig mockorConfig) {
    final name = mockorConfig.registerFallbackValuesName;
    return Method((b) {
      b
        ..name = name
        ..returns = refer('void')
        ..body = _createRegisterFallbackValuesMethodBody(mockorConfig);
    });
  }

  Parameter _buildRelaxedParam() {
    return Parameter((b) => b
      ..name = "relaxed"
      ..defaultTo = Code("false")
      ..named = true
      ..type = refer('bool'));
  }

  Method _buildMockerMethod(MockorConfig mockorConfig) {
    final name = mockorConfig.mockerName;
    return Method((b) {
      if (mockorConfig.generateMockitoAnnotation) {
        b.annotations.add(_buildGenerateMocksAnnotation(mockorConfig));
      }
      b
        ..name = "_\$$name"
        ..optionalParameters.add(_buildRelaxedParam())
        ..returns = refer('dynamic')
        ..types.add(refer("T extends Object"))
        ..body = _createMockerMethodBody(mockorConfig);
    });
  }

  Extension buildAsMockExtension(MockDef mockDef) {
    final asMockMethod = Method((_) => _
      ..name = "asMock"
      ..lambda = true
      ..returns = refer(mockDef.targetMockClassName)
      ..body = Code("this as ${mockDef.targetMockClassName}"));
    return Extension((_) => _
      ..name = "${mockDef.type.nameUnique}AsMockExtension"
      ..on = refer(mockDef.type.nameWithPrefix)
      ..methods.addAll([asMockMethod]));
  }
}
