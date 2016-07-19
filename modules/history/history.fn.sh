#!/bin/sh

# get from history
%() {
    
}

hist_append() {
    echo "$1" >> "$HISTFILE"
}

hist_refresh() {
    cat "$HISTFILE" | tail -n $HISTSIZE
}
