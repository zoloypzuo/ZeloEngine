set(target ingredients)

set(ingredients_SOURCES
        teapotpatch.cpp
        teapot.cpp
        torus.cpp
        glutils.cpp
        objmesh.cpp
        cube.cpp
        plane.cpp
        sphere.cpp
        trianglemesh.cpp
        )

add_library(${target} STATIC ${ingredients_SOURCES})

set_property(TARGET ${target} PROPERTY CXX_STANDARD 17)
set_property(TARGET ${target} PROPERTY CXX_STANDARD_REQUIRED ON)

