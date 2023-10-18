#!/usr/bin/env sh

MODULES=`grep path .gitmodules | cut -d= -f2 | awk '{$1=$1};1' | awk '{printf("%s ",$0)}'`

for p in $MODULES; do
    cd $p
    git pull
    cd ..
done

git add $MODULES
git commit -m 'update modules'
git push
