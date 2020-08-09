#!/usr/bin/env bash

source ./utils.sh

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
