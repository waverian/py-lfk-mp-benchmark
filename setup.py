from distutils.core import setup, Extension
import sys
from os import environ
from os.path import dirname, join

if environ.get('BENCHY_USE_SETUPTOOLS'):
    from setuptools import setup, Extension
    print('Using setuptools')
else:
    from distutils.core import setup
    from distutils.extension import Extension
    print('Using distutils')

try:
    from Cython.Distutils import build_ext
    have_cython = True
except ImportError:
    have_cython = False


platform = sys.platform
if platform == 'win32':
    cstdarg = '-std=gnu99'
else:
    cstdarg = '-std=c99'

if have_cython:
    benchy_files = ['benchy.pyx']
    cmdclass = {'build_ext': build_ext}
else:
    benchy_files = ['benchy.c']
    cmdclass = {}

ext = Extension('benchy',
    benchy_files,
    include_dirs=['lfk-mp-benchmark/lfk_benchmark/inc'],
    language="c",
    extra_link_args=["-Llfk-mp-benchmark/build_local/cmake_build/lfk_benchmark/"],
    libraries=["lfk-benchmark"])

setup(
    name='benchy',
    description='Python Interface to lfk-mp-benchmark',
    author='quanon',
    author_email='akshay@kivy.org',
    cmdclass=cmdclass,
    packages=['benchy'],
    package_data={'benchy': ['lfk-mp-benchmark/lfk_benchmark/inc/lfk.h',]},
    package_dir={'benchy': 'benchy'},
    ext_modules=[ext],
    version='0.0.0.dev0'
)


# setup(ext_modules = cythonize(Extension(
#     "benchy",
#     sources=["benchy.pyx"],
#     include_dirs=['lfk-mp-benchmark/lfk_benchmark/inc'],
#     language="c",
#     extra_link_args=["-Llfk-mp-benchmark/build_local/cmake_build/lfk_benchmark/"],
#     libraries=["lfk-benchmark"]
# )))
