/// Configuration for using `package:build`-compatible build systems.
///
/// See:
/// * [build_runner](https://pub.dev/packages/build_runner)
///
/// This library is **not** intended to be imported by typical end-users unless
/// you are creating a custom compilation pipeline. See documentation for
/// details, and `build.yaml` for how these builders are configured by default.
library mockito_builder.builder;

import 'package:build/build.dart';
import 'package:mockito_builder/src/generators/mockito_generator.dart';
import 'package:source_gen/source_gen.dart';

/// Supports `package:build_runner` creation and configuration of
/// `mockito_builder`.
///
/// Not meant to be invoked by hand-authored code.
Builder mockitoBuilder(BuilderOptions builderOptions) => PartBuilder(
      const [MockitoGenerator()],
      '.g.dart',
      header: '''
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: non_constant_identifier_names
    ''',
    );
