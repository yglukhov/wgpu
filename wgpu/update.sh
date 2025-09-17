#!/usr/bin/env bash

# Run this script to download new webgpu build

set -xe

version=v27.0.4.0
archs="linux-x86_64 macos-aarch64 macos-x86_64"
flavor=release

cd $(dirname $0)

rm -f wgpu.h webgpu.h

for arch in $archs; do
  echo "ARCH: $arch"
  rm -rf $arch wgpu.zip extracted
  curl -L --output wgpu.zip "https://github.com/gfx-rs/wgpu-native/releases/download/$version/wgpu-$arch-$flavor.zip"
  unzip wgpu.zip -d extracted
  rm wgpu.zip
  mv -f extracted/include/webgpu/*.h ./
  mv extracted/lib ./$arch
  mv -f extracted/wgpu-native-meta/wgpu-native-git-tag ./
  rm -rf extracted
done





# rm -rf linux-x86_64 linux-i386 macos-aarch64 macos-x86_64 wgpu.zip WebGPU-distribution-wgpu

# curl -L --output wgpu.zip https://github.com/eliemichel/WebGPU-distribution/archive/refs/heads/wgpu.zip
# #wget https://github.com/eliemichel/WebGPU-distribution/archive/refs/heads/wgpu.zip
# unzip wgpu.zip

# mv WebGPU-distribution-wgpu/bin/linux-x86_64 ./
# mv WebGPU-distribution-wgpu/bin/macos-aarch64 ./
# mv WebGPU-distribution-wgpu/bin/macos-x86_64 ./

# # mv WebGPU-distribution-wgpu/bin/linux-i386 ./
# mv WebGPU-distribution-wgpu/wgpu-native-git-tag.txt ./
# mv WebGPU-distribution-wgpu/include/webgpu/*.h ./

# rm -rf WebGPU-distribution-wgpu wgpu.zip
