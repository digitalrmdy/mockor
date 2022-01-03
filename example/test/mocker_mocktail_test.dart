import 'package:flutter_test/flutter_test.dart';
import 'package:mockor/mockor.dart';
import 'package:mocktail/mocktail.dart';

import 'mocker_mocktail_test.fallback.dart';
import 'models/model_a.dart' as ModelA;
import 'models/model_b.dart' as ModelB;
part 'mocker_mocktail_test.mockor.dart';

abstract class MockerMocktailUseCase {
  int test(int i);
  _Model test2(_Model model);
  _Model2 test3(_Model2 model);
  void test4(Model3 model3);
  void test5({required Model3 model3});
  void test6({Model4? model4});
  void test7(Model5<Model4> model5);
  void test8(ModelA.Model modelA, ModelB.Model modelB);
  void test9(Model6 model6);
  void testNullable(int? i);
}

class _Model {}

class _Model2 {}

class Model3 {}

class Model4 {}

class Model5<T> {}

class Model6 {}

@GenerateMocker(
  [MockerMocktailUseCase],
  generateMockExtensions: false,
  generateMockitoAnnotation: false,
  useMockitoGeneratedTypes: false,
  generateMocktailFallbackValues: GenerateMocktailFallbackValues(
    [_Model2, MockerMocktailUseCase, Model6],
    autoDetect: true,
  ),
)
T _mock<T extends Object>({bool relaxed = true}) =>
    _$_mock<T>(relaxed: relaxed);

void registerFallbackValuesAll() {
  _$registerFallbackValues();
  registerFallbackValuesAutoDetected();
}

void main() {
  late MockerMocktailUseCase useCase;
  late MockerMocktailUseCase useCaseNotRelaxed;
  setUpAll(() {
    registerFallbackValuesAll();
  });
  setUp(() {
    useCase = _mock(relaxed: true);
    useCaseNotRelaxed = _mock(relaxed: false);
  });
  test("`when` with any() doesn't crash and works as expected", () {
    when(() => useCase.test(any())).thenReturn(1);
    expect(useCase.test(2), 1);
  });
  test("any() with custom class doesn't work without registerFallbackValue",
      () {
    final model = _Model();
    try {
      when(() => useCase.test2(any())).thenReturn(model);
      fail("expected exception");
    } catch (ex) {}
  });
  test("any() with custom class works with registerFallbackValue", () {
    final model = _Model2();
    when(() => useCase.test3(any())).thenReturn(model);
    expect(useCase.test3(_Model2()), model);
  });
  group("relaxed", () {
    group("given relaxed is true", () {
      test("then don't throw exception on nullable method not stubbed", () {
        useCase.testNullable(0);
      });
      test("then throw typeError on non null method not stubbed", () {
        try {
          useCase.test(0);
        } on TypeError {
        } on MissingStubError {
          fail("did not expect $MissingStubError");
        }
      });
    });
    group("given relaxed is false", () {
      test("then throw $MissingStubError on nullable method not stubbed", () {
        try {
          useCaseNotRelaxed.testNullable(0);
          fail("expected $MissingStubError");
        } on MissingStubError {}
      });
      test("then throw $MissingStubError on non null method not stubbed", () {
        try {
          useCaseNotRelaxed.test(0);
        } on MissingStubError {
        } on TypeError {
          fail("did not expect $TypeError");
        }
      });
    });
  });
}
