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
# Set output variant (https://docs.docker.com/engine/reference/commandline/buildx_build/#output)
# The image will be named using `SB_IMAGE` variable.
# The reason is unknown but `type=image` doesn't work on CI.
export SB_OUTPUT="${SB_OUTPUT:-type=docker}"

# Detect and set architecture for general users to build without installing emulator.
remap_arch() {
  local ARCH="${1}" AMD64="${2:-amd64}" ARM64="${3:-arm64}" ARMv7="${4:-armv7}" ARMv6="${5:-armv6}"

  [[ "${ARCH}" == *"amd64"* || "${ARCH}" == *"x86_64"* ]] && ARCH="${AMD64}"
  [[ "${ARCH}" == *"arm64"* || "${ARCH}" == *"aarch64"* ]] && ARCH="${ARM64}"
  [[ "${ARCH}" == *"v7"* ]] && ARCH="${ARMv7}"
  [[ "${ARCH}" == *"v6"* ]] && ARCH="${ARMv6}"

  echo "${ARCH}"
}

# Specify the target platform with `$SB_PLATFORM`.
[[ -z "${SB_PLATFORM:-}" ]] && SB_PLATFORM="$(remap_arch "$(uname -m)" linux/amd64 linux/arm64 linux/arm/v7 linux/arm/v6)"

# Newer node images have no valid content trust data.
# Pin the image node:16.12-alpine3.14 by tag for multi-platform support.
# See versions at https://hub.docker.com/_/node/
readonly NODE_IMAGE="node:16.12-alpine3.14"

# Use Docker Buildx for building multi-platform images.
docker buildx build \
  --platform "${SB_PLATFORM}" \
  --output "${SB_OUTPUT}" \
  --force-rm \
  --build-arg NODE_IMAGE="${NODE_IMAGE}" \
  --build-arg GITHUB_RELEASE="${TRAVIS_TAG:-none}" \
  -f src/shadowbox/docker/Dockerfile \
  -t "${SB_IMAGE:-outline/shadowbox}" \
  "${ROOT_DIR}"
