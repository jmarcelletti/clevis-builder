#!/usr/bin/env bash

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <ubuntu_version"
    echo
    echo "Example: $0 18.04"
    echo "Example: $0 20.04"
    echo
    exit 1
fi

docker build --build-arg UBUNTU_VERSION=$1 -t clevis-builder:$1 .

mkdir -p out/$1
id=$(docker create clevis-builder:$1)
docker cp ${id}:/out/. out/$1
docker rm -v ${id}

