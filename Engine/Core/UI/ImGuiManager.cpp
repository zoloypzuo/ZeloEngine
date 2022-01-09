// ImGuiManager.cpp
// created on 2021/8/16
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "ImGuiManager.h"

#include "Core/OS/Input.h"
#include "Core/OS/Window.h"
#include "Core/Resource/Resource.h"

#include <imgui.h>
#include <imgui_internal.h>

#define IMGUI_IMPL_OPENGL_LOADER_GLAD

#include <backends/imgui_impl_opengl3.h>
#include <backends/imgui_impl_sdl.h>
#include <nfd.h>

using namespace Zelo::Core::UI;
using namespace Zelo::Core::OS;

template<> ImGuiManager *Zelo::Singleton<ImGuiManager>::msSingleton = nullptr;

ImGuiManager *ImGuiManager::getSingletonPtr() {
    return msSingleton;
}

ImGuiManager &ImGuiManager::getSingleton() {
    assert(msSingleton);
    return *msSingleton;
}

void ImGuiManager::initialize() {
    // ... SDL and OpenGL setup before imgui initialize

    // register SDL input
    Window::getSingletonPtr()->WindowEvent.AddListener(ImGui_ImplSDL2_ProcessEvent);

    // Setup Dear ImGui context
    IMGUI_CHECKVERSION();
    ImGui::CreateContext();

    ImGuiIO &io = ImGui::GetIO();
    io.ConfigFlags |= ImGuiConfigFlags_NavEnableKeyboard;
    io.ConfigFlags |= ImGuiConfigFlags_DockingEnable;
    io.ConfigFlags |= ImGuiConfigFlags_ViewportsEnable;

    // Setup Dear ImGui style
    ImGui::StyleColorsDark();
    ApplyStyle(EStyle::DUNE_DARK);

    // When viewports are enabled we tweak WindowRounding/WindowBg so platform windows can look identical to regular ones.
    ImGuiStyle &style = ImGui::GetStyle();
    if (io.ConfigFlags & ImGuiConfigFlags_ViewportsEnable) {
        style.WindowRounding = 0.0f;
        style.Colors[ImGuiCol_WindowBg].w = 1.0f;
    }

    // Setup Platform/Renderer bindings
    auto *window = Window::getSingletonPtr()->getSDLWindow();
    auto *context = Window::getSingletonPtr()->getGLContext();

    ImGui_ImplSDL2_InitForOpenGL(window, context);
    ImGui_ImplOpenGL3_Init();
}

void ImGuiManager::finalize() {
    // Cleanup
    ImGui_ImplOpenGL3_Shutdown();
    ImGui_ImplSDL2_Shutdown();
    ImGui::DestroyContext();
}

void ImGuiManager::update() {
    // Start the Dear ImGui frame
    ImGui_ImplOpenGL3_NewFrame();
    ImGui_ImplSDL2_NewFrame();
    ImGui::NewFrame();

    // Docking
    if (IsDockingEnabled()) {
        ImGuiViewport *viewport = ImGui::GetMainViewport();
        ImGui::SetNextWindowPos(viewport->Pos);
        ImGui::SetNextWindowSize(viewport->Size);
        ImGui::SetNextWindowViewport(viewport->ID);

        ImGui::PushStyleVar(ImGuiStyleVar_WindowRounding, 0.0f);
        ImGui::PushStyleVar(ImGuiStyleVar_WindowBorderSize, 0.0f);
        ImGui::PushStyleVar(ImGuiStyleVar_WindowPadding, ImVec2(0.0f, 0.0f));

        ImGui::Begin("##dockspace", nullptr,
                     ImGuiWindowFlags_NoTitleBar | ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_NoResize |
                     ImGuiWindowFlags_NoMove | ImGuiWindowFlags_NoBringToFrontOnFocus | ImGuiWindowFlags_MenuBar |
                     ImGuiWindowFlags_NoDocking);
        ImGuiID dockspace_id = ImGui::GetID("MyDockspace");
        ImGui::DockSpace(dockspace_id, ImVec2(0.0f, 0.0f), ImGuiDockNodeFlags_PassthruCentralNode);
        ImGui::SetWindowPos({0.f, 0.f});
        ImVec2 displaySize = ImGui::GetIO().DisplaySize;
        ImGui::SetWindowSize({(float) displaySize.x, (float) displaySize.y});
        ImGui::End();

        ImGui::PopStyleVar(3);
    }

    // update logic (in lua script)
}

