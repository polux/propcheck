// Copyright (c) 2014, Google Inc. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

// Author: Paul Brauner (polux@google.com)

import 'package:propcheck/propcheck_mirrors.dart';
import 'package:enumerators/combinators.dart' as c;
import 'package:enumerators/enumerators.dart' as e;
import 'package:test/test.dart';

bool boolArgument(bool x) => true;
bool intArgument(int x) => true;

void compareEnumerations(e.Enumeration actual, e.Enumeration expected) {
  expect(actual.take(1000).toList(), equals(expected.take(1000).toList()));
}

void checkProperty(Function fun, e.Enumeration expected) {
  compareEnumerations(property(fun).enumeration, expected);
}

void testPropertyOfBools() {
  checkProperty((bool _) => true, c.productsOf([c.bools]));
}

void testPropertyOfInts() {
  checkProperty((int _) => true, c.productsOf([c.ints]));
}

void testPropertyOfStrings() {
  checkProperty((String _) => true, c.productsOf([c.strings]));
}

void testPropertyOfListsOfBools() {
  checkProperty((List<bool> _) => true,
                c.productsOf([c.listsOf(c.bools)]));
}

void testPropertyOfListsOfListsOfBools() {
  checkProperty((List<List<bool>> _) => true,
                c.productsOf([c.listsOf(c.listsOf(c.bools))]));
}

void testPropertyOfSetsOfBools() {
  checkProperty((Set<bool> _) => true,
                c.productsOf([c.setsOf(c.bools)]));
}

void testPropertyOfSetsOfSetsOfBools() {
  checkProperty((Set<Set<bool>> _) => true,
                c.productsOf([c.setsOf(c.setsOf(c.bools))]));
}

void testPropertyOfMapsFromStringsToInts() {
  checkProperty((Map<String, int> _) => true,
                c.productsOf([c.mapsOf(c.strings, c.ints)]));
}

void testPropertyOfMapsFromStringsToMapsFromStringsToInts() {
  checkProperty(
      (Map<String, Map<String,int>> _) => true,
      c.productsOf([c.mapsOf(c.strings, c.mapsOf(c.strings, c.ints))]));
}

void testTernaryProperty() {
  checkProperty(
      (int x, bool y, List<String> z) => true,
      c.productsOf([c.ints, c.bools, c.listsOf(c.strings)]));
}

void testPropertyCallsFunctionWithRightNumberOfArguments() {
  bool called = false;
  bool f(int x, bool y, List<String> z) {
    called = true;
    return true;
  }
  Property prop = property(f);
  prop.property(prop.enumeration.first);
  expect(called, isTrue);
}

void main() {
  test('property of bools', testPropertyOfBools);
  test('property of ints', testPropertyOfInts);
  test('property of strings', testPropertyOfStrings);
  test('property of lists of bools', testPropertyOfListsOfBools);
  test('property of lists of lists of bools',
       testPropertyOfListsOfListsOfBools);
  test('property of sets of bools', testPropertyOfListsOfBools);
  test('property of sets of sets of bools',
       testPropertyOfListsOfListsOfBools);
  test('property of lists of maps from strings to ints',
      testPropertyOfMapsFromStringsToInts);
  test('property of lists of maps from strings to maps from strings to ints',
       testPropertyOfMapsFromStringsToMapsFromStringsToInts);
  test('ternary property', testTernaryProperty);
  test('property calls function with right number of arguments',
       testPropertyCallsFunctionWithRightNumberOfArguments);
}