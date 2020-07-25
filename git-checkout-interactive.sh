#!/usr/bin/env bash

grep_command="rg"

git_checkout_interactive() {
    echo "Called git checkout interactive with args $@"
    if ! command -v fzf &> /dev/null
    then
        echo "Unable to find command 'fzf'. Please install 'fzf'."
        return 1
    fi

    show_remote_branches=false
    show_all_branches=false
    for arg in "$@"
    do
        shift
        if [ "$arg" = "-r" ] || [ "$arg" = "--include-remote-branches" ]
        then
            show_remote_branches=true
            continue
        elif [ "$arg" = "-a" ] || [ "$arg" = "--all" ]
        then
            show_all_branches=true
            continue
        fi
        set -- "$@" "$arg"
    done
    echo "modes: remote? $show_remote_branches all? $show_all_branches"

    if [ "$#" -gt 1 ]
    then
        echo "Too many arguments."
        __gci_usage
        return 1
    fi

    if [ "$show_all_branches" = true ]
    then
        branches="$(git branch -a)"
    elif [ "$show_remote_branches" = false ]
    then
        branches="$(git branch)"
    else
        branches="$(git branch -r)"
    fi
    branches="$(echo $branches | sed -r 's/^\*?\s*//')"
    if [ "$#" -eq 1 ]
    then
        branches="$(echo $branches | eval $grep_command $1)"
    fi
    echo "Branches:\n$branches"

    nb_branches=$(echo $branches | wc -l)
    echo "Nb branches: $nb_branches"
    if [ "$nb_branches" -lt 1 ]
    then
        echo "No branch to select"
        return 0
    elif [ "$nb_branches" -eq 1 ]
    then
        echo "A single branch corresponds: $branches"
        git checkout "$branches"
    else
        selected_branch=$(echo "$branches" | fzf)
        if [ -n "$selected_branch" ]
        then
            git checkout "$selected_branch"
        fi
    fi
}

gchk() {
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
        if [ "$interactive" = false ]
        then
            git checkout $@
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
