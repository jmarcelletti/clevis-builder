#!/usr/bin/env bash

docker build -t clevis-builder:latest . 

mkdir -p out/
id=$(docker create clevis-builder:latest)
docker cp ${id}:/out/. out/
docker rm -v ${id}
