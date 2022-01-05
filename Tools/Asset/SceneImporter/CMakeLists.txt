project(Chapter7)
add_executable(SceneImporter
        SceneImporter_fb.cpp
        SceneMergeUtil.cpp
        )

set_property(TARGET SceneImporter PROPERTY CXX_STANDARD 20)
set_property(TARGET SceneImporter PROPERTY CXX_STANDARD_REQUIRED ON)

target_link_libraries(SceneImporter PRIVATE Engine)

find_package(meshoptimizer CONFIG REQUIRED)
target_link_libraries(SceneImporter PRIVATE meshoptimizer::meshoptimizer)

find_package(assimp CONFIG REQUIRED)
target_link_libraries(SceneImporter PRIVATE assimp::assimp)

find_package(RapidJSON CONFIG REQUIRED)
target_include_directories(SceneImporter PRIVATE ${RAPIDJSON_INCLUDE_DIRS})

find_path(STB_INCLUDE_DIRS "stb.h")
target_include_directories(SceneImporter PRIVATE ${STB_INCLUDE_DIRS})