link_libraries(
        cyclone
        glut32 opengl32 glu32
        Winmm.lib  # timeGetTime
)
add_executable(01-ballistic app.cpp timing.cpp main.cpp ballistic/ballistic.cpp)
add_executable(02-bigballistic app.cpp timing.cpp main.cpp bigballistic/bigballistic.cpp)
add_executable(03-blob app.cpp timing.cpp main.cpp blob/blob.cpp)
add_executable(04-bridge app.cpp timing.cpp main.cpp bridge/bridge.cpp)
add_executable(05-explosion app.cpp timing.cpp main.cpp explosion/explosion.cpp)
add_executable(06-fireworks app.cpp timing.cpp main.cpp fireworks/fireworks.cpp)
add_executable(07-flightsim app.cpp timing.cpp main.cpp flightsim/flightsim.cpp)
add_executable(08-fracture app.cpp timing.cpp main.cpp fracture/fracture.cpp)
add_executable(09-platform app.cpp timing.cpp main.cpp platform/platform.cpp)
add_executable(10-ragdoll app.cpp timing.cpp main.cpp ragdoll/ragdoll.cpp)
add_executable(11-sailboat app.cpp timing.cpp main.cpp sailboat/sailboat.cpp)
