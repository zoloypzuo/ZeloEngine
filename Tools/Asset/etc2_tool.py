import os

import time

EngineDir = "../.."

SrcDir = os.path.join(EngineDir, "Resource/GRCookbookAssets/textures")
OutDir = os.path.join(EngineDir, "Resource/GRCookbookAssets/textures_ktx")


def iter_files(root, predicate, ignore):
    for root, dirs, files in os.walk(root, topdown=True):
        dirs[:] = [d for d in dirs if d not in ignore]
        for file in files:
            if predicate(file):
                yield os.path.join(root, file)


def main():
    t1 = time.time()
    with open("etc2_tool.bat", "w") as fp:
        for file in iter_files(SrcDir, lambda file: True, []):
            basename = os.path.basename(file)
            out_path = os.path.join(OutDir, basename.replace(".png", ".ktx"))
            print("EtCTool", file, "-jobs 18", "-output", out_path, file=fp)
    os.system("etc2_tool.bat")
    t2 = time.time()
    print("etc2_tool finished with [%s] s", t2 - t1)
    os.remove("etc2_tool.bat")


if __name__ == '__main__':
    main()
