import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'test_utils/mocker.dart';
import 'usecase/example_use_case.dart';

class ExampleUseCase3 {}

void main() {
  ExampleUseCase? exampleUseCase;
  ExampleUseCase2? exampleUseCase2;
  ExampleUseCase? exampleUseCaseThrows;

  setUp(() {
    exampleUseCase = mock();
    exampleUseCase2 = mock();
    exampleUseCaseThrows = mock(throwOnMissingStub: true);
  });
  test('test 2 different example use cases', () {
    expect(exampleUseCase, isNotNull);
    expect(exampleUseCase2, isNotNull);
    when(exampleUseCase!.example()).thenReturn(2);
    when(exampleUseCase2!.example2()).thenThrow(Exception());

    expect(exampleUseCase!.example(), 2);
    try {
      exampleUseCase2!.example2();
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

  test('demonstrate throwOnMissingStub', () {
    try {
      exampleUseCaseThrows!.example();
      fail('expected exception');
    } catch (e) {
      print(e);
    }
  });
}
