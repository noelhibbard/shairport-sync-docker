#!/usr/bin/env bash

git clone https://github.com/mikebrady/nqptp -b development
git clone https://github.com/mikebrady/shairport-sync -b development
cd ./shairport-sync

sed -i 's/RUN .\/configure /RUN .\/configure --with-pa /' ./docker/Dockerfile
sed -i 's/git \\/git \\\n        pulseaudio-dev \\/' ./docker/Dockerfile
sed -i 's/alsa-lib \\/alsa-lib \\\n        pulseaudio \\\n        pulseaudio-utils \\\n        curl \\/' ./docker/Dockerfile

SHAIRPORT_SYNC_BRANCH=development
NQPTP_BRANCH=development

docker buildx build -f ./docker/Dockerfile --no-cache --build-arg SHAIRPORT_SYNC_BRANCH=$SHAIRPORT_SYNC_BRANCH --build-arg NQPTP_BRANCH=$NQPTP_BRANCH -t shairport-sync:unstable-development .