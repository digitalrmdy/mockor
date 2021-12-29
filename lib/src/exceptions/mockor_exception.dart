///Exception that will be thrown on validation errors
class MockorException implements Exception {
  final String cause;

  MockorException(this.cause);

  @override
  String toString() {
    return '$runtimeType: $cause';
  }
}

void error(String message) {
  throw MockorException(message);
}
