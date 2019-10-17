cmake_minimum_required(VERSION 3.8)  # cmake 3.8 to use VS_DEBUGGER_WORKING_DIRECTORY
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 11)
project(bullet)
FILE(GLOB_RECURSE SRC_LIST bullet_collision/*.h bullet_collision/*.cpp bullet_dynamics/*.h bullet_dynamics/*.cpp bullet_linearmath/*.h bullet_linearmath/*.cpp)
MESSAGE(STATUS ${SRC_LIST})
ADD_LIBRARY(bullet ${SRC_LIST})
target_include_directories(bullet PRIVATE bullet_collision/include/ bullet_collision/include/BulletCollision/BroadphaseCollision bullet_collision/include/BulletCollision/CollisionDispatch bullet_collision/include/BulletCollision/CollisionShapes bullet_collision/include/BulletCollision/Gimpact bullet_collision/include/BulletCollision/NarrowPhaseCollision bullet_linearmath/include bullet_collision/include/ bullet_collision/include/BulletCollision/BroadphaseCollision bullet_collision/include/BulletCollision/CollisionDispatch bullet_collision/include/BulletCollision/CollisionShapes bullet_collision/include/BulletCollision/Gimpact bullet_collision/include/BulletCollision/NarrowPhaseCollision bullet_linearmath/include bullet_dynamics/include/ bullet_collision/include/ bullet_dynamics/include/BulletDynamics/Character bullet_dynamics/include/BulletDynamics/ConstraintSolver bullet_dynamics/include/BulletDynamics/Dynamics bullet_dynamics/include/BulletDynamics/Vehicle bullet_linearmath/include bullet_linearmath/include/ bullet_linearmath/include/LinearMath)
target_compile_definitions(bullet PRIVATE WIN32 _CRT_SECURE_NO_WARNINGS)
