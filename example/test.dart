// Copyright (c) 2015, Google Inc. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

// Author: Paul Brauner (polux@google.com)


import 'package:propcheck/propcheck_mirrors.dart';

class Model {
  List<int> _stack = [];

  Model();

  void push(int i) {
    _stack.add(i);
  }

  int pop() {
    if (!_stack.isEmpty) {
      return _stack.removeLast();
    } else {
      throw new StateError("stack is empty");
    }
  }

  int peek() {
    if (!_stack.isEmpty) {
      return _stack.last;
    } else {
      throw new StateError("stack is empty");
    }
  }
}

class Cons<A> {
  final A value;
  final Cons tail;

  Cons(this.value, this.tail);
}

class Stack<A> {
  Cons<A> _stack = null;

  Stack();

  void push(int i) {
    _stack = new Cons(i, _stack);
  }

  A pop() {
    if (_stack != null) {
      final res = _stack.value;
      _stack = _stack.tail;
      return res;
    } else {
      throw new StateError("stack is empty");
    }
  }

  A peek() {
    if (_stack != null) {
      return _stack.value;
    } else {
      throw new StateError("stack is empty");
    }
  }
}

main() {
  new SmallCheck(depth: 6).check(implementationMatchesModel(
      Model, [#Model], (new Stack<int>()).runtimeType, [#Stack], [#push, #pop, #peek]));
}
