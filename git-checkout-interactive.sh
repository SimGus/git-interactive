#!/usr/bin/env bash

source ./utils.sh

__gchk_usage() {
    echo "Git Checkout++ -- SimGus 2020"
    echo "Usage: gchk [-i|--interactive] [<PARTIAL-BRANCH-NAME>]"
    echo "\t<PARTIAL-BRANCH-NAME>\t\tThe name of a git branch (can be partial in interactive mode)"
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
    echo "Usage: git_checkout_interactive [-r|-a] [<PARTIAL-BRANCH-NAME>]"
    echo "\t<PARTIAL-BRANCH-NAME>\t\tA pattern to look for in the branches names (filters out other branches)"
    echo "\t-r, --include-remote-branches\tIf the command runs interactively, only takes into account the remote branches"
    echo "\t-a, --all\t\t\tIf the command runs interactively, take into account both the local and remote branches"
}
git_checkout_interactive() {
    if [ "$(__gi_is_git_repo)" = false ]
    then
        echo "Fatal: not in a get repository"
        return 1
    else
        __gi_check_dependencies

        local branches=$(__gi_fetch_branches $@)
        local branch_selection_return_value="$?"

        local include_remote_branches_flag=""
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

        if [ "$#" -gt 1 ]
        then
            echo "Too many arguments."
            __gci_usage
            return 1
        fi

        if [ "$branch_selection_return_value" -ne 0 ] # Error when getting branches
        then
            echo "Error while fetching branches."
            return 1
        else
            local nb_branches=$(echo $branches | wc -l)
            if [ "$nb_branches" -lt 1 ]
            then
                echo "No branch to select"
                return 0
            elif [ "$nb_branches" -eq 1 ]
            then
                local selected_branch="$branches"
                echo "A single branch corresponds: $selected_branches"
            else
                local selected_branch=$(echo "$branches" | fzf --cycle -q "$1")
                if [ -z "$selected_branch" ]
                then
                    return 0
                fi
            fi
            __gci_checkout $include_remote_branches_flag $selected_branches
        fi
    fi
}

__gci_checkout() {
    local include_remote_branches=false
    for arg in "$@"
    do
        if [ "$arg" = "--include-remote-branches" ]
        then
            include_remote_branches=true
            continue
        else
            local selected_branch="$arg"
        fi
    done

    if [ "$include_remote_branches" = false ]
    then
        git checkout $selected_branch
    else
        local remote_name="$(echo $selected_branch | sed 's:remotes/::')"
        local corresponding_local_branch="$(__gci_find_corresponding_local_branch $remote_name)"
        if [ -z "$corresponding_local_branch" ]
        then
            git checkout -t $selected_branch
        else
            echo "Local branch '$corresponding_local_branch' already tracks '$remote_name'"
            echo -n "Create a new local branch with another name? [y/n] "
            local create_local_branch
            read create_local_branch
            if [[ $create_local_branch =~ [yY] ]]
            then
                echo -n "Please specify the name of the new branch: "
                local new_branch_name
                read new_branch_name
                if [ -n "$new_branch_name" ]
                then
                    git checkout -b $new_branch_name $remote_name
                else
                    echo "No name provided"
                    return 1
                fi
            fi
        fi
    fi
}
__gci_find_corresponding_local_branch() {
    if [ "$#" -ne 1 ]
    then
        return 0
    else
        echo "$(git branch -vv | eval $__gi_grep_command $remote_name | cut -d' ' -f2)"
    fi
}
