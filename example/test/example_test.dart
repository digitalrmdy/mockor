import 'package:example/example.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  late ExampleUseCase exampleUseCase;
  late ExampleUseCase2 exampleUseCase2;

  setUp(() {
    exampleUseCase = mock();
    exampleUseCase2 = mock();
  });
  test('test 2 different example use cases', () {
    expect(exampleUseCase, isNotNull);
    expect(exampleUseCase2, isNotNull);
    when(exampleUseCase.mock.example(any)).thenReturn(2);
    when(exampleUseCase2.example2()).thenThrow(Exception());

    expect(exampleUseCase.mock.example(any), 2);
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
