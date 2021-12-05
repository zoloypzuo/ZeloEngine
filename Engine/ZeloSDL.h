#pragma once

// fix SDL
#ifndef SDL_MAIN_HANDLED
#define SDL_MAIN_HANDLED
#endif

#include <SDL.h>

#if _WIN32
#undef main
#endif