void ImGuiManager::render() {
    ImGui::Render();
    ImGuiIO &io = ImGui::GetIO();
    ImGui_ImplOpenGL3_RenderDrawData(ImGui::GetDrawData());
    // Update and Render additional Platform Windows
    // (Platform functions may change the current OpenGL context, so we save/restore it to make it easier to paste this code elsewhere.
    //  For this specific demo app we could also call SDL_GL_MakeCurrent(window, gl_context) directly)
    if (io.ConfigFlags & ImGuiConfigFlags_ViewportsEnable) {
        SDL_Window *backup_current_window = SDL_GL_GetCurrentWindow();
        SDL_GLContext backup_current_context = SDL_GL_GetCurrentContext();
        ImGui::UpdatePlatformWindows();
        ImGui::RenderPlatformWindowsDefault();
        SDL_GL_MakeCurrent(backup_current_window, backup_current_context);
    }
}

void ImGuiManager::ApplyStyle(ImGuiManager::EStyle style) {
    ImGuiStyle *imStyle = &ImGui::GetStyle();

    switch (style) {
        case EStyle::IM_CLASSIC_STYLE:
            ImGui::StyleColorsClassic();
            break;
        case EStyle::IM_DARK_STYLE:
            ImGui::StyleColorsDark();
            break;
        case EStyle::IM_LIGHT_STYLE:
            ImGui::StyleColorsLight();
            break;
        case EStyle::DUNE_DARK: {
            imStyle->WindowPadding = ImVec2(15, 15);
            imStyle->WindowRounding = 1.0f;
            imStyle->FramePadding = ImVec2(5, 5);
            imStyle->FrameRounding = 1.0f;
            imStyle->ItemSpacing = ImVec2(12, 8);
            imStyle->ItemInnerSpacing = ImVec2(8, 6);
            imStyle->IndentSpacing = 25.0f;
            imStyle->ScrollbarSize = 15.0f;
            imStyle->ScrollbarRounding = 9.0f;
            imStyle->GrabMinSize = 5.0f;
            imStyle->GrabRounding = 3.0f;

            imStyle->Colors[ImGuiCol_Text] = ImVec4(0.80f, 0.80f, 0.83f, 1.00f);
            imStyle->Colors[ImGuiCol_TextDisabled] = ImVec4(0.24f, 0.23f, 0.29f, 1.00f);
            imStyle->Colors[ImGuiCol_WindowBg] = ImVec4(0.06f, 0.05f, 0.07f, 1.00f);
            imStyle->Colors[ImGuiCol_ChildBg] = ImVec4(0.07f, 0.07f, 0.09f, 1.00f);
            imStyle->Colors[ImGuiCol_PopupBg] = ImVec4(0.07f, 0.07f, 0.09f, 1.00f);
            imStyle->Colors[ImGuiCol_Border] = ImVec4(0.2f, 0.2f, 0.2f, 0.88f);
            imStyle->Colors[ImGuiCol_BorderShadow] = ImVec4(0.92f, 0.91f, 0.88f, 0.00f);
            imStyle->Colors[ImGuiCol_FrameBg] = ImVec4(0.10f, 0.09f, 0.12f, 1.00f);
            imStyle->Colors[ImGuiCol_FrameBgHovered] = ImVec4(0.24f, 0.23f, 0.29f, 1.00f);
            imStyle->Colors[ImGuiCol_FrameBgActive] = ImVec4(0.56f, 0.56f, 0.58f, 1.00f);
            imStyle->Colors[ImGuiCol_TitleBg] = ImVec4(0.10f, 0.09f, 0.12f, 1.00f);
            imStyle->Colors[ImGuiCol_TitleBgCollapsed] = ImVec4(0.3f, 0.3f, 0.3f, 0.75f);
            imStyle->Colors[ImGuiCol_TitleBgActive] = ImVec4(0.07f, 0.07f, 0.09f, 1.00f);
            imStyle->Colors[ImGuiCol_MenuBarBg] = ImVec4(0.10f, 0.09f, 0.12f, 1.00f);
            imStyle->Colors[ImGuiCol_ScrollbarBg] = ImVec4(0.10f, 0.09f, 0.12f, 1.00f);
            imStyle->Colors[ImGuiCol_ScrollbarGrab] = ImVec4(0.80f, 0.80f, 0.83f, 0.31f);
            imStyle->Colors[ImGuiCol_ScrollbarGrabHovered] = ImVec4(0.56f, 0.56f, 0.58f, 1.00f);
            imStyle->Colors[ImGuiCol_ScrollbarGrabActive] = ImVec4(0.06f, 0.05f, 0.07f, 1.00f);
            imStyle->Colors[ImGuiCol_CheckMark] = ImVec4(0.80f, 0.80f, 0.83f, 0.31f);
            imStyle->Colors[ImGuiCol_SliderGrab] = ImVec4(0.80f, 0.80f, 0.83f, 0.31f);
            imStyle->Colors[ImGuiCol_SliderGrabActive] = ImVec4(0.06f, 0.05f, 0.07f, 1.00f);
            imStyle->Colors[ImGuiCol_Button] = ImVec4(0.10f, 0.09f, 0.12f, 1.00f);
            imStyle->Colors[ImGuiCol_ButtonHovered] = ImVec4(0.24f, 0.23f, 0.29f, 1.00f);
            imStyle->Colors[ImGuiCol_ButtonActive] = ImVec4(0.56f, 0.56f, 0.58f, 1.00f);
            imStyle->Colors[ImGuiCol_Header] = ImVec4(0.10f, 0.09f, 0.12f, 1.00f);
            imStyle->Colors[ImGuiCol_HeaderHovered] = ImVec4(0.56f, 0.56f, 0.58f, 1.00f);
            imStyle->Colors[ImGuiCol_HeaderActive] = ImVec4(0.06f, 0.05f, 0.07f, 1.00f);
            imStyle->Colors[ImGuiCol_Separator] = ImVec4(0.56f, 0.56f, 0.58f, 1.00f);
            imStyle->Colors[ImGuiCol_SeparatorHovered] = ImVec4(0.24f, 0.23f, 0.29f, 1.00f);
            imStyle->Colors[ImGuiCol_SeparatorActive] = ImVec4(0.56f, 0.56f, 0.58f, 1.00f);
            imStyle->Colors[ImGuiCol_ResizeGrip] = ImVec4(0.00f, 0.00f, 0.00f, 0.00f);
            imStyle->Colors[ImGuiCol_ResizeGripHovered] = ImVec4(0.56f, 0.56f, 0.58f, 1.00f);
            imStyle->Colors[ImGuiCol_ResizeGripActive] = ImVec4(0.06f, 0.05f, 0.07f, 1.00f);
            imStyle->Colors[ImGuiCol_PlotLines] = ImVec4(0.40f, 0.39f, 0.38f, 0.63f);
            imStyle->Colors[ImGuiCol_PlotLinesHovered] = ImVec4(0.25f, 1.00f, 0.00f, 1.00f);
            imStyle->Colors[ImGuiCol_PlotHistogram] = ImVec4(0.40f, 0.39f, 0.38f, 0.63f);
            imStyle->Colors[ImGuiCol_PlotHistogramHovered] = ImVec4(0.25f, 1.00f, 0.00f, 1.00f);
            imStyle->Colors[ImGuiCol_TextSelectedBg] = ImVec4(0.25f, 1.00f, 0.00f, 0.43f);

            imStyle->Colors[ImGuiCol_Tab] = imStyle->Colors[ImGuiCol_TabUnfocused];
            break;
        }
        case EStyle::ALTERNATIVE_DARK: {
            imStyle->WindowPadding = ImVec2(15, 15);
            imStyle->WindowRounding = 0.0f;
            imStyle->FramePadding = ImVec2(5, 5);
            imStyle->FrameRounding = 0.0f;
            imStyle->ItemSpacing = ImVec2(12, 8);
            imStyle->ItemInnerSpacing = ImVec2(8, 6);
            imStyle->IndentSpacing = 25.0f;
            imStyle->ScrollbarSize = 15.0f;
            imStyle->ScrollbarRounding = 0.0f;
            imStyle->GrabMinSize = 5.0f;
            imStyle->GrabRounding = 0.0f;
            imStyle->TabRounding = 0.0f;
            imStyle->ChildRounding = 0.0f;
            imStyle->PopupRounding = 0.0f;

            imStyle->WindowBorderSize = 1.0f;
            imStyle->FrameBorderSize = 0.0f;
            imStyle->PopupBorderSize = 1.0f;

            ImVec4 *colors = ImGui::GetStyle().Colors;
            colors[ImGuiCol_Text] = ImVec4(0.96f, 0.96f, 0.99f, 1.00f);
            colors[ImGuiCol_TextDisabled] = ImVec4(0.50f, 0.50f, 0.50f, 1.00f);
            colors[ImGuiCol_WindowBg] = ImVec4(0.09f, 0.09f, 0.10f, 1.00f);
            colors[ImGuiCol_ChildBg] = ImVec4(0.09f, 0.09f, 0.10f, 1.00f);
            colors[ImGuiCol_PopupBg] = ImVec4(0.06f, 0.06f, 0.07f, 1.00f);
            colors[ImGuiCol_Border] = ImVec4(0.12f, 0.12f, 0.14f, 1.00f);
            colors[ImGuiCol_BorderShadow] = ImVec4(0.00f, 0.00f, 0.00f, 0.00f);
            colors[ImGuiCol_FrameBg] = ImVec4(0.12f, 0.12f, 0.13f, 1.00f);
            colors[ImGuiCol_FrameBgHovered] = ImVec4(0.20f, 0.20f, 0.22f, 1.00f);
            colors[ImGuiCol_FrameBgActive] = ImVec4(0.27f, 0.27f, 0.29f, 1.00f);
            colors[ImGuiCol_TitleBg] = ImVec4(0.07f, 0.07f, 0.07f, 1.00f);
            colors[ImGuiCol_TitleBgActive] = ImVec4(0.07f, 0.07f, 0.07f, 1.00f);
            colors[ImGuiCol_TitleBgCollapsed] = ImVec4(0.07f, 0.07f, 0.07f, 1.00f);
            colors[ImGuiCol_MenuBarBg] = ImVec4(0.07f, 0.07f, 0.07f, 1.00f);
            colors[ImGuiCol_ScrollbarBg] = ImVec4(0.07f, 0.07f, 0.07f, 1.00f);
            colors[ImGuiCol_ScrollbarGrab] = ImVec4(0.31f, 0.31f, 0.32f, 1.00f);
            colors[ImGuiCol_ScrollbarGrabHovered] = ImVec4(0.41f, 0.41f, 0.42f, 1.00f);
            colors[ImGuiCol_ScrollbarGrabActive] = ImVec4(0.51f, 0.51f, 0.53f, 1.00f);
            colors[ImGuiCol_CheckMark] = ImVec4(0.44f, 0.44f, 0.47f, 1.00f);
            colors[ImGuiCol_SliderGrab] = ImVec4(0.44f, 0.44f, 0.47f, 1.00f);
            colors[ImGuiCol_SliderGrabActive] = ImVec4(0.59f, 0.59f, 0.61f, 1.00f);
            colors[ImGuiCol_Button] = ImVec4(0.20f, 0.20f, 0.22f, 1.00f);
            colors[ImGuiCol_ButtonHovered] = ImVec4(0.44f, 0.44f, 0.47f, 1.00f);
            colors[ImGuiCol_ButtonActive] = ImVec4(0.59f, 0.59f, 0.61f, 1.00f);
            colors[ImGuiCol_Header] = ImVec4(0.20f, 0.20f, 0.22f, 1.00f);
            colors[ImGuiCol_HeaderHovered] = ImVec4(0.44f, 0.44f, 0.47f, 1.00f);
            colors[ImGuiCol_HeaderActive] = ImVec4(0.59f, 0.59f, 0.61f, 1.00f);
            colors[ImGuiCol_Separator] = ImVec4(1.00f, 1.00f, 1.00f, 0.20f);
            colors[ImGuiCol_SeparatorHovered] = ImVec4(0.44f, 0.44f, 0.47f, 0.39f);
            colors[ImGuiCol_SeparatorActive] = ImVec4(0.44f, 0.44f, 0.47f, 0.59f);
            colors[ImGuiCol_ResizeGrip] = ImVec4(0.26f, 0.59f, 0.98f, 0.00f);
            colors[ImGuiCol_ResizeGripHovered] = ImVec4(0.26f, 0.59f, 0.98f, 0.00f);
            colors[ImGuiCol_ResizeGripActive] = ImVec4(0.26f, 0.59f, 0.98f, 0.00f);
            colors[ImGuiCol_Tab] = ImVec4(0.20f, 0.20f, 0.22f, 1.00f);
            colors[ImGuiCol_TabHovered] = ImVec4(0.44f, 0.44f, 0.47f, 1.00f);
            colors[ImGuiCol_TabActive] = ImVec4(0.44f, 0.44f, 0.47f, 1.00f);
            colors[ImGuiCol_TabUnfocused] = ImVec4(0.20f, 0.20f, 0.22f, 0.39f);
            colors[ImGuiCol_TabUnfocusedActive] = ImVec4(0.44f, 0.44f, 0.47f, 0.39f);
            colors[ImGuiCol_DockingPreview] = ImVec4(0.91f, 0.62f, 0.00f, 0.78f);
            colors[ImGuiCol_DockingEmptyBg] = ImVec4(0.20f, 0.20f, 0.20f, 1.00f);
            colors[ImGuiCol_PlotLines] = ImVec4(0.96f, 0.96f, 0.99f, 1.00f);
            colors[ImGuiCol_PlotLinesHovered] = ImVec4(0.12f, 1.00f, 0.12f, 1.00f);
            colors[ImGuiCol_PlotHistogram] = ImVec4(0.96f, 0.96f, 0.99f, 1.00f);
            colors[ImGuiCol_PlotHistogramHovered] = ImVec4(0.12f, 1.00f, 0.12f, 1.00f);
            colors[ImGuiCol_TextSelectedBg] = ImVec4(0.26f, 0.59f, 0.98f, 0.35f);
            colors[ImGuiCol_DragDropTarget] = ImVec4(0.91f, 0.62f, 0.00f, 1.00f);
            colors[ImGuiCol_NavHighlight] = ImVec4(0.26f, 0.59f, 0.98f, 1.00f);
            colors[ImGuiCol_NavWindowingHighlight] = ImVec4(1.00f, 1.00f, 1.00f, 0.70f);
            colors[ImGuiCol_NavWindowingDimBg] = ImVec4(0.80f, 0.80f, 0.80f, 0.20f);
            colors[ImGuiCol_ModalWindowDimBg] = ImVec4(0.80f, 0.80f, 0.80f, 0.35f);
            break;
        }
    }
}

