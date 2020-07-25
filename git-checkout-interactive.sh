#!/usr/bin/env bash

git-checkout-interactive() {
    echo "Called git checkout interactive"
}

gc() {
    if [ "$#" -eq 0 ]
    then
        echo "Too few arguments"
        __gci_usage
    else
        echo "Arguments: $@"
    fi
}

__gci_usage() {
    echo "Git Checkout Interactive -- SimGus 2020"
    echo "Usage: gc [-i|--interactive] [<BRANCH-NAME>]"
    echo "\t<BRANCH-NAME>\tThe name of a git branch (can be partial)"
    echo "\t-i, --interactive\tRun the script as an interactive command"
}
