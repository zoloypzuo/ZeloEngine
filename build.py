import os
import shutil
import sys


def copy(src, dest):
    if os.path.dirname(src) == dest:
        return
    print("copy to %s => %s" % (src, src))
    shutil.copy(src, dest)


def write(filename, content):
    print("write to =>", filename)
    with open(filename, "w") as fp:
        fp.write(content)


def main():
    print("build.py start")
    engine_dir = sys.argv[1]
    exe_dir = sys.argv[2]
    lua51_dll_path = sys.argv[3]

    # create boot.ini
    boot_ini_path = os.path.join(exe_dir, "boot.ini")
    content_template = """
    [boot]
    engineDir = {}
    """.lstrip()
    content = content_template.format(engine_dir)
    write(boot_ini_path, content)

    # copy lua51.dll
    copy(lua51_dll_path, exe_dir)

    print("build.py end")


if __name__ == '__main__':
    main()
