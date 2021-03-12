import 'package:mockito_builder_annotations/mockito_builder_annotations.dart';
import 'package:mockito/mockito.dart';

abstract class ExampleUseCase {
  int example();
}

abstract class ExampleUseCase2 {
  void example2();
}

@GenerateMocker([ExampleUseCase, ExampleUseCase2])
T mock<T>() => _$mock<T>();
