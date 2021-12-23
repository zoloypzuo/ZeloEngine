import os
import shutil

import sys

content_template = """
    [boot]
    engineDir = {}
    """.lstrip()


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
    engine_relative_dir = engine_dir  # os.path.relpath(engine_dir, exe_dir) for release build
    write(boot_ini_path, content_template.format(engine_relative_dir))

    # copy vld.ini
    vld_ini_src_path = os.path.join(engine_dir, "Config", "vld.ini")
    vld_ini_dest_path = os.path.join(exe_dir, "vld.ini")
    copy(vld_ini_src_path, vld_ini_dest_path)

    # copy lua51.dll
    copy(lua51_dll_path, exe_dir)

    print("build.py end")


if __name__ == '__main__':
    main()
