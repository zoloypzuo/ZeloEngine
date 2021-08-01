"""
test command time
usage example:
python build_time.py build_vs2019.py
"""
import datetime
import sys
import timeit
import os

if __name__ == '__main__':
    argv = sys.argv
    filename = argv[1] if len(argv) > 1 else "build_vs2019.bat"
    os.system("build_clean.bat")
    delta_time = timeit.timeit("os.system(%s)" % repr(filename), setup="import os", number=1)
    print("time cost ", delta_time)
    with open("build_time_%s.txt" % filename, "a") as fp:
        fp.write("%s %s\n" % (datetime.datetime.now(), delta_time))
