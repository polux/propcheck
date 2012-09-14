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

#library('dart_check.dart');

#import('dart:io');
#import('dart:math');
#import('package:dart_enumerators/enumerators.dart');

#source('products.dart');

class Property {
  final Enumeration<_Product> enum;
  final Function property;
  Property(this.enum, this.property);
}

Property forall(Enumeration enumeration, bool property(x)) =>
    new Property(_P1.enumerate(enumeration),
                 (_P1 p) => property(p.proj1));

Property forall2(Enumeration enumeration1, Enumeration enumeration2,
                 bool property(x, y)) =>
    new Property(_P2.enumerate(enumeration1, enumeration2),
                 (_P2 p) => property(p.proj1, p.proj2));

Property forall3(Enumeration enumeration1, Enumeration enumeration2,
                 Enumeration enumeration3, bool property(x, y, z)) =>
    new Property(_P3.enumerate(enumeration1, enumeration2, enumeration3),
                 (_P3 p) => property(p.proj1, p.proj2, p.proj3));

Property forall4(Enumeration enumeration1, Enumeration enumeration2,
                 Enumeration enumeration3, Enumeration enumeration4,
                 bool property(x, y, z, w)) =>
    new Property(_P4.enumerate(enumeration1, enumeration2, enumeration3,
                               enumeration4),
                 (_P4 p) => property(p.proj1, p.proj2, p.proj3, p.proj4));

abstract class Check {
  final bool quiet;

  Check(this.quiet);

  abstract check(Property);

  void display(String message) {
    if (!quiet) {
      stdout.writeString("\r\u001b[K$message");
    }
  }

  void clear() => display('');

  static String _errorMessage(int counter, _Product prod) {
    final res = new StringBuffer("falsified after $counter tests\n");
    final args = prod.toStrings();
    for (int i = 0; i < args.length; i++) {
      res.add("  argument ${i+1}: ${args[i]}\n");
    }
    return res.toString();
  }
}

class SmallCheck extends Check {
  final int depth;

  SmallCheck([depth = 4, quiet = false])
      : this.depth = depth
      , super(quiet);

  void check(Property property) {
    LazyList<Finite> parts = property.enum.parts.take(depth + 1);
    int total = 0;
    for(var it = parts; !it.isEmpty(); it = it.tail) {
      total += it.head.card;
    }

    int counter = 0;
    int currentDepth = 0;
    for(var it = parts; !it.isEmpty(); it = it.tail) {
      final part = it.head;
      int card = part.card;
      for(int i = 0; i < card; i++) {
        display("${counter+1}/$total (depth $currentDepth: ${i+1}/$card)");
        _Product arg = part[i];
        if (!property.property(arg)) {
          clear();
          throw Check._errorMessage(counter + 1, arg);
        }
        counter++;
      }
      currentDepth++;
    }
    clear();
  }
}

class QuickCheck extends Check {
  final int seed;
  final int maxSize;

  QuickCheck([seed = 0, maxSuccesses = 100, maxSize = 100, quiet = false])
      : this.seed = seed
      , this.maxSize = maxSize
      , super(quiet);

  void check(Property property) {
    final random = new Random(seed);
    final nonEmptyParts = <Pair<int,Finite>>[];
    var parts = property.enum.parts;
    int counter = 0;
    while (counter <= maxSize && !parts.isEmpty()) {
      if (parts.head.card > 0) {
        nonEmptyParts.addLast(new Pair(counter, parts.head));
      }
      counter++;
      parts = parts.tail;
    }
    int numParts = nonEmptyParts.length;
    for (int i = 0; i < numParts; i++) {
      final pair = nonEmptyParts[i];
      final size = pair.fst;
      final part = pair.snd;
      display("${i+1}/$numParts (size $size)");
      // TODO: replace by randInt when it handles bigints
      int index = ((part.card-1) * random.nextDouble()).toInt();
      _Product arg = part[index];
      if (!property.property(arg)) {
        clear();
        throw Check._errorMessage(i + 1, arg);
      }
    }
    clear();
  }
}
