^!b::  ; Ctrl+Alt+B
Gui, Add, Button,, run_overload_bat
Gui, Add, Button,, run_zelo_bat

Gui, Show
Return

LCtrl & Esc::Gui Cancel


Buttonrun_overload_bat:
Gui, Submit, NoHide
    Run, Tools\run_overload.bat
Return


Buttonrun_zelo_bat:
Gui, Submit, NoHide
    Run, Tools\run_zelo.bat
Return