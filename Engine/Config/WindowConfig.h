// WindowConfig.h
// created on 2021/12/11
// author @zoloypzuo
#pragma once

struct WindowConfig {
    std::string title{};
    int window_x = 0;
    int window_y = 45;
    int windowed_width = 1280;
    int windowed_height = 720;
    int fullscreen_width = 3240;
    int fullscreen_height = 2160;
    int refresh_rate = 60;
    bool fullscreen = false;
    bool vsync = false;
};
