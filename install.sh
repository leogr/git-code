#!/usr/bin/env bash

if [ -e "${HOME}/.git-code" ]; then
    echo "~> .git-code folder already found in ${HOME}. Updating..."
    git -C ~/.git-code pull --rebase
else
    echo "~> Installing .git-code folder in ${HOME}..."
    git clone https://github.com/leogr/git-code ~/.git-code
fi

git config --global alias.code "!~/.git-code/bin/git-code.sh"