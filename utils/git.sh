#!/bin/bash

# Original code from efatsi https://github.com/efatsi
function github-create-repo {
	repo_name=$1

	dir_name=`basename $(pwd)`

	if [ "$repo_name" = "" ]; then
		echo "Repo name (hit enter to use '$dir_name')?"
		read repo_name
	fi

	if [ "$repo_name" = "" ]; then
		repo_name=$dir_name
	fi

	username=`git config github.user`
	if [ "$username" = "" ]; then
		echo "Could not find username, run 'git config --global github.user <username>'"
		invalid_credentials=1
	fi

	token=`git config github.token`
	if [ "$token" = "" ]; then
		echo "Could not find token, run 'git config --global github.token <token>'"
		invalid_credentials=1
	fi

	if [ "$invalid_credentials" == "1" ]; then
		return 1
	fi

	echo "Creating Github repository '$repo_name' ..."
	response=`curl -u "$username:$token" https://api.github.com/user/repos -d '{"name":"'$repo_name'", "private": true}' 2>/dev/null` 
	errors_in_response=`python -c "import sys, json; response = json.loads(sys.argv[1]); print 1 if 'errors' in response else 0" "$response"`
	
	if [ "$errors_in_response" == "1" ]; then
		echo "Errors in response: "
		echo $response | python -m json.tool | pygmentize -l json
		return 1
	fi
	echo "done"

	echo "Pushing local code to remote ..."
	git init
	git add .
	git commit -m "Initial commit"
	git remote add origin git@github.com:$username/$repo_name.git
	git push -u origin master
	echo "done"
}