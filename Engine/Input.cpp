// Input.cpp
// created on 2021/3/28
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "Input.h"

Input::Input() {
    m_mouseDelta = glm::vec2(0, 0);
    m_mousePosition = glm::vec2(0, 0);
}

Input::~Input() {
}

void Input::handleKeyboardEvent(SDL_KeyboardEvent keyEvent) {
    // Action handler
    auto keyToActionIt = m_keyToAction.find(keyEvent.keysym.sym);

    if (keyToActionIt != m_keyToAction.end()) {
        auto actionInputEventIt = m_actionInputEventHandler.find(keyToActionIt->second);

        if (actionInputEventIt != m_actionInputEventHandler.end()) {
            auto inputEventHandler = actionInputEventIt->second;

            auto inputEventHandlerIt = inputEventHandler.find(
                    keyEvent.state == SDL_PRESSED
                    ? (m_keyState[keyEvent.keysym.sym] == SDL_PRESSED
                       ? IE_REPEAT // TODO: I dont think this will ever happen..
                       : IE_PRESSED)
                    : IE_RELEASED);

            if (inputEventHandlerIt != inputEventHandler.end()) {
                inputEventHandlerIt->second();
            }
        }
    }

    // Axis handler
    auto keyToAxisIt = m_keyToAxis.find(keyEvent.keysym.sym);

    if (keyToAxisIt != m_keyToAxis.end()) {
        auto actionHandlerIt = m_axisHandler.find(keyToAxisIt->second.axis);

        if (actionHandlerIt != m_axisHandler.end()) {
            actionHandlerIt->second(keyEvent.state == SDL_PRESSED ? keyToAxisIt->second.value : 0);
        }
    }

    m_keyState[keyEvent.keysym.sym] = keyEvent.state;
    m_keyModState = SDL_GetModState();
}

void Input::handleMouseEvent(SDL_MouseButtonEvent buttonEvent) {
    auto buttonToActionIt = m_buttonToAction.find(buttonEvent.button);

    if (buttonToActionIt != m_buttonToAction.end()) {
        auto actionInputEventIt = m_actionInputEventHandler.find(buttonToActionIt->second);

        if (actionInputEventIt != m_actionInputEventHandler.end()) {
            auto inputEventHandler = actionInputEventIt->second;

            auto inputEventHandlerIt = inputEventHandler.find(
                    buttonEvent.state == SDL_PRESSED
                    ? (m_buttonState[buttonEvent.button] == SDL_PRESSED
                       ? IE_REPEAT
                       : IE_PRESSED)
                    : IE_RELEASED);

            if (inputEventHandlerIt != inputEventHandler.end()) {
                inputEventHandlerIt->second();
            }
        }
    }

    m_buttonState[buttonEvent.button] = buttonEvent.state;
}

void Input::handleMouseWheelEvent(Sint32 x, Sint32 y) {
    m_mouseWheel.x = x;
    m_mouseWheel.y = y;
}

void Input::handleMultigesture(SDL_MultiGestureEvent multigestureEvent) {
}

bool Input::isPressed(SDL_Keycode key) {
    return (m_keyState[key] == SDL_PRESSED);
}

bool Input::isReleased(SDL_Keycode key) {
    return (m_keyState[key] == SDL_RELEASED);
}

bool Input::mouseIsPressed(Uint8 button) {
    return (m_buttonState[button] == SDL_PRESSED);
}

bool Input::mouseIsReleased(Uint8 button) {
    return (m_buttonState[button] == SDL_RELEASED);
}

void Input::setMouseDelta(int x, int y) {
    m_mouseDelta.x = x;
    m_mouseDelta.y = y;
}

void Input::setMousePosition(int x, int y) {
    m_mousePosition.x = x;
    m_mousePosition.y = y;
}

glm::vec2 Input::getMouseDelta() const {
    return m_mouseDelta;
}

glm::vec2 Input::getMousePosition() const {
    return m_mousePosition;
}

glm::vec2 Input::getMouseWheel() const {
    return m_mouseWheel;
}

SDL_Keymod Input::getKeyModState() const {
    return m_keyModState;
}

void Input::grabMouse() {
    SDL_SetRelativeMouseMode(SDL_TRUE);
}

void Input::releaseMouse() {
    SDL_SetRelativeMouseMode(SDL_FALSE);
}

void Input::bindAction(const std::string &action, InputEvent state, std::function<void()> handler) {
    m_actionInputEventHandler[action][state] = handler;
}

void Input::bindAxis(const std::string &axis, std::function<void(float)> handler) {
    m_axisHandler[axis] = handler;
}

bool Input::unbindAction(const std::string &action) {
    auto it = m_actionInputEventHandler.find(action);
    if (it != m_actionInputEventHandler.end()) {
        m_actionInputEventHandler.erase(it);
        return true;
    }

    return false;
}

bool Input::unbindAxis(const std::string &action) {
    auto it = m_axisHandler.find(action);
    if (it != m_axisHandler.end()) {
        m_axisHandler.erase(it);
        return true;
    }

    return false;
}

void Input::registerKeyToAction(SDL_Keycode key, const std::string &action) {
    m_keyToAction[key] = action;
}

void Input::registerKeysToAxis(SDL_Keycode keyA, SDL_Keycode keyB, float min, float max, const std::string &axis) {
    m_keyToAxis[keyA].axis = axis;
    m_keyToAxis[keyA].value = min;

    m_keyToAxis[keyB].axis = axis;
    m_keyToAxis[keyB].value = max;
}

void Input::registerButtonToAction(Uint8 button, const std::string &action) {
    m_buttonToAction[button] = action;
}

template<> Input* Singleton<Input>::msSingleton = nullptr;
Input *Input::getSingletonPtr() {
    return msSingleton;
}

Input &Input::getSingleton() {
    assert(msSingleton);
    return *msSingleton;
}
