import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:mockor/annotations.dart';
import 'package:mockor/src/models/models.dart';

///Builds Dart code of the mocker function
class MockerDartBuilder {
  String buildDartFile(MockorConfig mockorConfig) {
    final lib = Library(
      (b) {
        b
          ..body.add(_buildMockerMethod(mockorConfig))
          ..body.addAll(
              mockorConfig.mockDefsToGenerate.map(_buildMockClass).toList())
          ..body.addAll(mockorConfig.mockDefs
              .where((element) => element.generateExtension)
              .map(buildAsMockExtension)
              .toList());
        final mocktailFallbackMockDefs = mockorConfig.mocktailFallbackMockDefs;
        if (mocktailFallbackMockDefs != null) {
          b
            ..body.add(_buildRegisterFallbackValuesMethod(mockorConfig))
            ..body
                .addAll(mocktailFallbackMockDefs.map(_buildMockClass).toList());
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
      ..implements.add(refer(mockitoDef.type.displayNameWithPrefix)));
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
      list.add("case ${mockDef.type.displayNameWithPrefix}:");
      list.add("return ${mockDef.targetMockClassName}();");
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
        code +=
            "MockSpec<${mockDef.type.displayNameWithPrefix}>(as: #$customName, ";
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
        ..name = "_\$$name"
        ..returns = refer('void')
        ..body = _createRegisterFallbackValuesMethodBody(mockorConfig);
    });
  }

  Method _buildMockerMethod(MockorConfig mockorConfig) {
    final name = mockorConfig.mockerName;
    return Method((b) {
      if (mockorConfig.generateMockitoAnnotation) {
        b.annotations.add(_buildGenerateMocksAnnotation(mockorConfig));
      }
      b
        ..name = "_\$$name"
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
      ..name = "${mockDef.type.displayNameUnique}AsMockExtension"
      ..on = refer(mockDef.type.displayNameWithPrefix)
      ..methods.addAll([asMockMethod]));
  }
}
