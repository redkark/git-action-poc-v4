#!/bin/bash

BRANCH=$(git rev-parse --abbrev-ref HEAD)

# branchType=${BRANCH:0:4}
# if [ "$branchType" == "feat" ] || [ "$branchType" == "dvbg" ] || [ "$branchType" == "esbg" ]
# then
#     parentBranch='main'
# elif [[ "$branchType" == "qabg" ]]
# then
#     parentBranch='main'
# 	#parentBranch='release/next'
# elif [[ "$branchType" == "hfbg" ]]
# then
#     parentBranch='main'
# 	#parentBranch='hotfix/next'
# else
#     echo "$(tput setaf 1) Your branch prefix is not valid, please contact the configuration manager!"
#     exit
# fi
parentBranch='main'
echo "executing command: git fetch origin"
git fetch origin
echo "executing command: git merge origin/$parentBranch"
git merge origin/$parentBranch