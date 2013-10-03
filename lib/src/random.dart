// Copyright (c) 2012, Google Inc. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

// Author: Paul Brauner (polux@google.com)

part of propcheck;

final int _MAX = pow(2, 32);

double _logBase(int b, int n) => log(n) / log(b);

int _nextBigInt(Random rand, int n) {
  if (n <= _MAX) return rand.nextInt(n);

  int dims = _logBase(_MAX, n).ceil();
  int cells = pow(_MAX, dims);
  int limit = cells - (cells % n);
  int result;
  do {
    result = rand.nextInt(_MAX);
    for (int i = 0; i < dims - 1; i++) {
      result = _MAX * result + rand.nextInt(_MAX);
    }
  } while (result > limit);
  return result % n;
}