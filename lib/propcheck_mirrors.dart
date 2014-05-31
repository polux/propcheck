// Copyright (c) 2014, Google Inc. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

// Author: Paul Brauner (polux@google.com)

library propcheck_mirrors;

import 'dart:mirrors';
import 'package:enumerators/enumerators.dart' as enumerators;
import 'package:enumerators/combinators.dart' as combinators;
import 'package:propcheck/propcheck.dart';

export 'package:propcheck/propcheck.dart';

final TypeMirror _BOOL_TYPE = reflectClass(bool);
final TypeMirror _INT_TYPE = reflectClass(int);
final TypeMirror _STRING_TYPE = reflectClass(String);
final TypeMirror _LIST_TYPE = reflectClass(List);
final TypeMirror _SET_TYPE = reflectClass(Set);
final TypeMirror _MAP_TYPE = reflectClass(Map);

enumerators.Enumeration enumerationForTypeMirror(TypeMirror typeMirror) {
  if (typeMirror == _INT_TYPE) {
    return combinators.ints;
  } else if (typeMirror == _BOOL_TYPE) {
    return combinators.bools;
  } else if (typeMirror == _STRING_TYPE) {
    return combinators.strings;
  } else {
    final original = typeMirror.originalDeclaration;
    if (original == _LIST_TYPE) {
      return combinators.listsOf(
          enumerationForTypeMirror(typeMirror.typeArguments[0]));
    } else if (original == _SET_TYPE) {
      return combinators.setsOf(
          enumerationForTypeMirror(typeMirror.typeArguments[0]));
    } else if (original == _MAP_TYPE) {
      return combinators.mapsOf(
          enumerationForTypeMirror(typeMirror.typeArguments[0]),
          enumerationForTypeMirror(typeMirror.typeArguments[1]));
    }
  }
  throw new ArgumentError("cannot generate an enumeration for $typeMirror");
}

Property property(Function f) {
  ClosureMirror closureMirror = reflect(f);
  final enumerations = closureMirror.function.parameters
      .map((parameter) => enumerationForTypeMirror(parameter.type))
      .toList();
  return forallN(enumerations, (args) => closureMirror.apply(args).reflectee);
}
