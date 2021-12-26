import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'example_test.mocks.dart';
import 'package:mockito_builder/annotations.dart';
part 'example_test.g.dart';

abstract class ExampleUseCase {
  int example(int i);

  Future<int> exampleAsync();

  void exampleVoid();

  int? exampleNullable();

  Future<void> exampleVoidAsync();

  factory ExampleUseCase() => ExampleUseCaseImpl();
}

class ExampleUseCaseImpl implements ExampleUseCase {
  @override
  int example(int i) => 1;

  @override
  Future<int> exampleAsync() async {
    return 2;
  }

  @override
  void exampleVoid() {}

  @override
  Future<void> exampleVoidAsync() async {}

  @override
  int? exampleNullable() {
    return 1;
  }
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
    exampleUseCase = _mock();
    exampleUseCase2 = _mock();
  });
  test('test 2 different example use cases', () async {
    expect(exampleUseCase, isNotNull);
    expect(exampleUseCase2, isNotNull);
    when(exampleUseCase.asMock().example(any)).thenReturn(2);
    when(exampleUseCase2.example2()).thenThrow(Exception());
    expect(exampleUseCase.example(1), 2);
    try {
      exampleUseCase2.example2();
      fail('expected exception');
    } on Exception {}
  });

  test('throw unimplemented error when mock class not generated', () {
    try {
      // ignore: unused_local_variable
      ExampleUseCase3 exampleUseCase3 = _mock();
      fail("expected an exception");
    } on UnimplementedError catch (e) {
      print(e.message);
    } catch (e) {
      fail("expected 'UnimplementedError'");
    }
  });
}
