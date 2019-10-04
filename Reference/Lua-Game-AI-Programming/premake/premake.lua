--require "SandboxDemos"
dofile("SandboxDemos.lua");

solution("Learning Game AI Programming")
location("../build/")
configurations({"Debug", "Release"})
platforms({"x32", "x64"})

-- configuration shared between all projects
language("C++")
includedirs({"../src/%{prj.name}/include/"})
-- warnings("Extra")
flags({
    -- "FatalWarnings",
    "MultiProcessorCompile",
    "NoEditAndContinue",
    "NoImplicitLink",
    "NoImportLib",
    "NoIncrementalLink",
    "NoMinimalRebuild",
    "StaticRuntime"
})
vpaths({
    ["include/*"] = {
        "src/%{prj.name}/include/**.h",
        "src/%{prj.name}/include/**.hpp"
    },
    ["script/*"] = {
        "src/%{prj.name}/script/**.lua"
    },
    ["src/*"] = {
        "src/%{prj.name}/src/**.c",
        "src/%{prj.name}/src/**.cpp"
    }})
    
    -- platform(windows/linux) specific configurations
    configuration("windows")
    -- fatal linker warnings
    -- linkoptions ({"/WX"})
    configuration("linux")
    configuration("*")
    
    -- solution configuration specific configurations
    configuration("Debug")
    -- debug symbols
    flags({"Symbols"})
    configuration("Release")
    -- optimized build
    optimize("Full")
    flags({"Symbols"})
    defines({"NDEBUG"})
    configuration("*")
    
    -- platform configurations
    configuration("x32")
    vectorextensions("SSE")
    vectorextensions("SSE2")
    -- build for x86-32bit machines
    linkoptions("/MACHINE:X86")
    configuration("x64")
    -- build for x86-64bit machine
    linkoptions("/MACHINE:X64")
    configuration("*")
    
    -- configurations for executables
    configuration({"ConsoleApp or WindowedApp", "x32", "Debug"})
    targetdir("../bin/x32/debug")
    libdirs({"../lib/x32/debug"})
    configuration({"ConsoleApp or WindowedApp", "x32", "Release"})
    targetdir("../bin/x32/release")
    libdirs({"../lib/x32/release"})
    configuration({"ConsoleApp or WindowedApp", "x64", "Debug"})
    targetdir("../bin/x64/debug")
    libdirs({"../lib/x64/debug"})
    configuration({"ConsoleApp or WindowedApp", "x64", "Release"})
    targetdir("../bin/x64/release")
    libdirs({"../lib/x64/release"})
    configuration("*")
    
    -- configurations for static libraries
    configuration({"StaticLib", "x32", "Debug"})
    targetdir("../lib/x32/debug")
    configuration({"StaticLib", "x32", "Release"})
    targetdir("../lib/x32/release")
    configuration({"StaticLib", "x64", "Debug"})
    targetdir("../lib/x64/debug")
    configuration({"StaticLib", "x64", "Release"})
    targetdir("../lib/x64/release")
    configuration("*")
    
    --------------------------------------------------------------------------------
    -- Demo application definitions
    --------------------------------------------------------------------------------
    -- All demo projects share the same configuration.
    local function CreateSandboxProject(projectName)
        project(projectName)
        kind("WindowedApp")
        location("../build/projects/%{prj.name}")
        debugdir("$(OutDir)")
        -- increase precompiled header allocation limit
        buildoptions({"/Zm256"})
        -- link against all other libraries
        links({
            "bullet_collision",
            "bullet_dynamics",
            "bullet_linearmath",
            "demo_framework",
            "detour",
            "freeimage",
            "freetype",
            "gorilla_audio",
            "libjpeg",
            "libogg",
            "libopenjpeg",
            "libpng",
            "libraw",
            "libtiff4",
            "libvorbis",
            "lua",
            "ogre3d",
            "ogre3d_direct3d9",
            "ogre3d_gorilla",
            "ogre3d_particlefx",
            "ogre3d_procedural",
            "ois",
            "openexr",
            "opensteer",
            "recast",
            "zlib",
            "zzip"
        })
        configuration({"windows"})
        -- add the directx include directory
        buildoptions({"/I \"$(DXSDK_DIR)/Include/\""})
        -- link against directx libraries
        links({
            "d3d9",
            "dinput8",
            "dxguid",
            "d3dx9",
            "DxErr"
        })
        -- static linking against ogre requires linking against ogre's resource file
        linkoptions("OgreWin32Resources.res")
        configuration({"windows", "x32", "Debug"})
        libdirs({
            "\"../build/projects/ogre3d/obj/x32/Debug\"",
            "\"$(DXSDK_DIR)/Lib/x86\"",
        })
        configuration({"windows", "x32", "Release"})
        libdirs({
            "\"../build/projects/ogre3d/obj/x32/Release\"",
            "\"$(DXSDK_DIR)/Lib/x86\"",
        })
        configuration({"windows", "x64", "Debug"})
        libdirs({
            "\"../build/projects/ogre3d/obj/x64/Debug\"",
            "\"$(DXSDK_DIR)/Lib/x64\""
        })
        configuration({"windows", "x64", "Release"})
        libdirs({
            "\"../build/projects/ogre3d/obj/x64/Release\"",
            "\"$(DXSDK_DIR)/Lib/x64\""
        })
        configuration("*")
        includedirs({
            "../src/",
            "../src/bullet_collision/include/",
            "../src/bullet_dynamics/include/",
            "../src/bullet_linearmath/include/",
            "../src/demo_framework/include",
            "../src/ois/include/",
            "../src/ogre3d/include/",
            "../src/ogre3d_direct3d9/include/"
        })
        -- TODO(David Young 6-8-13): the current premake-dev doesn't support
        -- %{prj.name} within "files"
        files({
            "../src/" .. projectName .. "/include/**.h",
            "../src/" .. projectName .. "/src/**.cpp",
            "../src/" .. projectName .. "/script/**.lua"
        })
    end
    
    group("Demos")
    -- Creates all sandbox projects defined in the "SandboxDemos.lua" file.
    group("Demos")
    for index = 1, #SandboxDemos do
        CreateSandboxProject(SandboxDemos[index]);
    end
    
    group("Framework")
    project("demo_framework")
    kind("StaticLib")
    location("../build/projects/demo_framework")
    pchheader("PrecompiledHeaders.h")
    pchsource("../src/demo_framework/src/PrecompiledHeaders.cpp")
    buildoptions({"/Zm256"})
    includedirs({
        "../src/",
        "../src/bullet_collision/include/",
        "../src/bullet_dynamics/include/",
        "../src/bullet_linearmath/include/",
        "../src/ois/include/",
        "../src/ogre3d/include/",
        "../src/ogre3d_direct3d9/include/"
    })
    configuration({"windows"})
    buildoptions({"/I \"$(DXSDK_DIR)/Include/\""})
    configuration({"*"})
    files({
        "../src/demo_framework/include/**.h",
        "../src/demo_framework/src/**.cpp",
        "../src/demo_framework/script/**.lua"
    })
    
    CreateSandboxProject("demo_framework_test");
    kind("ConsoleApp");
    -- postbuildcommands( { "cd \"$(OutDir)\" & \"$(TargetPath)\"" } );
    
    --------------------------------------------------------------------------------
    -- Open source library definitions
    --------------------------------------------------------------------------------
    group("Libraries")
    -- bullet collision v2.81 revision 2613
    project("bullet_collision")
    kind("StaticLib")
    location("../build/projects/bullet_collision")
    buildoptions({
        "/wd\"4127\"", "/wd\"4100\"", "/wd\"4244\"", "/wd\"4702\"",
        "/wd\"4512\"", "/wd\"4267\""
    })
    includedirs({
        "../src/bullet_collision/include/BulletCollision/BroadphaseCollision",
        "../src/bullet_collision/include/BulletCollision/CollisionDispatch",
        "../src/bullet_collision/include/BulletCollision/CollisionShapes",
        "../src/bullet_collision/include/BulletCollision/Gimpact",
        "../src/bullet_collision/include/BulletCollision/NarrowPhaseCollision",
        "../src/bullet_linearmath/include"
    })
    files({
        "../src/bullet_collision/include/**.h",
        "../src/bullet_collision/src/**.cpp"
    })
    defines({"WIN32", "_CRT_SECURE_NO_WARNINGS"})
    
    -- bullet dynamics v2.81 revision 2613
    project("bullet_dynamics")
    kind("StaticLib")
    location("../build/projects/bullet_dynamics")
    buildoptions({
        "/wd\"4127\"", "/wd\"4100\"", "/wd\"4244\"", "/wd\"4702\"",
        "/wd\"4512\"", "/wd\"4267\"", "/wd\"4305\""
    })
    includedirs({
        "../src/bullet_collision/include/",
        "../src/bullet_dynamics/include/BulletDynamics/Character",
        "../src/bullet_dynamics/include/BulletDynamics/ConstraintSolver",
        "../src/bullet_dynamics/include/BulletDynamics/Dynamics",
        "../src/bullet_dynamics/include/BulletDynamics/Vehicle",
        "../src/bullet_linearmath/include"
    })
    files({
        "../src/bullet_dynamics/include/**.h",
        "../src/bullet_dynamics/src/**.cpp"
    })
    defines({"WIN32", "_CRT_SECURE_NO_WARNINGS"})
    
    -- bullet linearmath v2.81 revision 2613
    project("bullet_linearmath")
    kind("StaticLib")
    location("../build/projects/bullet_linearmath")
    buildoptions({
        "/wd\"4127\"", "/wd\"4245\"", "/wd\"4244\"", "/wd\"4267\"",
        "/wd\"4701\""
    })
    includedirs({
        "../src/bullet_linearmath/include/LinearMath"
    })
    files({
        "../src/bullet_linearmath/include/**.h",
        "../src/bullet_linearmath/src/**.cpp"
    })
    defines({"WIN32", "_CRT_SECURE_NO_WARNINGS"})
    
    -- detour v1.4 static library
    project("detour")
    kind("StaticLib")
    location("../build/projects/detour")
    files({"../src/detour/include/**.h", "../src/detour/src/**.cpp"})
    defines({"WIN32", "_CRT_SECURE_NO_WARNINGS"})
    
    -- freeimage v3.15.4 static library
    project("freeimage")
    kind("StaticLib")
    location("../build/projects/freeimage")
    buildoptions({
        "/wd\"4100\"", "/wd\"4127\"", "/wd\"4189\"", "/wd\"4244\"",
        "/wd\"4611\"", "/wd\"4389\"", "/wd\"4324\"", "/wd\"4702\"",
        "/wd\"4701\"", "/wd\"4789\""
    })
    includedirs({
        "../src/libjpeg/include/",
        "../src/libopenjpeg/include/",
        "../src/libpng/include/",
        "../src/libraw/include/",
        "../src/libtiff4/include/",
        "../src/openexr/include",
        "../src/openexr/include/half",
        "../src/openexr/include/iex",
        "../src/openexr/include/ilmimf",
        "../src/openexr/include/imath",
        "../src/openexr/include/ilmthread",
        "../src/zlib/include/"
    })
    files({
        "../src/freeimage/include/**.h",
        "../src/freeimage/src/**.cpp"
    })
    defines({
        "WIN32",
        "_CRT_SECURE_NO_WARNINGS",
        "FREEIMAGE_LIB",
        "OPJ_STATIC",
        "LIBRAW_NODLL"
    })
    
    -- freetype v2.4.12 static library
    project("freetype")
    kind("StaticLib")
    location("../build/projects/freetype")
    buildoptions({
        "/wd\"4100\"", "/wd\"4244\"", "/wd\"4245\"", "/wd\"4701\"",
        "/wd\"4267\"", "/wd\"4324\"", "/wd\"4306\"", "/wd\"4703\""
    })
    buildoptions({"/FI \"ft2build.h\""})
    defines({"FT2_BUILD_LIBRARY", "_CRT_SECURE_NO_WARNINGS"})
    -- required to specify only the module level "c" files
    files({
        "../src/freetype/include/**.h",
        "../src/freetype/src/**.c"
    })
    configuration({
        "../src/freetype/src/**.c"
    })
    flags("ExcludeFromBuild")
    configuration({
        "**/autofit.c or " ..
        "**/bdf.c or " ..
        "**/cff.c or " ..
        "**/fgtlcdfil.c or " ..
        "**/ftbbox.c or " ..
        "**/ftbase.c or " ..
        "**/ftbitmap.c or " ..
        "**/ftcache.c or " ..
        "**/ftdebug.c or " ..
        "**/ftfstype.c or " ..
        "**/ftgasp.c or " ..
        "**/ftglyph.c or " ..
        "**/ftgxval.c or " ..
        "**/ftgzip.c or " ..
        "**/ftinit.c or " ..
        "**/ftlzw.c or " ..
        "**/ftmm.c or " ..
        "**/ftotval.c or " ..
        "**/ftpatent.c or " ..
        "**/ftpfr.c or " ..
        "**/ftstroke.c or " ..
        "**/ftsynth.c or " ..
        "**/ftsystem.c or " ..
        "**/fttype1.c or " ..
        "**/ftwinfnt.c or " ..
        "**/ftxf86.c or " ..
        "**/pcf.c or " ..
        "**/pfr.c or " ..
        "**/psaux.c or " ..
        "**/pshinter.c or " ..
        "**/psmodule.c or " ..
        "**/raster.c or " ..
        "**/sfnt.c or " ..
        "**/smooth.c or " ..
        "**/truetype.c or " ..
        "**/type1.c or " ..
        "**/type1cid.c or " ..
        "**/type42.c or " ..
        "**/winfnt.c"
    })
    removeflags("ExcludeFromBuild")
    configuration("*")
    
    -- gorilla_audio v0.3.0 static library
    project("gorilla_audio")
    kind("StaticLib")
    location("../build/projects/gorilla_audio")
    includedirs({
        "../src/libogg/include/",
        "../src/libvorbis/include/"
    })
    buildoptions({
        "/I \"$(DXSDK_DIR)/Include/\"",
        "/wd\"4100\"", "/wd\"4189\"", "/wd\"4244\"", "/wd\"4389\"",
        "/wd\"4702\"", "/wd\"4267\""
    })
    files({
        "../src/gorilla_audio/include/**.h",
        "../src/gorilla_audio/src/**.c"
    })
    configuration({"**/ga_openal.c"})
    flags("ExcludeFromBuild")
    configuration("*")
    defines({"ENABLE_XAUDIO2", "WIN32"})
    
    -- libjpeg 8d static library
    project("libjpeg")
    kind("StaticLib")
    location("../build/projects/libjpeg")
    buildoptions({
        "/wd\"4100\"", "/wd\"4244\"", "/wd\"4127\"", "/wd\"4267\""
    })
    files({"../src/libjpeg/include/**.h", "../src/libjpeg/src/**.c"})
    defines({"WIN32", "_CRT_SECURE_NO_WARNINGS"})
    
    -- libogg v1.3.1 static library
    project("libogg")
    kind("StaticLib")
    location("../build/projects/libogg")
    files({"../src/libogg/include/**.h", "../src/libogg/src/**.c"})
    defines({"WIN32"})
    
    -- libopenjpeg v1.5.1 static library
    project("libopenjpeg")
    kind("StaticLib")
    location("../build/projects/libopenjpeg")
    buildoptions({
        "/wd\"4100\"", "/wd\"4244\"", "/wd\"4127\"", "/wd\"4267\"",
        "/wd\"4701\"", "/wd\"4706\""
    })
    files({
        "../src/libopenjpeg/include/**.h",
        "../src/libopenjpeg/src/**.c"
    })
    defines({"WIN32", "_CRT_SECURE_NO_WARNINGS", "OPJ_STATIC"})
    
    -- libpng v1.5.13 static library
    project("libpng")
    kind("StaticLib")
    location("../build/projects/libpng")
    buildoptions({"/wd\"4127\""})
    includedirs({"../src/zlib/include/"})
    files({"../src/libpng/include/**.h", "../src/libpng/src/**.c"})
    defines({"WIN32", "_CRT_SECURE_NO_WARNINGS"})
    
    -- libraw v1.5.13 static library
    project("libraw")
    kind("StaticLib")
    location("../build/projects/libraw")
    buildoptions({
        "/wd\"4244\"", "/wd\"4189\"", "/wd\"4101\"", "/wd\"4706\"",
        "/wd\"4100\"", "/wd\"4018\"", "/wd\"4305\"", "/wd\"4309\"",
        "/wd\"4127\"", "/wd\"4389\"", "/wd\"4804\"", "/wd\"4146\"",
        "/wd\"4245\"", "/wd\"4996\"", "/wd\"4702\"", "/wd\"4267\"",
        "/wd\"4701\""
    })
    files({
        "../src/libraw/include/**.h",
        "../src/libraw/src/**.c",
        "../src/libraw/src/**.cpp"
    })
    excludes({"../src/libraw/src/**dcb_demosaicing.c"})
    defines({"WIN32", "_CRT_SECURE_NO_WARNINGS", "LIBRAW_NODLL"})
    
    -- libtiff4 v4.0.3 static library
    project("libtiff4")
    kind("StaticLib")
    location("../build/projects/libtiff4")
    buildoptions({
        "/wd\"4127\"", "/wd\"4244\"", "/wd\"4706\"", "/wd\"4702\"",
        "/wd\"4701\"", "/wd\"4018\"", "/wd\"4306\"", "/wd\"4305\"",
        "/wd\"4267\"", "/wd\"4324\"", "/wd\"4703\"", "/wd\"4100\""
    })
    includedirs({
        "../src/libjpeg/include/",
        "../src/zlib/include/"
    })
    files({"../src/libtiff4/include/**.h", "../src/libtiff4/src/**.c"})
    defines({"WIN32", "_CRT_SECURE_NO_WARNINGS"})
    
    -- libvorbis v1.3.4 static library
    project("libvorbis")
    kind("StaticLib")
    location("../build/projects/libvorbis")
    includedirs({"../src/libogg/include/"})
    buildoptions({
        "/wd\"4244\"", "/wd\"4127\"", "/wd\"4706\"", "/wd\"4305\"",
        "/wd\"4267\""
    })
    files({"../src/libvorbis/include/**.h", "../src/libvorbis/src/**.c"})
    configuration({
        "**/psytune.c or " ..
        "**/tone.c"
    })
    flags("ExcludeFromBuild")
    configuration("*")
    defines({"WIN32", "_CRT_SECURE_NO_WARNINGS"})
    
    -- lua v5.1.5 static library
    project("lua")
    kind("StaticLib")
    location("../build/projects/lua")
    buildoptions({
        "/wd\"4244\"", "/wd\"4702\"", "/wd\"4324\"", "/wd\"4334\""
    })
    files({
        "../src/lua/include/**.h",
        "../src/lua/include/**.hpp",
        "../src/lua/src/**.c"
    })
    defines({"WIN32", "_CRT_SECURE_NO_WARNINGS"})
    
    -- ogre3d v1.8.1 static library
    project("ogre3d")
    kind("StaticLib")
    location("../build/projects/ogre3d")
    pchheader("OgreStableHeaders.h")
    pchsource("../src/ogre3d/src/OgrePrecompiledHeaders.cpp")
    buildoptions({
        "/bigobj",
        "/wd\"4100\"", "/wd\"4127\"", "/wd\"4193\"", "/wd\"4244\"",
        "/wd\"4305\"", "/wd\"4512\"", "/wd\"4706\"", "/wd\"4702\"",
        "/wd\"4245\"", "/wd\"4503\"", "/wd\"4146\"", "/wd\"4565\"",
        "/wd\"4267\"", "/wd\"4996\"", "/wd\"4005\"", "/wd\"4345\"",
        "/Zm198"
    })
    includedirs({
        "../src/freeimage/include/",
        "../src/freetype/include/",
        "../src/ogre3d/include/nedmalloc",
        "../src/zlib/include/",
        "../src/zzip/include/"
    })
    files({
        "../src/ogre3d/include/**.h",
        "../src/ogre3d/src/**.cpp",
        "../src/ogre3d/resources/**.rc",
        "../src/ogre3d/resources/**.ico",
        "../src/ogre3d/resources/**.bmp"
    })
    configuration("**/Ogre*.cpp")
    flags("ExcludeFromBuild")
    configuration("**/OgrePrecompiledHeaders.cpp")
    removeflags("ExcludeFromBuild")
    configuration("*")
    defines({
        "WIN32",
        "_CRT_SECURE_NO_WARNINGS",
        "OGRE_NONCLIENT_BUILD",
        "FREEIMAGE_LIB"
    })
    vpaths({
    ["resources/*"] = {"**.rc", "**.bmp", "**.ico"}})
    
    -- ogre3d direct3d9 plugin v1.8.1 static library
    project("ogre3d_direct3d9")
    kind("StaticLib")
    location("../build/projects/ogre3d_direct3d9")
    includedirs({"../src/ogre3d/include/"})
    buildoptions({
        "/wd\"4100\"", "/wd\"4189\"", "/wd\"4018\"", "/wd\"4193\"",
        "/wd\"4127\"", "/wd\"4389\"", "/wd\"4512\"", "/wd\"4701\"",
        "/wd\"4244\"", "/wd\"4702\"", "/wd\"4267\"", "/wd\"4703\"",
        "/Zm198"
    })
    linkoptions ({"/ignore:\"4221\""})
    configuration("windows")
    buildoptions({"/I \"$(DXSDK_DIR)/Include/\""})
    configuration("*")
    files({
        "../src/ogre3d_direct3d9/include/**.h",
        "../src/ogre3d_direct3d9/src/**.cpp"
    })
    configuration("**/Ogre*.cpp")
    flags("ExcludeFromBuild")
    configuration("*")
    defines({"WIN32", "_CRT_SECURE_NO_WARNINGS"})
    
    -- ogre3d gorilla ui "master" static library
    project("ogre3d_gorilla")
    kind("StaticLib")
    location("../build/projects/ogre3d_gorilla")
    includedirs({"../src/"})
    buildoptions({
        "/Zm198"
    })
    configuration("*")
    files({
        "../src/ogre3d_gorilla/include/**.h",
        "../src/ogre3d_gorilla/src/**.cpp"
    })
    defines({"WIN32"})
    
    -- ogre3d particlefx plugin v1.8.1 static library
    project("ogre3d_particlefx")
    kind("StaticLib")
    location("../build/projects/ogre3d_particlefx")
    includedirs({"../src/ogre3d/include/"})
    buildoptions({
        "/wd\"4100\"", "/wd\"4189\"", "/wd\"4018\"", "/wd\"4193\"",
        "/wd\"4127\"", "/wd\"4389\"", "/wd\"4512\"", "/wd\"4701\"",
        "/wd\"4244\"", "/wd\"4702\"", "/wd\"4267\"", "/wd\"4703\"",
        "/Zm198"
    })
    linkoptions ({"/ignore:\"4221\""})
    configuration("windows")
    buildoptions({"/I \"$(DXSDK_DIR)/Include/\""})
    configuration("*")
    files({
        "../src/ogre3d_particlefx/include/**.h",
        "../src/ogre3d_particlefx/src/**.cpp"
    })
    configuration("**/Ogre*.cpp")
    flags("ExcludeFromBuild")
    configuration("*")
    defines({"WIN32", "_CRT_SECURE_NO_WARNINGS"})
    
    -- ogre3d procedural v0.2 static library
    project("ogre3d_procedural")
    kind("StaticLib")
    location("../build/projects/ogre3d_procedural")
    pchheader("ProceduralStableHeaders.h")
    pchsource("../src/ogre3d_procedural/src/ProceduralPrecompiledHeaders.cpp")
    includedirs({"../src/ogre3d/include/"})
    buildoptions({
        "/wd\"4100\"", "/wd\"4127\"", "/wd\"4244\"", "/wd\"4701\"",
        "/wd\"4267\"",
        "/Zm198"
    })
    files({
        "../src/ogre3d_procedural/include/**.h",
        "../src/ogre3d_procedural/src/**.cpp"
    })
    defines({"WIN32", "_CRT_SECURE_NO_WARNINGS"})
    
    -- ois v1.3 static library
    project("ois")
    kind("StaticLib")
    location("../build/projects/ois")
    buildoptions({
        "/wd\"4512\"", "/wd\"4100\"", "/wd\"4189\""
    })
    configuration("windows")
    buildoptions({"/I \"$(DXSDK_DIR)/Include/\""})
    configuration("*")
    files({"../src/ois/include/**.h", "../src/ois/src/**.cpp"})
    
    -- openexr v1.5.13 static library
    project("openexr")
    kind("StaticLib")
    location("../build/projects/openexr")
    buildoptions({
        "/wd\"4244\"", "/wd\"4305\"", "/wd\"4100\"", "/wd\"4127\"",
        "/wd\"4245\"", "/wd\"4512\"", "/wd\"4706\"", "/wd\"4267\"",
        "/wd\"4702\"", "/wd\"4101\"", "/wd\"4800\"", "/wd\"4018\"",
        "/wd\"4701\"", "/wd\"4389\"", "/wd\"4334\"", "/wd\"4722\""
    })
    linkoptions ({"/ignore:\"4221\""})
    includedirs({
        "../src/openexr/include/half",
        "../src/openexr/include/iex",
        "../src/openexr/include/ilmimf",
        "../src/openexr/include/ilmthread",
        "../src/openexr/include/imath",
        "../src/zlib/include/"
    })
    files({"../src/openexr/include/**.h", "../src/openexr/src/**.cpp"})
    defines({"WIN32", "_CRT_SECURE_NO_WARNINGS"})
    
    -- opensteer revision 190 static library
    project("opensteer")
    kind("StaticLib")
    location("../build/projects/opensteer")
    buildoptions({"/wd\"4701\"", "/wd\"4244\"", "/wd\"4100\""})
    files({
        "../src/opensteer/include/**.h",
        "../src/opensteer/src/**.c",
        "../src/opensteer/src/**.cpp"
    })
    defines({"WIN32", "HAVE_NO_GLUT"})
    
    -- recast v1.4 static library
    project("recast")
    kind("StaticLib")
    location("../build/projects/recast")
    files({"../src/recast/include/**.h", "../src/recast/src/**.cpp"})
    defines({"WIN32", "_CRT_SECURE_NO_WARNINGS"})
    
    -- zlib v1.2.8 static library
    project("zlib")
    kind("StaticLib")
    location("../build/projects/zlib")
    buildoptions({
        "/wd\"4131\"", "/wd\"4996\"", "/wd\"4244\"", "/wd\"4127\""
    })
    files({"../src/zlib/include/**.h", "../src/zlib/src/**.c"})
    defines({"WIN32"})
    
    -- zziplib v0.13.62 static library
    project("zzip")
    kind("StaticLib")
    location("../build/projects/zzip")
    buildoptions({
        "/wd\"4127\"", "/wd\"4996\"", "/wd\"4706\"", "/wd\"4244\"",
        "/wd\"4267\"", "/wd\"4028\"", "/wd\"4305\""
    })
    includedirs({"../src/zlib/include/"})
    files({"../src/zzip/include/**.h", "../src/zzip/src/**.c"})
    defines({"WIN32", "_CRT_SECURE_NO_WARNINGS"})
    
