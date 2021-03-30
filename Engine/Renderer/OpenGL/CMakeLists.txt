# created on 2021/3/29
# author @zoloypzuo
add_library(OpenGLRenderer
        GLManager.cpp
        ForwardRenderer.cpp
        )

find_package(GLEW REQUIRED)
target_link_libraries(OpenGLRenderer PRIVATE GLEW::GLEW)
