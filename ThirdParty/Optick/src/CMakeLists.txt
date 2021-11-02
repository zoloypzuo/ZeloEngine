set(PROJECT_NAME Optick)

add_library(Optick
		optick_capi.cpp
		optick_core.cpp
		optick_gpu.cpp
		optick_message.cpp
		optick_message.h
		optick_miniz.cpp
		optick_miniz.h
		optick_serialization.cpp
		optick_server.cpp
		)

target_include_directories(Optick PUBLIC ./)
