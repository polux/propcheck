// Copyright (c) 2015, Google Inc. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

// Author: Paul Brauner (polux@google.com)

import 'package:enumerators/enumerators.dart' as C;
import 'package:enumerators/combinators.dart' as C;

abstract class Term {
  String prettyForDepth(int depth);
  String toString() => prettyForDepth(0);
}

class Var extends Term {
  final int n;

  Var(this.n);

  @override
  String prettyForDepth(int depth) {
    return "x${depth-n-1}";
  }
}

class Lam extends Term {
  final Term t;

  Lam(this.t);

  @override
  String prettyForDepth(int depth) {
    return "\\x${depth} -> ${t.prettyForDepth(depth+1)}";
  }
}

class App extends Term {
  final Term t1;
  final Term t2;

  App(this.t1, this.t2);

  @override
  String prettyForDepth(int depth) {
    return "(${t1.prettyForDepth(depth)}) (${t2.prettyForDepth(depth)})";
  }
}

Term lam(Term t) => new Lam(t);
Term app(Term t1, Term t2) => new App(t1, t2);
Term v(int n) => new Var(n);

rec(C.Enumeration f()) => new C.Enumeration(new C.Thunk(() => f().parts));

final C.Enumeration<Term> terms = termsForDepth(0);

C.Enumeration<int> intsBetween(int min, int max) {
  var res = C.empty();
  for (int i = min; i < max; i++) {
    res += C.singleton(i);
  }
  return res;
}

final memo = <int, C.Enumeration<Term>>{};

C.Enumeration<Term> termsForDepth(int depth) {
  return memo.putIfAbsent(depth, () => _termsForDepth(depth));
}

C.Enumeration<Term> _termsForDepth(int depth) {
  final rec0 = rec(() => termsForDepth(depth)).pay();
  final rec1 = rec(() => termsForDepth(depth + 1)).pay();
  return C.apply(v, intsBetween(0, depth))
       + C.apply(lam, rec1)
       + C.apply(app, rec0, rec0);
}

main() {
  terms.parts[10].forEach(print);
}