#!/bin/sh
set -euC

################################################################################
##
##  Parse arguments

readonly DEFAULT_SECRET_WORD=eagle
readonly DEFAULT_WAITING_TIME=2

usage () {
    cat <<EOF
Usage: $0 OPTION

OPTION can be:

  --normal     Use the normal validateGuess.
  --with-or    Change validateGuess to use the || operator
  --with-and   Change validateGuess to use the && operator
  --help,-h    Print this help and exit
EOF
}

MODE=
set_mode () {
    if [ -n "$MODE" ]; then
        printf 'Only one of --normal, --with-or and --with-and can be used.\n\n'
        usage
        exit 2
    else
        MODE=$1
    fi
}

while [ $# -gt 0 ]; do
    one=$1; shift
    case $one in
        --normal) set_mode normal ;;
        --with-or) set_mode or ;;
        --with-and) set_mode and ;;
        --help|-h) usage; exit 0 ;;
        *) printf 'Unknown option: %s\n\n' "$1"; usage; exit 2 ;;
    esac
done

readonly MODE

if [ -z "$MODE" ]; then
    printf 'One of --normal, --with-or and --with-and has to be specified.\n\n'
    usage
    exit 2
fi

################################################################################
##
##  Go for it.

case $MODE in
    normal) REPL='isGoodGuess hs cs' ;;
    or)     REPL='if True || error () then isGoodGuess hs cs else True' ;;
    and)    REPL='if False && error () then True else isGoodGuess hs cs' ;;
    *) printf 'Unexpected error. Mode is not one of the expected values.\n\n'
       usage
       exit 77
esac
readonly REPL

sed -i "s/^validateGuess[^=]*=.*\$/validateGuess hs cs _ = $REPL/" \
    "$(dirname "$0")"/examples/src/Plutus/Contracts/Game.hs
