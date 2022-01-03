library example;

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// This import is used by the generated mockor file to add Mockito's `@GenerateMocks` annotation.
// This need to be added manually.
import 'package:mockito/annotations.dart';

// <file_name>.mocks.dart will be generated by Mockito which contain all the generated mocks.
// This needs to be added manually.
import 'example.mocks.dart';

import 'package:mockor/annotations.dart';

part 'example.mockor.dart';

abstract class ExampleUseCase {
  int example(int i);
}

abstract class ExampleUseCase2 {
  void example2();
}

@GenerateMocker([
  ExampleUseCase,
  ExampleUseCase2,
])
T mock<T extends Object>() => _$mock<T>();

void main() {
  late ExampleUseCase exampleUseCase;
  late ExampleUseCase2 exampleUseCase2;

  setUp(() {
    // this will return [MockExampleUseCase]
    exampleUseCase = mock();
    exampleUseCase2 = mock();
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
     * By default an `asMock` extension method will be generated for all [GenerateMocker.types]
     * which casts it as generated mocked type (MockExampleUseCase).
     * Due to null safety we can only use the [any] matcher on non null params when using the mocked type.
     * Please read Mockito's [Null Safety README](https://github.com/dart-lang/mockito/blob/master/NULL_SAFETY_README.md) for more info.
     */
    when(exampleUseCase.asMock().example(any)).thenReturn(2);
    expect(exampleUseCase.example(1), 2);
  });
}
