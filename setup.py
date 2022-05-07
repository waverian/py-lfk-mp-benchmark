from distutils.core import setup, Extension
from Cython.Build import cythonize
import os

setup(ext_modules = cythonize(Extension(
    "benchy",
    sources=["benchy.pyx"],
    include_dirs=['lfk-mp-benchmark/lfk_benchmark/inc'],
    language="c",
    # extra_link_args=["-L/Users/quanon/code/waverian/benchmarkapp/benchmarkapp/service/bench/"],
    extra_objects=["lfk-mp-benchmark/build_local/cmake_build/lfk_benchmark/liblfk-benchmark.dylib"],
    # libraries=["liblfk-benchmark.dylib"]
)))
