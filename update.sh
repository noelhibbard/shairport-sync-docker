#!/usr/bin/env bash

needsupdate=0

#check to see if a new shairport-sync version is available
cd ./shairport-sync
git reset --hard > /dev/null 2>&1
git fetch > /dev/null 2>&1
status=$(git status -sb --porcelain=v2)
regex="branch.ab \+([0-9]*) -([0-9]*)"
if [[ $status =~ $regex ]]
then
    ahead=${BASH_REMATCH[1]}
    behind=${BASH_REMATCH[2]}
    if [ $behind -gt 0 ]
    then
        needsupdate=1
        git pull > /dev/null 2>&1
    fi
fi
cd ..

#check to see if a new nqptp version is available
cd ./nqptp
git reset --hard > /dev/null 2>&1
git fetch > /dev/null 2>&1
status=$(git status -sb --porcelain=v2)
regex="branch.ab \+([0-9]*) -([0-9]*)"
if [[ $status =~ $regex ]]
then
    ahead=${BASH_REMATCH[1]}
    behind=${BASH_REMATCH[2]}
    if [ $behind -gt 0 ]
    then
        needsupdate=1
        git pull > /dev/null 2>&1
    fi
fi
cd ..

if [ $needsupdate -gt 0 ]
then
    cd ./shairport-sync
    sed -i 's/RUN .\/configure /RUN .\/configure --with-pa /' ./docker/Dockerfile
    sed -i 's/git \\/git \\\n        pulseaudio-dev \\/' ./docker/Dockerfile
    sed -i 's/alsa-lib \\/alsa-lib \\\n        pulseaudio \\\n        pulseaudio-utils \\\n        curl \\/' ./docker/Dockerfile

    SHAIRPORT_SYNC_BRANCH=development
    NQPTP_BRANCH=development

    docker buildx build -f ./docker/Dockerfile --no-cache --build-arg SHAIRPORT_SYNC_BRANCH=$SHAIRPORT_SYNC_BRANCH --build-arg NQPTP_BRANCH=$NQPTP_BRANCH -t shairport-sync:unstable-development .

    cd ..
    docker-compose up -d
else
    echo "shairport-sync and nqptp are already up to date."
fi
