// Input.h
// created on 2021/3/28
// author @zoloypzuo

#ifndef ZELOENGINE_INPUT_H
#define ZELOENGINE_INPUT_H

#include "ZeloPrerequisites.h"
#include "Foundation/ZeloSingleton.h"
#include "Foundation/ZeloSDL.h"

enum InputEvent {
    IE_PRESSED,
    IE_RELEASED,
    IE_REPEAT,
};

struct AxisValuePair {
    std::string axis;
    float value;
};

namespace Zelo {
class Window;

// TODO namespace, move to Window target
class Input : public Singleton<Input> {
public:
    explicit Input(Window &window);

    ~Input();

    bool isPressed(SDL_Keycode key);

    bool isReleased(SDL_Keycode key);

    bool mouseIsPressed(Uint8 button);

    bool mouseIsReleased(Uint8 button);

    glm::vec2 getMouseDelta() const;

    glm::vec2 getMousePosition() const;

    glm::vec2 getMouseWheel() const;

    SDL_Keymod getKeyModState() const;

    void grabMouse();

    void releaseMouse();

    void bindAction(const std::string &action, InputEvent state, std::function<void()> handler);

    void bindAxis(const std::string &axis, std::function<void(float)> handler);

    void bindTextEdit(std::function<void(const char *)> handler);

    bool unbindAction(const std::string &action);

    bool unbindAxis(const std::string &action);

    void registerKeyToAction(SDL_Keycode key, const std::string &action);

    void registerKeysToAxis(SDL_Keycode keyA, SDL_Keycode keyB, float min, float max, const std::string &axis);

    void registerButtonToAction(Uint8 button, const std::string &action);

public:
    static Input *getSingletonPtr();

    static Input &getSingleton();

private:
    void handleWindowEvent(SDL_Event *pEvent);

    void handlePreWindowEvent(void *);

    void setMouseDelta(int x, int y);

    void setMousePosition(int x, int y);

    void handleKeyboardEvent(SDL_KeyboardEvent keyEvent);

    void handleMouseEvent(SDL_MouseButtonEvent buttonEvent);

    void handleMouseWheelEvent(Sint32 x, Sint32 y);

    void handleMultiGesture(SDL_MultiGestureEvent multiGestureEvent);

    void handleTextEdit(const char *text);

private:
    std::map<SDL_Keycode, Uint8> m_keyState{};
    std::map<Uint8, Uint8> m_buttonState{};
    SDL_Keymod m_keyModState{};

    glm::ivec2 m_mouseDelta = glm::vec2(0, 0);
    glm::ivec2 m_mousePosition = glm::vec2(0, 0);
    glm::ivec2 m_mouseWheel{};

    std::map<Uint8, std::string> m_buttonToAction{};
    std::map<SDL_Keycode, std::string> m_keyToAction{};
    std::map<SDL_Keycode, AxisValuePair> m_keyToAxis{};
    std::map<std::string, std::map<InputEvent, std::function<void()>>> m_actionInputEventHandler{};
    std::map<std::string, std::function<void(float)>> m_axisHandler{};
    std::vector<std::function<void(const char *)>> m_textEditHandler{};

};
}

#endif //ZELOENGINE_INPUT_H