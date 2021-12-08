import os
import re
import shutil


def copy(src, dest):
    if os.path.dirname(src) == dest:
        return
    print("copy to %s => %s" % (src, src))
    shutil.copy(src, dest)


def write(filename, content):
    print("write to =>", filename)
    with open(filename, "w") as fp:
        fp.write(content)


def read(filename):
    with open(filename, "r") as fp:
        return fp.read()


def list_dir(dir_):
    return [f for f in os.listdir(dir_) if os.path.isdir(os.path.join(dir_, f))]


def iter_files(root, predicate, ignore):
    for root, dirs, files in os.walk(root, topdown=True):
        dirs[:] = [d for d in dirs if d not in ignore]
        for file in files:
            if predicate(file):
                yield os.path.join(root, file)


def main():
    print("build from source:")
    for dir_ in list_dir("../ThirdParty"):
        print("*", dir_.lower())

    print()
    print("build from vcpkg:")
    libs = set()
    for file in iter_files("../",
                           lambda name: name == "CMakeLists.txt",
                           ["ThirdParty", "Playbox", "deps", "__Deprecated", "Dep"]):
        content = read(file)
        for line in content.splitlines():
            match_obj = re.search(r"find_package\((.*) CONFIG REQUIRED\)", line)
            if match_obj:
                libs.add(match_obj.group(1).lower())

    rename_map = {"unofficial-sqlite3": "sqlite3"}
    libs = sorted([rename_map.get(lib, lib) for lib in libs])
    for dir_ in sorted(list(libs)):
        print("*", dir_)

    print()
    print("install command:")
    print(r"Vcpkg\vcpkg.exe install --triplet x86-windows " + " ".join(libs))
    print(r"Vcpkg\vcpkg.exe install --triplet x86-windows "
          "glad[extensions,gl-api-latest,gles1-api-latest,gles2-api-latest,glsc2-api-latest] --recurse")


if __name__ == '__main__':
    main()
