library example;

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito_builder_annotations/mockito_builder_annotations.dart';

part 'example.g.dart';

abstract class ExampleUseCase {
  int example();

  factory ExampleUseCase() => ExampleUseCaseImpl();
}

class ExampleUseCaseImpl implements ExampleUseCase {
  @override
  int example() => 1;
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

@GenerateMocker([ExampleUseCase, ExampleUseCase2])
T mock<T>() => _$mock<T>();

class ExampleUseCase3 {}

void main() {
  ExampleUseCase exampleUseCase;
  ExampleUseCase2 exampleUseCase2;

  setUp(() {
    exampleUseCase = mock();
    exampleUseCase2 = mock();
  });
  test('test 2 different example use cases', () {
    expect(exampleUseCase, isNotNull);
    expect(exampleUseCase2, isNotNull);
    when(exampleUseCase.example()).thenReturn(2);
    when(exampleUseCase2.example2()).thenThrow(Exception());

    expect(exampleUseCase.example(), 2);
    try {
      exampleUseCase2.example2();
      fail('expected exception');
    } on Exception {}
  });

  test('throw unimplemented error when mock class not generated', () {
    try {
      // ignore: unused_local_variable
      ExampleUseCase3 exampleUseCase3 = mock();
      fail("expected an exception");
    } on UnimplementedError catch (e) {
      print(e.message);
    } catch (e) {
      fail("expected 'UnimplementedError'");
    }
  });
}
