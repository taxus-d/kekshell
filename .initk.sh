#!/bin/sh

export PS1="`whoami`@kekmachine $ "
export LC_MESSAGES=C
#export KROOT=`pwd`
export MODULES_DIR="$KROOT"/modules
export TMPDIR=/tmp/kekshell
mkdir "$TMPDIR"
echo -n > "$TMPDIR"/.loadlog

. "$KROOT"/loader.sh
load verbose::greeting
greet
incinerate greet
