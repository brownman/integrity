#!/bin/sh
echo "Performing local branch"
git checkout -b deploy v22.6
./install.sh
