from distutils.core import setup, Extension
import sys
from os import environ
from os.path import dirname, join, abspath

if environ.get('PYLFK_BENHMARK_USE_SETUPTOOLS'):
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
import sysconfig
if platform == 'win32':
    cstdarg = '-std=gnu99'
else:
    cstdarg = '-std=c99'

use_embed_signature = environ.get('USE_EMBEDSIGNATURE', '0') == '1'
use_embed_signature = use_embed_signature or bool(
    platform not in ('ios', 'android'))



with open(join(dirname(__file__), 'lfkbenchmark', 'lfkbenchmark.pyx')) as f:
    for line in f.readline():
        if line.startswith('__version__'):
            __version__ == line.split('=')[-1].strip()[1:-1]

class CythonExtension(Extension):

    def __init__(self, *args, **kwargs):
        Extension.__init__(self, *args, **kwargs)
        self.cython_directives = {
            'c_string_encoding': 'utf-8',
            'profile': 'USE_PROFILE' in environ,
            'embedsignature': use_embed_signature,
            'language_level': 3,
            'unraisable_tracebacks': True,
        }
        # XXX with pip, setuptools is imported before distutils, and change
        # our pyx to c, then, cythonize doesn't happen. So force again our
        # sources
        self.sources = args[1]

if have_cython:
    benchy_files = [join('lfkbenchmark', 'lfkbenchmark.pyx'), ]
    cmdclass = {'build_ext': build_ext}
else:
    benchy_files = [join('lfkbenchmark', 'lfkbenchmark.c'), ]
    cmdclass = {}

root_dir = abspath(dirname(__file__))
ext = CythonExtension('lfkbenchmark',
    benchy_files,
    include_dirs=[join(root_dir, 'lfk-mp-benchmark', 'lfk_benchmark', 'inc')],
    language="c",
    libraries=["liblfk-benchmark" if sysconfig.get_platform() == 'mingw' else "lfk-benchmark"],
    library_dirs=[
        join(root_dir, 'lfk-mp-benchmark', 'build_local', 'cmake_build', 'lfk_benchmark'),
        join(root_dir, 'lfk-mp-benchmark', 'build', 'lfk_benchmark'),
        join(root_dir, 'lfk-mp-benchmark', 'build-' + ('x64' if sys.maxsize > 2**32 else 'Win32'), 'lfk_benchmark', 'Release')]
    )

setup(
    name='lfkbenchmark',
    description='Python Interface to lfk-mp-benchmark',
    author='quanon',
    author_email='akshay@kivy.org',
    cmdclass=cmdclass,
    packages=['lfkbenchmark'],
    package_data={'lfkbenchmark': [join('lfk-mp-benchmark', 'lfk_benchmark', 'inc', 'lfk.h'), ]},
    package_dir={'lfkbenchmark': 'lfkbenchmark'},
    options={'bdist_wheel':{'universal':'1'}},
    ext_modules=[ext],
    version='v1.0.0-Beta.2'
)
