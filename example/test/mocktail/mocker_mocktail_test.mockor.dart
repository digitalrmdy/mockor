// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: non_constant_identifier_names

part of 'mocker_mocktail_test.dart';

// **************************************************************************
// MockerGenerator
// **************************************************************************

dynamic _$_mock<T extends Object>({bool? relaxed, bool? relaxedVoid}) {
  relaxed ??= true;
  relaxedVoid ??= relaxed;
  switch (T) {
    case MockerMocktailUseCase:
      final mock = _$MockMockerMocktailUseCase();
      if (!relaxed || relaxedVoid) {
        throwOnMissingStub(mock,
            exceptionBuilder: relaxedVoid
                ? (env) =>
                    _$MockerMocktailUseCaseExceptionBuilder(env, relaxed!)
                : null);
      }
      return mock;
    default:
      throw UnimplementedError(
          '''Error, a mock class for '$T' has not been generated yet.
Navigate to the '_mock' method and add the type to the types list in the 'GenerateMocker' annotation.
Finally run the build command: 'flutter packages pub run build_runner build'.''');
  }
}

class _$MockMockerMocktailUseCase extends Mock
    implements MockerMocktailUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    try {
      return super.noSuchMethod(invocation);
    } on MissingFutureVoidStubException {
      return Future<void>.value();
    } on MissingNullStubException {
      return null;
    }
  }
}

void _$registerFallbackValues() {
  registerFallbackValue(_$Mock_Model2());
  registerFallbackValue(_$MockMockerMocktailUseCase());
  registerFallbackValue(_$MockModel6());
}

class _$Mock_Model2 extends Mock implements _Model2 {}

class _$MockModel6 extends Mock implements Model6 {}

void _$MockerMocktailUseCaseExceptionBuilder(Invocation inv, bool relaxed) {
  switch (inv.memberName) {
    case #test4:
    case #test5:
    case #test6:
    case #test7:
    case #test8:
    case #test9:
    case #testVoid:
    case #[]:
    case #[]=:
      return null;
    case #testFutureVoid:
    case #testFutureOrVoid:
      throw MissingFutureVoidStubException();
    default:
      relaxed ? throw MissingNullStubException() : throw MissingStubError(inv);
  }
}
