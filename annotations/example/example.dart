import 'package:mockito_builder_annotations/mockito_builder_annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'mocker.mocks.dart';

abstract class ExampleUseCase {
  int example();
}

abstract class ExampleUseCase2 {
  void example2();
}

const List<Type> _types = [ExampleUseCase, ExampleUseCase2];
@GenerateMocker(_types)
@GenerateMocks(_types)
T mock<T>() => _$mock<T>();
