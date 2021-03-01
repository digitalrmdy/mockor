// GENERATED CODE - DO NOT MODIFY BY HAND

part of example;

// **************************************************************************
// MockitoGenerator
// **************************************************************************

class _$MockExampleUseCase extends Mock implements ExampleUseCase {}

class _$MockExampleUseCase2 extends Mock implements ExampleUseCase2 {}

dynamic _$mock<T>() {
  switch (T) {
    case ExampleUseCase:
      return _$MockExampleUseCase();
    case ExampleUseCase2:
      return _$MockExampleUseCase2();
    default:
      throw UnimplementedError(
          '''Error, a mock class for '$T' has not been generated yet.
Navigate to the 'mock' method and add the type to the types list in the 'GenerateMocker' annotation.
Finally run the build command: 'flutter packages pub run build_runner build'.''');
  }
}
