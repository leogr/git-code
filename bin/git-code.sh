#!/usr/bin/env bash

: ${GIT_CODE_EDITOR:="code"}
: ${GIT_CODE_FOLDER:="${HOME}/code"}

repo="$1"

reg_schema="http[s]?|git|ssh|git\+ssh"
reg_user="[a-z0-9]+"
reg_host="[a-z0-9.\-]+\.[a-z0-9]+"
reg_port="[0-9]+"
reg_path="[A-Za-z0-9_.\/\-]+"

p_git="^($reg_user)\@($reg_host)\:\~?($reg_path)(\/)?$"
p_url="^($reg_schema)\:\/\/($reg_host)(:$reg_port)?\/($reg_path)(\/)?$"
p_short="^($reg_host)\/($reg_path)(\/)?$"

if [[ "$repo" =~ $p_git ]]; then
    host="${BASH_REMATCH[2]}"
    path="${BASH_REMATCH[3]}"
elif [[ "$repo" =~ $p_url ]]; then
    host="${BASH_REMATCH[2]}"
    path="${BASH_REMATCH[4]}"
elif [[ "$repo" =~ $p_short ]]; then
    host="${BASH_REMATCH[1]}"
    path="${BASH_REMATCH[2]}"
    repo="https://$host/$path.git"
    echo "Using '$repo'."
else 
    echo "fatal: repository '$repo' is not valid."
    exit 128
fi

path=$(echo "$path" | sed -e 's|\.bundle$||' -e 's|\.git$||' -e 's|/$||')
dest="${GIT_CODE_FOLDER}/$host/$path"
open_editor="$GIT_CODE_EDITOR $dest"

if [ -e "$dest" ]; then
    if [ -e "$dest/.git" ]; then
        echo "Pulling into '$dest'..."
        cd $dest
        git pull --rebase && $open_editor
    else 
        echo "fatal: destination path '$dest' already exists and is not a valid git repository."
        exit 128
    fi
else
    mkdir -p $dest
    git clone $repo $dest && $open_editor
fi