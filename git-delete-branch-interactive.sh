#!/usr/bin/env bash

source ./utils.sh

__gdel_usage() {
    echo "Git Delete++ -- SimGus 2020"
    echo "Usage: gdel [-i|--interactive] [<PARTIAL-BRANCH-NAME>]"
    echo "\t<PARTIAL-BRANCH-NAME>\t\tThe name of a git branch (can be partial in interactive mode)"
    echo "\t-i, --interactive\t\tRun the command in interactive mode"
    echo "\t-r, --remote-branches\tIf the command runs interactively, only takes into account the remote branches"
    echo "\nFor information about Git's official branch delete command, please read 'man git branch'."
}
gdel() {
    if [ "$#" -eq 0 ]
    then
        echo "Too few arguments"
        __gdel_usage
        return 1
    else
        echo "todo"
    fi
}

gdi() {
    echo "git delete interactive called with params $@"
    delete_remote_branch=false
    for arg in "$@"
    do
        shift
        if [ "$arg" = "-r" ] || [ "$arg" = "--remote-branch" ]
        then
            delete_remote_branch=true
        fi
        set -- "$@" "$arg"
    done

    echo "del remote: $delete_remote_branch"
}
