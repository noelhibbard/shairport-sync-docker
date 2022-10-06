#!/usr/bin/env bash

SHAIRPORT_SYNC_BRANCH=development
NQPTP_BRANCH=development

git clone https://github.com/mikebrady/nqptp -b $SHAIRPORT_SYNC_BRANCH
git clone https://github.com/mikebrady/shairport-sync -b $NQPTP_BRANCH
cd ./shairport-sync

sed -i 's/configure --/configure --with-pa --/' ./docker/Dockerfile
sed -i 's/git \\/git \\\n        pulseaudio-dev \\/' ./docker/Dockerfile
sed -i 's/alsa-lib \\/alsa-lib \\\n        pulseaudio \\\n        pulseaudio-utils \\\n        curl \\/' ./docker/Dockerfile

make distclean > /dev/null 2>&1
docker buildx build -f ./docker/Dockerfile --no-cache --build-arg SHAIRPORT_SYNC_BRANCH=$SHAIRPORT_SYNC_BRANCH --build-arg NQPTP_BRANCH=$NQPTP_BRANCH -t shairport-sync:pulse .