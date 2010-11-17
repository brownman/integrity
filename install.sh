#!/bin/sh
echo "Performing local branch"
git checkout -b deploy v22.7
./install.sh
