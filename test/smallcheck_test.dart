// Copyright (c) 2012, Google Inc. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

// Author: Paul Brauner (polux@google.com)

import 'package:propcheck/propcheck.dart';
import 'package:enumerators/combinators.dart' as c;
import 'package:unittest/unittest.dart';

void smallCheckPerformsCheck() {
  bool called = false;
  test(int n) {
    called = true;
    return true;
  }
  new SmallCheck(quiet: true).check(forall(c.ints, test));
  expect(called, isTrue, reason: "test wasn't called");
}

void falseTriggersException() {
  bool test(int n) {
    return false;
  }
  expect(() => new SmallCheck(quiet: true).check(forall(c.ints, test)),
         throwsA(new isInstanceOf<String>()));
}

void smallCheckIsExhaustive() {
  final collected = new Set<int>();
  final expected = new Set<int>();
  for (int i = 0; i <= 100; i++) expected.add(i);
  bool test(int n) {
    collected.add(n);
    return true;
  }
  new SmallCheck(depth: 100, quiet: true).check(forall(c.nats, test));
  expect(collected, equals(expected));
}

void smallCheckIsMonotonous() {
  final collected = <int>[];
  bool test(int n) {
    collected.add(n);
    return true;
  }
  new SmallCheck(depth: 100, quiet: true).check(forall(c.nats, test));
  for(int i = 0; i < collected.length - 2; i++) {
    expect(collected[i], lessThan(collected[i+1]));
  }
}

void main() {
  test('SmallCheck performs check', smallCheckPerformsCheck);
  test('SmallCheck throws exception on false', falseTriggersException);
  test('SmallCheck is exhaustive', smallCheckIsExhaustive);
  test('SmallCheck is monotonous', smallCheckIsMonotonous);
}

