// Copyright (c) 2014, Google Inc. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

// Author: Paul Brauner (polux@google.com)

library propcheck_mirrors;

import 'dart:mirrors';
import 'package:collection/equality.dart';
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
  final name = MirrorSystem.getName(typeMirror.qualifiedName);
  throw new ArgumentError("cannot generate an enumeration for $name");
}

Property property(Function f) {
  ClosureMirror closureMirror = reflect(f);
  final enumerations = closureMirror.function.parameters
      .map((parameter) => enumerationForTypeMirror(parameter.type))
      .toList();
  return forallN(enumerations, (args) => closureMirror.apply(args).reflectee);
}

class _ConstructorCall {
  final int index;
  final List arguments;

  _ConstructorCall(this.index, this.arguments);

  toString() => "Constructor_${index}(${arguments.join(',')})";

  Object eval(ClassMirror classMirror, List<Symbol> constructors) {
    // TODO(polux): remove this hack once www.dartbug.com/11161 is fixed
    final ctorName = MirrorSystem.getName(constructors[index]);
    final dotIndex = ctorName.indexOf('.');
    final suffix = (dotIndex < 0) ? '' : ctorName.substring(dotIndex + 1);
    final ctorSymbol = MirrorSystem.getSymbol(suffix);
    return classMirror.newInstance(ctorSymbol, arguments).reflectee;
  }
}

class _MethodCall {
  final Symbol methodName;
  final List arguments;  // null means getter

  _MethodCall(this.methodName, this.arguments);

  toString() {
    final readableName = MirrorSystem.getName(methodName);
    return "${readableName}(${arguments.join(',')})";
  }

  Object eval(Object receiver) {
    return reflect(receiver).invoke(methodName, arguments).reflectee;
  }
}

class _Program {
  final _ConstructorCall constructorCall;
  final List<_MethodCall> methodCalls;

  _Program(this.constructorCall, this.methodCalls);

  List<_Result> eval(ClassMirror classMirror, List<Symbol> constructors) {
    try {
      final receiver = constructorCall.eval(classMirror, constructors);
      final trace = [];
      for (final methodCall in methodCalls) {
        var result = null;
        try {
          result = new _Value(methodCall.eval(receiver));
        } catch(e) {
          result = new _Issue(e);
        }
        trace.add(result);
      }
      return trace;
    } catch(e) {
      return [new _Issue(e)];
    }
  }

  toString() => ([constructorCall]..addAll(methodCalls)).toString();
}

abstract class _Result {}

class _Value implements _Result {
  final Object value;

  _Value(this.value);

  String toString() {
    return 'Value($value)';
  }

  bool operator ==(other) {
    return (other is _Value)
        && (value == other.value);
  }
}

class _Issue implements _Result {
  final Error error;

  _Issue(this.error);

  String toString() {
    return 'Issue($error)';
  }

  bool operator ==(other) {
    return (other is _Issue)
        && (error.toString() == other.error.toString());
  }
}

enumerators.Enumeration<List>
    _enumerationForSignature(List<TypeMirror> signature) {
  return combinators.productsOf(signature
      .map((parameter) => enumerationForTypeMirror(parameter))
      .toList());
}

List<List<TypeMirror>>
    _signatures(ClassMirror classMirror, List<Symbol> methods) {
  List<TypeMirror> parameterTypes(Symbol method) {
    return (classMirror.declarations[method] as MethodMirror)
        .parameters
        .map((parameter) => parameter.type)
        .toList();
  }
  return methods.map(parameterTypes).toList();
}

const _SIG_EQUALITY = const ListEquality(const ListEquality());
const _TRACE_EQUALITY = const ListEquality();

Property implementationMatchesModel(Type model,
                                    List<Symbol> modelConstructors,
                                    Type implem,
                                    List<Symbol> implemConstructors,
                                    List<Symbol> methodsToTest) {
  ClassMirror modelClass = reflectClass(model);
  ClassMirror implClass = reflectClass(implem);

  final modelCtorSignatures = _signatures(modelClass, modelConstructors);
  final implCtorSignatures = _signatures(implClass, implemConstructors);
  if (!_SIG_EQUALITY.equals(modelCtorSignatures, implCtorSignatures)) {
    throw new ArgumentError("the two lists of constructors don't match");
  }

  final modelMethodSignatures = _signatures(modelClass, methodsToTest);
  final implMethodSignatures = _signatures(implClass, methodsToTest);
  if (!_SIG_EQUALITY.equals(modelMethodSignatures, implMethodSignatures)) {
    throw new ArgumentError("the signatures of the methods don't match");
  }

  enumerators.Enumeration<_ConstructorCall> ctorCalls = enumerators.empty();
  for (int i = 0; i < modelCtorSignatures.length; i++) {
    ctorCalls += enumerators.apply(
        (args) => new _ConstructorCall(i, args),
        _enumerationForSignature(modelCtorSignatures[i]));
  }

  enumerators.Enumeration<_ConstructorCall> methodCalls = enumerators.empty();
  for (int i = 0; i < methodsToTest.length; i++) {
    methodCalls += enumerators.apply(
        (args) => new _MethodCall(methodsToTest[i], args),
        _enumerationForSignature(modelMethodSignatures[i]));
  }

  enumerators.Enumeration<_Program> programs =
      enumerators.apply(
          (ctorCall, methodCalls) => new _Program(ctorCall, methodCalls),
          ctorCalls,
          combinators.listsOf(methodCalls));

  return forall(programs, (program) {
    final modelTrace = program.eval(modelClass, modelConstructors);
    final implTrace = program.eval(implClass, implemConstructors);
    if (_TRACE_EQUALITY.equals(modelTrace, implTrace)) {
      return true;
    } else {
      print("model trace: $modelTrace");
      print("implem trace: $implTrace");
      return false;
    }
  });
}
