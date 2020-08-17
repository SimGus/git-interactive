# Git interactive
Git interactive is a set of small commands that aim at giving a few git commands interactive abilities with the help of the excellent `fzf` project, all that without moving out of your terminal.

2 git commands are covered:
- `git checkout`
- `git branch --delete`

The commands defined in this project should work on all POSIX-compliant shell, including bash and zsh.

Checkout [git-fuzzy](https://github.com/bigH/git-fuzzy) for a more complete interactive git experience in your terminal.

## Dependencies
The only dependency is [**fzf**](https://github.com/junegunn/fzf), which is available on most platforms.
Refer to their GitHub to have installation instructions.

⚠ This script will not work if dependencies are missing.

## Installation
- Clone or download this repository
- Add the following lines to your `.bashrc` (if you are using bash) or `.zshrc` (if you are using zsh):
    ```sh
    source <PATH_TO_CLONED_REPO>/git-checkout-interactive.sh
    source <PATH_TO_CLONED_REPO>/git-delete-branch-interactive.sh
    ```
    If you only want to have the "checkout" commands, only add the first line; if you only want the "delete" ones, only add the second.
- Close and reopen your terminal (or run `source .bashrc` or `source .zshrc`)

## Usage
### Checkout
Checkout commands allow to checkout git branches. 2 are defined in this project:
- `gchk`
- `git_checkout_interactive`

#### gchk
Usage: `gchk [-i|--interactive] [<PARTIAL-BRANCH-NAME>]`

`<PARTIAL-BRANCH-NAME>`: The name of a git branch (can be partial in interactive mode)

`-i`, `--interactive`: Runs the command in interactive mode

`-r`, `--include-remote-branches`: If the command runs interactively, only takes into account the remote branches

`-a`, `--all`: If the command runs interactively, take into account both the local and remote branches

#### git_checkout_interactive
Usage: `git_checkout_interactive [-r|-a] [<PARTIAL-BRANCH-NAME>]`

`<PARTIAL-BRANCH-NAME>`: A pattern to look for in the branches names (filters out other branches)

`-r`, `--include-remote-branches`: If the command runs interactively, only takes into account the remote branches

`-a`, `--all`: If the command runs interactively, take into account both the local and remote branches

### Delete
Delete commands allow to delete branches (both local branches and remote branches). 2 are defined in this project:
- `gdel`
- `git_delete_interactive`

#### gdel
Usage: `gdel [-i|--interactive] [<PARTIAL-BRANCH-NAME>]`

`<PARTIAL-BRANCH-NAME>`: The name of a git branch (can be partial in interactive mode)

`-i`, `--interactive`: Runs the command in interactive mode

`-l`, `--local-only`: If the command runs interactively, only allows to select and delete a local branch

`-r`, `--remote-only`: If the command runs interactively, only allows to select and delete a remote branch

#### git_delete_interactive
Usage: `git_delete_interactive [-l|-r] [<PARTIAL-BRANCH-NAME>]`

`<PARTIAL-BRANCH-NAME>`: A pattern to look for in the branches names (filters out other branches)

`-l`, `--local-only`: Only allows to select and delete a local branch

`-r`, `--remote-only`: Only allows to select and delete a remote branch
