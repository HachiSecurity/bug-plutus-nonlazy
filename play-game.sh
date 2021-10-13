#!/bin/sh
set -euC

################################################################################
##
##  Parse arguments

readonly DEFAULT_SECRET_WORD=eagle
readonly DEFAULT_WAITING_TIME=2

usage () {
    cat <<EOF
Usage: $0 [OPTION...]

OPTION can be:

  --guess-right        At the end, guess the right secret word
  --guess-wrong        At the end, guess the wrong secret word (default)
  --secret-word WORD   Secret word to use (default: $DEFAULT_SECRET_WORD)
  --waiting-time NB    Time to wait between two instructions (default: $DEFAULT_WAITING_TIME)
  --help,-h            Print this help and exit
EOF
}

GUESS_RIGHT=false
SECRET_WORD=$DEFAULT_SECRET_WORD
WAITING_TIME=$DEFAULT_WAITING_TIME

while [ $# -gt 0 ]; do
    one=$1; shift
    case $one in
        --guess-right) GUESS_RIGHT=true ;;
        --guess-wrong) GUESS_WRONG=false ;;
        --secret-word) SECRET_WORD=$1; shift ;;
        --waiting-time) WAITING_TIME=$1; shift ;;
        --help|-h) usage; exit 0 ;;
        *) printf 'Unknown option: %s\n\n' "$1"; usage; exit 2 ;;
    esac
done

readonly GUESS_RIGHT
readonly SECRET_WORD
readonly WAITING_TIME

################################################################################
##
##  Let's go! First, we create wallets.

create_wallet () { curl -s -d '' http://localhost:9080/wallet/create | jq -r '.wiWallet.getWalletId'; }

printf 'Create wallet 1... '
readonly WALLET1=$(create_wallet)
printf 'done!\nWallet 1 = %s\n\n' "$WALLET1"
sleep "$WAITING_TIME"

printf 'Create wallet 2... '
readonly WALLET2=$(create_wallet)
printf 'done!\nWallet 2 = %s\n\n' "$WALLET2"
sleep "$WAITING_TIME"

################################################################################
##
##  Then, we start instances.

printf 'Start two corresponding instances... '

start_instance () {
    curl -s -H "Content-Type: application/json" \
        --request POST \
        --data '{"caID": "GameContract", "caWallet":{"getWalletId": "'$1'"}}' \
        http://localhost:9080/api/contract/activate \
        | jq -r '.unContractInstanceId'
}

readonly INSTANCE1=$(start_instance "$WALLET1")
readonly INSTANCE2=$(start_instance "$WALLET2")

printf 'done!\n  Instance 1 = %s\n  Instance 2 = %s\n\n' "$INSTANCE1" "$INSTANCE2"

sleep "$WAITING_TIME"

################################################################################
##
##  Then, we lock the secret word.

printf 'Lock secret word "%s" in instance 2... ' "$SECRET_WORD"

curl -H "Content-Type: application/json" \
  --request POST \
  --data '{"amount":{"getValue":[[{"unCurrencySymbol":""},[[{"unTokenName":""},90]]]]},"secretWord":"'$SECRET_WORD'"}' \
  http://localhost:9080/api/contract/instance/$INSTANCE2/endpoint/lock

printf 'done!\n\n'

sleep "$WAITING_TIME"

################################################################################
##
##  Finally, we guess the secret word.

if $GUESS_RIGHT; then
    right=right
    prefix=
else
    right=wrong
    prefix=not
fi

printf 'Guess %s in instance 1... ' $right

curl -H "Content-Type: application/json" \
  --request POST \
  --data '{"guessWord": "'$prefix$SECRET_WORD'"}' \
  http://localhost:9080/api/contract/instance/$INSTANCE1/endpoint/guess

printf 'done!\n\n'

################################################################################
##
##  ...and we're done!
