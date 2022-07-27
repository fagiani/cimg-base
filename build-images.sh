#!/usr/bin/env bash

docker buildx install
docker build --platform linux/amd64,linux/arm64 --file 18.04/Dockerfile -t fagiani/cimg-base:18.04 .
docker build --platform linux/amd64,linux/arm64 --file 20.04/Dockerfile -t fagiani/cimg-base:20.04 .
docker build --platform linux/amd64,linux/arm64 --file 22.04/Dockerfile -t fagiani/cimg-base:22.04 .
