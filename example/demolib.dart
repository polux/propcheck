// Copyright (c) 2012, Google Inc. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

// Author: Paul Brauner (polux@google.com)

part of demo;

List reverse(List xs) {
  List res = [];
  for (int i = xs.length - 1; i >= 0; i--) {
    res.add(xs[i]);
  }
  return res;
}

List append(List xs, List ys) {
  List res = [];
  res.addAll(xs);
  res.addAll(ys);
  return res;
}

