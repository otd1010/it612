#!/bin/bash

COMMIT_MESSAGE=$1

if [ -z "$COMMIT_MESSAGE" ]; then
    echo "Error: Empty message"
    exit 1
fi

if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo "Error: Not a git repo"
    exit 1
fi

git add .

if ! git commit -m "$COMMIT_MESSAGE"; then
    echo "Error: Commit failed"
    exit 1
fi

CURRENT_BRANCH=$(git symbolic-ref --short HEAD)

if git push origin "$CURRENT_BRANCH"; then
    echo "Success: Pushed to $CURRENT_BRANCH"
    exit 0
else
    echo "Error: Push failed"
    exit 1
fi