#!/bin/sh
WD="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
. $WD/config.sh

if [ -z "$SHX_CFG" ]
then
  echo "NO config set."
else
  # git commands
  if [ $(($SHX_CFG & $SHX_CFG_GIT)) -ge 0 ]
  then
    alias gst="git status"
    alias gpl="git pull"
    alias gps="git push"
    alias gci="git commit -m"
    alias gc="git commit"
    alias gl="git log"
    alias glo="git log --oneline"
    alias gri="git rebase -i"
  fi
fi
