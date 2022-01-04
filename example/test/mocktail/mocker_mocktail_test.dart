import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockor/mockor.dart';
import 'package:mocktail/mocktail.dart';

import 'mocker_mocktail_test.fallback.dart';
import '../models/model_a.dart' as ModelA;
import '../models/model_b.dart' as ModelB;
part 'mocker_mocktail_test.mockor.dart';

abstract class MockerMocktailUseCase {
  int test(int i);
  _Model test2(_Model model);
  _Model2 test3(_Model2 model);
  void test4(Model3 model3);
  void test5({required Model3 model3});
  void test6({Model4? model4});
  void test7(Model5<Model4> model5);
  void test8(ModelA.Model modelA, ModelB.Model modelB);
  void test9(Model6 model6);
  void testVoid(int? i);
  int? testNullable();
  Future<void> testFutureVoid();
  FutureOr<void> testFutureOrVoid();
  dynamic testDynamic();
  void operator [](String key);
  void operator []=(String key, String value);
}

class _Model {}

class _Model2 {}

class Model3 {}

class Model4 {}

class Model5<T> {}

class Model6 {}

@GenerateMocker.mocktail(
  [MockerMocktailUseCase],
  generateMocktailFallbackValues: GenerateMocktailFallbackValues(
    [_Model2, MockerMocktailUseCase, Model6],
    autoDetect: true,
  ),
)
T _mock<T extends Object>({bool relaxed = false, bool? relaxedVoid}) =>
    _$_mock<T>(
      relaxed: relaxed,
      relaxedVoid: relaxedVoid ?? relaxed,
    );

void registerFallbackValuesAll() {
  _$registerFallbackValues();
  registerFallbackValuesAutoDetected();
}

void main() {
  group("general", () {
    late MockerMocktailUseCase useCase;
    setUp(() {
      useCase = _mock(relaxed: true, relaxedVoid: false);
    });
    test("`when` with any() doesn't crash and works as expected", () {
      when(() => useCase.test(any())).thenReturn(1);
      expect(useCase.test(2), 1);
    });
    test("any() with custom class doesn't work without registerFallbackValue",
        () {
      final model = _Model();
      try {
        when(() => useCase.test2(any())).thenReturn(model);
        fail("expected exception");
      } catch (ex) {}
    });
    test("any() with custom class works with registerFallbackValue", () {
      final model = _Model2();
      when(() => useCase.test3(any())).thenReturn(model);
      expect(useCase.test3(_Model2()), model);
    });
  });
  group("relaxed", () {
    group("given relaxed is true and relaxedVoid is false", () {
      late MockerMocktailUseCase useCase;
      setUp(() {
        useCase = _mock(relaxed: true, relaxedVoid: false);
      });
      test("then don't throw exception on bracket operator", () {
        useCase[""];
      });
      test("then don't throw exception on bracket assign operator", () {
        useCase[""] = "";
      });
      test("then don't throw exception on nullable method not stubbed", () {
        useCase.testVoid(0);
      });
      test("then throw $TypeError on non null method not stubbed", () {
        try {
          useCase.test(0);
        } on TypeError {
        } on MissingStubError {
          fail("did not expect $MissingStubError");
        }
      });
      test("then throw $TypeError on Future<void> method not stubbed",
          () async {
        try {
          await useCase.testFutureVoid();
          fail("expected exception");
        } on MissingStubError {
          fail("did not expect $MissingStubError");
        } on TypeError {}
      });
    });
    group("given relaxed is false and relaxedVoid is true", () {
      late MockerMocktailUseCase useCase;
      setUp(() {
        useCase = _mock(relaxed: false, relaxedVoid: true);
      });
      test("then throw exception on nullable method not stubbed", () {
        try {
          useCase.testNullable();
          fail("expected exception");
        } on MissingStubError {}
      });
      test("then don't throw exception on void method not stubbed", () {
        useCase.testVoid(0);
      });
      test("then throw missing stub error on non null method not stubbed", () {
        try {
          useCase.test(0);
        } on TypeError {
          fail("did not expect $TypeError");
        } on MissingStubError {}
      });
      test("then don't throw exception on Future<void> method not stubbed",
          () async {
        try {
          await useCase.testFutureVoid();
        } on TypeError {
          fail("did not expect $TypeError");
        }
      });
    });
    group("given relaxed is false and relaxedVoid is false", () {
      late MockerMocktailUseCase useCase;
      setUp(() {
        useCase = _mock(relaxed: false, relaxedVoid: false);
      });
      test("then throw $MissingStubError on nullable method not stubbed", () {
        try {
          useCase.testVoid(0);
          fail("expected $MissingStubError");
        } on MissingStubError {}
      });
      test("then throw $MissingStubError on non null method not stubbed", () {
        try {
          useCase.test(0);
        } on MissingStubError {
        } on TypeError {
          fail("did not expect $TypeError");
        }
      });

      test("then throw exception on Future<void> method not stubbed", () async {
        try {
          await useCase.testFutureVoid();
          fail("expected exception");
        } on TypeError {
          fail("did not expect $TypeError");
        } on MissingStubError {}
      });
    });
    group("given relaxed is true and relaxedVoid is true", () {
      late MockerMocktailUseCase useCase;
      setUp(() {
        useCase = _mock(relaxed: true, relaxedVoid: true);
      });
      test("then don't throw exception on bracket operator", () {
        useCase[""];
      });
      test("then don't throw exception on bracket assign operator", () {
        useCase[""] = "";
      });
      test("then don't throw exception on nullable method not stubbed", () {
        useCase.testVoid(0);
      });
      test("then throw $TypeError on non null method not stubbed", () {
        try {
          useCase.test(0);
        } on TypeError {
        } on MissingStubError {
          fail("did not expect $MissingStubError");
        }
      });
      test("then don't throw exception on Future<void> method not stubbed",
          () async {
        await useCase.testFutureVoid();
      });
    });
  });
}
