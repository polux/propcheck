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

part of dart_check;

abstract class _Product {
  List<String> toStrings();
}

class _P1 extends _Product {
  final proj1;

  _P1(this.proj1);

  List<String> toStrings() => <String>[proj1.toString()];

  static Enumeration<_P1> enumerate(Enumeration e1) =>
      singleton((x1) => new _P1(x1))
          .apply(e1);
}

class _P2 extends _Product {
  final proj1;
  final proj2;

  _P2(this.proj1, this.proj2);

  List<String> toStrings() => <String>[proj1.toString(), proj2.toString()];

  static Enumeration<_P2> enumerate(Enumeration e1, Enumeration e2) =>
      singleton((x1) => (x2) => new _P2(x1, x2))
          .apply(e1)
          .apply(e2);
}

class _P3 extends _Product {
  final proj1;
  final proj2;
  final proj3;

  _P3(this.proj1, this.proj2, this.proj3);

  List<String> toStrings() => <String>[proj1.toString(), proj2.toString(),
                                       proj3.toString()];

  static Enumeration<_P3> enumerate(Enumeration e1, Enumeration e2,
      Enumeration e3) =>
          singleton((x1) => (x2) => (x3) => new _P3(x1, x2, x3))
              .apply(e1)
              .apply(e2)
              .apply(e3);
}

class _P4 extends _Product {
  final proj1;
  final proj2;
  final proj3;
  final proj4;

  _P4(this.proj1, this.proj2, this.proj3, this.proj4);

  List<String> toStrings() => <String>[proj1.toString(), proj2.toString(),
                                       proj3.toString(), proj4.toString()];

  static Enumeration<_P3> enumerate(Enumeration e1, Enumeration e2,
      Enumeration e3, Enumeration e4) =>
          singleton((x1) => (x2) => (x3) => (x4) => new _P4(x1, x2, x3, x4))
              .apply(e1)
              .apply(e2)
              .apply(e3)
              .apply(e4);
}
