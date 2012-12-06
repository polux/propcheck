// Copyright (c) 2012, Google Inc. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

// Author: Paul Brauner (polux@google.com)

library demo;

import 'package:propcheck/propcheck.dart';
import 'package:enumerators/combinators.dart' as c;
import 'package:unittest/unittest.dart';

// Defines append and reverse.
part 'demolib.dart';

// We turn dart unittest's listEquals into a boolean function.
bool listEquals(List xs, List ys) {
  try { Expect.listEquals(xs, ys); return true; }
  catch (_) { return false; }
}

// This should hold for any sound implementation of reverse and append.
bool good(List xs, List ys) =>
  listEquals(reverse(append(xs, ys)),
             append(reverse(ys), reverse(xs)));

// This should NOT hold for any sound implementation of reverse and append.
// We usually don't want to test false properties, it is false for the sake of
// the presentation.
bool bad(List xs, List ys) =>
    listEquals(reverse(append(xs, ys)),
               append(reverse(xs), reverse(ys)));

main() {
  // We define an enumeration of lists of booleans.
  final boolsLists = c.listsOf(c.bools);

  // We declare the properties '∀x:List<bool>, ∀y:List<bool>, good(x,y)' and
  // '∀x:List<bool>, ∀y:List<bool>, bad(x,y)'. We use 'forall2' because 'good'
  // and 'bad' expect *two* arguments each. In 'goodProperty', the arguments of
  // 'good' are made explicit to hilight the similarity with the formula we
  // wish to represent, while 'badProperty' features a terser style.
  Property goodProperty = forall2(boolsLists, boolsLists, (x,y) => good(x,y));
  Property badProperty = forall2(boolsLists, boolsLists, bad);

  // We test the properties against *every* pair of lists of bools whose
  // combined size is <= 10.
  group('smallcheck', () {
    final sc = new SmallCheck(depth: 10);
    test('good', () => sc.check(goodProperty));
    test('bad', () => sc.check(badProperty));
  });

  // We test the properties against random pairs of lists of bools of combined
  // size 0, 1, ..., 300.
  group('quickcheck', () {
    final qc = new QuickCheck(maxSize: 300, seed: 42);
    test('good', () => qc.check(goodProperty));
    test('bad', () => qc.check(badProperty));
  });
}
