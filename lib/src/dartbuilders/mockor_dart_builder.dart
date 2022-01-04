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
        final relaxedVoidMocks = mockDefsToGenerate
            .where((element) => element.isRelaxedVoidSupported)
            .toList();
        if (relaxedVoidMocks.isNotEmpty) {
          b.body.addAll(relaxedVoidMocks
              .map(_buildRelaxedVoidExceptionBuilderMethod)
              .toList());
        }
      },
    );
    final emitter = DartEmitter();
    return DartFormatter().format('${lib.accept(emitter)}');
  }

  Block _buildNoSuchMethodRelaxedVoidBody() {
    final list = <String>[];
    list.add("try {");
    list.add(("return super.noSuchMethod(invocation);"));
    list.add("} on $MissingFutureVoidStubException {");
    list.add("return Future<void>.value();");
    list.add("} on $MissingNullStubException {");
    list.add("return null;");
    list.add("}");
    return Block.of(list.map((e) => Code(e)).toList());
  }

  Method _buildNoSuchMethodRelaxedVoid() {
    return Method((b) => b
      ..name = "noSuchMethod"
      ..requiredParameters.add(Parameter((p) => p
        ..name = "invocation"
        ..type = refer("Invocation")))
      ..returns = refer("dynamic")
      ..annotations.add(refer("override"))
      ..body = _buildNoSuchMethodRelaxedVoidBody());
  }

  Class _buildMockClass(MockDef mockitoDef) {
    assert(mockitoDef.mockDefNaming == MockDefNaming.INTERNAL);
    return Class((b) {
      if (mockitoDef.isRelaxedVoidSupported) {
        b.methods.add(_buildNoSuchMethodRelaxedVoid());
      }
      b
        ..name = mockitoDef.targetMockClassName
        ..extend = refer("Mock")
        ..implements.add(refer(mockitoDef.type.nameWithPrefix));
    });
  }

  String createUnimplementedErrorMessage(MockorConfig mockorConfig) {
    final mockerName = mockorConfig.mockerName;
    return '''Error, a mock class for \'\$T\' has not been generated yet.
Navigate to the \'$mockerName\' method and add the type to the types list in the \'$GenerateMocker\' annotation.
Finally run the build command: \'flutter packages pub run build_runner build\'.''';
  }

  Block _createMockerMethodBody(MockorConfig mockorConfig) {
    final list = <String>[];
    list.add("relaxed ??= ${!mockorConfig.hasMockitoGeneratedTypes};");
    if (mockorConfig.addRelaxedVoidParam) {
      list.add("relaxedVoid ??= relaxed;");
    }
    // switch statement
    list.add("switch(T) {");
    mockorConfig.mockDefs.forEach((mockDef) {
      list.add("case ${mockDef.type.nameWithPrefix}:");
      list.add("final mock = ${mockDef.targetMockClassName}();");

      if (mockDef.isRelaxedVoidSupported) {
        list.add("if (!relaxed || relaxedVoid) {");
        list.add(
            "throwOnMissingStub(mock, exceptionBuilder: relaxedVoid ? (env) => ${mockDef.relaxedVoidExceptionBuilderMethodName}(env, relaxed!) : null);");
        list.add("}");
      } else {
        list.add("if (!relaxed) {");
        list.add("throwOnMissingStub(mock);");
        list.add("}");
      }
      list.add("return mock;");
    });
    list.add(
        "default: throw UnimplementedError(\'\'\'${createUnimplementedErrorMessage(mockorConfig)}\'\'\');");
    list.add("}");
    return Block.of(list.map((e) => Code(e)).toList());
  }

  Expression _buildGenerateMocksAnnotation(MockorConfig mockorConfig) {
    final mockDefs = mockorConfig.mockDefsMockitoGenerated;
    var code = "GenerateMocks([]";
    if (mockDefs.isNotEmpty) {
      code += ", customMocks: [";
      mockDefs.forEach((mockDef) {
        final customName = mockDef.targetMockClassName;
        code +=
            "MockSpec<${mockDef.type.nameWithPrefix}>(as: #$customName, returnNullOnMissingStub: true,), ";
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
      ..named = true
      ..type = refer('bool?'));
  }

  Parameter _buildRelaxedVoidParam() {
    return Parameter((b) => b
      ..name = "relaxedVoid"
      ..named = true
      ..type = refer('bool?'));
  }

  Method _buildMockerMethod(MockorConfig mockorConfig) {
    final name = mockorConfig.mockerName;
    return Method((b) {
      if (mockorConfig.generateMockitoAnnotation) {
        b.annotations.add(_buildGenerateMocksAnnotation(mockorConfig));
      }
      b.optionalParameters.add(_buildRelaxedParam());
      if (mockorConfig.addRelaxedVoidParam) {
        b.optionalParameters.add(_buildRelaxedVoidParam());
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
      ..name = "${mockDef.type.nameUnique}AsMockExtension"
      ..on = refer(mockDef.type.nameWithPrefix)
      ..methods.addAll([asMockMethod]));
  }

  Block _buildRelaxedVoidExceptionBuilderMethodBody(
      MocktailRelaxedVoidConfig relaxedVoidConfig) {
    final list = <String>[];
    list.add("switch(inv.memberName) {");
    final voidMethods = relaxedVoidConfig.voidMethodNames;
    voidMethods.forEach((voidMethodName) {
      list.add("case #$voidMethodName:");
    });
    if (voidMethods.isNotEmpty) {
      list.add("return null;");
    }
    final futureVoidMethods = relaxedVoidConfig.futureVoidMethodNames;
    futureVoidMethods.forEach((futureVoidMethodName) {
      list.add("case #$futureVoidMethodName:");
    });
    if (futureVoidMethods.isNotEmpty) {
      list.add("throw $MissingFutureVoidStubException();");
    }
    list.add("default:");
    list.add(
        "relaxed ? throw $MissingNullStubException() : throw MissingStubError(inv);");
    list.add("}");

    return Block.of(list.map((e) => Code(e)).toList());
  }

  Method _buildRelaxedVoidExceptionBuilderMethod(MockDef mockDef) {
    final mocktailConfig = mockDef.mocktailRelaxedVoidConfig!;
    return Method((b) => b
      ..name = mockDef.relaxedVoidExceptionBuilderMethodName
      ..requiredParameters.addAll([
        Parameter((p) => p
          ..name = "inv"
          ..type = refer("Invocation")),
        Parameter((p) => p
          ..name = "relaxed"
          ..type = refer("bool")),
      ])
      ..body = _buildRelaxedVoidExceptionBuilderMethodBody(mocktailConfig)
      ..returns = refer("void"));
  }
}
