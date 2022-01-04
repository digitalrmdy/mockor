import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

abstract class TestUseCase {
  Future<void> futureVoidTest();
}

class TestMock extends Mock implements TestUseCase {
  @override
  noSuchMethod(Invocation invocation) {
    try {
      return super.noSuchMethod(invocation);
    } on FutureVoidException {
      return Future<void>.value();
    }
  }
}

class FutureVoidException implements Exception {}

void main() {
  test("test with exception handler", () async {
    final mock = TestMock();
    throwOnMissingStub(mock, exceptionBuilder: (inv) {
      switch (inv.memberName) {
        case #futureVoidTest:
          throw FutureVoidException();
        default:
          throw MissingStubError(inv);
      }
    });
    await mock.futureVoidTest();
  });

  test("test without exception handler", () async {
    final mock = TestMock();
    try {
      await mock.futureVoidTest();
      fail("expected exception");
    } on TypeError {}
  });

  test("test with default exception handler", () async {
    final mock = TestMock();
    throwOnMissingStub(mock);
    try {
      await mock.futureVoidTest();
      fail("expected exception");
    } on MissingStubError {}
  });
}
