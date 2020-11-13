skipSubfoldersOfTheseFolders=()

function firstStringContainsSecond {
	string="$1"
    substring="$2"
	local contains=false
	if test "${string#*$substring}" != "$string" 
	then
		contains=true
	fi
	echo $contains
}

function arrayContains {
	skipTheseFolders=("_3s")
    matchThis="$1"
	local contains=false
	
	for folder in "${skipTheseFolders[@]}"
	do
		if test "${folder#*$matchThis}" != "$folder" 
		then
			contains=true
		fi
		echo $contains
	done
}

function gitCollectGarbage {
	requestedFolder="$1"    
	
	for folder in "${skipSubfoldersOfTheseFolders[@]}"
	do
		if test "${requestedFolder#*$folder}" != "$requestedFolder" 
		then
			echo "skipping folder $requestedFolder"
			return 0
		fi
	done
	
	cd "$1" \
	&& pwd \
	&& git gc --quiet\
	&& git gc --quiet --aggressive \
	&& git gc --quiet --prune=now \
	
}

cd c:\source
for D in ./*/; do (gitCollectGarbage $D) done
for D in ./_*/*/; do (gitCollectGarbage $D) done