import os
import re

EngineDir = "../.."


def write(filename, content):
    print("write to =>", filename)
    with open(filename, "w") as fp:
        fp.write(content)


def read(filename):
    with open(filename, "r") as fp:
        return fp.read()


def iter_files(root, predicate, ignore):
    for root, dirs, files in os.walk(root, topdown=True):
        dirs[:] = [d for d in dirs if d not in ignore]
        for file in files:
            if predicate(file):
                yield os.path.join(root, file)


def find_pattern(patterns, line):
    for pattern in patterns:
        match_obj = re.search(pattern, line)
        if match_obj:
            return match_obj.group(1)
    return ""


def main():
    options = set()
    for file in iter_files(EngineDir,
                           lambda name: name == "CMakeLists.txt",
                           ["ThirdParty", "Playbox", "deps", "__Deprecated", "Dep", "Resource"]):
        content = read(file)
        for line in content.splitlines():
            result = find_pattern([r"option\((.*)\)"], line)
            if result:
                options.add(result)

    options = sorted(options)

    doc_buffer = []
    doc_buffer.append("engine cmake options:\n")
    for dir_ in sorted(list(options)):
        doc_buffer.append("* " + dir_)

    write("../../Doc/BuildOptions.md", "\n".join(doc_buffer))


if __name__ == '__main__':
    main()
