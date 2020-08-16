#!/usr/bin/env bash

gdel() {
    __gdel_usage() {
        echo "Git Delete++ -- SimGus 2020"
        echo "Usage: gdel [-i|--interactive] [<PARTIAL-BRANCH-NAME>]"
        echo "\t<PARTIAL-BRANCH-NAME>\t\tThe name of a git branch (can be partial in interactive mode)"
        echo "\t-i, --interactive\t\tRun the command in interactive mode"
        echo "\t-l, --local-only\tIf the command runs interactively, only allows to select and delete a local branch"
        echo "\t-r, --remote-only\tIf the command runs interactively, only allows to select and delete a remote branch"
        echo "\nFor information about Git's official branch delete command, please read 'man git branch'."
    }

    if [ "$#" -eq 0 ]
    then
        echo "Too few arguments"
        __gdel_usage
        return 1
    else
        local interactive=false
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

git_delete_interactive() (
    source ./utils.sh

    __gdi_usage() {
        echo "Git Delete Interactive -- SimGus 2020"
        echo "Usage: git_delete_interactive [-l|-r] [<PARTIAL-BRANCH-NAME>]"
        echo "\t<PARTIAL-BRANCH-NAME>\t\tA pattern to look for in the branches names (filters out other branches)"
        echo "\t-l, --local-only\tOnly allows to select and delete a local branch"
        echo "\t-r, --remote-only\tOnly allows to select and delete a remote branch"
    }

    __gdi_get_info_remote_branch() {
        if [ "$#" -ne 1 ]
        then
            return 1
        fi

        local pattern="^\*?\s+$1"
        local branch_info=$(git branch -vv | eval $__gi_grep_command '$pattern')
        if [[ "$branch_info" =~ '^\*?\s+\w+\s+\w+\s+\[' ]]
        then
            local remote_info="${${branch_info#*\[}%%\]*}"
            if [[ "$remote_info" =~ ':' ]]
            then
                echo "${remote_info%%:*} false"
            else
                echo "${remote_info%%:*} true"
            fi
        fi
    }

    __gdi_delete_branch() {
        local local_branch=false
        local remote_branch=false
        for arg in "$@"
        do
            shift
            if [ "$arg" = "--local" ]
            then
                local_branch=true
                continue
            elif [ "$arg" = "--remote" ]
            then
                remote_branch=true
                continue
            fi
            set -- "$@" "$arg"
        done

        if  [ "$#" -ne 1 ]
        then
            echo "Internal error: $0 received an incorrect number of parameters."
            return 1
        fi

        if [ $local_branch = true ]
        then
            echo "Deleting local branch $1"
            git branch -D "$1"
        elif [ $remote_branch = true ]
        then
            echo "Deleting remote branch $1"
            git push --delete $(echo $1 | sed 's|/| |')
        fi
    }

    echo "git delete interactive called with params $@"
    if [ "$(__gi_is_git_repo)" = false ]
    then
        echo "Fatal: not in a get repository"
        return 1
    else
        __gi_check_dependencies

        local only_remote_branch=false
        local only_local_branch=false
        local branch_list_arg=""
        for arg in "$@"
        do
            shift
            if [ "$arg" = "-r" ] || [ "$arg" = "--remote-only" ]
            then
                only_remote_branch=true
                branch_list_arg="-r"
                continue
            elif [ "$arg" = "-l" ] || [ "$arg" = "--local-only" ]
            then
                only_local_branch=true
                continue
            fi
            set -- "$@" "$arg"
        done

        local branches=$(__gi_fetch_branches "$branch_list_arg")
        local branch_selection_return_value="$?"

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
            local nb_branches=$(echo $branches | wc -l)
            if [ "$nb_branches" -lt 1 ]
            then
                echo "No branch to delete"
                return 0
            elif [ "$nb_branches" -eq 1 ]
            then
                local selected_branch=$branches
                echo "Only one branch found: $selected_branch"
            else
                local selected_branch=$(echo $branches | fzf --cycle -q "$1")
                if [ -z "$selected_branch" ]
                then
                    return 0
                fi
            fi

            if [ $only_local_branch = true ]
            then
                __gdi_delete_branch --local $selected_branch
            elif [ $only_remote_branch = true ]
            then
                git fetch &> /dev/null
                __gdi_delete_branch --remote $selected_branch
            else
                git fetch &> /dev/null

                local remote_branch_info="$(__gdi_get_info_remote_branch $selected_branch)"
                if [ -n "$remote_branch_info" ]
                then
                    remote_branch_name="$(echo $remote_branch_info | cut -d' ' -f1)"
                    local up_to_date_with_remote="$(echo $remote_branch_info | cut -d' ' -f2)"

                    if [ $up_to_date_with_remote = true ]
                    then
                        __gdi_delete_branch --remote $remote_branch_name
                    else
                        echo "Remote branch $remote_branch_name is not up-to-date with the local tracking branch $selected_branch"
                        echo -n "Delete it anyway? [y/n] "
                        local delete_anyway
                        read delete_anyway
                        if [[ "$delete_anyway" =~ [yY] ]]
                        then
                            __gdi_delete_branch --remote $remote_branch_name
                        else
                            echo "Not deleting remote branch $remote_branch_name"
                        fi
                    fi
                    echo ""
                fi

                if [ "$selected_branch" = "$(git_current_branch)" ]
                then
                    echo "Cannot delete current local branch. Please checkout another branch and retry."
                    return 1
                else
                    echo -n "Delete local branch $selected_branch (the last copy of the work)? [y/N] "
                    local delete_local_branch
                    read delete_local_branch
                    if [[ "$delete_local_branch" =~ [yY] ]]
                    then
                        __gdi_delete_branch --local $selected_branch
                    else
                        echo "Not deleting local branch $selected_branch"
                    fi
                fi
            fi
        fi
    fi
)
