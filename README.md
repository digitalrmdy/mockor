# mockor

Generic mocker method generator for [mockito](https://pub.dev/packages/mockito) or [mocktail](https://pub.dev/packages/mocktail).
One `mock` method to mock any class just like in the original [mockito](https://site.mockito.org/). 

[![Pub Package](https://img.shields.io/pub/v/mockor.svg)](https://pub.dev/packages/mockor).

## Getting Started

### Add the dependencies

```yaml
dev_dependencies:
  mockor: ^1.0.0

```

Don't forget to add the mockito dependency.

### Add a `mocker.dart` file in your test folder and a mock method with a `@GenerateMocker` annotation. Don't forget to import [mockito](https://pub.dev/packages/mockito) here.


```dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// This import is used by the generated mockor file to add Mockito's `@GenerateMocks` annotation.
// This need to be added manually.
import 'package:mockito/annotations.dart';

// <file_name>.mocks.dart will be generated by Mockito which contain all the generated mocks.
// This needs to be added manually.
import 'example.mocks.dart';
import 'package:mockor/annotations.dart';

part 'example.mockor.dart';

abstract class ExampleUseCase {
  int example(int i);
}

abstract class ExampleUseCase2 {
  void example2();
}

@GenerateMocker([
  ExampleUseCase,
  ExampleUseCase2,
])
T mock<T>() => _$mock<T>();
```

### To use the generated mocks, simply import and call the defined mock function

```dart
import '../../mocker.dart';

void main() {
  late ExampleUseCase exampleUseCase;
  late ExampleUseCase2 exampleUseCase2;

  setUp(() {
    // this will return [MockExampleUseCase]
    exampleUseCase = mock();
    exampleUseCase2 = mock();
  });
}
```

for more info check out the [example](https://github.com/digitalrmdy/mockito-builder/tree/master/example) module.

## Getting Started Mocktail
### Follow steps like before with slight modifications to the `@GenerateMocker` annotation
```dart

@GenerateMocker(
  [
    ExampleUseCase,
    ExampleUseCase2,
  ],
  generateMockExtensions: false,
  generateMockitoAnnotation: false,
  useMockitoGeneratedTypes: false,
)
T mock<T>() => _$_mock<T>();

```
## Advantages Over Vanilla Mockito (5.0.0+)

- No references to generated code in any of your tests
- Always work with the original type:
    - Renaming the class will not break tests.
    - Find usages will give a more accurate view where it's used.

