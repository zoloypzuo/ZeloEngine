add_library(D3D12Renderer
        Common/d3dApp.cpp
        Common/d3dUtil.cpp
        Common/GameTimer.cpp
        Common/DDSTextureLoader.cpp
        Common/MathHelper.cpp

        D3D12RenderSystem.cpp
        )

target_link_libraries(D3D12Renderer PUBLIC Core)
target_link_libraries(D3D12Renderer PRIVATE SDL)

find_package(directx-headers CONFIG REQUIRED)
target_link_libraries(D3D12Renderer PRIVATE Microsoft::DirectX-Guids Microsoft::DirectX-Headers)

find_package(directxmath CONFIG REQUIRED)
target_link_libraries(D3D12Renderer PRIVATE Microsoft::DirectXMath)

#link_libraries(D3D12Renderer)
#add_executable(InitDirect3DApp WIN32 InitDirect3DApp.cpp)