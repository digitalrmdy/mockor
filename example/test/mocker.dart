import 'package:example/example.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito_builder_annotations/mockito_builder_annotations.dart';
import 'mocker.mocks.dart';
part 'mocker.g.dart';

const List<Type> _types = [ExampleUseCase, ExampleUseCase2];

@GenerateMocker(_types)
@GenerateMocks(_types)
T mock<T>() => _$mock<T>();
