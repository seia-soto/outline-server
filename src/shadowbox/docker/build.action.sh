#!/bin/bash -eu
#
# Copyright 2018 The Outline Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

export DOCKER_CONTENT_TRUST="${DOCKER_CONTENT_TRUST:-1}"
# Enable Docker BuildKit (https://docs.docker.com/develop/develop-images/build_enhancements)
export DOCKER_BUILDKIT=1

# Detect and set architecture for general users to build without installing emulator.
if [[ -z "${SB_PLATFORM:-}" ]]; then
    SB_PLATFORM="$(uname -m)"

    # Specify the target platform with `$SB_PLATFORM`.
    [[ "${SB_PLATFORM}" == "x86_64" ]] && export SB_PLATFORM="linux/amd64"
    [[ "${SB_PLATFORM}" == "aarch64" ]] && export SB_PLATFORM="linux/arm64"
    [[ "${SB_PLATFORM}" == "armv7l" ]] && export SB_PLATFORM="linux/arm/v7"
fi

# Newer node images have no valid content trust data.
# Pin the image node:16.12-alpine3.14 by tag for multi-platform support.
# See versions at https://hub.docker.com/_/node/
readonly NODE_IMAGE="node:16.12-alpine3.14"

# Use Docker Buildx for building multi-platform images.
docker buildx build \
    --platform="${SB_PLATFORM}" \
    --push \
    --force-rm \
    --build-arg NODE_IMAGE="${NODE_IMAGE}" \
    --build-arg GITHUB_RELEASE="${TRAVIS_TAG:-none}" \
    -f src/shadowbox/docker/Dockerfile \
    -t "${SB_IMAGE:-outline/shadowbox}" \
    "${ROOT_DIR}"
