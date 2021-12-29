import 'package:flutter_test/flutter_test.dart';
import 'package:mockor/annotations.dart';
import 'package:mocktail/mocktail.dart';
part 'mocker_mocktail.mockor.dart';

abstract class MockerMocktailUseCase {
  int test(int i);
  _Model test2(_Model model);
  _Model2 test3(_Model2 model);
}

class _Model {}

class _Model2 {}

@GenerateMocker(
  [MockerMocktailUseCase],
  generateMockExtensions: false,
  generateMockitoAnnotation: false,
  useMockitoGeneratedTypes: false,
  generateMocktailFallbackValues: GenerateMocktailFallbackValues([_Model2]),
)
T _mock<T extends Object>() => _$_mock<T>();

void registerFallbackValuesAll() {
  _$registerFallbackValues();
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
