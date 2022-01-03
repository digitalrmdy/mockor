import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:mockor/src/models/models.dart';

class MocktailFallbackValuesDartBuilder {
  const MocktailFallbackValuesDartBuilder();

  static const _mocktailUri = "package:mocktail/mocktail.dart";

  String buildDartFile(MocktailFallbackValuesConfig config) {
    final lib = Library(
      (b) {
        b
          ..body.add(_buildRegisterFallbackValuesMethod(config))
          ..body.addAll(
              config.mocktailFallbackMockDefs.map(_buildMockClass).toList());
      },
    );
    final emitter = DartEmitter.scoped();
    return DartFormatter().format('${lib.accept(emitter)}');
  }

  Class _buildMockClass(MockDef mockitoDef) {
    assert(mockitoDef.mockDefNaming == MockDefNaming.INTERNAL);
    return Class((b) => b
      ..name = mockitoDef.targetMockClassName
      ..extend = refer("Mock", _mocktailUri)
      ..implements.add(refer(mockitoDef.type.name, mockitoDef.import)));
  }

  Method _buildRegisterFallbackValuesMethod(
      MocktailFallbackValuesConfig config) {
    final name = config.registerFallbackValuesName;
    return Method((b) {
      b
        ..name = name
        ..returns = refer('void')
        ..body = _createRegisterFallbackValuesMethodBody(config);
    });
  }

  Block _createRegisterFallbackValuesMethodBody(
      MocktailFallbackValuesConfig config) {
    final list = <Code>[];
    config.mocktailFallbackMockDefs.forEach((mockDef) {
      final code = Code.scope((a) =>
          "${a(refer('registerFallbackValue', _mocktailUri))}(${mockDef.targetMockClassName}());");
      list.add(code);
    });
    return Block.of(list);
  }
}
