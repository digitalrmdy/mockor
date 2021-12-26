/// Configuration for using `package:build`-compatible build systems.
///
/// See:
/// * [build_runner](https://pub.dev/packages/build_runner)
///
/// This library is **not** intended to be imported by typical end-users unless
/// you are creating a custom compilation pipeline. See documentation for
/// details, and `build.yaml` for how these builders are configured by default.
library mockor.builder;

import 'package:build/build.dart';
import 'package:mockor/src/generators/mocker_generator.dart';
import 'package:source_gen/source_gen.dart';

/// Supports `package:build_runner` creation and configuration of
/// `mockor`.
///
/// Not meant to be invoked by hand-authored code.
Builder mockor(BuilderOptions builderOptions) => PartBuilder(
      const [MockerGenerator()],
      '.mockor.dart',
      header: '''
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: non_constant_identifier_names
    ''',
    );
