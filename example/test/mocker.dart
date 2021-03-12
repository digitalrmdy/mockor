import 'package:example/example.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito_builder_annotations/mockito_builder_annotations.dart';

part 'mocker.g.dart';

@GenerateMocker([ExampleUseCase, ExampleUseCase2])
T mock<T>() => _$mock<T>();
