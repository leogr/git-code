#!/usr/bin/env bash

: ${GIT_CODE_EDITOR:=$(which code)}
: ${GIT_CODE_FOLDER:="${HOME}/code"}
: ${GIT_CODE_CLONE_OPT:=""}
: ${GIT_CODE_PULL_OPT:="--rebase"}

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

# Check editor 
if [[ ! -e  $GIT_CODE_EDITOR  ]]; then
    editor="echo No editor found."
else
    editor="$GIT_CODE_EDITOR $dest"
fi

# Clone (or pull) info destination path then open the editor
if [ -e "$dest" ]; then
    if [ -e "$dest/.git" ]; then
        echo "Pulling into '$dest'..."
        cd $dest
        git pull $GIT_CODE_PULL_OPT && $editor
    else 
        echo "fatal: destination path '$dest' already exists and is not a valid git repository."
        exit 128
    fi
else
    mkdir -p $dest
    git clone $GIT_CODE_CLONE_OPT $repo $dest && $editor
fi