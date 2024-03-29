import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'mocker_with_custom_mockito_annotation_test.mocks.dart';
import 'package:mockor/mockor.dart';
part 'mocker_with_custom_mockito_annotation_test.mockor.dart';

abstract class MockerWithCustomMockitoUseCase {
  void test();
}

abstract class MockerWithCustomMockitoUseCase2 {
  void test();
}

@GenerateMocker([MockerWithCustomMockitoUseCase],
    generateMockitoAnnotation: false)
@GenerateMocks([
  MockerWithCustomMockitoUseCase,
  MockerWithCustomMockitoUseCase2
], customMocks: [
  MockSpec<MockerWithCustomMockitoUseCase>(
      as: #MockerWithCustomMockitoUseCaseRelaxed, returnNullOnMissingStub: true)
])
T _mock<T extends Object>({bool relaxed = false}) =>
    _$_mock<T>(relaxed: relaxed);

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
  test("MockerWithCustomMockitoUseCaseRelaxed gets generated", () {
    MockerWithCustomMockitoUseCase useCase =
        MockerWithCustomMockitoUseCaseRelaxed();
    useCase.test();
  });
}
