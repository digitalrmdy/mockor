// Copyright 2019 Dart Mockito authors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
import 'dart:collection';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:path/path.dart' as p;

/// Returns a library which exports [element], selecting from the imports of
/// [inputLibraries] (and all exported libraries).
///
/// If [element] is not exported by any libraries in this set, then
/// [element]'s declaring library is returned.
LibraryElement _findExportOf(
    Iterable<LibraryElement> inputLibraries, Element element) {
  final elementName = element.name;
  if (elementName == null) {
    return element.library!;
  }

  final libraries = Queue.of([
    for (final library in inputLibraries) ...library.importedLibraries,
  ]);

  for (final library in libraries) {
    if (library.exportNamespace.get(elementName) == element) {
      return library;
    }
  }
  return element.library!;
}

Future<Map<InterfaceType, String>> resolveAssetUris(
    {required List<InterfaceType> dartTypes,
    required String entryAssetPath,
    required Resolver resolver}) async {
  final librariesWithTypes = <LibraryElement>{};
  final seenTypes = <InterfaceType>{};

  final typeUris = <InterfaceType, String>{};
  void addTypesFrom(InterfaceType type) {
    // Prevent infinite recursion.
    if (seenTypes.contains(type)) {
      return;
    }
    seenTypes.add(type);
    librariesWithTypes.add(type.element.library);
    // For a type like `Foo<Bar>`, add the `Bar`.
    type.typeArguments.whereType<InterfaceType>().forEach(addTypesFrom);
    // For a type like `Foo extends Bar<Baz>`, add the `Baz`.
    for (var supertype in type.allSupertypes) {
      addTypesFrom(supertype);
    }
  }

  for (var type in dartTypes) {
    addTypesFrom(type);
  }
  for (final type in dartTypes) {
    final element = type.element;
    final elementLibrary = element.library;
    final elementLibraryName = elementLibrary.name ?? '';
    if (elementLibrary.isInSdk && !elementLibraryName.startsWith('dart._')) {
      // For public SDK libraries, just use the source URI.
      typeUris[type] = elementLibrary.source.uri.toString();
      continue;
    }
    final exportingLibrary = _findExportOf(librariesWithTypes, element);

    try {
      final typeAssetId = await resolver.assetIdForElement(exportingLibrary);

      if (typeAssetId.path.startsWith('lib/')) {
        typeUris[type] = typeAssetId.uri.toString();
      } else {
        typeUris[type] =
            p.relative(typeAssetId.path, from: p.dirname(entryAssetPath));
      }
    } on UnresolvableAssetException {
      // Asset may be in a summary.
      typeUris[type] = exportingLibrary.source.uri.toString();
    }
  }
  return typeUris;
}
