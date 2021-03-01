library mockito_builder;

export 'src/annotations/mockito_builder_annotation.dart';

import 'package:build/build.dart';
import 'package:mockito_builder/src/generators/mockito_generator.dart';
import 'package:source_gen/source_gen.dart';

Builder mockitoBuilder(BuilderOptions builderOptions) =>
    SharedPartBuilder(const [MockitoGenerator()], 'mockito_builder');
