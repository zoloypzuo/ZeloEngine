scripts = [
    "run_overload.bat",
    "run_zelo.bat"
]

template = r"""
^!b::  ; Ctrl+Alt+B
%s
Gui, Show
Return

%s
"""

stmt_add_button = "Gui, Add, Button,, %s\n"
stmt_run_script = """
Button%s:
Gui, Submit, NoHide
    Run, Tools\Runner\%s
Return\n
"""


def join(strs):
    return "".join(strs)

def script_id(script):
    return script.replace(".", "_")

code = template % (
    join([stmt_add_button % script_id(script) for script in scripts]),
    join([stmt_run_script % (script_id(script), script) for script in scripts])
)

with open("../build.ahk", "w") as fp:
    fp.write(code.strip())