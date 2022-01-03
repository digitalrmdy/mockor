import 'package:flutter_test/flutter_test.dart';
import 'package:mockor/annotations.dart';
import 'package:mocktail/mocktail.dart';

import 'mocker_mocktail.fallback.dart';
import 'models/model_a.dart' as ModelA;
import 'models/model_b.dart' as ModelB;
part 'mocker_mocktail.mockor.dart';

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
T _mock<T extends Object>() => _$_mock<T>();

void registerFallbackValuesAll() {
  _$registerFallbackValues();
  registerFallbackValuesAutoDetected();
}

void main() {
  late MockerMocktailUseCase useCase;
  setUpAll(() {
    registerFallbackValuesAll();
  });
  setUp(() {
    useCase = _mock();
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
}
