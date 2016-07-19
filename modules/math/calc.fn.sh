#!/bin/sh

[ `hostname` = 'pocketbook' ] && . /mnt/ext1/system/bin/startup.sh

calc() {
    expr="$1"
    echo "$expr" | bc -l
}


