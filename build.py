import os
import shutil
import sys


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
    print("write to =>", boot_ini_path)
    with open(boot_ini_path, "w") as fp:
        fp.write(content)

    # copy vld.ini
    vld_ini_src_path = os.path.join(engine_dir, "Config/vld.ini")
    vld_ini_dest_path = os.path.join(exe_dir, "vld.ini")
    print("copy to %s => %s" % (vld_ini_src_path, vld_ini_dest_path))
    shutil.copy(vld_ini_src_path, vld_ini_dest_path)

    # copy lua51.dll
    print("copy to %s => %s" % (lua51_dll_path, exe_dir))
    shutil.copy(lua51_dll_path, exe_dir)

    print("build.py end")


if __name__ == '__main__':
    main()
