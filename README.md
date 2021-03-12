[![Pub Package](https://img.shields.io/pub/v/mockito_builder.svg)](https://pub.dev/packages/mockito_builder)

Generate Flutter [mockito](https://pub.dev/packages/mockito) mocks and mock method with a list of types to be mocked.

## Getting Started

### Add the dependency

Add the `mockito_builder` to your dev_dependencies. And [`mockito_builder_annotations`](https://pub.dev/packages/mocktio_builder_annotations) to dependencies.

```yaml
dependencies:
  mockito_builder_annotations: ^0.2.2
dev_dependencies:
  mockito_builder: ^0.2.2

```

### Add a `mocker.dart` file in your test folder and a mock method with a [`@GenerateMocker`](https://pub.dev/packages/mocktio_builder_annotations) annotation. Don't forget to import [mockito](https://pub.dev/packages/mockito) here.


```dart

import 'package:mockito_builder/mockito_builder.dart';
import 'domain/navigation/navigation_service.dart';
import 'domain/usecases/register_user_use_case.dart';
///make sure to import the mockito package because the generated code depends on it.
import 'package:mockito/mockito.dart';

part 'mocker.g.dart';

///this will generate a `mocker.g.dart` file.
///specify the classes that should be mocked. 
@GenerateMocker([RegisterUserUseCase, NavigationService])
///define a method without any paramters and one type paramter. 
///an implementation of the method will be generated with a _$ prefix.
T mock<T>() => _$mock<T>();
```

### To use the generated mocks, simply import and call the defined mock function

```dart
import '../../mocker.dart';
import 'domain/navigation/navigation_service.dart';
import 'domain/usecases/register_user_use_case.dart';

void main() {
  RegisterUserUseCase registerUserUseCase;
  NavigationService navigationService;
  RegisterViewModel viewModel;

  setUp(() {
    registerUserUseCase = mock();
    navigationService = mock();
    viewModel = RegisterViewModelImpl(registerUserUseCase, navigationService);
  });
  
  ...
  
}
```

for more info check out the [example](https://github.com/digitalrmdy/mockito-builder/tree/master/example) module.
