# created on 2021/7/26
# author @zoloypzuo
add_library(Scene SceneManager.cpp)
target_link_libraries(Scene PRIVATE ECS)
