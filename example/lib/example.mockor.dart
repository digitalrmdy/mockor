// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: non_constant_identifier_names

part of 'example.dart';

// **************************************************************************
// MockerGenerator
// **************************************************************************

@GenerateNiceMocks([
  MockSpec<ExampleUseCase>(
    as: #MockExampleUseCase,
  ),
  MockSpec<ExampleUseCase2>(
    as: #MockExampleUseCase2,
  ),
])
dynamic _$mock<T extends Object>({bool? relaxed}) {
  relaxed ??= false;
  switch (T) {
    case ExampleUseCase:
    case MockExampleUseCase:
      final mock = MockExampleUseCase();
      if (!relaxed) {
        throwOnMissingStub(mock);
      }
      return mock;
    case ExampleUseCase2:
    case MockExampleUseCase2:
      final mock = MockExampleUseCase2();
      if (!relaxed) {
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

extension ExampleUseCaseAsMockExtension on ExampleUseCase {
  MockExampleUseCase asMock() => this as MockExampleUseCase;
}

extension ExampleUseCase2AsMockExtension on ExampleUseCase2 {
  MockExampleUseCase2 asMock() => this as MockExampleUseCase2;
}
