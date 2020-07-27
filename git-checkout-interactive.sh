#!/usr/bin/env bash

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
        if [ "$(__gchk_is_git_repo)" = false ]
        then
            echo "Fatal: not in a get repository"
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
    fi
}


__gchk_is_git_repo() {
    git rev-parse --git-dir &> /dev/null && echo "true" || echo "false"
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

        include_remote_branches=false
        include_remote_branches_flag=""
        for arg in "$@"
        do
            if [ "$arg" = "-r" ] || [ "$arg" = "--include-remote-branches" ] || [ "$arg" = "-a" ] || [ "$arg" = "--all" ]
            then
                include_remote_branches=true
                include_remote_branches_flag="--include-remote-branches"
            fi
        done

        branches=$(__gci_fetch_branches $@)
        if [ "$?" -eq 1 ]
        then
            echo "Too many arguments."
            __gci_usage
            return 1
        else
            nb_branches=$(echo $branches | wc -l)
            if [ "$nb_branches" -lt 1 ]
            then
                echo "No branch to select"
                return 0
            elif [ "$nb_branches" -eq 1 ]
            then
                echo "A single branch corresponds: $branches"
                __gci_checkout "$include_remote_branches_flag" "$selected_branch"
            else
                selected_branch=$(echo "$branches" | fzf)
                if [ -n "$selected_branch" ]
                then
                    __gci_checkout "$include_remote_branches_flag" "$selected_branch"
                fi
            fi
        fi
    fi
}

__gci_check_dependencies() {
    if ! command -v fzf &> /dev/null
    then
        echo "Unable to find command 'fzf'. Please install 'fzf'."
        return 1
    fi
}

__gci_fetch_branches() {
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

    if [ "$#" -gt 1 ]
    then
        return 1
    fi

    if [ "$show_all_branches" = true ]
    then
        branches=$(git branch -a)
    elif [ "$show_remote_branches" = false ]
    then
        branches=$(git branch)
    else
        branches=$(git branch -r)
    fi
    branches=$(echo $branches | sed -r 's/^\*?\s*//')
    if [ "$#" -eq 1 ]
    then
        branches=$(echo $branches | eval $grep_command $1)
    fi

    if [ -n "$branch_filter_command" ]
    then
        branches=$(echo $branches | eval $branch_filter_command)
    fi
    echo "$branches"
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
        git checkout "$selected_branch"
    else
        $already_existing_local_branch=$(__gci_find_existing_local_branch "$selected_branch")
        echo "Already existing local branch: $already_existing_local_branch"
        git checkout -t "$selected_branch" # TODO check whether the local branch already exists
    fi
}
__gci_find_existing_local_branch() {
    echo "$(git branch -vv | eval $grep_command '$1')"
}
