import 'package:mockito_builder/mockito_builder.dart';

import '../usecase/example_use_case.dart';
import 'package:mockito/mockito.dart';

part 'mocker.g.dart';

@GenerateMocker([ExampleUseCase, ExampleUseCase2])
T mock<T>() => _$mock<T>();
