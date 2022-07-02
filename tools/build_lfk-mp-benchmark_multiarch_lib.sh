#!/bin/bash 

# let's build lfk-mp-benchmark

# check if lfk-mp-benchmark has repository

mkdir -p lfk-mp-benchmark/build_local/cmake_build
pushd lfk-mp-benchmark/build_local/cmake_build
CMAKE_OSX_ARCHITECTURES="arm64;x86_64" cmake ../../ -DCMAKE_BUILD_TYPE=Release
cmake --build .
popd