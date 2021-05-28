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

// SDL
#define SDL_MAIN_HANDLED
#include <SDL.h>
#if _WIN32
#undef main
#endif

class IRuntimeModule {
public:
    virtual ~IRuntimeModule() = default;

    virtual void initialize() = 0;

    virtual void finalize() = 0;

    virtual void update() = 0;
};

template<typename T>
using Scope = std::unique_ptr<T>;
template<typename T, typename ... Args>
constexpr Scope<T> CreateScope(Args&& ... args)
{
    return std::make_unique<T>(std::forward<Args>(args)...);
}

template<typename T>
using Ref = std::shared_ptr<T>;
template<typename T, typename ... Args>
constexpr Ref<T> CreateRef(Args&& ... args)
{
    return std::make_shared<T>(std::forward<Args>(args)...);
}

#endif //ZELOENGINE_ZELOPREREQUISITES_H
