import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'test_utils/mocker.dart';
import 'usecase/example_use_case.dart';

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
}
