#!/usr/bin/env sh

cd ansible
git pull
cd ..

cd compiler
git pull
cd ..

cd docker
git pull
cd ..

cd drupal
git pull
cd ..

git commit -m 'update modules'
git push
