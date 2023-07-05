import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:mockor/mockor.dart';
import 'package:mockor/src/exceptions/mockor_exception.dart';
import 'package:mockor/src/models/models.dart';
import 'package:source_gen/source_gen.dart';

ConstantReader readParam(ConstantReader annotation, String parameter) {
  final reader = annotation.read(parameter);
  if (reader.isNull) {
    throw ArgumentError.notNull('$parameter');
  }
  return reader;
}

DartObject? readParamInsideNestedObject(ConstantReader annotation,
    {String parameter = "generateMocktailFallbackValues", required String nestedParameter}) {
  final reader = annotation.read(parameter);
  if (reader.isNull) {
    return null;
  }
  return reader.objectValue.getField(nestedParameter);
}

Future<List<ResolvedType>> readDartTypesParam(
    ConstantReader annotation, ImportAliasTable importAliasTable) {
  return readParam(annotation, "types")
      .listValue
      .map((x) => x.toTypeValue())
      .toList()
      .nonNullUniqueDartTypesOrThrow(importAliasTable, attributeName: "$GenerateMocker.types");
}

extension NullableListExtension<T> on List<T?> {
  // ignore: unused_element
  List<T> filterNotNull() => where((element) => element != null).cast<T>().toList();
}

extension FutureListExtension<T> on List<Future<T>> {
  // ignore: unused_element
  Future<List<T>> toFuture() => Stream.fromFutures(this).toList();
}

void validateDartType(DartType dartType, onError(String message)) {
  if (dartType is DynamicType) {
    onError("cannot mock `dynamic`");
  }
  if (dartType.alias?.element != null) {
    onError("cannot mock a typedef");
  }
  final element = dartType.element;
  if (element == null) {
    onError("could not obtain element");
  } else {
    final library = element.library;
    if (library == null) {
      onError("could not obtain library element");
    } else {
      final typeProvider = library.typeProvider;
      if (element is ClassElement) {
        if (typeProvider.isNonSubtypableClass(element)) {
          onError("This type is non-subtypable so cannot be mocked");
        }
      }
      if (!(dartType is InterfaceType)) {
        onError("This type is not an interface type so cannot be mocked");
      }
    }
  }
}

class ClassName {
  final InterfaceType dartType;
  final String name;
  final String librarySource;

  ClassName(this.dartType, this.name, this.librarySource);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClassName &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          librarySource == other.librarySource;

  @override
  int get hashCode => name.hashCode ^ librarySource.hashCode;

  @override
  String toString() {
    return name;
  }
}

extension on InterfaceType {
  ClassName toClassName() {
    return ClassName(this, element.name, element.librarySource.toString());
  }
}

class ImportAliasTable {
  final Map<String, String> _importAliasMap;

  ImportAliasTable(this._importAliasMap);

  String? operator [](String import) {
    return _importAliasMap[import];
  }

  factory ImportAliasTable.fromElement(Element element) {
    final table = <String, String>{};
    element.library?.libraryImports.forEach((importElement) {
      final prefix = importElement.prefix?.element.name;
      if (prefix != null) {
        final import = importElement.importedLibrary?.source.toString();
        if (import == null) {
          throw MockorException(
              "Could not resolve full library name for ${importElement.uri} in ${importElement.librarySource}");
        }
        table[import] = prefix;
      }
    });
    return ImportAliasTable(table);
  }

  factory ImportAliasTable.empty() => ImportAliasTable({});

  @override
  String toString() {
    return '_ImportAliasTable{_importAliasMap: $_importAliasMap}';
  }
}

extension DartTypeExtension on Iterable<DartType?> {
  Future<List<ResolvedType>> nonNullUniqueDartTypesOrThrow(ImportAliasTable importAliasTable,
      {required String attributeName}) async {
    forEachIndexed((i, type) {
      void errorF(String msg) => error(
          "Error with type ${type != null ? "`$type`" : ""} at position $i in 'types' argument: $msg");
      if (type == null) {
        errorF("this is not a type");
      } else {
        validateDartType(type, error);
      }
    });
    final nonNullDartTypes = where((element) => element != null)
        .cast<InterfaceType>()
        .map((e) => e.toClassName())
        .toList();
    final resolvedTypes = nonNullDartTypes
        .map((type) => ResolvedType(
            name: type.name,
            librarySource: type.librarySource,
            prefix: importAliasTable[type.librarySource],
            dartType: type.dartType))
        .toList();
    // check if resolvedTypes is unique
    resolvedTypes.forEach((type) {
      final occurrence = resolvedTypes.where((x) => x == type).length;
      if (occurrence > 1) {
        error("Identical type '$type' appears $occurrence times");
      }
    });
    return resolvedTypes;
  }
}

extension IterableExtension<T> on Iterable<T> {
  // ignore: unused_element
  Iterable<T> onEach(test(T e)) {
    forEach((element) {
      test(element);
    });
    return this;
  }

  // ignore: unused_element
  Iterable<T> onEachIndexed(test(int i, T e)) {
    var i = 0;
    forEach((element) {
      test(i, element);
      i++;
    });
    return this;
  }

  void forEachIndexed(void Function(int i, T item) block) {
    var i = 0;
    for (final item in this) {
      block(i, item);
      i++;
    }
  }

  T? firstOrNull({bool Function(T)? where}) {
    final test = where ?? (_) => true;
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

extension InterfaceTypeExtension on InterfaceType {
  List<ExecutableElement> findAllExecutableElements() {
    final list = <ExecutableElement>[];
    list.addAll(accessors);
    list.addAll(methods);
    allSupertypes.forEach((element) {
      list.addAll(element.findAllExecutableElements());
    });
    return list;
  }
}
