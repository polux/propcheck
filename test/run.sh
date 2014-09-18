#!/bin/bash

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

dartanalyzer $ROOT_DIR/lib/*.dart \
&& dartanalyzer $ROOT_DIR/test/*.dart \
&& dartanalyzer $ROOT_DIR/example/*.dart \
&& dart --enable-checked-mode $ROOT_DIR/test/smallcheck_test.dart \
&& dart --enable-checked-mode $ROOT_DIR/test/quickcheck_test.dart \
&& dart --enable-checked-mode $ROOT_DIR/test/mirrors_test.dart
