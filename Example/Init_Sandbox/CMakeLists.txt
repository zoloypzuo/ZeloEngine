# created on 2019/10/18
# author @zoloypzuo

file(GLOB_RECURSE SRC_LIST ./*.h ./*.cpp)
ADD_EXECUTABLE(Init_Sandbox ${SRC_LIST})
target_include_directories(Init_Sandbox PRIVATE "D:/ZeloEngine/Reference/Lua-Game-AI-Programming/src/" "D:/ZeloEngine/Reference/Lua-Game-AI-Programming/src/lua/include/" "D:/ZeloEngine/Reference/Lua-Game-AI-Programming/src/bullet_collision/include/" "D:/ZeloEngine/Reference/Lua-Game-AI-Programming/src/bullet_dynamics/include/" "D:/ZeloEngine/Reference/Lua-Game-AI-Programming/src/bullet_linearmath/include/" "D:/ZeloEngine/Reference/Lua-Game-AI-Programming/src/demo_framework/include" "D:/ZeloEngine/Reference/Lua-Game-AI-Programming/src/ois/include/" "D:/ZeloEngine/Reference/Lua-Game-AI-Programming/src/ogre3d/include/" "D:/ZeloEngine/Reference/Lua-Game-AI-Programming/src/ogre3d_direct3d9/include/" "C:/Program Files (x86)/Microsoft DirectX SDK (June 2010)/Include")
target_link_directories(Init_Sandbox PRIVATE "D:/ZeloEngine/Reference/Lua-Game-AI-Programming/lib/x64/debug/" "C:/Program Files (x86)/Microsoft DirectX SDK (June 2010)/Lib/x64")
TARGET_LINK_LIBRARIES(Init_Sandbox bullet_collision bullet_dynamics bullet_linearmath demo_framework detour freeimage freetype gorilla_audio libjpeg libogg libopenjpeg libpng libraw libtiff4 libvorbis lua ogre3d ogre3d_direct3d9 ogre3d_gorilla ogre3d_particlefx ogre3d_procedural ois openexr opensteer recast zlib zzip d3d9 dinput8 dxguid d3dx9 DxErr)
target_include_directories(Init_Sandbox PRIVATE ${PROJECT_SOURCE_DIR}Src/LuaConfig/CppConfigClass_Generated ${PROJECT_SOURCE_DIR}Src/Common)
target_link_directories(Init_Sandbox PRIVATE Lib/Win32Debug/)
TARGET_LINK_LIBRARIES(Init_Sandbox Common)