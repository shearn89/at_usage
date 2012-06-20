#!/bin/bash

DIR="$( cd "$( dirname "$0" )" && pwd )"
cd $DIR/../
echo ">> Attempting `git pull` to update system. If it fails, navigate to the root of the app and attempt it manually."
git pull origin master
touch tmp/restart.txt
cd -