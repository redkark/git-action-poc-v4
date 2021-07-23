#!/bin/bash

echo "Executing command: git rev-parse --abbrev-ref HEAD"
BRANCH=$(git rev-parse --abbrev-ref HEAD)

previousDate=$(date --date="120 days ago" +"%Y-%m-%d")

echo "$(tput setaf 7)Executing command: git fetch origin"
git fetch origin

branchType=${BRANCH:0:4}
if [[ "$branchType" == "hfbg" ]]
then
	echo "Identifying PR number for the current branch"
	#getting the pull request number created for the current branch to merge into main branch.
	echo "$(tput setaf 7)Executing command: gh pr list --base main -s all --search 'created:>$previousDate' | grep $BRANCH"
	prNumber=$(gh pr list --base main -s all --search "created:>$previousDate" | grep $BRANCH | cut -d $'\t' -f1)
	echo "$(tput setaf 2)PR Number is:  $prNumber"
    

    while true; do
        read -p "$(tput setaf 3)Is $prNumber PR number is correct? yes/no: " prValid
        case $prValid in
            [Yy]* ) break;;
            [Nn]* ) read -p "Please enter correct PR number: " prNumber;;
            * ) echo "Please answer yes or no.";;
        esac
    done

	searchString="(#$prNumber)"
	echo $searchString
	#Getting the commitID for the PR from the main branch created by the PR. Assumption the search string will never be provided manually.
	echo "$(tput setaf 7)Executing command: git log --oneline origin/main | grep $searchString | cut -d $' ' -f1"
    commitID=$(git log --oneline origin/main | grep $searchString | cut -d $' ' -f1)
	echo "$(tput setaf 2)commitID is: $commitID"

    while true; do
        read -p "$(tput setaf 6)Is ($prNumber) PR number commit ($commitID) ID is correct? yes/no: " prValid
        case $prValid in
            [Yy]* ) break;;
            [Nn]* ) read -p "Please enter correct commid ID of PR number: " commitID;;
            * ) echo "Please answer yes or no.";;
        esac
    done

	#Create a hfhn branch from origin/hotfix/next
	hfhnBranchName="${BRANCH/hfbg/hfhn}"
	echo "$(tput setaf 7)Executing command: git checkout -b $hfhnBranchName origin/hotfix/next"
	if ! git checkout --no-track -b $hfhnBranchName origin/hotfix/next
	then
		echo "$(tput setaf 1)ERROR: Failed to create hfhn branch!"
		exit;
	fi
	
    echo "$(tput setaf 7)Executing command: git cherry-pick $commitID"
    if ! git cherry-pick $commitID
    then
		echo "$(tput setaf 1)ERROR: Failed to cherry-pick!"
		exit;
	fi

    git push origin $hfhnBranchName -f
    hotfixBranch='hotfix/next'
    gh pr create -t "Merge hfhn branch for $BRANCH to hotfix/next branch" -b "hfhn PR merge to hotfix/next branch" -B "$hotfixBranch"

elif [[ "$branchType" == "hfhn" ]]
then
    # TODO: generate the PR if not already generated for QARN branch
    prNumber=$(gh pr list --base hotfix/next -s all --search "created:>$previousDate" | grep $BRANCH | cut -d $'\t' -f1)
    if [[ "$prNumber" != "" ]]
    then
        echo "$(tput setaf 1)ERROR: PR($prNumber) is already exist for this branch!"
        exit
    fi

    while true; do
        read -p "$(tput setaf 6)Do you want generate PR for hotfix/next branch? yes/no: " prValid
        case $prValid in
            [Yy]* ) break;;
            [Nn]* ) exit;;
            * ) echo "Please answer yes or no.";;
        esac
    done
    hotfixBranch='hotfix/next'
    gh pr create -t "Merge hfhn branch for $BRANCH to hotfix/next branch" -b "Hotfix PR merge to hotfix/next branch" -B "$hotfixBranch"
else
    echo "$(tput setaf 1) ***** This script is applicable only for hfbg and hfhn prefix branches! **** "
    exit;
fi