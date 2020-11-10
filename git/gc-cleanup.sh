function gitCollectGarbage {
	cd "$1" \
	&& pwd \
	&& git gc \
	&& git gc --aggressive \
	&& git gc --prune=now
}

cd c:\source
for D in ./*/; do (gitCollectGarbage $D) done
for D in ./_*/*/; do (gitCollectGarbage $D) done
