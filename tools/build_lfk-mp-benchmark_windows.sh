#!/bin/bash

# Copyright (c) 2022 Waverian Team

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

# let's build lfk-mp-benchmark

# check if lfk-mp-benchmark has repository

mkdir -p lfk-mp-benchmark/build-Win32
pushd lfk-mp-benchmark/build-Win32
cmake .. -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=On -A Win32
cmake --build . --config Release
popd

mkdir -p lfk-mp-benchmark/build-x64
pushd lfk-mp-benchmark/build-x64
cmake .. -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=On -A x64
cmake --build . --config Release
popd
