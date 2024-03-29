import os
import re
import shutil

EngineDir = "../.."
ThirdPartyDir = os.path.join(EngineDir, "ThirdParty")


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
    if name == "absl":
        return "abseil[cxx17]"
    return name


def find_package(patterns, line):
    for pattern in patterns:
        match_obj = re.search(pattern, line)
        if match_obj:
            return match_obj.group(1)
    return ""


def main():
    libs = set()
    for file in iter_files(EngineDir,
                           lambda name: name == "CMakeLists.txt",
                           ["ThirdParty", "Playbox", "deps", "__Deprecated", "Dep", "Resource"]):
        content = read(file)
        for line in content.splitlines():
            result = find_package([r"find_package\((.*) CONFIG REQUIRED\)", r"find_path\((.*)_INCLUDE_DIRS"], line)
            if result:
                lib_name = result.lower().replace("_", "-")
                libs.add(lib_name)

    libs = sorted([rename_vcpkg_pkg(lib) for lib in libs])

    doc_buffer = []
    doc_buffer.append("build from source:\n")
    for dir_ in list_dir(ThirdPartyDir):
        doc_buffer.append("* " + dir_.lower())
    doc_buffer.append("")
    doc_buffer.append("build from vcpkg:\n")
    for dir_ in sorted(list(libs)):
        doc_buffer.append("* " + dir_)

    write("../../Doc/ThirdParty.md", "\n".join(doc_buffer))

    triplets = ["x86-windows", "x64-windows"]
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
    write("vcpkg_install.bat", code)


if __name__ == '__main__':
    main()
