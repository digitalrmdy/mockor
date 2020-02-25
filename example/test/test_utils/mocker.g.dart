// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mocker.dart';

// **************************************************************************
// MockitoGenerator
// **************************************************************************

class _$MockExampleUseCase extends Mock implements ExampleUseCase {}

class _$MockExampleUseCase2 extends Mock implements ExampleUseCase2 {}

dynamic _$mock<T>({bool enableThrowOnMissingStub = false}) {
  switch (T) {
    case ExampleUseCase:
      final mock = _$MockExampleUseCase();
      if (enableThrowOnMissingStub) {
        throwOnMissingStub(mock);
      }
      return mock;
    case ExampleUseCase2:
      final mock = _$MockExampleUseCase2();
      if (enableThrowOnMissingStub) {
        throwOnMissingStub(mock);
      }
      return mock;
    default:
      throw UnimplementedError(
          '''Error, a mock class for '$T' has not been generated yet.
Navigate to the 'mock' method and add the type to the types list in the 'GenerateMocker' annotation.
Finally run the build command: 'flutter packages pub run build_runner build'.''');
  }
}
