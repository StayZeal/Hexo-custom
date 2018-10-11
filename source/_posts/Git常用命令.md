---
title: Git常用命令
date: 2016-04-12 17:32:58
tags:
     - Git
---
博客地址：[http://blog.stayzeal.cn-时光机](http://blog.stayzeal.cn)

#### 问题描述：

`git init` //初始化一个git仓库
`git clone`
`git merge`
`git fetch`
`git pull`
<!--more-->
`git checkout`
`git reset commitId --hard`//重置提交到某一提交
`git reset HEAD^`
`git cherry-pick commitId`//从其他分支或者自己分支获取一个提交
`git revert`
`git add`
`git commit -se`
`git commit --amend`//追加提交到上一次commit
`git push`
`git log --author==username -1`//显示1条为username的提交
`git log branchName`//显示指定分支
`git stash`
`git stash list`
`git stash pop`
`git update-index --assume-unchanged /.htaccess`//忽略根目录下的.htaccess文件
`git update-index --no-assume-unchanged /.htaccess`//不再忽略
`git rebase -i`

