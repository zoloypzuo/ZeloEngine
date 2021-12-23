^!b::  ; Ctrl+Alt+B
Gui, Add, Button,, Build\build_vs2019_bat
Gui, Add, Button,, Runner\run_zelo_bat

Gui, Show
Return


ButtonBuild\build_vs2019_bat:
Gui, Submit, NoHide
    Run, ..\Build\build_vs2019.bat
Return


ButtonRunner\run_zelo_bat:
Gui, Submit, NoHide
    Run, ..\Runner\run_zelo.bat
Return