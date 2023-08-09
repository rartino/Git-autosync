#!/bin/bash

set -e

if [ "$#" -lt "1" ]; then
    echo "Usage: $0 <origin repo> <sync repo> [git-as branch] [dest path]"
    exit 1
fi

REPO=$1
SYNC_REPO=$2
if [ -z "$3" ]; then
    BRANCH="git-autosync-$(hostname)"
else
    BRANCH="$3"
fi
if [ -z "$4" ]; then
    REPONAME=$(basename "$REPO" .git)
    DEST="./$REPONAME"
else
    DEST="$4"
    REPONAME=$(basename "$DEST")
fi

if [ ! -e "$REPONAME" ]; then
    git clone "$REPO" "$DEST"
fi
cd "$DEST"
if ! git remote get-url git-autosync >& /dev/null; then
    git remote add git-autosync "$SYNC_REPO"
fi

if [ ! -e ~/.git-autosync/worktrees ]; then
    mkdir -p ~/.git-autosync/worktrees
fi
if [ ! -e ~/".git-autosync/worktrees/$REPONAME/" ]; then
    git worktree add ~/".git-autosync/worktrees/$REPONAME/" -b "$BRANCH" --no-checkout
fi
