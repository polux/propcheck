#!/bin/bash

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

results=`dart_analyzer --work=/tmp $ROOT_DIR/lib/*.dart 2>&1`
if [ -n "$results" ]; then
    echo "$results"
    exit 1
else
    echo "done"
fi

dart --enable-checked-mode $ROOT_DIR/test/smallcheck_test.dart
dart --enable-checked-mode $ROOT_DIR/test/quickcheck_test.dart