void ImGuiManager::UseFont(Font &font) {
    ImGui::GetIO().FontDefault = font.getFont();
}

void ImGuiManager::EnableDocking(bool value) {
    if (value) { ImGui::GetIO().ConfigFlags |= ImGuiConfigFlags_DockingEnable; }
    else { ImGui::GetIO().ConfigFlags &= ~ImGuiConfigFlags_DockingEnable; }
}

bool ImGuiManager::IsDockingEnabled() const {
    return ImGui::GetIO().ConfigFlags & ImGuiConfigFlags_DockingEnable;
}

void ImGuiManager::ResetLayout(std::string_view fileName) const {
    Resource layoutConfig(fileName);
    ImGui::LoadIniSettingsFromMemory(layoutConfig.read(), layoutConfig.getFileSize());
}

std::string ImGuiManager::OpenFileDialog() {
    nfdchar_t *outPath = NULL;
    nfdresult_t result = NFD_OpenDialog(NULL, NULL, &outPath);
    if (result == NFD_OKAY) {
        std::string s(outPath);
        free(outPath);
        return s;
    }
    return "";
}

std::string ImGuiManager::SaveFileDialog() {
    nfdchar_t *outPath = NULL;
    nfdresult_t result = NFD_SaveDialog(NULL, NULL, &outPath);
    if (result == NFD_OKAY) {
        std::string s(outPath);
        free(outPath);
        return s;
    }
    return "";
}

void ImGuiManager::MessageBox(int type, const std::string &title, const std::string &message) {
    auto flags = static_cast<uint32_t>(type);
    SDL_ShowSimpleMessageBox(flags, title.c_str(), message.c_str(), Window::getSingletonPtr()->getSDLWindow());
}

const std::string &ImGuiManager::getName() const {
    static std::string s("ImGuiManager");
    return s;
}

void ImGuiManager::install() {}

void ImGuiManager::uninstall() {}
