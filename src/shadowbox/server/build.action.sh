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

readonly OUT_DIR="${BUILD_DIR}/shadowbox"
rm -rf "${OUT_DIR}"
mkdir -p "${OUT_DIR}"

webpack --config=src/shadowbox/webpack.config.js ${BUILD_ENV:+--mode="${BUILD_ENV}"}

# Install third_party dependencies
remap_arch() {
  local ARCH="${1}" AMD64="${2:-amd64}" ARM64="${3:-arm64}" ARMv7="${4:-armv7}" ARMv6="${5:-armv6}"

  [[ "${ARCH}" == *"amd64"* || "${ARCH}" == *"x86_64"* ]] && ARCH="${AMD64}"
  [[ "${ARCH}" == *"arm64"* ]] && ARCH="${ARM64}"
  [[ "${ARCH}" == *"v7"* ]] && ARCH="${ARMv7}"
  [[ "${ARCH}" == *"v6"* ]] && ARCH="${ARMv6}"

  echo "${ARCH}"
}

if [[ "$(uname)" == "Darwin" ]]; then
  readonly OS="macos"
  readonly ARCH="x86_64"
else
  # Accept `$ARCH` from outside of the script
  [[ -z "${ARCH:-}" ]] && ARCH="$(uname -m)"

  readonly OS="linux"
  readonly ARCH="$(remap_arch "${ARCH}" x86_64 aarch64 armv7 armv6)"
fi

readonly BIN_DIR="${OUT_DIR}/bin"

mkdir -p "${BIN_DIR}"
cp "${ROOT_DIR}/third_party/prometheus/${OS}/prometheus_${ARCH}" "${BIN_DIR}/prometheus"
cp "${ROOT_DIR}/third_party/outline-ss-server/${OS}/outline-ss-server_${ARCH}" "${BIN_DIR}/outline-ss-server"

# Copy shadowbox package.json
cp "${ROOT_DIR}/src/shadowbox/package.json" "${OUT_DIR}/"
