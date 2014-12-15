library mirrors_demo;

import 'demolib.dart';
import 'package:propcheck/propcheck_mirrors.dart';
import 'package:unittest/unittest.dart' hide equals;

/* --- the properties to test --- */

// this should always hold
bool good(List<bool> xs, List<bool> ys) =>
    listEquals(reverse(append(xs, ys)),
               append(reverse(ys), reverse(xs)));

// this should NOT always hold
bool bad(List<bool> xs, List<bool> ys) =>
    listEquals(reverse(append(xs, ys)),
               append(reverse(xs), reverse(ys)));

/* --- how we test them --- */

main() {
  // 'good' and 'bad' are converted to properties by reflection on the declared
  // typed of their parameters
  Property goodProperty = property(good);
  Property badProperty = property(bad);

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
