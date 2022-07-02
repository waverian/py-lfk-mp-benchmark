#!/bin/bash 

# let's build lfk-mp-benchmark
sh ./tools/build_lfk-mp-benchmark_multiarch_lib.sh

rm -rf build
python setup.py build_ext -t build/
pip wheel . -w build/wheels

pip install delocate
LFK_WHEEL=$(ls build/wheels/)
DYLD_LIBRARY_PATH=lfk-mp-benchmark/build_local/cmake_build/lfk_benchmark delocate-wheel -w build/fixed_wheels -v build/wheels/"$LFK_WHEEL"

