#!/usr/bin/env bash

docker buildx install
docker context create cimg-ma
docker buildx create cimg-ma --name docker-multiarch --platform linux/amd64,linux/arm64 --use
docker buildx inspect --builder docker-multiarch --bootstrap
docker buildx build --platform linux/amd64,linux/arm64 --file 18.04/Dockerfile -t fagiani/cimg-base:18.04 .
docker buildx build --platform linux/amd64,linux/arm64 --file 20.04/Dockerfile -t fagiani/cimg-base:20.04 .
docker buildx build --platform linux/amd64,linux/arm64 --file 22.04/Dockerfile -t fagiani/cimg-base:22.04 .
