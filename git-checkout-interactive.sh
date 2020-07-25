#!/usr/bin/env bash

git_checkout_interactive() {
    echo "Called git checkout interactive with args $@"
}

gc() {
    if [ "$#" -eq 0 ]
    then
        echo "Too few arguments"
        __gci_usage
    else
        interactive=false
        for arg in "$@"
        do
            shift
            echo "Handling arg $arg"
            if [ "$arg" = "-i" ] || [ "$arg" = "--interactive" ]
            then
                interactive=true
                continue
            fi
            set -- "$@" "$arg"
        done
        echo "args: $@"
        echo "interactive? $interactive"
        if [ "$interactive" = false ]
        then
            eval "git checkout $@"
        else
            git_checkout_interactive $@
        fi
    fi
}

__gci_usage() {
    echo "Git Checkout Interactive -- SimGus 2020"
    echo "Usage: gc [-i|--interactive] [<BRANCH-NAME>]"
    echo "\t<BRANCH-NAME>\tThe name of a git branch (can be partial)"
    echo "\t-i, --interactive\tRun the script as an interactive command"
}
