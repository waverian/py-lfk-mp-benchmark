This is a simple Python interface to lfk-mp-benchmark


# INSTALL

Make sure to either compile the lfk-mp-benchmark library in the root of this repo or just pass the path to the library for compilation::

    git --recurse-submodules clone `https://github.com/waverian/py-lfk-benchmark`
    cd pylfk-mp-benchmark
	cd lfk-mp-benchmark

## Compile lfk-mp-benchmark

### osx

#### Using script

    cd path/to/py-ldk-mp-benchmark
    sh tools/build_osx_wheel_universal2.sh

#### Manual instructions


Let's build  lfk-mp-benchmark submodule::

		mkdir -p lfk-mp-benchmark/build_local/cmake_build
	    cd lfk-mp-benchmark/build_local/cmake_build
	    CMAKE_OSX_ARCHITECTURES="arm64;x86_64" cmake ../../ -DCMAKE_BUILD_TYPE=Release
	    cmake --build .


Check if compiled lib shows both architectures::

	    % file lfk_benchmark/liblfk-benchmark.dylib 

Should give a output similar to::

	    lfk_benchmark/liblfk-benchmark.dylib: Mach-O universal binary with 2 architectures: [x86_64:Mach-O 64-bit dynamically linked shared library x86_64Mach-O 64-bit dynamically linked shared library x86_64] [arm64:Mach-O 64-bit dynamically linked shared library arm64Mach-O 64-bit dynamically linked shared library arm64]
		lfk_benchmark/liblfk-benchmark.dylib (for architecture x86_64):	Mach-O 64-bit dynamically linked shared library x86_64
		lfk_benchmark/liblfk-benchmark.dylib (for architecture arm64):	Mach-O 64-bit dynamically linked shared library arm64


Let's build our wheel for py-lfk-benchmark

	    % python setup.py build_ext -t build/

	Now Let's build our wheel.

		% pip wheel . -w build/wheels

	This wheel by default does not include the liblfk-benchmark.so to include this we need `delocate` package

```
        % pip install delocate
        % DYLD_LIBRARY_PATH=lfk-mp-benchmark/build_local/cmake_build/lfk_benchmark delocate-wheel -w fixed_wheels -v build/wheels/path/to/your/wheel.universal2.whl
```

    The wheel in dir fixed_wheels should now be a univeral wheel that should be able dynamically load the benchmark lib.
    Let's test this::

```
		% pip install fixed_wheels/lfkbenchmark-0.1.0.dev0-cp39-cp39-macosx_10_9_universal2.whl
		% python -c "import lfkbenchmark"

