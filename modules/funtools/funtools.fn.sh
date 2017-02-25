#!/usr/bin/env sh

is_function() {
    name="$1"
    type "$name" &>/dev/null && \
        LANG=C type "$name" | grep -q 'function'
    return $?
}

