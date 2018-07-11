// Copyright (c) 2012, Google Inc. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

// Author: Paul Brauner (polux@google.com)

library demolib;

import 'package:collection/collection.dart';

bool listEquals(List xs, List ys) => const ListEquality().equals(xs, ys);
List reverse(List xs) => xs.reversed.toList();
List append(List xs, List ys) => new List.from(xs)..addAll(ys);
