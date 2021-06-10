// ImGuiManager.cpp
// created on 2021/5/28
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "ImGuiManager.h"

#include "Engine.h"

static void ImImpl_RenderDrawLists(ImDrawList **const draw_lists, int count) {
    ImGuiManager::getSingletonPtr()->renderDrawLists(draw_lists, count);
}

static const char *ImImpl_GetClipboardTextFn() {
    return ImGuiManager::getSingletonPtr()->getClipboardText();
}

static void ImImpl_SetClipboardTextFn(const char *text, const char *text_end) {
    ImGuiManager::getSingletonPtr()->setClipboardText(text, text_end);
}

// TODO
//    glfwSetKeyCallback(window, glfw_key_callback);
//    glfwSetScrollCallback(window, glfw_scroll_callback);
//    glfwSetCharCallback(window, glfw_char_callback);
//static void glfw_scroll_callback(GLFWwindow* window, double xoffset, double yoffset)
//{
//    mouse_wheel = (float)yoffset;
//}
//
//static void glfw_key_callback(GLFWwindow* window, int key, int scancode, int action, int mods)
//{
//    ImGuiIO& io = ImGui::GetIO();
//    if (action == GLFW_PRESS)
//        io.KeysDown[key] = true;
//    if (action == GLFW_RELEASE)
//        io.KeysDown[key] = false;
//    io.KeyCtrl = (mods & GLFW_MOD_CONTROL) != 0;
//    io.KeyShift = (mods & GLFW_MOD_SHIFT) != 0;
//}

//static void glfw_char_callback(GLFWwindow* window, unsigned int c)
//{
//    if (c > 0 && c <= 255)
//        ImGui::GetIO().AddInputCharacter((char)c);
//}


ImGuiManager::ImGuiManager() = default;

ImGuiManager::~ImGuiManager() = default;

void ImGuiManager::initialize() {
    initGL();
    initImGui();
}

void ImGuiManager::finalize() {
    ImGui::Shutdown();
}

void ImGuiManager::update() {
    auto *window = Engine::getSingletonPtr()->getWindow();

    ImGuiIO &io = ImGui::GetIO();

    // 1) ImGui start frame, setup time delta & inputs
    auto delta = Engine::getSingletonPtr()->getDeltaTime();
    auto deltaTime = std::chrono::duration_cast<std::chrono::duration<float>>(delta).count();

    io.DeltaTime = deltaTime ? deltaTime : io.DeltaTime;

    glm::vec2 mousePos = window->getInput()->getMousePosition();
    io.MousePos = ImVec2(mousePos.x, mousePos.y);

    io.MouseDown[0] = window->getInput()->mouseIsPressed(SDL_BUTTON_LEFT);
    io.MouseDown[1] = window->getInput()->mouseIsPressed(SDL_BUTTON_RIGHT);
//    io.MouseDown[2] = window->getInput()->mouseIsPressed(SDL_BUTTON_MIDDLE);

    io.MouseWheel = window->getInput()->getMouseWheel().y / 15.0f;

    io.KeyShift = (window->getInput()->getKeyModState() & KMOD_SHIFT) != 0;
    io.KeyCtrl = (window->getInput()->getKeyModState() & KMOD_CTRL) != 0;
//    io.KeyAlt = (window->getInput()->getKeyModState() & KMOD_ALT) != 0;
//    io.KeySuper = (window->getInput()->getKeyModState() & KMOD_GUI) != 0;

    ImGui::NewFrame();

    // 2) ImGui usage
    static bool show_test_window = true;
    static bool show_another_window = false;
    static float f;
    ImGui::Text("Hello, world!");
    ImGui::SliderFloat("float", &f, 0.0f, 1.0f);
    show_test_window ^= ImGui::Button("Test Window");
    show_another_window ^= ImGui::Button("Another Window");

    // Calculate and show framerate
    static float ms_per_frame[120] = {0};
    static int ms_per_frame_idx = 0;
    static float ms_per_frame_accum = 0.0f;
    ms_per_frame_accum -= ms_per_frame[ms_per_frame_idx];
    ms_per_frame[ms_per_frame_idx] = io.DeltaTime * 1000.0f;
    ms_per_frame_accum += ms_per_frame[ms_per_frame_idx];
    ms_per_frame_idx = (ms_per_frame_idx + 1) % 120;
    const float ms_per_frame_avg = ms_per_frame_accum / 120;
    ImGui::Text("Application average %.3f ms/frame (%.1f FPS)", ms_per_frame_avg, 1000.0f / ms_per_frame_avg);

    if (show_test_window) {
        // More example code in ShowTestWindow()
        ImGui::SetNewWindowDefaultPos(ImVec2(650,
                                             20));        // Normally user code doesn't need/want to call it because positions are saved in .ini file anyway. Here we just want to make the demo initial state a bit more friendly!
        ImGui::ShowTestWindow(&show_test_window);
    }

    if (show_another_window) {
        ImGui::Begin("Another Window", &show_another_window, ImVec2(200, 100));
        ImGui::Text("Hello");
        ImGui::End();
    }

}

