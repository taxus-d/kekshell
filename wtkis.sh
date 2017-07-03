#!/usr/bin/env sh


# supposedly, stands for ``what kek is $cmd''
#  parsing output of `type' command actually
#+ it usually looks like ``$cmd is $smth'', where $smth is:
#   * nothing at all        -> ''
#   * shell function        -> 'f'
#   * shell bultin          -> 'b'
#   * cmd path like /bin/ls -> 'c' <<< a tricky part here, as SH says something like `tracked alias'
#   * alias                 -> 'a'
#   * something unknown     -> 'u'
export LANG=C
cmd="$1"
pathstr=" $( echo "$PATH" | sed 's/:/\\|/g')"

#     [ "$DEBUG" ] && type "$cmd"
typestr=$(type "$cmd")
if [ $? = 0 ]; then
    # really no quotes here, otherwise `set' will put everything in $1
    #           vvvvvvvv
    set $typestr 
    shift 2
    rest="$*"
    if echo "$rest" | grep -q 'function' ; then
        echo -n 'f'
    elif echo "$rest" | grep -q 'builtin'; then
        echo -n 'b'
    elif echo "$rest" | grep -q "$pathstr"; then
        echo -n 'c'
    elif echo "$rest" | grep -q 'alias'; then
        echo -n 'a'
    else
        echo -n 'u'
        return 1
    fi
else
    echo -n ''
fi
return $?
