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

        branches=$(__gi_fetch_branches $@)
        branch_selection_return_value="$?"

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

        if [ "$#" -gt 1 ]
        then
            echo "Too many arguments."
            __gdi_usage
            return 1
        fi

        if [ "$branch_selection_return_value" -ne 0 ]
        then
            echo "Error while fetching branches."
            return 1
        else
            nb_branches=$(echo $branches | wc -l)
            if [ "$nb_branches" -lt 1 ]
            then
                echo "No branch to delete"
                return 0
            elif [ "$nb_branches" -eq 1 ]
            then
                selected_branch=$branches
                echo "Only one branch found: $selected_branch"
            else
                selected_branch=$(echo $branches | fzf --cycle -q "$1")
                if [ -z "$selected_branch" ]
                then
                    return 0
                fi
            fi
            echo "Selected branch: $selected_branch"
            __gdi_get_info_remote_branch $selected_branch
        fi
    fi
}

__gdi_get_info_remote_branch() {
    if [ "$#" -ne 1 ]
    then
        return 1
    fi
    echo "$(git branch -vv)"
}
