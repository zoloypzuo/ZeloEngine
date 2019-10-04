# @rem build.bat
# @rem created on 2019/8/31
# @rem author @zoloypzuo

Write-Output @"
=========================
==== build.ps1 start ====
=========================
"@
$CurrentDir = Get-Location
$ScriptDir = $PSScriptRoot
Set-Location -Path $ScriptDir

Write-Output @"
========================================
==== set environment variable start ====
========================================
"@

setx LUA_INIT_5_3 "@D:\ZeloEngine\Src\Script\global.lua"
setx LUA_PATH_5_3 @"
D:\LuaRocks\lua\?.lua;
D:\LuaRocks\lua\?\init.lua;
D:\ZeloEngine\lua\?.lua;
D:\ZeloEngine\lua\?\init.lua;
D:\ZeloEngine\?.lua;
D:\ZeloEngine\?\init.lua;
D:\ZeloEngine\..\share\lua\5.3\?.lua;
D:\ZeloEngine\..\share\lua\5.3\?\init.lua;
.\?.lua;
.\?\init.lua;
C:\Users\91018\AppData\Roaming/luarocks/share/lua/5.3/?.lua;
C:\Users\91018\AppData\Roaming/luarocks/share/lua/5.3/?/init.lua;
D:\LuaRocks\systree/share/lua/5.3/?.lua;
D:\LuaRocks\systree/share/lua/5.3/?/init.lua;
D:\ZeloEngine\Src\Script\?.lua
"@

setx LUA_CPATH_5_3 @"
D:\ZeloEngine\?.dll;
D:\ZeloEngine\..\lib\lua\5.3\?.dll;
D:\ZeloEngine\loadall.dll;.\?.dll;
D:\ZeloEngine\?53.dll;
.\?53.dll;
C:\Users\91018\AppData\Roaming/luarocks/lib/lua/5.3/?.dll;
D:\LuaRocks\systree/lib/lua/5.3/?.dll
"@

Write-Output ================================
# Write-Output ==== cmake build zelo start ====
# Write-Output ================================
mkdir build
Set-Location build
cmake -G "Visual Studio 16" ..

function buildVS
{
    param
    (
        [parameter(Mandatory=$true)]
        [String] $path
    )
    process
    {
        $msBuildExe = "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\MSBuild.exe"

        Write-Host "Building $($path)" -foregroundcolor green
        & "$($msBuildExe)" "$($path)" /t:Build /m
    }
}

Write-Output @"
=======================
==== msbuild start ====
=======================
"@
buildVS ZeloEngine.sln

# @rem lib build switch, uncomment this only when you want to rebuild lib
# rem call External/build.bat

# @rem call submodule build here
# rem call d3d12book/build.bat
# rem call GameEngineFromScratch/Article21_DX12App/build.bat

# Write-Output =======================
# Write-Output ==== build.ps1 end ====
# Write-Output =======================
# Set-Location $CurrentDir
# pause