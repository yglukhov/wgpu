#!/usr/bin/env sh

# Run this script to download new webgpu build

set -xe

rm -rf linux-x86_64 linux-i386 macos-aarch64 macos-x86_64 wgpu.zip WebGPU-distribution-wgpu

curl -L --output wgpu.zip https://github.com/eliemichel/WebGPU-distribution/archive/refs/heads/wgpu.zip
#wget https://github.com/eliemichel/WebGPU-distribution/archive/refs/heads/wgpu.zip
unzip wgpu.zip

mv WebGPU-distribution-wgpu/bin/linux-x86_64 ./
mv WebGPU-distribution-wgpu/bin/macos-aarch64 ./
mv WebGPU-distribution-wgpu/bin/macos-x86_64 ./

# mv WebGPU-distribution-wgpu/bin/linux-i386 ./
mv WebGPU-distribution-wgpu/wgpu-native-git-tag.txt ./
mv WebGPU-distribution-wgpu/include/webgpu/*.h ./

rm -rf WebGPU-distribution-wgpu wgpu.zip
