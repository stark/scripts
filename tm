#!/bin/sh

# DATE Format: DAY-DD-MM-YY
# date (1p) format:
STAMP="$(date +"%A-%d-%B-%Y")"
# TMP
TMP="$HOME/tmp"
# Working Directory
DIR="$TMP/$STAMP"
# Default Tmux Session name
SESSION=scratch

# If the directory is non-existent then create it
[ ! -d "$DIR" ] && mkdir -p "$DIR"

# Create a new tmux session with the $SESSION name and $DIR as working directory
exec tmux new-session -s $SESSION -c "$DIR"

exit $?
# vim: set ft=sh:
