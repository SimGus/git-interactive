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
            git branch -d $@
        else
            git_delete_interactive $@
        fi
    fi
}

__gdi_usage() {
    echo "Git Delete Interactive -- SimGus 2020"
    echo "Usage: git_delete_interactive [-r] [<PARTIAL-BRANCH-NAME>]"
    echo "\t<PARTIAL-BRANCH-NAME>\t\tA pattern to look for in the branches names (filters out other branches)"
    echo "\t-r, --include-remote-branches\tIf the command runs interactively, only takes into account the remote branches"
    echo "\t-a, --all\t\t\tIf the command runs interactively, take into account both the local and remote branches"
}
git_delete_interactive() {
    echo "git delete interactive called with params $@"
    if [ "$(__gi_is_git_repo)" = false ]
    then
        echo "Fatal: not in a get repository"
        return 1
    else
        __gi_check_dependencies

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
    fi
}
