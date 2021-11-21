add_library(GLSLBook
        ImageProcessing/BloomPipeline.cpp
        ImageProcessing/BlurPipeline.cpp
        ImageProcessing/EdgePipeline.cpp
        Shadow/ShadowMapPipeline.cpp
#        Shadow/ForwardShadowMapPcf.cpp
        GLSLBookPlugins.cpp GLSLBookPlugins.h

        Drawable/Quad.cpp Drawable/Quad.h)