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
