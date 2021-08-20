// UIManager.cpp
// created on 2021/8/16
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "UIManager.h"
#include "ZeloGLPrerequisites.h"
#include <imgui.h>
#define IMGUI_IMPL_OPENGL_LOADER_GLAD
#include "Core/UI/ImGuiBackend/imgui_impl_opengl3.h"
#include "Core/UI/ImGuiBackend/imgui_impl_sdl.h"
#include "Core/Window/Window.h"

using namespace Zelo::Core::UI;

template<> UIManager *Singleton<UIManager>::msSingleton = nullptr;

UIManager *UIManager::getSingletonPtr() {
    return msSingleton;
}

UIManager &UIManager::getSingleton() {
    assert(msSingleton);
    return *msSingleton;
}

void UIManager::initialize() {
    // SDL and OpenGL setup...

    // Setup Dear ImGui context
    IMGUI_CHECKVERSION();
    ImGui::CreateContext();
    ImGuiIO &io = ImGui::GetIO();
    (void) io;

    // Setup Dear ImGui style
    ImGui::StyleColorsDark();

    // Setup Platform/Renderer bindings
    // window is the SDL_Window*
    // context is the SDL_GLContext
    auto *window = Window::getSingletonPtr()->getSDLWindow();
    auto *context = Window::getSingletonPtr()->getGLContext();

    ImGui_ImplSDL2_InitForOpenGL(window, context);
    ImGui_ImplOpenGL3_Init();
}

void UIManager::finalize() {
    // Cleanup
    ImGui_ImplOpenGL3_Shutdown();
    ImGui_ImplSDL2_Shutdown();
    ImGui::DestroyContext();
}

void UIManager::update() {
    // Start the Dear ImGui frame
    ImGui_ImplOpenGL3_NewFrame();
    auto *window = Window::getSingletonPtr()->getSDLWindow();
    ImGui_ImplSDL2_NewFrame(window);
    ImGui::NewFrame();
    // Frame logic here...
    ImGui::ShowDemoWindow();
}

void UIManager::draw() {
    ImGui::Render();
    ImGui_ImplOpenGL3_RenderDrawData(ImGui::GetDrawData());
}
