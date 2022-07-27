#!/usr/bin/env bash

export DOCKER_CLI_EXPERIMENTAL=enabled
docker buildx install
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
docker rm -f buildx_buildkit_docker-multiarch0
docker context create cimg-ma
docker buildx create cimg-ma --name docker-multiarch --driver docker-container --platform linux/amd64,linux/arm64 --use
docker buildx inspect --builder docker-multiarch --bootstrap
docker buildx build --push --platform linux/amd64,linux/arm64 --file 18.04/Dockerfile -t fagiani/cimg-base:18.04 .
docker buildx build --push --platform linux/amd64,linux/arm64 --file 20.04/Dockerfile -t fagiani/cimg-base:20.04 .
docker buildx build --push --platform linux/amd64,linux/arm64 --file 22.04/Dockerfile -t fagiani/cimg-base:22.04 .
