// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: non_constant_identifier_names

part of 'example_test.dart';

// **************************************************************************
// MockerGenerator
// **************************************************************************

@GenerateMocks([], customMocks: [
  MockSpec<ExampleUseCase>(
    as: #MockExampleUseCase,
    returnNullOnMissingStub: true,
  ),
  MockSpec<ExampleUseCase2>(
    as: #MockExampleUseCase2,
    returnNullOnMissingStub: true,
  ),
  MockSpec<ModelA.Model>(
    as: #MockModelAModel,
    returnNullOnMissingStub: true,
  ),
  MockSpec<ModelB.Model>(
    as: #MockModelBModel,
    returnNullOnMissingStub: true,
  ),
])
dynamic _$_mock<T extends Object>({bool? relaxed}) {
  relaxed ??= false;
  switch (T) {
    case ExampleUseCase:
      final mock = MockExampleUseCase();
      if (!relaxed) {
        throwOnMissingStub(mock);
      }
      return mock;
    case ExampleUseCase2:
      final mock = MockExampleUseCase2();
      if (!relaxed) {
        throwOnMissingStub(mock);
      }
      return mock;
    case ModelA.Model:
      final mock = MockModelAModel();
      if (!relaxed) {
        throwOnMissingStub(mock);
      }
      return mock;
    case ModelB.Model:
      final mock = MockModelBModel();
      if (!relaxed) {
        throwOnMissingStub(mock);
      }
      return mock;
    default:
      throw UnimplementedError(
          '''Error, a mock class for '$T' has not been generated yet.
Navigate to the '_mock' method and add the type to the types list in the 'GenerateMocker' annotation.
Finally run the build command: 'flutter packages pub run build_runner build'.''');
  }
}

extension ExampleUseCaseAsMockExtension on ExampleUseCase {
  MockExampleUseCase asMock() => this as MockExampleUseCase;
}

extension ExampleUseCase2AsMockExtension on ExampleUseCase2 {
  MockExampleUseCase2 asMock() => this as MockExampleUseCase2;
}

extension ModelAModelAsMockExtension on ModelA.Model {
  MockModelAModel asMock() => this as MockModelAModel;
}

extension ModelBModelAsMockExtension on ModelB.Model {
  MockModelBModel asMock() => this as MockModelBModel;
}
