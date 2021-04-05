^!b::  ; Ctrl+Alt+B
Gui, Add, Button,, BuildClean
Gui, Add, Button,, BuildSwig
Gui, Add, Button,, BuildVS2017
Gui, Add, Button,, BuildVS2019
Gui, Show
Return

LCtrl & Esc::Gui Cancel

ButtonBuildClean:
Gui, Submit, NoHide
    Run, Tools\build_clean.bat
Return

ButtonBuildSwig:
Gui, Submit, NoHide
    Run, Tools\build_swig.bat
Return


ButtonBuildVS2017:
Gui, Submit, NoHide
    Run, Tools\build_vs2017.bat
Return

ButtonBuildVS2019:
Gui, Submit, NoHide
    Run, Tools\build_vs2019.bat
Return
