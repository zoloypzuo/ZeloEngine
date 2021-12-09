import os
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


def match_ext(ext):
    return lambda item: os.path.splitext(item)[1] == ext


def file_size(filename):
    return os.path.getsize(filename)


def main():
    for file in sorted([_ for _ in iter_files("../Engine", match_ext(".cpp"), [])], key=file_size):
        if file_size(file) < 200:
            print(file, file_size(file))


if __name__ == '__main__':
    main()
