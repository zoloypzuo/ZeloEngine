//
// Created by zoloypzuo on 2021/3/28.
//

#ifndef ZELOENGINE_ZELOPREREQUISITES_H
#define ZELOENGINE_ZELOPREREQUISITES_H

#include "ZeloPlatform.h"

// cpp libraries
#include <memory>
#include <iostream>
#include <sstream>
#include <fstream>
#include <functional>
#include <typeindex>
#include <algorithm>
#include <chrono>
#include <utility>
#include <typeindex>
#include <filesystem>
#include <utility>

// containers
#include <string>
#include <array>
#include <vector>
#include <map>
#include <unordered_map>
#include <unordered_set>

#include <glm/glm.hpp>
#include <glm/gtc/type_ptr.hpp>

// c libraries
#include <cfloat>
#include <cstdarg>
#include <cstdlib>
#include <cctype>
#include <cmath>
#include <cstdio>
#include <cstring>

// SDL
#ifndef SDL_MAIN_HANDLED
#define SDL_MAIN_HANDLED
#endif

#include <SDL.h>

#if _WIN32
#undef main
#endif

// interface
#include "Core/Interface/IRuntimeModule.h"
#include "Core/Interface/ISerializable.h"

template<typename T>
using Scope = std::unique_ptr<T>;

template<typename T, typename ... Args>
constexpr Scope<T> CreateScope(Args &&... args) {
    return std::make_unique<T>(std::forward<Args>(args)...);
}

template<typename T>
using Ref = std::shared_ptr<T>;

template<typename T, typename ... Args>
constexpr Ref<T> CreateRef(Args &&... args) {
    return std::make_shared<T>(std::forward<Args>(args)...);
}

// forward declaration
namespace Zelo { class Engine; }

class GLManager;

class Input;

class DirectionalLight;

class PointLight;

class SpotLight;

#endif //ZELOENGINE_ZELOPREREQUISITES_H
