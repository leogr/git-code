#!/usr/bin/env bash

: ${GIT_CODE_EDITOR:="code"}
: ${GIT_CODE_FOLDER:="${HOME}/code"}

repo=$(echo "$1" | sed -e 's|/$||')

regex="((((http[s]?|git|ssh|git\+ssh):\/\/([[A-Za-z0-9\-\.]+@)?)|([[A-Za-z0-9\-\.]+@)))([A-Za-z0-9\-\.]+)(:[0-9]+\/|:|\/)(.*)"

if [[ "$repo" =~ $regex ]]; then
    host="${BASH_REMATCH[7]}"
    path=$(echo "${BASH_REMATCH[9]}" | sed -e 's|\.bundle$||' -e 's|\.git$||' -e 's|/$||')
    
    clone_dir="${GIT_CODE_FOLDER}/$host/$path"
    open_editor="$GIT_CODE_EDITOR $clone_dir"

    echo "$repo ~> $clone_dir"

    # Clone or pull
    if [ -e "$clone_dir" ]; then
        cd $clone_dir
        git pull --rebase && $open_editor
    else
        mkdir -p $clone_dir
        git clone $1 $clone_dir && $open_editor
    fi
else
    echo "Invalid repo URL: $repo"
fi
