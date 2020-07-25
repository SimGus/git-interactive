#!/usr/bin/env bash

grep_program="rg"

git_checkout_interactive() {
    echo "Called git checkout interactive with args $@"
    show_remote_branches=false
    for arg in "$@"
    do
        shift
        if [ "$arg" = "-r" ] || [ "$arg" = "--include-remote-branches" ]
        then
            show_remote_branches=true
            continue
        fi
        set -- "$@" "$arg"
    done

    if [ "$show_remote_branches" = false ]
    then
        branches="$(git branch)"
    else
        branches="$(git branch -r)"
    fi
    branches="$(echo $branches | sed -r 's/^\*?\s*//')"
    echo "Branches:\n$branches"
    if [ "$(echo $branches | wc -l)" -lt 2 ]
    then
        echo "No branch to select"
        return 0
    fi

    if ! command -v fzf &> /dev/null
    then
        echo "Unable to find command 'fzf'. Please install 'fzf'."
        return 1
    else
        selected_branch=$(echo "$branches" | fzf)
        echo "Selected branch: $selected_branch"
    fi
}

gc() {
    if [ "$#" -eq 0 ]
    then
        echo "Too few arguments"
        __gci_usage
        return 1
    else
        interactive=false
        for arg in "$@"
        do
            shift
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
