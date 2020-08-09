#!/usr/bin/env bash

branch_filter_command="rg -v '_backup'"


__gi_is_git_repo() {
    git rev-parse --git-dir &> /dev/null && echo "true" || echo "false"
}

__gi_check_dependencies() {
    if ! command -v fzf &> /dev/null
    then
        echo "Unable to find command 'fzf'. Please install 'fzf'."
        return 1
    fi
}

__gi_fetch_branches() {
    git_branch_arg=""
    for arg in "$@"
    do
        if [ "$arg" = "-r" ] || [ "$arg" = "--include-remote-branches" ]
        then
            git_branch_arg="-r"
        elif [ "$arg" = "-a" ] || [ "$arg" = "--all" ]
        then
            git_branch_arg="-a"
        fi
    done

    branches=$(git branch $git_branch_arg | sed -r 's/^\*?\s*//')

    if [ -n "$branch_filter_command" ]
    then
        branches="$(echo $branches | eval $branch_filter_command)"
    fi
    echo "$branches"
}

