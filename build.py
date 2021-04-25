import os

import sys

engine_dir = sys.argv[1]
exe_dir = sys.argv[2]
boot_ini_path = os.path.join(exe_dir, "boot.ini")
content_template = """
[boot]
engineDir = {}
""".lstrip()
content = content_template.format(engine_dir)
print "write to =>", boot_ini_path
with open(boot_ini_path, "w") as fp:
    fp.write(content)

# TODO copy vld.ini