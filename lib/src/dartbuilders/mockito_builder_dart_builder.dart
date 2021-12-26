import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:mockito_builder/src/models/models.dart';
import 'package:mockito_builder_annotations/mockito_builder_annotations.dart';

///Builds Dart code of the mocker function
class MockitoDartBuilder {
  String buildDartFile(MockitoConfig mockitoConfig) {
    final lib = Library(
      (b) {
        b
          ..body.addAll(
              mockitoConfig.mockDefsToGenerate.map(_buildMockClass).toList())
          ..body.add(buildMockerMethod(mockitoConfig))
          ..body.addAll(mockitoConfig.mockDefs
              .where((element) => element.generateExtension)
              .map(buildAsMockExtension)
              .toList());
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
      ..implements.add(refer(mockitoDef.type)));
  }

  String createUnimplementedErrorMessage(MockitoConfig mockitoConfig) {
    final mockerName = mockitoConfig.mockerName;
    return '''Error, a mock class for \'\$T\' has not been generated yet.
Navigate to the \'$mockerName\' method and add the type to the types list in the \'$GenerateMocker\' annotation.
Finally run the build command: \'flutter packages pub run build_runner build\'.''';
  }

  Block _createSwitchStatement(MockitoConfig mockitoConfig) {
    final list = <Code>[];
    list.add(Code("switch(T) {"));
    mockitoConfig.mockDefs.forEach((mockDef) {
      list.add(Code("case ${mockDef.type}:"));
      list.add(Code("return ${mockDef.targetMockClassName}();"));
    });
    list.add(Code(
        "default: throw UnimplementedError(\'\'\'${createUnimplementedErrorMessage(mockitoConfig)}\'\'\');"));
    list.add(Code("}"));
    return Block.of(list);
  }

  Expression _buildGenerateMocksAnnotation(MockitoConfig mockitoConfig) {
    final mockDefs = mockitoConfig.mockDefsMockitoGenerated;
    final typesJoined = mockDefs.map((e) => e.type).join(",");
    var code = "";
    code += "GenerateMocks([$typesJoined])";
    return CodeExpression(Code(code));
  }

  Method buildMockerMethod(MockitoConfig mockitoConfig) {
    final name = mockitoConfig.mockerName;
    return Method((b) {
      if (mockitoConfig.generateMockitoAnnotation) {
        b.annotations.add(_buildGenerateMocksAnnotation(mockitoConfig));
      }
      b
        ..name = "_\$$name"
        ..returns = refer('dynamic')
        ..types.add(refer("T"))
        ..body = _createSwitchStatement(mockitoConfig);
    });
  }

  Extension buildAsMockExtension(MockDef mockDef) {
    final asMockMethod = Method((_) => _
      ..name = "asMock"
      ..lambda = true
      ..returns = refer(mockDef.targetMockClassName)
      ..body = Code("this as ${mockDef.targetMockClassName}"));
    return Extension((_) => _
      ..name = "${mockDef.targetMockClassName}Extension"
      ..on = refer(mockDef.type)
      ..methods.addAll([asMockMethod]));
  }
}
