# build.ps1
# created on 2019/8/31
# author @zoloypzuo

function Initialize {
    Write-Output @"
=========================
==== build.ps1 start ====
=========================
"@
    $global:CurrentDir = Get-Location
    $global:ScriptDir = $PSScriptRoot
    Set-Location -Path $ScriptDir
}

function Finialize {
    Write-Output @"
=========================
==== build.ps1 end ====
=========================
"@
    Set-Location $global:CurrentDir
    # pause
}

function BuildZeloEngine {
    Write-Output @"
=================================================
==== cmake config-generate zelo-engine start ====
=================================================
"@
    New-Item -ItemType Directory -Force -Path build  # https://stackoverflow.com/questions/16906170/create-directory-if-it-does-not-exist
    Set-Location build
    cmake -DCMAKE_TOOLCHAIN_FILE=D:/vcpkg/scripts/buildsystems/vcpkg.cmake -G  "Visual Studio 16" ..

    Write-Output @"
===============================================
==== visual studio build zelo-engine start ====
===============================================
"@
    cmake --build . --config debug
}

Initialize
BuildZeloEngine
Finialize

