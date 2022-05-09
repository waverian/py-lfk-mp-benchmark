import os
from kivy.logger import Logger
from kivy.utils import platform

CPU_COUNT = 0 #0  is auto # os.cpu_count()
LFKX_FAST = 'LFKX_FAST' in os.environ

ctypedef void (*benchmark_progress_callback_t)(void *data, int progress,
                                          const char *message)

cdef extern from "lfk.h":
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
    print(progress, message)

cdef void progress_callback(void *data, int progress,
                                                  const char *message) nogil:
        with gil:
            callback_func(progress, message)

cdef class lfk_benchmark:

    cdef benchmark_handler_t handler

    def _setup_benchmark(self):
        Logger.debug('Benchmark App: benchmark init.')
        self.handler = handler = benchmark_init()
        Logger.debug('Benchmark App: set execution time.')
        benchmark_set_execution_time(handler, 1.00000)# 1 execution per sec
        Logger.debug('Benchmark App: set core count to auto.')
        benchmark_set_core_count(handler, CPU_COUNT)
        Logger.debug('Benchmark App: set progress callback.')
        callbackHandler = benchmark_progress_callback_handler_tf
        # Logger.debug('-5')
        # callbackHandler.data = None
        callbackHandler.callback = progress_callback
        benchmark_set_progress_callback(handler, callbackHandler)
        # Logger.debug('-3')

    def run_benchmark(self, callback=None):
        Logger.debug('Benchy:  Setting up benchmark.')
        if callback:
            callback_func = callback
        
        self._setup_benchmark()
        handler = self.handler

        Logger.debug('Benchy: Runing benchmark.')
        with nogil:
            benchmark_run(handler)

        # Logger.debug('Benchy: Getting results.')
        results = self._get_results()

        # Logger.debug('Benchy: Cleaning up.')
        self._cleanup()

        # Logger.debug('Benchy: Returning results.')
        return results

    def _get_results(self):
        handler = self.handler
        benchmark_version = benchmark_get_version(handler).decode('utf-8')
        Logger.debug(f'BenchMarkApp: Benchmark Version: {benchmark_version}')
        benchmark_date = benchmark_get_date(handler).decode('utf-8')
        benchmark_compiler = benchmark_get_compiler_info(handler).decode('utf-8')
        Logger.debug(f'BenchMarkApp: Benchmark Compiler: {benchmark_compiler}')
        benchmark_core_count = benchmark_get_core_count(handler)
        Logger.debug(f'BenchMarkApp: Benchmark Core Count: {benchmark_core_count}')
        cdef const lfk_full_result_t *results = benchmark_get_results(handler)


        
        return {
            'version': benchmark_version, 'date': benchmark_date,
            'compiler': benchmark_compiler, 'core_count': benchmark_core_count,
            'singlecore_results': results.singlecore_result,
            'multicore_results': results.multicore_result,
            'results': results.lfk_run_result}

    def _cleanup(self):
        benchmark_cleanup(self.handler)
