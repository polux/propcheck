// Copyright (c) 2012, Google Inc. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

// Author: Paul Brauner (polux@google.com)

import 'package:propcheck/propcheck.dart';
import 'package:enumerators/combinators.dart' as c;
import 'package:enumerators/enumerators.dart' as e;
import 'package:test/test.dart';

void quickCheckPerformsCheck() {
  bool called = false;
  bool test(int n) {
    called = true;
    return true;
  }
  new QuickCheck(quiet: true).check(forall(c.ints, test));
  expect(called, isTrue, reason: "test wasn't called");
}

void falseTriggersException() {
  bool test(int n) {
    return false;
  }
  expect(() => new QuickCheck(quiet: true).check(forall(c.ints, test)),
         throwsA(new isInstanceOf<String>()));
}

void quickCheckHonorsMaxSize() {
  final collected = new Set<int>();
  bool test(int n) {
    collected.add(n);
    return true;
  }
  new QuickCheck(maxSize: 100, quiet: true).check(forall(c.nats, test));
  for (int n in collected) {
    expect(n, lessThanOrEqualTo(100));
  }
}

void quickCheckHonorsMaxSize2() {
  // represents the enumeration { 0: [42, 43], 1: [44] }
  final enumeration = e.singleton(42)
                    + e.singleton(43)
                    + e.singleton(44).pay();

  int counter = 0;
  bool test(int n) {
    counter++;
    return true;
  }
  new QuickCheck(maxSuccesses: 100, quiet: true).check(forall(enumeration,
                                                              test));
  expect(counter, equals(2),
         reason: "test wasn't called 2 times");
}

void quickCheckIsMonotonous() {
  final collected = <String>[];
  bool test(String s) {
    collected.add(s);
    return true;
  }
  new QuickCheck(maxSize: 50, quiet: true).check(forall(c.strings, test));
  for(int i = 0; i < collected.length - 2; i++) {
      expect(collected[i].length, lessThan(collected[i+1].length));
  }
}

void main() {
  test('QuickCheck performs check', quickCheckPerformsCheck);
  test('QuickCheck throws exception on false', falseTriggersException);
  test('QuickCheck honors maxSize on infinite enumerations',
       quickCheckHonorsMaxSize);
  test('QuickCheck honors maxSize on finite enumerations',
       quickCheckHonorsMaxSize2);
  test('QuickCheck is monotonous', quickCheckIsMonotonous);
}
