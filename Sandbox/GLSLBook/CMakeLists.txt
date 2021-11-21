add_library(GLSLBook
        PostEffectPipeline.cpp
#        ImageProcessing/Bloom.cpp
        ImageProcessing/BlurPipeline.cpp
        ImageProcessing/EdgePipeline.cpp
#        Shadow/ForwardShadowMap.h
#        Shadow/ForwardShadowMapPcf.cpp
        GLSLBookPlugins.cpp GLSLBookPlugins.h

        Drawable/Quad.cpp Drawable/Quad.h)