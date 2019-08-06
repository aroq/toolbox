#!/usr/bin/env bash

# Install implementation is taken from https://github.com/cloudposse/build-harness/

export TOOLBOX_ORG=${1:-aroq}
export TOOLBOX_PROJECT=${2:-toolbox}
export TOOLBOX_BRANCH=${3:-master}
export GITHUB_REPO="https://github.com/${TOOLBOX_ORG}/${TOOLBOX_PROJECT}.git"

if [ "$TOOLBOX_PROJECT" ] && [ -d "$TOOLBOX_PROJECT" ]; then
  echo "Removing existing $TOOLBOX_PROJECT"
  rm -rf "$TOOLBOX_PROJECT"
fi

echo "Cloning ${GITHUB_REPO}#${TOOLBOX_BRANCH}..."
git clone -b "$TOOLBOX_BRANCH $GITHUB_REPO"
