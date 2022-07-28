'''This is the python module for interfacing with lfk-mp-benchmark.

 Usage::

     import lfkbenchmark
     benchmark = lfkbenchmark.lfk_benchmark()
     benchmark.console_run_benchmark()


 Repository: https://github.com/waverian/py-lfk-mp-benchmark

 For details of the C module look at https://github.com/waverian/lfk-mp-benchmark
 '''
 
#cython: language_level=3

import os
try:
    from kivy.logger import Logger
except ImportError: 
    import logging

    log = logging.getLogger()
    log.setLevel(logging.NOTSET)
    hd = logging.StreamHandler()
    hd.setLevel(logging.NOTSET)
    log.addHandler(hd)
    Logger = log


CPU_COUNT = 0 
'''
0:  is auto # os.cpu_count()
'''

__version__ = 'v1.0.0-Beta.4'

ctypedef void (*benchmark_progress_callback_t)(void *data, int progress,
                                          const char *message)

cdef extern from "lfk/lfk.h":
    ctypedef enum lfk_run_type_e:
        single_core_non_optimized,
        multi_core_non_optimized,
        single_core_optimized,
        multi_core_optimized

    ctypedef struct lfk_run_result_t:
        double run_type
        double maximum
        double average
        double geometric
        double harmonic
        double minimum
        double kernel_results[24]

    ctypedef struct lfk_full_result_t:
        double singlecore_result
        double multicore_result
        lfk_run_result_t lfk_run_result[4]

    ctypedef struct benchmark_progress_callback_handler_t:
        void *data
        benchmark_progress_callback_t callback

    ctypedef struct benchmark_handler_:
        unsigned core_count
        double execution_time
        unsigned optimization_enabled
        unsigned auto_mode  
        lfk_run_type_e  current_run
        char *compiler_info
        char *version_info
        char *timestamp
        lfk_full_result_t result 
        benchmark_progress_callback_handler_t progress_callback

    ctypedef benchmark_handler_ *benchmark_handler_t

    cdef benchmark_handler_t benchmark_init()
    cdef void benchmark_set_execution_time(benchmark_handler_t handler, double execution_time)
    cdef void benchmark_set_core_count(benchmark_handler_t handler, unsigned core_count)
    void benchmark_set_progress_callback(
        benchmark_handler_t handler,
        benchmark_progress_callback_handler_t callback)
    void benchmark_run(benchmark_handler_t handler) nogil
    const char *benchmark_get_version(benchmark_handler_t handler)
    const char *benchmark_get_date(benchmark_handler_t handler)
    const char *benchmark_get_compiler_info(benchmark_handler_t handler)
    unsigned int benchmark_get_core_count(benchmark_handler_t handler)
    const lfk_full_result_t *benchmark_get_results(benchmark_handler_t handler)
    void benchmark_cleanup(benchmark_handler_t handler)

cdef benchmark_progress_callback_handler_t benchmark_progress_callback_handler_tf


def callback_func(progress, message):
    '''Default progress callback for displaying benchmark progress. Override this to 
    Use your own callback.

    Arguments: 

        `data`: usually Null, type `void`.
        `progress`: Percentage benchmark progress, type: `int`.

    '''

    Logger.debug(f'LFKBenchmark: {progress}, {message}')


cdef void progress_callback(void *data, int progress,const char *message) nogil:
    with gil:
        callback_func(progress, message)

cdef class Benchmark:
    '''Wrapper around the lfkbenchmark module.
    '''

    cdef benchmark_handler_t handler

    cdef bint benchmark_initialised 

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.benchmark_initialised = False
        self._setup_benchmark()

    def _setup_benchmark(self):
        Logger.debug('LFKBenchmark: Setup benchmark init.')
        self.handler = handler = benchmark_init()
        self.benchmark_initialised = True
        Logger.debug('LFKBenchmark: set execution time.')
        benchmark_set_execution_time(handler, 1.00000)# 1 execution per sec
        Logger.debug('LFKBenchmark: set core count to auto.')
        benchmark_set_core_count(handler, CPU_COUNT)
        Logger.debug('LFKBenchmark: set progress callback.')
        callbackHandler = benchmark_progress_callback_handler_tf
        # Logger.debug('-5')
        # callbackHandler.data = None
        callbackHandler.callback = progress_callback
        benchmark_set_progress_callback(handler, callbackHandler)
        # Logger.debug('-3')

    def run_benchmark(self, callback=None):
        '''Run benchmark from UI.
        Warning::

            This is a blocking operation. You should be running this through a thread/async task.

        Arguments::
        
            `callback` pass a function here. Defaults to `None`.
        '''
        Logger.debug('LFKBenchmark:  Setting up benchmark.')
        if callback:
            callback_func = callback
        
        self._setup_benchmark()
        handler = self.handler

        Logger.debug('LFKBenchmark: Runing benchmark.')
        with nogil:
            benchmark_run(handler)

        Logger.debug('LFKBenchmark: Getting results.')
        results = self._get_results()

        Logger.debug('LFKBenchmark: Cleaning up.')
        self._cleanup()

        Logger.debug('LFKBenchmark: Returning results.')
        return results

    def run_print_benchmark(self):
        print(self.run_benchmark())

    def console_run_benchmark(self):
        '''Run the benchmark from console without blocking the terminal.
        '''
        import threading
        thread = threading.Thread(target=self.run_print_benchmark)
        thread.start()

    def _get_results(self):
        if not self.benchmark_initialised:
            self._setup_benchmark()
        handler = self.handler

        benchmark_version = benchmark_get_version(handler).decode('utf-8')
        Logger.debug(f'LFKBenchMark Version: {benchmark_version}')
        benchmark_date = benchmark_get_date(handler).decode('utf-8')
        benchmark_compiler = benchmark_get_compiler_info(handler).decode('utf-8')
        Logger.debug(f'LFKBenchMark Compiler: {benchmark_compiler}')
        benchmark_core_count = benchmark_get_core_count(handler)
        Logger.debug(f'LFKBenchMark Core Count: {benchmark_core_count}')
        cdef const lfk_full_result_t *results = benchmark_get_results(handler)


        
        return {
            'version': benchmark_version, 'date': benchmark_date,
            'compiler': benchmark_compiler, 'core_count': benchmark_core_count,
            'singlecore_results': results.singlecore_result,
            'multicore_results': results.multicore_result,
            'results': results.lfk_run_result}

    def _cleanup(self):
        benchmark_cleanup(self.handler)
