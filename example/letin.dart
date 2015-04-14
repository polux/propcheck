// Copyright (c) 2015, Google Inc. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

// Author: Emilie Balland (emilie.balland@gmail.com)

import 'package:enumerators/enumerators.dart' as C;
import 'package:enumerators/combinators.dart' as C;
import 'package:vacuum_persistent/persistent.dart';

abstract class Term {
}

class Let extends Term {
  final int n;
  final App t;
  final Term body;

  Let(this.n, this.t, this.body);

  String toString() {
    return "let x$n = $t in $body";
  }
}

class Type {
  final List<String> argsTypes;
  final String returnType;
  
  Type(this.argsTypes, this.returnType);
  
  String toString() {
    return "${argsTypes.join(" x ")} -> $returnType";
  }
  
}

class App extends Term {
  final String f;
  final List<int> args;

  App(this.f, this.args);

  String toString() {
    return "$f(${args.map((i)=>"x$i").join(", ")})";
  }
}

class Sig {
  final PMap<String, Type> sig;
  
  Sig(this.sig);
  
  Iterable<String> functionsOfReturnType(String type) {
    List<String> res = [];
    for(final pair in sig) {
      if (pair.snd.returnType == type) res.add(pair.fst);
    }
    return res;
  }
  
  Type typeOf(String f) {
    return sig[f];
  }
  
  Iterable<String> allReturnTypes() {
    return sig.values.map((x) => x.returnType).toSet();
  }
  
}

class Env {
  final int nextvar;
  final PMap<String,LinkedList<int>> env;
  
  static final empty = new Env(0, new PMap());
  
  Env(this.nextvar, this.env);
 
  Env add(int v, String type) {
    return new Env(nextvar+1, env.assoc(type,new Cons(v, variablesOfType(type))));
  }
  
  LinkedList<int> variablesOfType(String type) {
   return env.get(type, new Nil());
  }
  
  int nextVar() {
    return nextvar; 
  }
  
  String toString() {
    return '$env';
  }
  
}

App app(String f, List<int> args) => new App(f, args);
Let let(int v, App t, Term body) => new Let(v, t, body);

rec(C.Enumeration f()) => new C.Enumeration(new C.Thunk(() => f().parts));

C.Enumeration<int> setOf(Iterable<int> args) {
  var res = C.empty();
  for (int i in args) {
    res += C.singleton(i);
  }
  return res;
}

C.Enumeration<App> apps(Sig sig, Env env) {
  var res = C.empty();
  for (final type in sig.allReturnTypes()) {
    res += appsOfType(sig, env, type);
  }
  return res;
}

C.Enumeration<Let> lets(Sig sig, Env env) {
  var res = C.empty();
  for (final type in sig.allReturnTypes()) {
    final v = env.nextvar;
    res += C.apply(let, C.singleton(v), appsOfType(sig, env, type), rec(() => terms(sig, env.add(v, type)).pay()));
  }
  return res;
}

C.Enumeration<App> appsOfType(Sig sig, Env env, String returnType) {
  var res = C.empty();
  for (final fun in sig.functionsOfReturnType(returnType)) {
    final args = [];
    for (String type in sig.typeOf(fun).argsTypes) {
      args.add(setOf(env.variablesOfType(type)));
    }
    res += C.apply(app, C.singleton(fun), C.productsOf(args));
  }
  return res;
}

C.Enumeration<Term> terms(Sig sig, Env env) {
  //print(env);
  return apps(sig, env) + lets(sig, env);
}

main() {
  final nat = 'nat';
  final boolean = 'boolean';
  final unit = 'unit';
  Sig sig = new Sig( new PMap.fromMap({
    'zero': new Type([], nat), 
    'succ': new Type([nat], nat),
    'greaterThan':new Type([nat, nat], boolean),
    'or': new Type([boolean, boolean], boolean),
    'print':new Type([nat], unit)}));
  terms(sig, Env.empty).parts[3].forEach(print);
}