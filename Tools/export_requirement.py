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


def rename_vcpkg_pkg(name):
    # type: (str) -> str
    prefix = "unofficial-"
    if name.startswith(prefix):
        return name[len(prefix):]
    return name


def main():
    print("build from source:")
    for dir_ in list_dir("../ThirdParty"):
        print("*", dir_.lower())

    print()
    print("build from vcpkg:")
    libs = set()
    for file in iter_files("../",
                           lambda name: name == "CMakeLists.txt",
                           ["ThirdParty", "Playbox", "deps", "__Deprecated", "Dep", "Resource"]):
        content = read(file)
        for line in content.splitlines():
            match_obj = re.search(r"find_package\((.*) CONFIG REQUIRED\)", line)
            if match_obj:
                libs.add(match_obj.group(1).lower())

    libs = sorted([rename_vcpkg_pkg(lib) for lib in libs])
    for dir_ in sorted(list(libs)):
        print("*", dir_)

    print()
    print("install command:")

    triplets = ["x86-windows"]
    for triplet in triplets:
        print(r"Vcpkg\vcpkg.exe install --triplet %s " % triplet + " ".join(libs))
        print(r"Vcpkg\vcpkg.exe install --triplet %s " % triplet +
              "glad[extensions,gl-api-latest,gles1-api-latest,gles2-api-latest,glsc2-api-latest] --recurse")

    code = [r"@echo off",
            r"set CurrentDir=%cd%",
            r"set ScriptDir=%~dp0",
            r"set EngineDir=%ScriptDir%\..\..",
            r"set Args=%*",
            r"",
            r"cd /d %EngineDir%",
            r"@echo on",
            r"",
            r"cd %EngineDir%\ThirdParty", ]
    for triplet in triplets:
        code.append(r"Vcpkg\vcpkg.exe install --triplet %s " % triplet + " ".join(libs))
        code.append(r"Vcpkg\vcpkg.exe install --triplet %s " % triplet +
                    "glad[extensions,gl-api-latest,gles1-api-latest,gles2-api-latest,glsc2-api-latest] --recurse")
    code.append("cd %CurrentDir%")
    code = "\n".join(code)
    write("Setup/vcpkg_install.bat", code)


if __name__ == '__main__':
    main()
