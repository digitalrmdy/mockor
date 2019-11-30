import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'usecase/example_use_case.dart';
import 'package:mockito_builder_annotations/mockito_builder_annotations.dart';

part 'mockito_builder_test.g.dart';

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

@mocker
T mock<T>() => _$mock<T>();
