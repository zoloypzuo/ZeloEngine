"""
test command time
usage example:
python build_time.py build_vs2019.py
"""
import datetime
import os
import timeit

EngineDir = "../.."
BuildDir = os.path.abspath(os.path.join(EngineDir, "build_ninja"))
BuildBat = os.path.abspath(os.path.join(EngineDir, "Tools", "Build", "build_ninja.bat"))
BuildStatFile = os.path.join(EngineDir, "Tools", "Statistics", "build_time_result.txt")

if __name__ == '__main__':
    if os.path.exists(BuildDir):
        os.system("rd /s/q " + BuildDir)

    time_cost = timeit.timeit("os.system(%s)" % repr(BuildBat), setup="import os", number=1)
    print("time cost ", time_cost)
    with open(BuildStatFile, "a") as fp:
        fp.write("%s %s\n" % (datetime.datetime.now(), time_cost))
