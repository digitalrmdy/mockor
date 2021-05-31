abstract class ExampleUseCase {
  int example();

  factory ExampleUseCase() => ExampleUseCaseImpl();
}

class ExampleUseCaseImpl implements ExampleUseCase {
  @override
  int example() => 1;
}

abstract class ExampleUseCase2 {
  void example2();

  factory ExampleUseCase2() => ExampleUseCase2Impl();
}

class ExampleUseCase2Impl implements ExampleUseCase2 {
  @override
  void example2() {
    print('example2');
  }
}
