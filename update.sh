#!/bin/bash

ROOTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
OUTDIR=$ROOTDIR/continuous
TMPDIR=`mktemp -d`

cd $TMPDIR
git clone https://code.google.com/p/dart-check/
cd dart-check
pub install
rm -rf $OUTDIR
dartdoc -v --link-api --pkg packages/ --out $OUTDIR lib/propcheck.dart
#dartdoc -v --generate-app-cache --link-api --pkg packages/ --out $OUTDIR lib/propcheck.dart
rm -rf $TMPDIR
