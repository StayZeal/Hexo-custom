#!/bin/sh
gen=`hexo g`
add=`git add .`
commit=`git commit -m"a"`
push=`git push`
copy=`cp -ru ./public ../stayzeal.github.io`
