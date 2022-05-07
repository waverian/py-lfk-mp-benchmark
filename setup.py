from distutils.core import setup, Extension
from Cython.Build import cythonize
import os

# -----------------------------------------------------------------------------
# Determine on which platform we are

build_examples = build_examples or \
    os.environ.get('KIVY_BUILD_EXAMPLES', '0') == '1'

platform = sys.platform

# Detect Python for android project (http://github.com/kivy/python-for-android)
ndkplatform = environ.get('NDKPLATFORM')
if ndkplatform is not None and environ.get('LIBLINK'):
    platform = 'android'
kivy_ios_root = environ.get('KIVYIOSROOT', None)
if kivy_ios_root is not None:
    platform = 'ios'
# proprietary broadcom video core drivers
if exists('/opt/vc/include/bcm_host.h'):
    used_pi_version = pi_version
    # Force detected Raspberry Pi version for cross-builds, if needed
    if 'KIVY_RPI_VERSION' in environ:
        used_pi_version = int(environ['KIVY_RPI_VERSION'])
    # The proprietary broadcom video core drivers are not available on the
    # Raspberry Pi 4
    if (used_pi_version or 4) < 4:
        platform = 'rpi'
# use mesa video core drivers
if environ.get('VIDEOCOREMESA', None) == '1':
    platform = 'vc'
mali_paths = (
    '/usr/lib/arm-linux-gnueabihf/libMali.so',
    '/usr/lib/arm-linux-gnueabihf/mali-egl/libmali.so',
    '/usr/local/mali-egl/libmali.so')
if any((exists(path) for path in mali_paths)):
    platform = 'mali'

eo ={
    'darwin': "lfk-mp-benchmark/build_local/cmake_build/lfk_benchmark/liblfk-benchmark.dylib",
    'ios': 'lfk-mp-benchmark/build_local/cmake_build/lfk_benchmark/liblfk-benchmark.a',
    'windows': 'lfk-mp-benchmark/build_local/cmake_build/lfk_benchmark/liblfk-benchmark.dll'
    'linux': 'lfk-mp-benchmark/build_local/cmake_build/lfk_benchmark/liblfk-benchmark.so'
}
 [platform]

setup(ext_modules = cythonize(Extension(
    "benchy",
    sources=["benchy.pyx"],
    include_dirs=['lfk-mp-benchmark/lfk_benchmark/inc'],
    language="c",
    # extra_link_args=["-L/Users/quanon/code/waverian/benchmarkapp/benchmarkapp/service/bench/"],
    extra_objects=eo,
    # libraries=["liblfk-benchmark.dylib"]
)))
