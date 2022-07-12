#!/bin/bash 

# let's build lfk-mp-benchmark
./tools/build_lfk-mp-benchmark_multiarch_lib.sh

# remove intermediates
rm -rf build

# setup wheels
python setup.py build_ext -t build/

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
	# Linux
	# Install deps
	python -m venv temp-venv
	source temp-venv/bin/activate
	pip install wheel cython

	echo
	echo "Building wheels"
	echo
        pip wheel . -w build/wheels
	echo
	echo "**wheels available in build/wheels**"
	echo $(pwd)/build/wheels/$(ls build/wheels/)
	echo 
	echo auditing...
	echo
	LFK_WHEEL=$(ls build/wheels/)
	LD_LIBRARY_PATH=lfk-mp-benchmark/build/lfk_benchmark auditwheel repair build/wheels/$LFK_WHEEL -w fixed_wheels
elif [[ "$OSTYPE" == "darwin"* ]]; then
	# Install deps
	python3 -m venv temp-venv
	source temp-venv/bin/activate
	pip install wheel cython

        # Mac OSX
	pip wheel . -w build/wheels
	pip install delocate
        LFK_WHEEL=$(ls build/wheels/)
        DYLD_LIBRARY_PATH=lfk-mp-benchmark/build/lfk_benchmark delocate-wheel -w build/fixed_wheels -v build/wheels/"$LFK_WHEEL"
	echo
	echo "wheels available in build/fixed_wheels directory"
	echo $(ls build/fixed_wheels/)
#elif [[ "$OSTYPE" == "cygwin" ]]; then
#        # POSIX compatibility layer and Linux environment emulation for Windows
#elif [[ "$OSTYPE" == "msys" ]]; then
#        # Lightweight shell and GNU utilities compiled for Windows (part of MinGW)
#elif [[ "$OSTYPE" == "win32" ]]; then
#        # I'm not sure this can happen.
#elif [[ "$OSTYPE" == "freebsd"* ]]; then
#        # ...
#else
#        # Unknown.
fi



deactivate
rm -rf temp-venv