void ImGuiManager::render() {
    m_renderCommand->setClearColor({0.8f, 0.6f, 0.6f, 1.0f});
    m_renderCommand->clear();
    ImGui::Render();
}

template<> ImGuiManager *Singleton<ImGuiManager>::msSingleton = nullptr;

ImGuiManager *ImGuiManager::getSingletonPtr() {
    return msSingleton;
}

void ImGuiManager::initGL() {
    m_renderCommand = GLManager::getSingletonPtr();

    m_imguiShader = std::make_unique<GLSLShaderProgram>("Shader/imgui.lua");
    m_imguiShader->link();

    m_imguiShader->bindFragDataLocation("o_col", 0);

    // Load font texture
    const void *png_data{};
    unsigned int png_size{};
    ImGui::GetDefaultFontData(NULL, NULL, &png_data, &png_size);

    m_imguiTex = std::make_unique<GLTexture>(
            reinterpret_cast<const char *>(png_data),
            png_size,
            true,
            "proggy_clean_13_png");

    m_imguiVAO = CreateRef<Zelo::GLVertexArray>();

    m_imguiVBO = CreateRef<Zelo::GLVertexBuffer>();

    Ref<Zelo::GLVertexBuffer> imguiVBO = m_imguiVBO;

    imguiVBO->setLayout({
                                BufferElement(ShaderDataType::Float2, "i_pos"),
                                BufferElement(ShaderDataType::Float2, "i_uv"),
                                BufferElement(ShaderDataType::UByte, "i_col", true),
                        });

    m_imguiVAO->addVertexBuffer(imguiVBO);
}

void ImGuiManager::initImGui() {
    (void) this;
    auto *window = Engine::getSingletonPtr()->getWindow();

    ImGuiIO &io = ImGui::GetIO();
    auto displaySize = window->getDisplaySize();
    io.DisplaySize = ImVec2(displaySize.x, displaySize.y);
    io.DeltaTime = 1.0f / 60.0f;
    io.KeyMap[ImGuiKey_Tab] = SDLK_TAB; // Keyboard mapping. ImGui will use those indices to peek into the io.KeyDown[] array.
    io.KeyMap[ImGuiKey_LeftArrow] = SDL_SCANCODE_LEFT;
    io.KeyMap[ImGuiKey_RightArrow] = SDL_SCANCODE_RIGHT;
    io.KeyMap[ImGuiKey_UpArrow] = SDL_SCANCODE_UP;
    io.KeyMap[ImGuiKey_DownArrow] = SDL_SCANCODE_DOWN;
//    io.KeyMap[ImGuiKey_PageUp] = SDL_SCANCODE_PAGEUP;
//    io.KeyMap[ImGuiKey_PageDown] = SDL_SCANCODE_PAGEDOWN;
    io.KeyMap[ImGuiKey_Home] = SDL_SCANCODE_HOME;
    io.KeyMap[ImGuiKey_End] = SDL_SCANCODE_END;
    io.KeyMap[ImGuiKey_Delete] = SDLK_DELETE;
    io.KeyMap[ImGuiKey_Backspace] = SDLK_BACKSPACE;
    io.KeyMap[ImGuiKey_Enter] = SDLK_RETURN;
    io.KeyMap[ImGuiKey_Escape] = SDLK_ESCAPE;
    io.KeyMap[ImGuiKey_A] = SDLK_a;
    io.KeyMap[ImGuiKey_C] = SDLK_c;
    io.KeyMap[ImGuiKey_V] = SDLK_v;
    io.KeyMap[ImGuiKey_X] = SDLK_x;
    io.KeyMap[ImGuiKey_Y] = SDLK_y;
    io.KeyMap[ImGuiKey_Z] = SDLK_z;

    io.RenderDrawListsFn = ImImpl_RenderDrawLists;
    io.SetClipboardTextFn = ImImpl_SetClipboardTextFn;
    io.GetClipboardTextFn = ImImpl_GetClipboardTextFn;
}

