#!/bin/bash

for dep in buildozer python-for-android; do
	pushd $dep
	if ! git remote -v | grep upstream >/dev/null; then
		git remote set-url origin git@github.com:mkg20001/$dep
		git remote add upstream git@github.com:kivy/$dep
	fi
	git fetch -p
	git branch -D master
	git reset --hard origin/master
	git checkout -b master
	git rebase upstream/master
	bash
	if [ -e .ok ]; then
		git push origin HEAD:$(date +%s)
		git push -uf origin master
		rm .ok
	fi
	popd
done
