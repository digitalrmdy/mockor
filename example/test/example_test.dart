import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'example_test.mocks.dart';
import 'package:mockor/annotations.dart';
part 'example_test.mockor.dart';

abstract class ExampleUseCase {
  int example(int i);

  factory ExampleUseCase() => ExampleUseCaseImpl();
}

class ExampleUseCaseImpl implements ExampleUseCase {
  @override
  int example(int i) => 1;
}

abstract class ExampleUseCase2 {
  void example2();

  factory ExampleUseCase2() => ExampleUseCase2Impl();
}

class ExampleUseCase2Impl implements ExampleUseCase2 {
  @override
  void example2() {
    print('example2');
  }
}

class ExampleUseCase3 {}

class ExampleUseCase4 {}

class ExampleUseCase5 {}

class ExampleUseCase6 {}

class ExampleUseCase7 {}

@GenerateMocker([
  ExampleUseCase,
  ExampleUseCase2,
  ExampleUseCase4,
  ExampleUseCase5,
  ExampleUseCase6,
  ExampleUseCase7,
])
T _mock<T>() => _$_mock<T>();
void main() {
  late ExampleUseCase exampleUseCase;
  late ExampleUseCase2 exampleUseCase2;

  setUp(() {
    // this will return [MockExampleUseCase]
    exampleUseCase = _mock();
    exampleUseCase2 = _mock();
  });
  test("given example2 throws an exception then don't catch it", () {
    when(exampleUseCase2.example2()).thenThrow(Exception());
    try {
      exampleUseCase2.example2();
      fail('expected exception');
    } on Exception {}
  });
  test('given example with any param returns 2 then return 2', () {
    /**
     * by default an `asMock` extension method will be generated.
     * Which returns the mocked type.
     * Due to null safety we can only use the [any] matcher on non null params when using mock type.
     * Please read the [NULL_SAFETY_README](https://github.com/dart-lang/mockito/blob/master/NULL_SAFETY_README.md) for more info.
     */
    when(exampleUseCase.asMock().example(any)).thenReturn(2);
    expect(exampleUseCase.example(1), 2);
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
}
