# vim:set ft=dockerfile:

# Do not edit individual Dockerfiles manually. Instead, please make changes to the Dockerfile.template, which will be used by the build script to generate Dockerfiles.

FROM ubuntu:22.04

# Multiarch setup
ARG BUILDARCH

LABEL maintainer="Community & Partner Engineering Team <community-partner@circleci.com>"

# Change default shell for RUN from Dash to Bash
SHELL ["/bin/bash", "-exo", "pipefail", "-c"]

ENV DEBIAN_FRONTEND=noninteractive \
    TERM=dumb \
    PAGER=cat

# Configure environment
RUN echo 'APT::Get::Assume-Yes "true";' > /etc/apt/apt.conf.d/90circleci && \
	echo 'DPkg::Options "--force-confnew";' >> /etc/apt/apt.conf.d/90circleci && \
	apt-get update && apt-get install -y \
		curl \
		locales \
		sudo \
	&& \
	locale-gen en_US.UTF-8 && \
	rm -rf /var/lib/apt/lists/* && \

	useradd --uid=3434 --user-group --create-home circleci && \
	echo 'circleci ALL=NOPASSWD: ALL' >> /etc/sudoers.d/50-circleci && \
	echo 'Defaults    env_keep += "DEBIAN_FRONTEND"' >> /etc/sudoers.d/env_keep && \
	sudo -u circleci mkdir /home/circleci/project && \
	sudo -u circleci mkdir /home/circleci/bin && \

	# Install Dockerize v0.6.1
	# Source repo: https://github.com/jwilder/dockerize
	# I (Ricardo) would like to replace this one day. It's a tool not really
	# maintained and we can likely offer something better.
	echo "BUILDARCH: $BUILDARCH" && \
        if [ "$BUILDARCH" = "arm64" ]; \
          then export ARCH=armhf; \
          else export ARCH=amd64; \
        fi && \
	curl -sSL --fail --retry 3 --output /tmp/dockerize.tar.gz "https://github.com/jwilder/dockerize/releases/download/v0.6.1/dockerize-linux-${ARCH}-v0.6.1.tar.gz" && \
	tar -C /usr/local/bin -xzvf /tmp/dockerize.tar.gz && \
	rm -rf /tmp/dockerize.tar.gz && \
	# Quick test of Dockerize
	dockerize --version

ENV PATH=/home/circleci/bin:/home/circleci/.local/bin:$PATH \
	LANG=en_US.UTF-8 \
	LANGUAGE=en_US:en \
	LC_ALL=en_US.UTF-8

RUN noInstallRecommends="" && \
	if [[ "22.04" == "22.04" ]]; then \
		noInstallRecommends="--no-install-recommends"; \
	fi && \
	apt-get update && apt-get install -y $noInstallRecommends \
		autoconf \
		build-essential \
		ca-certificates \
		cmake \
		# already installed but here for consistency
		curl \
		gnupg \
		gzip \
		jq \
		libcurl4-openssl-dev \
		# popular DB lib - MariaDB
		libmariadb-dev \
		# allows MySQL users to use MariaDB lib
		libmariadb-dev-compat \
		# popular DB lib - PostgreSQL
		libpq-dev \
		libssl-dev \
		libsqlite3-dev \
		make \
		# for ssh-enabled builds
		nano \
		net-tools \
		netcat \
		openssh-client \
		parallel \
		# compiling tool
		pkg-config \
		postgresql-client \
		shellcheck \
		software-properties-common \
		# already installed but here for consistency
		sudo \
		tar \
		tzdata \
		unzip \
		# for ssh-enabled builds
		vim \
		wget \
		zip && \
	add-apt-repository ppa:git-core/ppa && apt-get install -y git && \
	rm -rf /var/lib/apt/lists/*

# Install Docker - needs the setup_remote_docker CircleCI step to work
ENV DOCKER_VERSION 5:20.10.16~3-0~ubuntu-
RUN apt-get update && apt-get install -y \
		apt-transport-https \
		ca-certificates \
		curl \
		gnupg-agent \
		software-properties-common && \
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && \
	add-apt-repository -y "deb [arch=${BUILDARCH}] https://download.docker.com/linux/ubuntu $( lsb_release -cs ) stable" && \
	apt-get install -y docker-ce=${DOCKER_VERSION}$( lsb_release -cs ) docker-ce-cli=${DOCKER_VERSION}$( lsb_release -cs ) containerd.io && \
	# Quick test of the Docker install
	docker --version && \
	rm -rf /var/lib/apt/lists/*

# Install Docker Compose - see prerequisite above
# Even though they use the same repo, Docker Compose is installed seperately
# from Docker Engine due to the fact that Docker Compose releases much more
# frequently. This is a caching decision.
ENV COMPOSE_VER 2.6.0
ENV COMPOSE_SWITCH_VERSION 1.0.4
RUN apt-get update && apt-get install --yes --no-install-recommends \
		docker-compose-plugin=${COMPOSE_VER}~ubuntu-$( lsb_release -cs ) \
	&& \
	curl -fL https://github.com/docker/compose-switch/releases/download/v${COMPOSE_SWITCH_VERSION}/docker-compose-linux-${BUILDARCH} -o /usr/local/bin/compose-switch && \
	# Quick test of the Docker Compose install
	docker compose version && \
	chmod +x /usr/local/bin/compose-switch && \
	update-alternatives --install /usr/local/bin/docker-compose docker-compose /usr/local/bin/compose-switch 99 && \
	# Tests if docker-compose for v1 is transposed to v2
	docker-compose version

RUN curl -sSL "https://github.com/mikefarah/yq/releases/download/v4.23.1/yq_linux_${BUILDARCH}.tar.gz" | \
	tar -xz -C /usr/local/bin && \
	mv /usr/local/bin/yq{_linux_${BUILDARCH},}

USER circleci
# Run commands and tests as circleci user
RUN whoami && \
	# opt-out of the new security feature, not needed in a CI environment
	git config --global --add safe.directory '*'

# Match the default CircleCI working directory
WORKDIR /home/circleci/project
