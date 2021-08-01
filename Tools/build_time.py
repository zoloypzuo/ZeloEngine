"""
test command time
usage example:
python build_time.py build_vs2019.py
"""
import datetime
import os
import timeit

if __name__ == '__main__':
    exe_filename = "build_vs2019.bat"
    output_filename = "build_time_vs2019.txt"
    clean_filename = "build_clean_vs2019.bat"

    os.system(clean_filename)
    time_cost = timeit.timeit("os.system(%s)" % repr(exe_filename), setup="import os", number=1)
    print("time cost ", time_cost)
    with open(output_filename, "a") as fp:
        fp.write("%s %s\n" % (datetime.datetime.now(), time_cost))
