skipSubfoldersOfTheseFolders=(_3s)

function collectGarbage {
	git gc --quiet \
	&& git gc --quiet --aggressive \
	&& git gc --quiet --prune=now
}

function cleanSingleBranchIfStale {
	oneMonthAgo=$(date -d "-1 month" +%s)
	commitThenDate=(${1//::/ })
	branch=${commitThenDate[0]}
	lastUpdated=$(date -d ${commitThenDate[1]} +%s) 
	
	if [ "$branch" == "master" ] || [ "$branch" == "main" ]; then
		return 0
	fi
	
	if [ "$lastUpdated" -gt "$oneMonthAgo" ]; then
		return 0
	fi
		# Branch is recent enough
		echo "Branch $branch is stale. Removing."
	
	currentlyCheckedOut=$(git branch --show-current)
	if [ "$branch" == "$currentlyCheckedOut" ]; then
		git checkout master
	fi

	git branch -D $branch
}

function cleanAllStaleBranches {
	branches=$(git for-each-ref --sort=committerdate refs/heads/ --format='%(refname:short)::%(committerdate:short)')
	for branch in $branches
	do
		cleanSingleBranchIfStale $branch
	done
}

function cleanRepo {
	requestedFolder=$1
	for folder in "${skipSubfoldersOfTheseFolders[@]}"
	do
		if test "${requestedFolder#*$folder}" != "$requestedFolder" 
		then
			echo "skipping folder $requestedFolder"
			return 0
		fi
	done

	cd $1
	pwd
	cleanAllStaleBranches
	collectGarbage
}

cd c:\source
for repoFolder in ./*/; do (cleanRepo $repoFolder) done
for repoFolder in ./_*/*/; do (cleanRepo $repoFolder) done

read -t 3 -n 1
if [ $? = 0 ] ; then
exit ;
fi