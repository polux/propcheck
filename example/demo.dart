// Copyright (c) 2012, Google Inc. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

// Author: Paul Brauner (polux@google.com)

library demo;

import 'demolib.dart';
import 'package:propcheck/propcheck.dart';
import 'package:enumerators/combinators.dart' as c;
import 'package:test/test.dart' hide equals;

/* --- the properties to test --- */

// this should always hold
bool good(List xs, List ys) =>
    listEquals(reverse(append(xs, ys)),
               append(reverse(ys), reverse(xs)));

// this should NOT always hold
bool bad(List xs, List ys) =>
    listEquals(reverse(append(xs, ys)),
               append(reverse(xs), reverse(ys)));

/* --- how we test them --- */

main() {
  // we define an enumeration of lists of integers
  final boolsLists = c.listsOf(c.bools);

  // 'good' and 'bad' take 2 arguments each so we use forall2
  Property goodProperty = forall2(boolsLists, boolsLists, good);
  Property badProperty = forall2(boolsLists, boolsLists, bad);

  // we test the properties against *every* pair of lists of bools whose
  // combined size is <= 10.
  group('smallcheck', () {
    final sc = new SmallCheck(depth: 10);
    test('good', () => sc.check(goodProperty));

    test('bad', () {
      try {
        sc.check(badProperty);
      } catch (exception) {
        expect(exception.toString(), equalsIgnoringWhitespace(
            'falsified after 11 tests\n'
            '  argument 1: [true]\n'
            '  argument 2: [false]\n'
            ''));
      }
    });
  });

  // we test the properties against random pairs of lists of bools of
  // combined size 0, 1, ..., 300.
  group('quickcheck', () {
    final qc = new QuickCheck(maxSize: 300, seed: 42);
    test('good', () => qc.check(goodProperty));

    test('bad', () {
      try {
        qc.check(badProperty);
      } catch(exception) {
        expect(exception.toString(), equalsIgnoringWhitespace(
            'falsified after 6 tests\n'
                '  argument 1: [true, false, true]\n'
                '  argument 2: [true, true]\n'
                ''));
      }
    });
  });
}
