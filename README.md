# Exhaustive and Randomized Testing for Dart

[![Build Status](https://drone.io/github.com/polux/propcheck/status.png)](https://drone.io/github.com/polux/propcheck/latest)

A library for exhaustive and randomized testing of Dart properties, based on
[enumerators](http://pub.dartlang.org/packages/enumerators). It is inspired by
Haskell's [smallcheck](http://hackage.haskell.org/package/smallcheck) and
[quickcheck](http://hackage.haskell.org/package/QuickCheck). If you don't know
these libraries, have a look at the small demo below to get an idea of what it
can be useful for. I also wrote a
[post](https://plus.google.com/u/0/110708326411316526253/posts/NVQj6zJWzap)
that goes into more details.

## Documentation

The only documentation so far is this README and the
[API reference](http://polux.github.io/propcheck/continuous/propcheck.html).

## Quick Start

```dart
import 'dart:collection';
import 'package:propcheck/propcheck.dart';
import 'package:enumerators/combinators.dart' as c;
import 'package:unittest/unittest.dart';

// defines append and reverse
part 'demolib.dart';

/* --- the properties to test --- */

// this should always hold
bool good(List xs, List ys) =>
    equals(reverse(append(xs, ys)),
           append(reverse(ys), reverse(xs)));

// this should NOT always hold
bool bad(List xs, List ys) =>
    equals(reverse(append(xs, ys)),
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
    test('bad', () => sc.check(badProperty));
  });

  // we test the properties against random pairs of lists of bools of
  // combined size 0, 1, ..., 300.
  group('quickcheck', () {
    final qc = new QuickCheck(maxSize: 300, seed: 42);
    test('good', () => qc.check(goodProperty));
    test('bad', () => qc.check(badProperty));
  });
}
```

Output:

```
unittest-suite-wait-for-done
PASS: smallcheck good
FAIL: smallcheck bad
  Caught falsified after 11 tests
    argument 1: [true]
    argument 2: [false]
  
  [...]
  
PASS: quickcheck good
FAIL: quickcheck bad
  Caught falsified after 5 tests
    argument 1: [false]
    argument 2: [false, false, true]
  
  [...]

2 PASSED, 2 FAILED, 0 ERRORS
```

## Try it!

```
git clone https://github.com/polux/propcheck
cd propcheck
pub install
dart example/demo.dart
```

Enjoy the progress indicator, probably the most elaborate part of this 
library :)
