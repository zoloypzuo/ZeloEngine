// ZeloPrerequisite.h
// created on 2021/3/28.
// author @zoloypzuo
#pragma once

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
#include <iterator>

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

// script API
#define ZELO_SCRIPT_API  // do nothing

// Element count of a static array
#define ARRAY_SIZE(x) (sizeof(x) / sizeof(x[0]))

// Example:
//	enum ProfilerMode
//	{
//		kProfilerEnabled = 1 << 0, 
//		kProfilerGame = 1 << 1,
//		kProfilerDeepScripts = 1 << 2,
//		kProfilerEditor = 1 << 3,
//	};
//	ENUM_FLAGS(ProfilerMode);
#define ENUM_FLAGS(T) \
inline T  operator  |(const T s, const T e) { return (T)((unsigned)s | e); } \
inline T &operator |=(T      &s, const T e) { return s = s | e; }            \
inline T  operator  &(const T s, const T e) { return (T)((unsigned)s & e); } \
inline T &operator &=(T      &s, const T e) { return s = s & e; }            \
inline T  operator  ^(const T s, const T e) { return (T)((unsigned)s ^ e); } \
inline T &operator ^=(T      &s, const T e) { return s = s ^ e; }            \
inline T  operator  ~(const T s)            { return (T)~(unsigned)s; }

// Example:
//  ZELO_PACKED(
//  struct Bar
//  {
//    float baz;
//    float boo;
//  };
//  )
#ifdef __GNUC__
#define ZELO_PACKED( class_to_pack ) class_to_pack __attribute__((__packed__))
#else
#define ZELO_PACKED( class_to_pack ) __pragma( pack(push, 1) ) class_to_pack __pragma( pack(pop) )
#endif

// mixin for class that cannot be copied
class NonCopyable {
public:
    NonCopyable() {}

private:
    NonCopyable(const NonCopyable &);

    NonCopyable &operator=(const NonCopyable &);
};


// typedef
namespace Zelo {
typedef int64_t GUID_t;
}

// fix SDL
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

// forward declaration
namespace Zelo { class Engine; }

class Input;

class DirectionalLight;

class PointLight;

class SpotLight;

namespace Zelo::Core::ECS {
class Entity;

class Component;

class Behaviour;

}

class MeshRenderer;