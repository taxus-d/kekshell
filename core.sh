#!/bin/sh

# TODO:
# Main purpose is to write bash (or zsh) on plain sh (or, to be more accurate, Busybox ash)
#[ ] 1. loader:
#[+]   1.1. load everything, so everything seems OK
#[ ]   1.2. unload: don't care about hidden funcs
#[ ] 2. Core:
#[ ]   2.1. Make calling hidden functions (like this: __rec_load()) impossible for end user
#[ ]   2.2. History
#[ ]   2.3. line editing (in some way)
#[ ]   2.4. support (( )) constructs
#[ ] 3. Tools
#[ ]   3.1. seq
#[+]   3.2. paste
#

KROOT=$(dirname $( which "$0" )) ; export KROOT
ENV="$KROOT"/.kekrc; export ENV
. "$ENV" 
[ -d "$TMPDIR" ] || mkdir "$TMPDIR"
echo -n > "$TMPDIR"/.loadlog
. "$KROOT"/loader.sh
[ -f "$HISTFILE" ] || touch "$HISTFILE"
load verbose::greeting
greet
# incinerate greet

while true; do
    prompt 
    read line
    eval "$line"
done

#if [ `hostname` = 'pocketbook' ]; then
#    exec sh -i
#else
#    exec bash --rcfile "$ENV"
#fi
