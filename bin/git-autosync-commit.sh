#!/bin/bash

set -e

if [ "$#" -lt "1" ]; then
    echo "Usage: $0 <repo>"
    exit 1
fi

REPO=$1

cd "$REPO"
if [ ! -e .git ]; then
    echo "Not a git repo"
    exit 1
fi

REPODIR=$(pwd -P .)
REPONAME=$(basename "$REPODIR")

if [ ! -e ~/".git-autosync/worktrees/$REPONAME/" ]; then
    echo "Missing git autosync worktree in: $REPODIR"
    exit 1
fi

#rsync --delete -aq ./ ~/".git-autosync/worktrees/$REPONAME/" --exclude=/.git
#cd ~/".git-autosync/worktrees/$REPONAME"
GIT=$(cat ~/".git-autosync/worktrees/$REPONAME/.git")
export GIT_DIR="${GIT#*: }"
git add -A

if [ -n "$(git diff --name-only --cached)" ]; then
    echo "Git-autosync commiting: $REPONAME"

    git commit -m "Git-Autosync autocommit $(hostname)" --no-gpg-sign

    SSH_COMMAND="$(git config git-autosync.sshCommand || true)"
    if [ -n "$SSH_COMMAND" ]; then
        GIT_SSH_COMMAND="$SSH_COMMAND" git push --set-upstream git-autosync "git-autosync_$(hostname)"
    else
        git push --set-upstream git-autosync "git-autosync-$(hostname)"
    fi
fi