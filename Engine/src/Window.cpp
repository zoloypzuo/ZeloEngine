// Window.cpp
// created on 2021/3/28
// author @zoloypzuo

#include "Window.h"

Window::Window() {

}

Window::~Window() {

}

void Window::initialize() {

}

void Window::update() {

}

void Window::swap_buffer() {

}

void Window::finalize() {

}

void Window::make_current_context() {

}

void Window::drawCursor() {

}

int Window::getWidth() const {
    return 0;
}

int Window::getHeight() const {
    return 0;
}

glm::vec4 Window::getViewport() const {
    return nullptr;
}

glm::vec2 Window::getDisplaySize() const {
    return nullptr;
}

glm::vec2 Window::getDrawableSize() const {
    return nullptr;
}

const char *Window::getClipboardText() const {
    return nullptr;
}

void Window::setClipboardText(const char *text) {

}

SDL_Window *Window::getSDLWindow() {
    return nullptr;
}

bool Window::shouldQuit() const {
    return false;
}

void Window::setFullscreen(uint32_t flag) {

}

void Window::toggleFullscreen() {

}
