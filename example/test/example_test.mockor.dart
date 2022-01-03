// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: non_constant_identifier_names

part of 'example_test.dart';

// **************************************************************************
// MockerGenerator
// **************************************************************************

@GenerateMocks([
  ExampleUseCase,
  ExampleUseCase2
], customMocks: [
  MockSpec<ModelA.Model>(
    as: #MockModelAModel,
  ),
  MockSpec<ModelB.Model>(
    as: #MockModelBModel,
  ),
])
dynamic _$_mock<T extends Object>() {
  switch (T) {
    case ExampleUseCase:
      return MockExampleUseCase();
    case ExampleUseCase2:
      return MockExampleUseCase2();
    case ModelA.Model:
      return MockModelAModel();
    case ModelB.Model:
      return MockModelBModel();
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
