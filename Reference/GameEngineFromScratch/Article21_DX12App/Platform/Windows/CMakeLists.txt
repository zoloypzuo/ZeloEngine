add_executable(MyGameEngineD3d12 
	WindowsApplication.cpp WindowsApplication.hpp
	D3d12Application.cpp
	)

target_link_libraries(MyGameEngineD3d12 Common D3dRHI d3d12 dxgi d3dcompiler)