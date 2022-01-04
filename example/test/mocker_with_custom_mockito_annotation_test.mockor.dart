// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: non_constant_identifier_names

part of 'mocker_with_custom_mockito_annotation_test.dart';

// **************************************************************************
// MockerGenerator
// **************************************************************************

dynamic _$_mock<T extends Object>({bool? relaxed}) {
  relaxed ??= false;
  switch (T) {
    case MockerWithCustomMockitoUseCase:
      final mock = MockMockerWithCustomMockitoUseCase();
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

extension MockerWithCustomMockitoUseCaseAsMockExtension
    on MockerWithCustomMockitoUseCase {
  MockMockerWithCustomMockitoUseCase asMock() =>
      this as MockMockerWithCustomMockitoUseCase;
}
