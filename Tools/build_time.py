"""
test command time
usage example:
python build_time.py build_vs2019.py
"""
import sys
import timeit

if __name__ == '__main__':
    argv = sys.argv
    if len(argv) > 1:
        timeit.timeit("os.system(%s)" % repr(argv[1]), setup="import os", number=1)
