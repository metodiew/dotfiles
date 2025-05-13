#!/bin/bash
git fetch --prune
for branch in $(git branch --format="%(refname:short)" | grep -v "^master$"); do
  if git log master --not "$branch" >/dev/null 2>&1; then
    echo "Deleting branch: $branch"
    git branch -d "$branch"
  fi
done