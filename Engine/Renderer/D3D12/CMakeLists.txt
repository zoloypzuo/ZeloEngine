add_library(D3D12Renderer
        Common/d3dApp.cpp
        Common/d3dUtil.cpp
        Common/GameTimer.cpp
        Common/DDSTextureLoader.cpp
        Common/MathHelper.cpp
        Common/GeometryGenerator.cpp
        Common/Camera.cpp

        D3D12RenderSystem.cpp
#        Demo/Chapter_4_Direct3D_Initialization.Init_Direct3D/InitDirect3DApp.cpp
#        Demo/Chapter_6_Drawing_in_Direct3D.Box/BoxApp.cpp
#        Demo/Chapter_7_Drawing_in_Direct3D_Part_II.LandAndWaves/LandAndWavesApp.cpp
#        Demo/Chapter_7_Drawing_in_Direct3D_Part_II.LandAndWaves/Waves.cpp
#        Demo/Chapter_7_Drawing_in_Direct3D_Part_II.Shapes/ShapesApp.cpp
#        Demo/Chapter_8_Lighting.LitColumns/LitColumnsApp.cpp
#        Demo/Chapter_8_Lighting.LitWaves/LitWavesApp.cpp
#        Demo/Chapter_8_Lighting.LitWaves/Waves.cpp
#        Demo/Chapter_9_Texturing.Crate/CrateApp.cpp
#        Demo/Chapter_9_Texturing.TexColumns/TexColumnsApp.cpp
#        Demo/Chapter_9_Texturing.TexWaves/TexWavesApp.cpp
#        Demo/Chapter_9_Texturing.TexWaves/Waves.cpp
#        Demo/Chapter_10_Blending.BlendDemo/BlendApp.cpp
#        Demo/Chapter_10_Blending.BlendDemo/Waves.cpp
#        Demo/Chapter_11_Stenciling.StencilDemo/StencilApp.cpp
#        Demo/Chapter_18_Cube_Mapping.CubeMap/CubeMapApp.cpp
#        Demo/Chapter_18_Cube_Mapping.DynamicCube/DynamicCubeMapApp.cpp
#        Demo/Chapter_18_Cube_Mapping.DynamicCube/CubeRenderTarget.cpp
#        Demo/Chapter_16_Instancing_and_Frustum_Culling.InstancingAndCulling/InstancingAndCullingApp.cpp
#        Demo/Chapter_19_Normal_Mapping.NormalMap/NormalMapApp.cpp
#        Demo/Chapter_20_Shadow_Mapping.Shadows/ShadowMapApp.cpp
#        Demo/Chapter_20_Shadow_Mapping.Shadows/ShadowMap.cpp
#        Demo/Chapter_21_Ambient_Occlusion.Ssao/SsaoApp.cpp
#        Demo/Chapter_21_Ambient_Occlusion.Ssao/ShadowMap.cpp
        Demo/Chapter_22_Quaternions.QuatDemo/QuatApp.cpp
        Demo/Chapter_22_Quaternions.QuatDemo/AnimationHelper.cpp
        )

target_link_libraries(D3D12Renderer PUBLIC Core)
target_link_libraries(D3D12Renderer PRIVATE SDL)

find_package(directx-headers CONFIG REQUIRED)
target_link_libraries(D3D12Renderer PRIVATE Microsoft::DirectX-Guids Microsoft::DirectX-Headers)

find_package(directxmath CONFIG REQUIRED)
target_link_libraries(D3D12Renderer PRIVATE Microsoft::DirectXMath)
