// Copyright (c) 2012, Google Inc. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

// Author: Paul Brauner (polux@google.com)

library demo;

import 'dart:collection';
import 'package:propcheck/propcheck.dart';
import 'package:enumerators/combinators.dart' as c;
import 'package:unittest/unittest.dart';

// Defines append and reverse.
part 'demolib.dart';

/* --- The properties to test --- */

// This should hold for any sound implementation of reverse and append.
bool good(List xs, List ys) =>
    Arrays.areEqual(reverse(append(xs, ys)),
                    append(reverse(ys), reverse(xs)));

// This should NOT hold for any sound implementation of reverse and append.
bool bad(List xs, List ys) =>
    Arrays.areEqual(reverse(append(xs, ys)),
                    append(reverse(xs), reverse(ys)));

/* --- How we test them --- */

main() {
  // We define an enumeration of lists of integers.
  final boolsLists = c.listsOf(c.bools);

  // 'good' and 'bad' take 2 arguments each so we use forall2.
  Property goodProperty = forall2(boolsLists, boolsLists, good);
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
