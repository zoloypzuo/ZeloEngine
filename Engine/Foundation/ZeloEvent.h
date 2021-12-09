#pragma once

#include <functional>  // std::function

namespace Zelo::Core::EventSystem {

using ListenerID = uint64_t;

template<class... ArgTypes>
class Event {
public:

    using Callback = std::function<void(ArgTypes...)>;

    ListenerID AddListener(Callback callback);

    ListenerID operator+=(Callback callback);

    bool RemoveListener(ListenerID listenerID);

    bool operator-=(ListenerID listenerID);

    void RemoveAllListeners();

    uint64_t GetListenerCount();

    void Invoke(ArgTypes... args);

private:
    std::unordered_map<ListenerID, Callback> m_callbacks;
    ListenerID m_availableListenerID = 0;
};
}

#include "ZeloEvent.inl"
