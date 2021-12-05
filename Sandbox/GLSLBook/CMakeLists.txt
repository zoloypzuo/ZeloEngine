add_library(GLSLBook
        Pipeline/ImageProcessing/BloomPipeline.cpp
        Pipeline/ImageProcessing/BlurPipeline.cpp
        Pipeline/ImageProcessing/EdgePipeline.cpp
        Pipeline/Shadow/ShadowMapPipeline.cpp

        GLSLBookPlugins.cpp GLSLBookPlugins.h

        Drawable/Quad.cpp Drawable/Quad.h
        )

target_link_libraries(GLSLBook PUBLIC Engine)
