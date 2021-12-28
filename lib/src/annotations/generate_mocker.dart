///the annotation to be place on your mock method.
class GenerateMocker {
  /// the types to generate Mock classes for
  final List<Type> types;

  /// if **true**, no mocks will be generated by this builder
  /// but will use the names of classes generated by Mockito.
  ///
  /// if **false**, simple one line mock classes will be generated
  /// which can be useful for Mocktail.
  ///
  /// **true** by default
  final bool useMockitoGeneratedTypes;

  /// if **true**, Mockito's own `@GenerateMocks` annotation will be added to
  /// the generated mock method. [useMockitoGeneratedTypes] must be **true** as well.
  ///
  /// if **false** but [useMockitoGeneratedTypes] is **true**,
  /// then you should include a `@GenerateMocks` to the mock method yourself.
  ///
  /// **true** by default
  final bool generateMockitoAnnotation;

  /// Generate an `asMock` extension method for all [types] which casts it as
  /// the generated mock type.
  /// Due to null safety we can only use the `any` matcher on non null params when using the mocked type.
  /// Please read Mockito's [Null Safety README](https://github.com/dart-lang/mockito/blob/master/NULL_SAFETY_README.md) for more info.
  ///
  /// **true** by default
  final bool generateMockExtensions;

  /// **false** by default
  final bool generateMocktailFallback;

  const GenerateMocker(
    this.types, {
    this.useMockitoGeneratedTypes = true,
    this.generateMockitoAnnotation = true,
    this.generateMockExtensions = true,
    this.generateMocktailFallback = false,
  });
}
