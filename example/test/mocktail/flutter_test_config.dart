import 'dart:async';
import 'package:flutter_test/flutter_test.dart';

import 'mocker_mocktail_test.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  // this will be executed before the main function of any test file in the test folder.
  setUpAll(() {
    registerFallbackValuesAll();
  });
  await testMain();
}
