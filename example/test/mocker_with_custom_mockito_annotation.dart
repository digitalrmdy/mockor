import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'mocker_with_custom_mockito_annotation.mocks.dart';
import 'package:mockor/annotations.dart';
part 'mocker_with_custom_mockito_annotation.mockor.dart';

abstract class MockerWithCustomMockitoUseCase {
  void test();
}

abstract class MockerWithCustomMockitoUseCase2 {
  void test();
}

@GenerateMocker([MockerWithCustomMockitoUseCase],
    generateMockitoAnnotation: false)
@GenerateMocks(
    [MockerWithCustomMockitoUseCase, MockerWithCustomMockitoUseCase2])
T _mock<T extends Object>() => _$_mock<T>();

void main() {
  test(
      "given MockerWithCustomMockitoUseCase type is provided to both annotations, it can be found",
      () {
    try {
      MockerWithCustomMockitoUseCase useCase1 = _mock();
      expect(useCase1, isNotNull);
    } on UnimplementedError {
      fail("could not find mock but expected it be found");
    }
  });

  test(
      "given MockerWithCustomMockitoUseCase2 type is not provided to $GenerateMocker annotation, it cannot be found",
      () {
    try {
      _mock<MockerWithCustomMockitoUseCase2>();
      fail("expected exception");
    } on UnimplementedError {}
  });
}
