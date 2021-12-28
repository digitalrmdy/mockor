import 'package:flutter_test/flutter_test.dart';
import 'package:mockor/annotations.dart';
import 'package:mocktail/mocktail.dart';
part 'mocker_mocktail.mockor.dart';

abstract class MockerMocktailUseCase {
  int test(int i);
}

@GenerateMocker(
  [MockerMocktailUseCase],
  generateMockExtensions: false,
  generateMockitoAnnotation: false,
  useMockitoGeneratedTypes: false,
)
T _mock<T>() => _$_mock<T>();

void main() {
  late MockerMocktailUseCase useCase;
  setUp(() {
    useCase = _mock();
  });
  test("mocktail test", () {
    when(() => useCase.test(any())).thenReturn(1);
    expect(useCase.test(2), 1);
  });
}
