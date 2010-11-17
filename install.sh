#!/bin/sh
echo "Performing local branch"
git checkout -b deploy v22.5
./install.sh
