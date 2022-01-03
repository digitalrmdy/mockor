import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'example_test.mocks.dart';
import 'package:mockor/mockor.dart';

import 'models/model_a.dart' as ModelA;
import 'models/model_b.dart' as ModelB;
part 'example_test.mockor.dart';

abstract class ExampleUseCase {
  int exampleInt(ExampleModel model);
}

class ExampleModel {}

abstract class ExampleUseCase2 {
  void exampleVoid();
  int? exampleNullableInt();
}

class ExampleUseCase3 {}

@GenerateMocker([
  ExampleUseCase,
  ExampleUseCase2,
  ModelA.Model,
  ModelB.Model,
])
T _mock<T extends Object>({bool relaxed = false}) =>
    _$_mock<T>(relaxed: relaxed);
void main() {
  late ExampleUseCase exampleUseCase;
  late ExampleUseCase2 exampleUseCase2;
  // ignore: unused_local_variable
  late ModelA.Model modelA;
  // ignore: unused_local_variable
  late ModelB.Model modelB;

  setUp(() {
    // this will return [MockExampleUseCase]
    exampleUseCase = _mock();
    exampleUseCase2 = _mock();
    modelA = _mock();
    modelB = _mock();
  });
  test("given example2 throws an exception then don't catch it", () {
    when(exampleUseCase2.exampleVoid()).thenThrow(Exception());
    try {
      exampleUseCase2.exampleVoid();
      fail('expected exception');
    } on Exception {}
  });
  test('given example with any param returns 2 then return 2', () {
    /**
     * by default an `asMock` extension method will be generated.
     * Which returns the mocked type.
     * Due to null safety we can only use the [any] matcher on non null params when using mock type.
     * Please read the [Null Safety README](https://github.com/dart-lang/mockito/blob/master/NULL_SAFETY_README.md) for more info.
     */
    when(exampleUseCase.asMock().exampleInt(any)).thenReturn(2);
    expect(exampleUseCase.exampleInt(ExampleModel()), 2);
  });

  test('throw unimplemented error when mock class not generated', () {
    try {
      _mock<ExampleUseCase3>();
      fail("expected an exception");
    } on UnimplementedError catch (e) {
      print(e.message);
    } catch (e) {
      fail("expected 'UnimplementedError'");
    }
  });
  group("relaxed", () {
    group("given relaxed is true", () {
      test("then don't throw exception on nullable method not stubbed", () {
        final ExampleUseCase2 useCase = _mock(relaxed: true);
        useCase..exampleVoid();
      });
      test("then throw typeError on non null method not stubbed", () {
        final ExampleUseCase useCase = _mock(relaxed: true);
        try {
          useCase.asMock().exampleInt(null);
        } on TypeError {
        } on MissingStubError {
          fail("did not expect $MissingStubError");
        }
      });
    });
    group("given relaxed is false", () {
      test("then throw $MissingStubError on nullable method not stubbed", () {
        final ExampleUseCase2 useCase = _mock(relaxed: false);
        try {
          useCase.exampleNullableInt();
          fail("expected $MissingStubError");
        } on MissingStubError {}
      });
      test("then throw don't exception on void method not stubbed", () {
        final ExampleUseCase2 useCase = _mock(relaxed: false);
        try {
          useCase.exampleVoid();
        } on MissingStubError {
          fail("did not $MissingStubError");
        }
      });
      test("then throw $MissingStubError on non null method not stubbed", () {
        final ExampleUseCase useCase = _mock(relaxed: false);
        try {
          useCase.asMock().exampleInt(null);
        } on MissingStubError {
        } on TypeError {
          fail("did not expect $TypeError");
        }
      });
    });
  });
}
