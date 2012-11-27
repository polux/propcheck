#!/bin/bash

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

dart --enable-checked-mode $ROOT_DIR/test/smallcheck_test.dart
dart --enable-checked-mode $ROOT_DIR/test/quickcheck_test.dart
