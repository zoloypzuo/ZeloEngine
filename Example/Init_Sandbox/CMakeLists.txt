# created on 2019/10/18
# author @zoloypzuo

add_executable(Init_Sandbox Init_Sandbox.cpp Init_Sandbox.h)

target_include_directories(Init_Sandbox PRIVATE D:/ZeloEngine/Reference/Lua-Game-AI-Programming/src/ D:/ZeloEngine/Reference/Lua-Game-AI-Programming/src/bullet_collision/include/ D:/ZeloEngine/Reference/Lua-Game-AI-Programming/src/bullet_dynamics/include/ D:/ZeloEngine/Reference/Lua-Game-AI-Programming/src/bullet_linearmath/include/ D:/ZeloEngine/Reference/Lua-Game-AI-Programming/src/demo_framework/include D:/ZeloEngine/Reference/Lua-Game-AI-Programming/src/ois/include/ D:/ZeloEngine/Reference/Lua-Game-AI-Programming/src/ogre3d/include/ D:/ZeloEngine/Reference/Lua-Game-AI-Programming/src/ogre3d_direct3d9/include/)
target_link_directories(Init_Sandbox PRIVATE D:/ZeloEngine/Reference/Lua-Game-AI-Programming/lib/x64/debug/ 7)
TARGET_LINK_LIBRARIES(Init_Sandbox bullet_collision bullet_dynamics bullet_linearmath demo_framework detour freeimage freetype gorilla_audio libjpeg libogg libopenjpeg libpng libraw libtiff4 libvorbis lua ogre3d ogre3d_direct3d9 ogre3d_gorilla ogre3d_particlefx ogre3d_procedural ois openexr opensteer recast zlib zzip)