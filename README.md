# Exhaustive and Randomized Testing of Properties

A library for exhaustive and randomized testing of Dart properties, based on
[enumerators](http://code.google.com/p/dart-enumerators/). It is inspired by
Haskell's [smallcheck](http://hackage.haskell.org/package/smallcheck) and
[quickcheck](http://hackage.haskell.org/package/QuickCheck). If you don't know
these libraries, have a look at the small demo below to get an idea of what it
can be useful for. I also wrote a
[post](https://plus.google.com/u/0/110708326411316526253/posts/NVQj6zJWzap)
that goes into more details.

## Quick Start

```dart
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
```

Output:

```
unittest-suite-wait-for-done
PASS: smallcheck good
FAIL: smallcheck bad
  Caught falsified after 11 tests
    argument 1: [true]
    argument 2: [false]
  
  #0      SmallCheck.check (package:propcheck/propcheck.dart:-1:-1)
  #1      main.<anonymous closure>.<anonymous closure> (file:///usr/local/google/home/polux/projects/dart-check/example/demo.dart:39:31)
  #2      TestCase.run (package:unittest/src/test_case.dart:83:11)
  #3      _nextBatch._nextBatch.<anonymous closure> (package:unittest/unittest.dart:808:19)
  #4      guardAsync (package:unittest/unittest.dart:767:19)
  
PASS: quickcheck good
FAIL: quickcheck bad
  Caught falsified after 5 tests
    argument 1: [false]
    argument 2: [false, false, true]
  
  #0      QuickCheck.check (package:propcheck/propcheck.dart:-1:-1)
  #1      main.<anonymous closure>.<anonymous closure> (file:///usr/local/google/home/polux/projects/dart-check/example/demo.dart:47:31)
  #2      TestCase.run (package:unittest/src/test_case.dart:83:11)
  #3      _nextBatch._nextBatch.<anonymous closure> (package:unittest/unittest.dart:808:19)
  #4      guardAsync (package:unittest/unittest.dart:767:19)
  

2 PASSED, 2 FAILED, 0 ERRORS
Unhandled exception:
Exception: Some tests failed.
#0      Configuration.onDone (package:unittest/src/config.dart:141:7)
#1      _completeTests (package:unittest/unittest.dart:837:17)
#2      _nextBatch._nextBatch (package:unittest/unittest.dart:819:17)
#3      runTests.runTests.<anonymous closure> (package:unittest/unittest.dart:756:16)
#4      _defer.<anonymous closure> (package:unittest/unittest.dart:713:13)
#5      _ReceivePortImpl._handleMessage (dart:isolate-patch:40:92)
```

## Try it!

```
git clone https://code.google.com/p/dart-check/
cd dart-check
pub install
dart example/demo.dart
```

Enjoy the progress indicator, probably the most elaborate part of this library :)
