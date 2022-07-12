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
if platform == 'win32':
    cstdarg = '-std=gnu99'
else:
    cstdarg = '-std=c99'

use_embed_signature = environ.get('USE_EMBEDSIGNATURE', '0') == '1'
use_embed_signature = use_embed_signature or bool(
    platform not in ('ios', 'android'))

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
    benchy_files = ['py-lfk-mp-benchmark/pylfk_benchmark.pyx']
    cmdclass = {'build_ext': build_ext}
else:
    benchy_files = ['pyl-fk-mp-benchmark/pylfk_benchmark.c']
    cmdclass = {}

root_dir = abspath(dirname(__file__))
ext = CythonExtension('lfkbenchmark',
    benchy_files,
    include_dirs=[f'{root_dir}/lfk-mp-benchmark/lfk_benchmark/inc'],
    language="c",
    libraries=["liblfk-benchmark" if platform == 'win32' else "lfk-benchmark"],
    library_dirs=[f'{root_dir}/lfk-mp-benchmark/build/lfk_benchmark' + ('/Release' if platform == 'win32' else '')]
    )

setup(
    name='lfkbenchmark',
    description='Python Interface to lfk-mp-benchmark',
    author='quanon',
    author_email='akshay@kivy.org',
    cmdclass=cmdclass,
    packages=['lfkbenchmark'],
    package_data={'lfkbenchmark': ['lfk-mp-benchmark/lfk_benchmark/inc/lfk.h', ]},
    package_dir={'lfkbenchmark': 'py-lfk-mp-benchmark'},
    options={'bdist_wheel':{'universal':'1'}},
    ext_modules=[ext],
    version='0.1.0.dev0'
)