#!/usr/bin/env bash

source ./utils.sh

grep_command="rg"
branch_filter_command="rg -v '_backup'"


__gchk_usage() {
    echo "Git Checkout++ -- SimGus 2020"
    echo "Usage: gchk [-i|--interactive] [<PARTIAL-BRANCH-NAME>]"
    echo "\t<PARTIAL-BRANCH-NAME>\t\tThe name of a git branch (can be partial)"
    echo "\t-i, --interactive\t\tRun the command in interactive mode"
    echo "\t-r, --include-remote-branches\tIf the command runs interactively, only takes into account the remote branches"
    echo "\t-a, --all\t\t\tIf the command runs interactively, take into account both the local and remote branches"
    echo "\nFor information about Git's official checkout, please read 'man git checkout'."
}
gchk() {
    if [ "$#" -eq 0 ]
    then
        echo "Too few arguments"
        __gchk_usage
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
    echo "Usage: git-checkout-interactive [-r|-a] [<PARTIAL-BRANCH-NAME>]"
    echo "\t<PARTIAL-BRANCH-NAME>\t\tA pattern to look for in the branches names (filters out other branches)"
    echo "\t-r, --include-remote-branches\tIf the command runs interactively, only takes into account the remote branches"
    echo "\t-a, --all\t\t\tIf the command runs interactively, take into account both the local and remote branches"
}
git_checkout_interactive() {
    echo "Called git checkout interactive with args $@"
    if [ "$(__gchk_is_git_repo)" = false ]
    then
        echo "Fatal: not in a get repository"
        return 1
    else
        __gci_check_dependencies

        branches=$(__gci_fetch_branches $@)
        branch_selection_return_value="$?"

        include_remote_branches_flag=""
        for arg in "$@"
        do
            shift
            if [ "$arg" = "-r" ] || [ "$arg" = "--include-remote-branches" ] || [ "$arg" = "-a" ] || [ "$arg" = "--all" ]
            then
                include_remote_branches_flag="--include-remote-branches"
                continue
            fi
            set -- "$@" "$arg"
        done

        if [ "$branch_selection_return_value" -gt 1 ] # Error when getting branches
        then
            echo "Too many arguments."
            __gci_usage
            return 1
        elif [ "$branch_selection_return_value" -eq 1 ]
        then
            selected_branch=$(echo "$branches" | fzf --cycle -q "$1")
            if [ -n "$selected_branch" ]
            then
                __gci_checkout $include_remote_branches_flag $selected_branch
            fi
        else
            nb_branches=$(echo $branches | wc -l)
            if [ "$nb_branches" -lt 1 ]
            then
                echo "No branch to select"
                return 0
            elif [ "$nb_branches" -eq 1 ]
            then
                echo "A single branch corresponds: $branches"
                __gci_checkout $include_remote_branches_flag $selected_branch
            else
                selected_branch=$(echo "$branches" | fzf --cycle)
                if [ -n "$selected_branch" ]
                then
                    __gci_checkout $include_remote_branches_flag $selected_branch
                fi
            fi
        fi
    fi
}

__gci_checkout() {
    echo "args are $@"
    include_remote_branches=false
    for arg in "$@"
    do
        if [ "$arg" = "--include-remote-branches" ]
        then
            include_remote_branches=true
            continue
        else
            selected_branch="$arg"
        fi
    done

    if [ "$include_remote_branches" = false ]
    then
        git checkout $selected_branch
    else
        remote_name="$(echo $selected_branch | sed 's:remotes/::')"
        corresponding_local_branch="$(__gci_find_corresponding_local_branch $remote_name)"
        if [ -z "$corresponding_local_branch" ]
        then
            git checkout -t $selected_branch
        else
            echo "Local branch '$corresponding_local_branch' already tracks '$remote_name'"
            return 1
        fi
    fi
}
__gci_find_corresponding_local_branch() {
    if [ "$#" -ne 1 ]
    then
        return 0
    else
        echo "$(git branch -vv | eval $grep_command $remote_name | cut -d' ' -f2)"
    fi
}
