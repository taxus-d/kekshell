#!/bin/sh

#  tool for checking if file is a kekshell module
#+ or a directory
__check_file() { 
    fname="$1"
    match=`echo "$fname" | grep  '.*\.fn\.sh'`
    [ ! -z "$match" -o -d "$fname" ] 
    return $?
}

# handles all recursive loading
# Basically, generates list of files to load
# separated from `load' to remove all argument
#+processing stuff
__rec_load_list() {
    module="$1"

    if [ -d "$module" ]; then
        for file in "$module"/[!_]* ; do
            fpath="$file"
            # `file' works badly :(
            __check_file "$fpath" || continue
            stfpath=$( echo `dirname $fpath`/`basename $fpath .fn.sh` )
            __rec_load "$stfpath"
        done
    else
        module="$module.fn.sh"
        echo "$module"
    fi
}

# loads new keksh modules, surprisingly
# Usage: load math::numtheory::factor
# flags :
#1) -d, --debug : echo loaded modules
load() {
    DEBUG=false
    [ -z "$*" ] && return 1
    [ "$1" = '-d' -o "$1" = '--debug' ] && DEBUG=true && shift 
    module="$MODULES_DIR::$1"

    module=$(echo "$module" | sed 's%::%/%g')
    __rec_load "$module" | while read mod; do
        # preventing multiple loading of single file
        if ! grep -q "$mod" "$TMPDIR"/.loadlog ;then
            echo "$mod" >> "$TMPDIR"/.loadlog
            [ "$DEBUG" = true ] && echo "+ $mod"
            . "$mod"
        else
            [ "$DEBUG" = true ] && echo "$mod have been loaded already"
        fi
    done
    
}

unload () {
    DEBUG=false
    [ -z "$*" ] && return 1
    [ "$1" = '-d' -o "$1" = '--debug' ] && DEBUG=true && shift 
    
    module="$MODULES_DIR::$1"
    module=`echo "$module" | sed 's%::%/%g'`
    
    loadlog="$TMPDIR"/.loadlog
    
    # extracting & incinerating shell functions
    funames=$(
    grep "^$module" "$loadlog" | while read file; do
# extracting all functions
        allfunlines=` sed -n '/^ *[0-9#_a-zA-Z]\+ *()/p' "$file" `
        allfunames=` echo "$allfunlines" | awk -F '(' '{print $1}'`
# do not remove hidden
        funames=` echo "$allfunames" `
        echo $funames
    done )
    
    incinerate $funames 
    #         ^^^^^^^^^
    # really no quotes here
    # function names must not contain special symbols
    
    # print debug info
    [ "$DEBUG" = true ] && grep "^$module" "$loadlog" | while read file;
    do echo "- $file"; done
    # finally, clean log
    grep -v "^$module" "$loadlog" > "$TMPDIR"/tmpfile
    mv "$TMPDIR"/tmpfile "$loadlog"
}


# incinerates given command 
# it can be dangerous, therefore such a long name :D
incinerate() {
    [ -z "$*" ] && return
    for cmd in "$@"; do
        # fail if cmd not exists
        type "$cmd" >/dev/null || return 1
        if ( type "$cmd" | grep -q 'function' ); then
            unset -f "$cmd"
        else
            [ "$cmd" = 'echo' ] && echo "Sorry, can't incinerate 'echo'" && return 1
            eval "$cmd" "() { echo \"$0: $cmd: command not found\" && return 127; }"
        fi
    done
}