void ImGuiManager::renderDrawLists(ImDrawList **const draw_lists, int count) {
    size_t total_vtx_count = 0;
    for (int n = 0; n < count; n++)
        total_vtx_count += draw_lists[n]->vtx_buffer.size();
    if (total_vtx_count == 0)
        return;

    int read_pos_clip_rect_buf = 0;        // offset in 'clip_rect_buffer'. each PushClipRect command consume 1 of those.

    ImVector<ImVec4> clip_rect_stack;
    clip_rect_stack.push_back(ImVec4(-9999, -9999, +9999, +9999));

    // Setup orthographic projection
    const float L = 0.0f;
    const float R = ImGui::GetIO().DisplaySize.x;
    const float B = ImGui::GetIO().DisplaySize.y;
    const float T = 0.0f;
    const glm::mat4 mvp =
            {
                    {2.0f / (R - L),     0.0f,               0.0f,  0.0f},
                    {0.0f,               2.0f / (T - B),     0.0f,  0.0f},
                    {0.0f,               0.0f,               -1.0f, 0.0f},
                    {-(R + L) / (R - L), -(T + B) / (T - B), 0.0f,  1.0f},
            };

    int vtx_consumed = 0;
    {
        auto mapBufferJanitor = Zelo::GLMapBufferJanitor(m_imguiVBO, total_vtx_count * sizeof(ImDrawVert));
        auto *buffer_data = mapBufferJanitor.getBufferData();
        for (int n = 0; n < count; n++) {
            const ImDrawList *cmd_list = draw_lists[n];
            if (!cmd_list->vtx_buffer.empty()) {
                memcpy(buffer_data, &cmd_list->vtx_buffer[0], cmd_list->vtx_buffer.size() * sizeof(ImDrawVert));
                buffer_data += cmd_list->vtx_buffer.size() * sizeof(ImDrawVert);
                vtx_consumed += cmd_list->vtx_buffer.size();
            }
        }
    }

    m_imguiShader->setUniformMatrix4f("MVP", mvp);

    // Setup render state: alpha-blending enabled, no face culling, no depth testing
    m_renderCommand->setBlendEnabled(true);
    m_renderCommand->setBlendFunc();
    m_renderCommand->setCullFaceEnabled(false);
    m_renderCommand->setDepthTestEnabled(false);

    m_imguiTex->bind(0);

    vtx_consumed = 0;                        // offset in vertex buffer. each command consume ImDrawCmd::vtx_count of those
    bool clip_rect_dirty = true;

    for (int n = 0; n < count; n++) {
        const ImDrawList *cmd_list = draw_lists[n];
        if (cmd_list->commands.empty() || cmd_list->vtx_buffer.empty())
            continue;
        const ImDrawCmd *pcmd = &cmd_list->commands.front();
        const ImDrawCmd *pcmd_end = &cmd_list->commands.back();
        int clip_rect_buf_consumed = 0;        // offset in cmd_list->clip_rect_buffer. each PushClipRect command consume 1 of those.
        while (pcmd <= pcmd_end) {
            const ImDrawCmd &cmd = *pcmd++;
            switch (cmd.cmd_type) {
                case ImDrawCmdType_DrawTriangleList:
                    if (clip_rect_dirty) {
                        m_imguiShader->setUniformVec4f("ClipRect", clip_rect_stack.back());
                        clip_rect_dirty = false;
                    }
                    m_renderCommand->drawArray(m_imguiVAO, vtx_consumed, cmd.vtx_count);
                    vtx_consumed += cmd.vtx_count;
                    break;

                case ImDrawCmdType_PushClipRect:
                    clip_rect_stack.push_back(cmd_list->clip_rect_buffer[clip_rect_buf_consumed++]);
                    clip_rect_dirty = true;
                    break;

                case ImDrawCmdType_PopClipRect:
                    clip_rect_stack.pop_back();
                    clip_rect_dirty = true;
                    break;
                default:
                    ZELO_ASSERT(false, "unhandled ImDrawCmd");
            }
        }
    }
}

const char *ImGuiManager::getClipboardText() {
    (void) this;
    return "test clip text";
}

void ImGuiManager::setClipboardText(const char *text, const char *text_end) {
    (void) this;
    if (!text_end)
        text_end = text + strlen(text);

    char *buf = (char *) malloc(text_end - text + 1);
    memcpy(buf, text, text_end - text);
    buf[text_end - text] = '\0';
//  TODO set text to window clipboard buffer
    free(buf);
}
