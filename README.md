# mockito_builder

generate flutter mockito mocks.

## Getting Started

### Add the dependency

Add the mockito code generator to your dev dependencies.

```yaml
dev_dependencies:
  mockito_builder:
    git:
      url: https://github.com/digitalrmdy/mockito-builder.git

```

### Add a `mocker.dart` file in your test folder with a `@GenerateMocker` method.


```dart

import 'package:mockito_builder_annotations/mockito_builder_annotations.dart';
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

### To use the generated mocks, simple import and call the defined mock function

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

### Optional: throw exceptions on missing stubs

The `_$mock<T>()` method takes in an optional `bool` parameter named `enableThrowOnMissingStub`. This wraps the `Mock` object with the `throwOnMissingStub` method so that you get exceptions when you try to call a method that is not stubbed.


```dart
T mock<T>({bool throwOnMissingStub = false}) => _$mock<T>(enableThrowOnMissingStub: throwOnMissingStub);

var myService = mock<MyService>(throwOnMissingStub: true);
when(myService.doSomethingElse()).thenReturn(true);

myService.doSomething(); // this will throw an exception
myService.doSomethingElse(); // this will not throw an exception
```

For more info check out the example module.
