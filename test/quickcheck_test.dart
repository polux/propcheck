// Copyright 2012 Google Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// Author: Paul Brauner (polux@google.com)

library test;

import 'package:dart_check/dart_check.dart';
import 'package:dart_enumerators/combinators.dart' as c;
import 'package:unittest/unittest.dart';

void quickCheckPerformsCheck() {
  bool called = false;
  bool test(int n) {
    called = true;
    return true;
  }
  new QuickCheck().check(forall(c.ints, test));
  expect(called, isTrue, reason: "test wasn't called");
}

void falseTriggersException() {
  bool test(int n) {
    return false;
  }
  expect(() => new QuickCheck().check(forall(c.ints, test)),
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

void quickCheckHonorsMaxSuccesses() {
  int counter = 0;
  bool test(int n) {
    counter++;
    return true;
  }
  new QuickCheck(maxSuccesses: 100, quiet: true).check(forall(c.nats, test));
  expect(counter, equals(100),
         reason: "test wasn't called maxSuccesses times");
}

void main() {
  test('QuickCheck performs check', quickCheckPerformsCheck);
  test('QuickCheck throws exception on false', falseTriggersException);
  test('QuickCheck honors maxSize', quickCheckHonorsMaxSize);
  test('QuickCheck honors maxSuccesses', quickCheckHonorsMaxSuccesses);
}
