#!/usr/bin/env bash
#-------------------------------------------------
# A small library to handle command-line arguments
# 
# flags may be:
# 1. binary
# 2. with arg : string
# 3. with arg : string of strings (slurpy)
#-------------------------------------------------

# small service function, see functools for more/less/same of them 
is_function() {
    name="$1"
    type "$name" &>/dev/null && \
        LANG=C type "$name" | grep -q 'function'
    return $?
}

# service macros, see handler example below

make_with_argument() {
    echo '[[ $# != 2 ]] && return 1'
}
make_slurpy() {
   echo '[[ $# -le 1 ]] && return 2' 
}
stop_parsing() {
   echo 'return 3' 
}
unknown_flag() {
    echo 'echo "handle_flag: unknown flag" >&2 && exit 1'
}

## there was a function, 'protect_args' 
## it turned out that 'for' loop is very rude to double quotes
##+ and totally ingnores them, hunting for spaces

# this simple function wants merely usage and handle_flag functions
# otherwise, it'll define them in its way
# Usage: parse_args "$@"

parse_args() {
# fail if cmd not exists
    if ! is_function usage; then
        usage() {
            echo "dummy usage"
        }
    fi
    if ! is_function handle_flag; then
        handle_flag() {
            echo "dummy arg_handler cant handle" "$@"
        }
    fi
    [[ -z "$@" ]] && usage && exit 0

# finite automata:
# 0: waits flag
# 1: waits flag argument
# 2: slurpy mode
# 3: immediate stop
    state=0
    plain=
    arg=

# some useful stuff, a kind of abstraction layer over bash
    __err_exp_arg() {
        echo "parse_args: Expected flag argument" >&2 && exit 1
    }
    __err_exp_end_slurp() {
        echo "parse_args: Expected '-' to end slurpy mode" >&2 && exit 1
    }
    __err_exp_another_universe() {
        echo "Check the universe you are in, something went wrong.
        Definitely." >&2 && exit 111
    }
    __begins_with_dash() {
        [[ $(expr substr "$1" 1 1) = '-' ]]
    }
    __append_spc_string() {
        [[ ! -z "$1" ]] && t="${1} "
        echo "${t}$2"
    }
    until [[ -z "$1" ]]; do
        [[ "$arg" = "--" ]] && state=3 
        case $state in
            0 )
                arg="$1"
                if __begins_with_dash "$arg"; then
                    handle_flag $arg # flag must not contain spaces
                    state=$?
                else
                    plain=`__append_spc_string "$plain" "$arg"`
                fi
                ;;
            1 )
                __begins_with_dash "$1" && __err_exp_arg 
                handle_flag "$arg" "$1" 
                state=$?
                ;;
            2 )
                if [[ "$1" = "-" ]]; then 
                    handle_flag $arg
                    state=$?
                else
                    arg="${arg} \"$1\""
                fi
                ;;
            3 )
                break
                ;;
            * )
                __err_exp_another_universe
                ;;    
        esac
        shift
    done
# postprocess, we can't end waiting for the next argument
    case $state in
        1 )
            __err_exp_arg
            ;;
        2 )
            __err_exp_end_slurp
            ;;
    esac
    plain=`__append_spc_string "$plain" "$*"`
    if [[ -z ${ARGC+x} ]]; then
        echo -n "$plain"
    else
        ARGC="$plain"
    fi
}

# handler example, shows all technics listed above
# :::::::::::::::::::::::::::::::::::::::::::::::
# handle_flag() {
#     case "$1" in
#         -h|--help )
#             usage
#             ;;
#         -a|--a-want-an-arg )
#             eval `make_with_argument`
#             echo "$1" "$2"
#             ;;
#         -s | --slon )
#             eval `make_slurpy`
#             echo "$@"
#             eval `stop_parsing`
#             ;;
#         * )
#             eval `unknown_flag`
#             ;;
#     esac
# }
# ::::::::::::::::::::::::::::::::::::::::::::::::
# 
# examples of main function call
# ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# parse_args -a kek --help -s what for -- --a-want-an-arg it lll aaa -- jkdf fdk
# parse_args
# ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
